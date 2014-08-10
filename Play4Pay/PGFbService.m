//
//  PGFbService.m
//  Play4Pay
//
//  Created by Benedikt Lotter on 8/9/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import "PGFbService.h"
#import "PGDataService.h"

@interface PGFbService()

typedef enum{
    GET,
    POST
}PGRequestType;

@end

@implementation PGFbService

PGDataService *dataService;

+ (id)sharedFbService {
    static PGFbService *sharedDS = nil;
    @synchronized(self) {
        if (sharedDS == nil)
            sharedDS = [[self alloc] init];
    }
    return sharedDS;
}

-(void) postNewHighScore:(float)score{
    
    NSString *scoreString = [NSString stringWithFormat:@"%f",score];
    
    NSMutableDictionary* postParams = [self fbParamsForRequestType:POST withOptionalScore:scoreString];
    //check that params are filled
    
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

-(float) getCurrentHighScore{
    float highScore = 0.0f;
    NSMutableDictionary* getParams = [self fbParamsForRequestType:GET withOptionalScore:nil];
    [FBRequestConnection startWithGraphPath:[self urlStringForCurrentUser]
                                 parameters:getParams
                                 HTTPMethod:@"GET"
                          completionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         if (result && !error) {
             float score = [[[[result objectForKey:@"data"] objectAtIndex:0] objectForKey:@"score"] floatValue];
             NSLog(@"Current score is %f", score);
         }
         else{
             NSLog(@"%@",error.description);
         }
     }];
    return highScore;
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
