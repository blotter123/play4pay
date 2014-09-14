//
//  SKSpriteNode+Animation.m
//  Play4Pay
//
//  Created by Julian Offermann on 9/14/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import "SKSpriteNode+Animation.h"

@implementation SKSpriteNode (Animation)

- (void)shake:(NSInteger)times
{
    CGPoint initialPoint = self.position;
    NSInteger amplitudeX = 32;
    NSInteger amplitudeY = 2;
    NSMutableArray * randomActions = [NSMutableArray array];
    
    for (int i=0; i < times; i++) {
        
        NSInteger randX = self.position.x + arc4random() % amplitudeX - amplitudeX / 2;
        NSInteger randY = self.position.y + arc4random() % amplitudeY - amplitudeY / 2;
        SKAction *action = [SKAction moveTo:CGPointMake(randX, randY) duration:0.1];
        [randomActions addObject:action];
    }
    
    SKAction *rep = [SKAction sequence:randomActions];
    
    [self runAction:rep completion:^{
        self.position = initialPoint;
    }];
}

@end
