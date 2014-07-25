//
//  PGGameMode.m
//  Play4Pay
//
//  Created by Julian Offermann on 7/6/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import "PGGameMode.h"

@implementation PGGameMode

#pragma mark - Convenience Constructor

+ (id<PGGameSceneDelegate>) gameModeWithDelegate:(id<PGScoreDelegate>)delegate {
    PGGameMode *gameMode = [[PGGameMode alloc] init];
    gameMode.delegate = delegate;
    return gameMode;
}

+ (id<PGGameSceneDelegate>) gameMode {
    return [[PGGameMode alloc] init];
}

#pragma mark - Game Scene Delegate Implementation

- (BOOL) isValidNode:(PGSpriteNode *)node atIndex:(NSInteger)rowIndex {
    return YES;
}

- (CGFloat) movingSpeed {
    return 0.0f;
}

@end
