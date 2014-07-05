//
//  PGSpriteNode.m
//  Play4Pay
//
//  Created by Julian Offermann on 7/4/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import "PGSpriteNode.h"

@interface PGSpriteNode ()

@property (nonatomic) NSInteger gridPosition;

@end

@implementation PGSpriteNode

#pragma mark - Convenience Constructor

+ (PGSpriteNode*) nodeWithSize:(CGSize)size gridPosition:(int)position andColor:(UIColor*)color {
    
    CGFloat positionX = (position % TOTAL_COLUMNS) * size.width, positionY = (int)(position / TOTAL_COLUMNS) * size.height;
    
    PGSpriteNode *spriteNode = [[PGSpriteNode alloc] initWithColor:color size:size];
    spriteNode.position = CGPointMake(positionX + size.width / 2.0f, positionY + size.height / 2.0f);
    spriteNode.name = [NSString stringWithFormat:@"%@%d", SPRITE_NAME, position];
    spriteNode.gridPosition = position;
    
//    SKLabelNode *labelNode = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
//    labelNode.text = spriteNode.name;
//    labelNode.fontSize = 16;
//    labelNode.fontColor = color;
//    labelNode.blendMode = SKBlendModeSubtract;
//    labelNode.position = CGPointMake(CGRectGetMidX(spriteNode.frame),
//                                            CGRectGetMidY(spriteNode.frame));
//    
//    [spriteNode addChild:labelNode];
    
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

- (BOOL) isInRow:(NSInteger)row {
    
    //  zero based - be careful!
    
    NSInteger maxPos = (row * TOTAL_COLUMNS) - 1;
    NSInteger minPos = (maxPos + 1) - TOTAL_COLUMNS;
    
    return self.gridPosition >= minPos && self.gridPosition <= maxPos;
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
