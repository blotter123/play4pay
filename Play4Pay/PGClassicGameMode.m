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

- (CGFloat) movingSpeed {
    return MANUAL_MOVE_SPEED;
}

- (UIColor*) colorAtIndexPath:(NSIndexPath*)indexPath {
    
    if (self.currentRow != indexPath.row) {
        self.randomIndex = arc4random() % TOTAL_COLUMNS;
        self.currentRow = indexPath.row;
    }
    
    if (indexPath.row == 0)
        return INACTIVE_COLOR;
    else if (indexPath.row >= 50)
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

- (void) setupWithScene:(SKScene *)scene andContainer:(SKNode*)container {

    //  Fill screen by 4x4 sprites
    
    for (int i = 0; i < TOTAL_ROWS; i++) {
        [self addRowAtIndex:i withScene:scene andContainer:container];
    }
}

- (void) addRowAtIndex:(NSInteger)index withScene:(SKScene *)scene andContainer:(SKNode*)container {
    
    int randomIndex = arc4random() % TOTAL_COLUMNS;
    
    CGFloat width = scene.size.width / TOTAL_COLUMNS,
    height = scene.size.height / TOTAL_ROWS;
    
    for (int i = 0; i < TOTAL_COLUMNS; i++) {
        
        if (i % TOTAL_COLUMNS == 0 && i != 0)
            randomIndex = arc4random() % TOTAL_COLUMNS;
        
        NSInteger positionWithinContainer = (index * TOTAL_COLUMNS) + i;
        
        PGSpriteNode *sprite = [PGSpriteNode nodeWithSize:CGSizeMake(width, height) position:positionWithinContainer andColor:SECONDARY_COLOR];
        
        if (randomIndex == (i % TOTAL_COLUMNS))
            sprite.color = PRIMARY_COLOR;
        
        if (index == 0)
            sprite.color = INACTIVE_COLOR;
        else if (index >= 50)
            sprite.color = COMPLETE_COLOR;
        
        [container addChild:sprite];
    }
}

@end
