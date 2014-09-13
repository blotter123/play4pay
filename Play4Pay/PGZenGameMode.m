//
//  PGZenGameMode.m
//  Play4Pay
//
//  Created by Julian Offermann on 8/30/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import "PGZenGameMode.h"

@interface PGZenGameMode ()

@property (nonatomic) NSInteger currentRow;
@property (nonatomic) NSInteger randomIndex;

@property (nonatomic) double firstTick;

@end

@implementation PGZenGameMode

#pragma mark - Convenience Constructor

+ (id<PGGameSceneDelegate>) gameModeWithDelegate:(id<PGScoreDelegate>)delegate {
    PGZenGameMode *gameMode = [[PGZenGameMode alloc] init];
    gameMode.delegate = delegate;
    return gameMode;
}

+ (id<PGGameSceneDelegate>) gameMode {
    return [[PGZenGameMode alloc] init];
}

- (id) init {
    self = [super init];
    if (self) {
        self.firstTick = -1;
    }
    return self;
}

#pragma mark - Game Scene Delegate Implementation

- (BOOL) isValidNode:(PGSpriteNode *)node atIndex:(NSInteger)rowIndex {
    
    BOOL isHot = [(PGSpriteNode*)node isHot];
    return isHot;
}

- (CGFloat) movementSpeed {
    return MANUAL_MOVEMENT_SPEED;
}

- (CGFloat) animationSpeed {
    return MANUAL_ANIMATION_SPEED;
}

- (UIColor*) colorAtIndexPath:(NSIndexPath*)indexPath {
    
    if (self.currentRow != indexPath.section) {
        self.randomIndex = arc4random() % TOTAL_COLUMNS;
        self.currentRow = indexPath.section;
    }
    
    if (indexPath.section == 0)
        return INACTIVE_COLOR;
    else {
        
        if (indexPath.item == self.randomIndex)
            return PRIMARY_COLOR;
        
        return SECONDARY_COLOR;
    }
}

- (PGGameStatus) statusForNode:(PGSpriteNode*)node inRow:(NSInteger)row {
    
    if (row == 0)
        return kGameStatusInvalid;
    else {
        
        if ([node isHot])
            return kGameStatusValid;
        
        //  Reset tick
        self.firstTick = -1;
        
        return kGameStatusFailed;
    }
}

- (PGGameStatus) didTick:(double)tick
{
    if (self.firstTick == -1)
        self.firstTick = tick;
    
    NSLog(@"delta %f", fabs(self.firstTick - tick));
    
    if (fabs(self.firstTick - tick) >= 10.0f) {
        self.firstTick = -1;
        return kGameStatusComplete;
    }
    
    return kGameStatusInvalid;
}

@end
