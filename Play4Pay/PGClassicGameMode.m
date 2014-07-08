//
//  PGClassicGameMode.m
//  Play4Pay
//
//  Created by Julian Offermann on 7/6/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import "PGClassicGameMode.h"

@interface PGClassicGameMode ()

@property (nonatomic) NSInteger currentRow;
@property (nonatomic) NSInteger randomIndex;

@end

@implementation PGClassicGameMode

#pragma mark - Convenience Constructor

+ (id<PGGameSceneDelegate>) gameMode {
    return [[PGClassicGameMode alloc] init];
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
    else if (indexPath.section >= 50)
        return COMPLETE_COLOR;
    else {
        
        if (indexPath.item == self.randomIndex)
            return PRIMARY_COLOR;
        
        return SECONDARY_COLOR;
    }
}

- (PGGameStatus) statusForNode:(PGSpriteNode*)node inRow:(NSInteger)row {
    
    if (row == 0)
        return kGameStatusInvalid;
    else if (row == 49 && [node isHot])
        return kGameStatusComplete;
    else {
        
        if ([node isHot])
            return kGameStatusValid;
        
        return kGameStatusFailed;
    }
}

@end
