//
//  UIColor+Comparison.h
//  Play4Pay
//
//  Created by Julian Offermann on 7/4/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Comparison)

- (BOOL) isEqualToColor:(UIColor *)color;
- (BOOL) isEqualToColor:(UIColor *)color withTolerance:(CGFloat)tolerance;

@end
