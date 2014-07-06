//
//  PGMyScene.h
//  Play4Pay
//

//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "PGSpriteNode.h"

typedef enum {
    kGameStatusValid,
    kGameStatusInvalid,
    kGameStatusComplete,
    kGameStatusFailed
} PGGameStatus;

@protocol PGGameSceneDelegate;

@interface PGMainScene : SKScene

@property (nonatomic, strong) id<PGGameSceneDelegate> gameMode;

@end

@protocol PGGameSceneDelegate <NSObject>

//- (BOOL) isValidNode:(PGSpriteNode *)node atIndex:(NSInteger)rowIndex;


- (CGFloat) movingSpeed;
- (UIColor*) colorAtIndexPath:(NSIndexPath*)indexPath;
- (PGGameStatus) statusForNode:(PGSpriteNode*)node inRow:(NSInteger)row;


//- (void) setupWithScene:(SKScene *)scene andContainer:(SKNode*)container;
//- (void) addRowAtIndex:(NSInteger)index withScene:(SKScene *)scene andContainer:(SKNode*)container;

@end