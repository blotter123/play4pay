//
//  PGDataService.m
//  Play4Pay
//
//  Created by Benedikt Lotter on 7/27/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import "PGDataService.h"

@implementation PGDataService

static PGDataService *sharedDS = nil;

+ (id)sharedDataService {
    if (sharedDS == nil)
        sharedDS = [[PGDataService alloc] init];
    return sharedDS;
}

-(void) writeProperty:(NSString*) propertyName withValue:(NSObject*) value{
    NSString *path = [[NSBundle mainBundle] pathForResource: @"sessions" ofType: @"plist"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile: path];
    NSString *currentUserId = [dict objectForKey:@"current_user"];
    if (currentUserId) {
        NSMutableDictionary *currentUserData = [dict objectForKey:currentUserId];
        [currentUserData setObject:value forKey:propertyName];
        [dict writeToFile:path atomically:YES];
    }
}

-(id) readProperty:(NSString*) propertyName{
    NSString *path = [[NSBundle mainBundle] pathForResource: @"sessions" ofType: @"plist"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile: path];
    NSString *currentUserId = [dict objectForKey:@"current_user"];
    if(currentUserId){
        NSDictionary *userData = [dict valueForKey:currentUserId];
        return [userData objectForKey:propertyName];
    }
    return nil;
}

-(void) setCurrentUser:(NSString*) fbUserId{
    NSString *path = [[NSBundle mainBundle] pathForResource: @"sessions" ofType: @"plist"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile: path];
    [dict setValue:fbUserId forKey:@"current_user"];
    [dict writeToFile:path atomically:YES];
}


-(NSString*) getCurrentUser{
    NSString *path = [[NSBundle mainBundle] pathForResource: @"sessions" ofType: @"plist"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile: path];
    return [dict valueForKey:@"current_user"];
}

-(void) initUserData:(NSString*) fbUserId withAccessToken:(NSString*) accessToken{
    NSString *path = [[NSBundle mainBundle] pathForResource: @"sessions" ofType: @"plist"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile: path];
    NSDictionary *userData = [dict valueForKey:fbUserId];
    if (userData == nil) {
        NSDictionary *userData = [NSDictionary dictionaryWithObjectsAndKeys:
                                  fbUserId, @"fb_user_id",
                                  accessToken, @"fb_access_token",
                                  0,@"zen_high_percent",
                                  0,@"classic_high_percent",
                                  0,@"arcade_high_percent",
                                  0,@"points_constant",
                                  0,@"high_score",
                                  nil];
        [dict setObject:userData forKey:fbUserId];
        [dict writeToFile:path atomically:YES];
    }
}


@end
