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


#pragma mark Facebook Scores API Methods

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
