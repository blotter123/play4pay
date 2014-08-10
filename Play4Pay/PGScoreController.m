//
//  PGScoreController.m
//  Play4Pay
//
//  Created by Benedikt Lotter on 7/6/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "PGScoreController.h"
#import "PGDataService.h"


@interface PGScoreController ()

typedef enum{
    GET,
    POST
}PGRequestType;

@end

@implementation PGScoreController


PGDataService *dataService;

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


- (IBAction) testSend:(id)sender {
    NSString *score = [NSString stringWithFormat:@"%f",5.0];
    [self sendScore:score];
    [self getCurrentScore];
}

- (IBAction)sendRequests:(id)sender {
    [FBWebDialogs
     presentRequestsDialogModallyWithSession:nil
     message:@"Invite your friends to Play 4 Pay"
     title:@"Friend Request"
     parameters:nil
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             // Error launching the dialog or sending the request.
             NSLog(@"Error sending request.");
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 // User clicked the "x" icon
                 NSLog(@"User canceled request.");
             } else {
                 // Handle the send request callback
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                
                 if (![urlParams valueForKey:@"request"]) {
                     // User clicked the Cancel button
                     NSLog(@"User canceled request.");
                 } else {
                     // User clicked the Send button
                     NSString *requestID = [urlParams valueForKey:@"request"];
                     NSLog(@"Request ID: %@", requestID);
                     
                     NSNumber *requestCount = [urlParams valueForKey:@"requestCount"];
                     NSLog(@"Request Count: %@",requestCount);
                     
                     NSArray *requestIds = [urlParams valueForKey:@"requestIds"];
                     NSLog(@"Request Count: %@",[requestIds firstObject]);
                     
                     
                 }
             }
         }
     }];
}



#pragma mark Facebook Scores API & Helper Methods

// request query is of form(without spaces_: "request=1499567556949993 & to5028959667=10152645333178659 & to5124443136=793054320726677"
-(NSDictionary*) parseURLParams:(NSString*) requestQuery{
    NSDictionary* urlParams = [[NSMutableDictionary alloc]init];
    NSArray* requestToSplit = [requestQuery componentsSeparatedByString:@"&"];
    NSString* requestObjectId = [[[requestToSplit firstObject]componentsSeparatedByString:@"="] objectAtIndex:1];
    [urlParams setValue:requestObjectId forKey:@"request"];
    
    NSRange toRange;
    toRange.location = 1;
    toRange.length = [requestToSplit count]- 1;
    NSArray* toArray = [requestToSplit subarrayWithRange:toRange];
    NSUInteger requestCount = [toArray count];
    [urlParams setValue:[NSNumber numberWithInteger:requestCount] forKey:@"requestCount"];
    
    NSMutableArray* userIds = [[NSMutableArray alloc]init];
    [toArray enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop){
        NSString* rawString = (NSString*) obj; // of the form to5028959667=10152645333178659
        NSString* userId = [[rawString componentsSeparatedByString:@"="] objectAtIndex:1];
        [userIds addObject:userId];
    }];
    [urlParams setValue:userIds forKey:@"requestIds"];
    return urlParams;
}

-(void) sendScore:(NSString *) score{

    NSMutableDictionary* postParams = [self fbParamsForRequestType:POST withOptionalScore:score];
    
    [FBRequestConnection startWithGraphPath:[self urlStringForCurrentUser]
                                 parameters:postParams
                                 HTTPMethod:@"POST"
                          completionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         if (result && !error) {
             //confirm that score was submitted
         }
         else{
             NSLog(@"%@",error.description);
         }
     }];
    
    
}

-(void) getCurrentScore{
    NSMutableDictionary* getParams = [self fbParamsForRequestType:GET withOptionalScore:nil];
    [FBRequestConnection startWithGraphPath:[self urlStringForCurrentUser]
                                 parameters:getParams
                                 HTTPMethod:@"GET"
                          completionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         if (result && !error) {
             double score = [[[[result objectForKey:@"data"] objectAtIndex:0] objectForKey:@"score"] doubleValue];
             NSLog(@"Current score is %f", score);
             
         }
         else{
             NSLog(@"%@",error.description);
         }
     }];
    //return score
}

-(NSMutableDictionary*) fbParamsForRequestType:(PGRequestType)type withOptionalScore:(NSString*) score{
    NSMutableDictionary* params;
    dataService =  [PGDataService sharedDataService];
    NSString *accessToken = (NSString*)[dataService readProperty:@"fb_access_token"];
    switch (type) {
        case GET:
            params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                     accessToken, @"access_token",
                     nil];
            break;
        
        case POST:
            params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                      score, @"score", accessToken, @"access_token",
                      nil];
            break;
    }
    return params;
}

-(NSString *) urlStringForCurrentUser{
    dataService =  [PGDataService sharedDataService];
    NSString *userId = (NSString*)[dataService readProperty:@"fb_user_id"];
    NSString *urlString = [userId stringByAppendingString:[NSString stringWithFormat:@"/scores"]];
    return urlString;
}


@end
