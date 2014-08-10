//
//  PGFbService.h
//  Play4Pay
//
//  Created by Benedikt Lotter on 8/9/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@interface PGFbService : NSObject

+ (id)sharedFbService;

- (void) postNewHighScore:(float) score;

- (float) getCurrentHighScore;

- (void) postAchievementForTime:(float) time;

@end
