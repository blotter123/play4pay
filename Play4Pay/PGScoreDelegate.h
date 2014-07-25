//
//  PGGameModeDelegate.h
//  Play4Pay
//
//  Created by Julian Offermann on 7/24/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kScoreTypeTime,
    kScoreTypeRow
} PGScoreType;

@protocol PGScoreDelegate <NSObject>

- (void) completedWithScore:(float)score ofType:(PGScoreType)type;

@end
