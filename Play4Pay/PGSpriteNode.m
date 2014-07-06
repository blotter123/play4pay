//
//  PGSpriteNode.m
//  Play4Pay
//
//  Created by Julian Offermann on 7/4/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import "PGSpriteNode.h"

@interface PGSpriteNode ()

@property (nonatomic) NSInteger positionWithinContainer;

@end

@implementation PGSpriteNode

#pragma mark - Convenience Constructor

+ (PGSpriteNode*) nodeWithSize:(CGSize)size position:(int)position andColor:(UIColor*)color {
    
    CGFloat positionX = (position % TOTAL_COLUMNS) * size.width, positionY = (int)(position / TOTAL_COLUMNS) * size.height;
    
    PGSpriteNode *spriteNode = [[PGSpriteNode alloc] initWithColor:color size:size];
    spriteNode.position = CGPointMake(positionX + size.width / 2.0f, positionY + size.height / 2.0f);
    spriteNode.name = [NSString stringWithFormat:@"%@%d", SPRITE_NAME, position];
    spriteNode.positionWithinContainer = position;

    return spriteNode;
}

#pragma mark - Constructor

- (id)initWithColor:(UIColor *)color size:(CGSize)size {
    
    self = [super initWithColor:color size:size];
    if (self) {
        
    }
    return self;
}

#pragma mark - API

- (NSInteger) rowIndex {
    return (self.positionWithinContainer / TOTAL_COLUMNS);
}

- (BOOL) isInRow:(NSInteger)row {
    
    //  zero based - be careful!
    
    NSInteger maxPos = (row * TOTAL_COLUMNS) - 1;
    NSInteger minPos = (maxPos + 1) - TOTAL_COLUMNS;
    
    return self.positionWithinContainer >= minPos && self.positionWithinContainer <= maxPos;
}

- (BOOL) isHot {
    return [self.color isEqualToColor:PRIMARY_COLOR];
}

- (void) highlight {
    
    SKAction *action = [SKAction colorizeWithColor:HIGHLIGHT_COLOR colorBlendFactor:1.0f duration:0.125f];
    [self runAction:action];
}

- (void) alert {
    
    SKAction *action = [SKAction colorizeWithColor:ALERT_COLOR colorBlendFactor:1.0f duration:0.125f];
    SKAction *reversedAction = [SKAction colorizeWithColor:SECONDARY_COLOR colorBlendFactor:1.0f duration:0.125f];
    
    [self runAction:[SKAction repeatAction:[SKAction sequence:@[action, reversedAction]] count:3]];
}

#pragma mark - Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

@end
