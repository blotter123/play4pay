//
//  PGArcadeGameMode.m
//  Play4Pay
//
//  Created by Julian Offermann on 8/30/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import "PGArcadeGameMode.h"

@interface PGArcadeGameMode ()

@property (nonatomic) NSInteger lastRow;

@end

@implementation PGArcadeGameMode

#pragma mark - Convenience Constructor

+ (id<PGGameSceneDelegate>) gameModeWithDelegate:(id<PGScoreDelegate>)delegate {
    PGArcadeGameMode *gameMode = [[PGArcadeGameMode alloc] init];
    gameMode.delegate = delegate;
    return gameMode;
}

+ (id<PGGameSceneDelegate>) gameMode {
    return [[PGArcadeGameMode alloc] init];
}

#pragma mark - Game Scene Delegate Implementation

- (BOOL) isValidNode:(PGSpriteNode *)node atIndex:(NSInteger)rowIndex {
    
    BOOL isHot = [(PGSpriteNode*)node isHot];
    return isHot;
}

- (CGFloat) movementSpeed {
    return AUTOMATIC_MOVEMENT_SPEED * fabs(1.0f - (self.currentRow / 100.0f));
}

- (CGFloat) animationSpeed {
    return AUTOMATIC_ANIMATION_SPEED;
}

- (PGGameStatus) statusForNode:(PGSpriteNode*)node inRow:(NSInteger)row {
    
    self.lastRow = row;
    
    if (row == 0)
        return kGameStatusInvalid;
    else {
        
        if ([node isHot])
            return kGameStatusValid;
        
        return kGameStatusFailed;
    }
}

- (PGGameStatus) statusForIndexPath:(NSIndexPath*)indexPath {

    if (indexPath.section > (self.lastRow + TOTAL_ROWS + 1))
        return kGameStatusFailed;
    else
        return kGameStatusInvalid;
}

@end
