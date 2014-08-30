//
//  PGGameMode.h
//  Play4Pay
//
//  Created by Julian Offermann on 7/6/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PGMainScene.h"
#import "PGScoreDelegate.h"

@interface PGGameMode : NSObject<PGGameSceneDelegate>

+ (id<PGGameSceneDelegate>) gameMode;
+ (id<PGGameSceneDelegate>) gameModeWithDelegate:(id<PGScoreDelegate>)delegate;

@property (nonatomic, strong) id<PGScoreDelegate> delegate;
@property (nonatomic) NSInteger currentRow;
@property (nonatomic) NSInteger randomIndex;

@end
