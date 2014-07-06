//
//  PGSpriteNode.h
//  Play4Pay
//
//  Created by Julian Offermann on 7/4/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#define SPRITE_NAME @"KEY_"

@interface PGSpriteNode : SKSpriteNode

+ (PGSpriteNode*) nodeWithSize:(CGSize)size position:(NSInteger)position andColor:(UIColor*)color;

- (NSInteger) rowIndex;

- (BOOL) isInRow:(NSInteger)row;
- (BOOL) isHot;

- (void) highlight;
- (void) alert;

@end
