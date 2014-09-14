//
//  PGGemNode.m
//  Play4Pay
//
//  Created by Julian Offermann on 9/13/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import "PGGemNode.h"

@interface PGGemNode ()

@property (nonatomic, strong) UIGestureRecognizer *touchRecognizer;

@end

@implementation PGGemNode

+ (PGGemNode*) gemWithType:(PGGemType)type {
    
    NSString *gemImage = nil;
    switch (type) {
        case kGemTypeBlue:
            gemImage = @"gem_blue";
            break;
        case kGemTypeGreen:
            gemImage = @"gem_green";
            break;
        case kGemTypeOrange:
            gemImage = @"gem_orange";
            break;
    }
    
    if (!gemImage) return nil;
    
    PGGemNode *node = [[PGGemNode alloc] initWithImageNamed:gemImage];
    [node setUserInteractionEnabled:YES];
    return node;
}

#pragma mark - Methods

- (void) animate {
    
    NSLog(@"ANIMATE");
    
    NSTimeInterval duration = 0.5f;
    CGFloat endScale = 3.0f;
    
    SKAction* scaleUpAction = [SKAction scaleTo:endScale duration:duration];
    SKAction* fadeOutAction = [SKAction fadeOutWithDuration:duration];
    
    SKAction* action = [SKAction group:@[scaleUpAction, fadeOutAction]];
    
    [self runAction:action];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self setUserInteractionEnabled:NO];
    [self animate];
}



@end
