//
//  PGScoreCalculator.h
//  Play4Pay
//
//  Created by Benedikt Lotter on 7/24/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PGScoreDelegate.h"

@interface PGScoreCalculator : NSObject<PGScoreDelegate>

@property float pointsConstant;
@property float highScore;

@end
