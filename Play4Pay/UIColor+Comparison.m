//
//  UIColor+Comparison.m
//  Play4Pay
//
//  Created by Julian Offermann on 7/4/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import "UIColor+Comparison.h"

@implementation UIColor (Comparison)

- (BOOL) isEqualToColor:(UIColor *)color {
    return [self isEqualToColor:color withTolerance:0.0f];
}
- (BOOL) isEqualToColor:(UIColor *)color withTolerance:(CGFloat)tolerance {
    
    CGFloat r1, g1, b1, a1, r2, g2, b2, a2;
    
    [self getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [color getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    
    return fabs(r1 - r2) <= tolerance && fabs(g1 - g2) <= tolerance && fabs(b1 - b2) <= tolerance && fabs(a1 - a2) <= tolerance;
}

@end
