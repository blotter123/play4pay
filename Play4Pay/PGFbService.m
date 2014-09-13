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

@property (nonatomic, strong) PGDataService *dataService;

typedef enum{
    GET,
    POST
}PGRequestType;

@end

@implementation PGFbService

static PGFbService *sharedDS = nil;

+ (id)sharedFbService {
    if (sharedDS == nil)
        sharedDS = [[PGFbService alloc] init];
    return sharedDS;
}

-(void) postNewHighScore:(float)score{
    
    NSString *scoreString = [NSString stringWithFormat:@"%f",score];
    
    NSDictionary* postParams = [self fbParamsForRequestType:POST withOptionalScore:scoreString];
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
    
    NSDictionary* getParams = [self fbParamsForRequestType:GET withOptionalScore:nil];
    
    [FBRequestConnection startWithGraphPath:[self urlStringForCurrentUser] parameters:getParams HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
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

-(NSDictionary*) fbParamsForRequestType:(PGRequestType)type withOptionalScore:(NSString*) score{
    NSDictionary* params;
    self.dataService =  [PGDataService sharedDataService];
    NSString *accessToken = [self.dataService readProperty:@"fb_access_token"];
    switch (type) {
        case GET:
            params = @{ @"access_token": accessToken };
            break;
            
        case POST:
            params = @{ @"score": score, @"access_token": accessToken };
            break;
    }
    return params;
}

-(NSString *) urlStringForCurrentUser{
    self.dataService =  [PGDataService sharedDataService];
    NSString *userId = [self.dataService readProperty:@"fb_user_id"];
    NSString *urlString = [userId stringByAppendingString:[NSString stringWithFormat:@"/scores"]];
    return urlString;
}

- (void) postAchievementForTime:(float) time{
    
}

@end
