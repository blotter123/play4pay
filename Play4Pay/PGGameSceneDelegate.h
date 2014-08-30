//
//  PGGameSceneDelegate.h
//  Play4Pay
//
//  Created by Julian Offermann on 7/6/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGSpriteNode.h"

typedef enum {
    kGameStatusValid,
    kGameStatusInvalid,
    kGameStatusComplete,
    kGameStatusFailed
} PGGameStatus;


@protocol PGGameSceneDelegate <NSObject>

- (CGFloat) movementSpeed;
- (CGFloat) animationSpeed;

- (UIColor*) colorAtIndexPath:(NSIndexPath*)indexPath;
- (PGGameStatus) statusForNode:(PGSpriteNode*)node inRow:(NSInteger)row;

@optional

- (PGGameStatus) didTick:(double)tick;
- (PGGameStatus) statusForIndexPath:(NSIndexPath*)indexPath;

@end
