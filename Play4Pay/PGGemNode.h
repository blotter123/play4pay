//
//  PGGemNode.h
//  Play4Pay
//
//  Created by Julian Offermann on 9/13/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum {
    
    kGemTypeBlue,
    kGemTypeGreen,
    kGemTypeOrange,
    
} PGGemType;

@interface PGGemNode : SKSpriteNode

+ (PGGemNode*) gemWithType:(PGGemType)type;

@end
