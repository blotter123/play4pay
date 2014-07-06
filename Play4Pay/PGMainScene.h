//
//  PGMyScene.h
//  Play4Pay
//

//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "PGSpriteNode.h"
#import "PGGameMode.h"

@interface PGMainScene : SKScene

@property (nonatomic, strong) id<PGGameSceneDelegate> gameMode;

@end