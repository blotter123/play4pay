//
//  PGScoreController.m
//  Play4Pay
//
//  Created by Benedikt Lotter on 7/6/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "PGScoreController.h"


@interface PGScoreController ()


@end

@implementation PGScoreController

NSString *accessToken;
NSString *userId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)initFbCredentials:(id)sender{
    [self setAccessToken];
    [self setUserID];
}

- (IBAction) testSend:(id)sender {
    NSNumber *score = [NSNumber numberWithInt:5];
    [self sendScore:score];
}


#pragma mark Facebook Scores API Methods

-(void) sendScore:(NSNumber *) score{
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"100", @"score", accessToken, @"access_token",
                                   nil];
    
    NSString *urlString = [userId stringByAppendingString:[NSString stringWithFormat:@"/scores"]];
    
    NSLog(@"urlString: %@",urlString);
    
    
    [FBRequestConnection startWithGraphPath:urlString
                                 parameters:params
                                 HTTPMethod:@"POST"
                          completionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         if (result && !error) {
             NSLog(@"data: %@",[result objectForKey:@"data"]);
             int nCurrentScore = [[[[result objectForKey:@"data"] objectAtIndex:0] objectForKey:@"score"] intValue];
             NSLog(@"Current score is %d", nCurrentScore);
         }
         else{
             NSLog(error.description);
         }
     }];
}


-(void) setAccessToken{
    
    NSLog(@"setAccessToken called");
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        
        [FBSession openActiveSessionWithReadPermissions:@[@"publish_actions"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          accessToken = [[session accessTokenData] accessToken];
                                      }];
    }
    else{
        NSLog(@"Please log in to Facebook in order to post scores");
    }
}

-(void) setUserID{
    [FBRequestConnection startForMeWithCompletionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error)
     {
         NSLog(@"facebook result: %@", result);
         NSLog(@"id: %@",[result objectForKey:@"id"]);
         userId = (NSString*)[result objectForKey:@"id"] ;
     }];

}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
