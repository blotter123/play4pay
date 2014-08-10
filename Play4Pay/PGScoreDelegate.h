//
//  PGGameModeDelegate.h
//  Play4Pay
//
//  Created by Julian Offermann on 7/24/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum{
    classic,
    arcade,
    zen
}PGGameModeType;


@protocol PGScoreDelegate <NSObject>

- (void) completedMode:(PGGameModeType) type withScore:(float) score andPlayingTime:(float) time;

@end
