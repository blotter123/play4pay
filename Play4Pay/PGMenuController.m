//
//  PGMenuController.m
//  Play4Pay
//
//  Created by Benedikt Lotter on 7/6/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "FlurryAdDelegate.h"
#import "FlurryAds.h"
#import "Flurry.h"

#import "PGMenuController.h"
#import "PGViewController.h"
#import "PGAppDelegate.h"
#import "PGGameMode.h"
#import "PGClassicGameMode.h"
#import "PGArcadeGameMode.h"
#import "PGZenGameMode.h"
#import "PGDataService.h"

#import "PGTileGenerator.h"

@interface PGMenuController ()

@property (nonatomic, strong) PGDataService *dataService;

@property bool initFb;

@end

@implementation PGMenuController





- (IBAction)fbLoginTouched:(id)sender {
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        // If the session state is not any of the two "open" states when the button is clicked
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile",@"publish_actions"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             NSLog(@"completion handler");
             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
             [self sessionStateChanged:session state:state error:error];
         }];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if(self.initFb == NO){
        [self initFbSession];
        self.initFb = YES;
    }
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //[FlurryAds fetchAndDisplayAdForSpace:@"test_banner" view:self.view size:BANNER_BOTTOM];
}

-(void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [FlurryAds removeAdFromSpace:@"test_banner"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark FB Session Methods

- (void) initFbSession{
    
    NSLog(@"initFBSession called");
    // Whenever a person opens the app, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"publish_actions"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          [self sessionStateChanged:session state:state error:error];
                                          
                                          
                                      }];
    }
    else{
        [self.fbLoginButton setTitle:@"Log in with Facebook" forState:UIControlStateNormal];
    }
}

// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    PGDataService* dataService = [PGDataService sharedDataService];
    NSLog(@"sessionStatChanged");
    if (!error && state == FBSessionStateOpen){
        [self userLoggedIn];
        
        
        [FBRequestConnection startForMeWithCompletionHandler:
         ^(FBRequestConnection *connection, id result, NSError *error)
         {
             //write the user's userId and accessToken to plist through DataService
             NSString* accessToken = [[session accessTokenData] accessToken];
             
             NSString* userId = (NSString*)[result objectForKey:@"id"] ;
             
             //sets the currentUserId within the data service
             [dataService setCurrentUser:userId];
             //initialize userData dictionary if it does not already exist
             [dataService initUserData:userId withAccessToken:accessToken];
             
             NSString* gender = (NSString*)[result objectForKey:@"gender"];
             [Flurry setGender:[gender substringToIndex:1]];
         }];
        
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        [self userLoggedOut];
        [dataService writeProperty:@"current_user" withValue:@"anonymous"];
        
    }
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
                
                // For simplicity, here we just show a generic message for all other errors
                // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
}

- (void)userLoggedOut
{
    [self.fbLoginButton setTitle:@"Log in with Facebook" forState:UIControlStateNormal];
    [self showMessage:@"Scores will not be posted to Facebook when you are logged out!" withTitle:@"You're now logged out"];
}

- (void)userLoggedIn
{
    [self.fbLoginButton setTitle:@"Log out" forState:UIControlStateNormal];
    [self showMessage:@"You're now logged in" withTitle:@"Welcome!"];
}

// Show an alert message
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil] show];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue: %@", segue.identifier);
    PGViewController *gameController = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"ClassicMode"]) {
        gameController.gameMode = [PGClassicGameMode gameMode];
        [Flurry logEvent:@"started_classic_game_mode"];
        
    } else if ([segue.identifier isEqualToString:@"ArcadeMode"]) {
        gameController.gameMode = [PGArcadeGameMode gameMode];
        [Flurry logEvent:@"started_arcade_game_mode"];
        
    }else if ([segue.identifier isEqualToString:@"ZenMode"]) {
        gameController.gameMode = [PGZenGameMode gameMode];
        [Flurry logEvent:@"started_zen_game_mode"];
    }
}




@end
