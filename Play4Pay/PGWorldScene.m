//
//  PGWorldScene.m
//  Play4Pay
//
//  Created by Julian Offermann on 9/13/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import "PGWorldScene.h"
#import "PGGemNode.h"
#import "PGTileGenerator.h"

#include <stdlib.h>

#define BLOCK_WIDTH     50
#define BLOCK_HEIGHT    85

#define MARGIN_LEFT     10

typedef enum {
    
//    kNodeTypeGrass  = 0,
//    kNodeTypeWater  = 1,
//    kNodeTypeDirt   = 2,
//    
//    kNodeTypePlain  = 3,
//    kNodeTypeStone  = 4,
//    
//    kNodeTypeWood   = 5,
//    kNodeTypeBrick  = 6,
//    
//    kNodeTypeTreeItem   = 10,
//    kNodeTypeRockItem   = 11,

    kNodeTypeGrass  = 1,
    kNodeTypeWater  = 2,
    kNodeTypeDirt   = 3,
    
    kNodeTypePlain  = 6,
    kNodeTypeStone  = 4,
    
    kNodeTypeWood   = 7,
    kNodeTypeBrick  = 5,
    
    kNodeTypeTreeItem   = 10,
    kNodeTypeRockItem   = 11,
    
} PGNodeType;

@interface PGWorldScene ()

@property (nonatomic, strong) NSMutableArray *description;

@property (nonatomic, strong) SKNode *world;
@property (nonatomic, strong) SKNode *camera;
@property (nonatomic, strong) SKNode *character;

@end

@implementation PGWorldScene

#pragma mark - Constructor

#pragma mark - Initialization

- (void) didMoveToView:(SKView *)view {

    //self.anchorPoint = CGPointMake (0.5,0.5);
    
    [self setWorld:[SKNode node]];
    [self addChild:self.world];
    
    [self setCamera:[SKNode node]];
    [self.camera setName:@"camera"];
    [self.world addChild:self.camera];
    
    
    
    //[self createWorldWithContentsOfFile:@"world"];
    
    PGTileGenerator *tile = [[PGTileGenerator alloc] init];
    [tile initializeConfigurations];
    
    for (int i = 100; i >= 0; i--) {
        
        float       positionX = MARGIN_LEFT;
        float       positionY = (i + 1.0f) * (BLOCK_HEIGHT / 2.0f);
        
        NSArray *row = [tile nextPathStep];
        for (int a = 0; a < [row count]; a++) {
            
            SKSpriteNode *node = [self createNodeWithType:[(NSNumber*)[row objectAtIndex:a] integerValue]];
            
            if (positionX == MARGIN_LEFT)
                positionX += node.size.width / 2;
            
            node.position = CGPointMake(positionX, positionY);
            
            [self.world addChild:node];
            
            positionX += node.size.width;
        }
    }
    //[self generateWorld];
}

#pragma mark - Methods

- (void) createWorldWithContentsOfFile:(NSString*)fileName
{
    NSError *error = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
    NSString *rawFile = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    if (!rawFile || error) {
        NSLog(@"Error creating world:\n%@", error);
        return;
    }
    
    NSArray *rawDescription = [rawFile componentsSeparatedByString:@"\n"];
    
    self.description = [NSMutableArray array];
    for (NSString *rawLine in rawDescription) {
        [self.description addObject:[rawLine componentsSeparatedByString:@","]];
    }
    
    self.description = [NSMutableArray arrayWithArray:[self.description reversedArray]];
    
    for (int i = self.description.count - 1; i >= 0; i--) {
        [self createRow:i];
    }
}

- (BOOL) createRow:(NSInteger)index {
    
    NSArray *rowDescription = [self.description objectAtIndex:index];

    if (!rowDescription || rowDescription.count < 6) return NO;

    NSInteger   counter = 0;
    float       positionX = MARGIN_LEFT;
    float       positionY = (index + 1.0f) * (BLOCK_HEIGHT / 2.0f);
    
    for (NSString *key in rowDescription) {
        
        SKSpriteNode *node = [self createNodeWithType:[self typeFromKey:key]];
        
        if (positionX == MARGIN_LEFT)
            positionX += node.size.width / 2;
        
        node.position = CGPointMake(positionX, positionY);
        
        [self.world addChild:node];
        
        positionX += node.size.width;
        
        if (counter >= 6) break;
        counter++;
    }
    
    if (index % 3 == 0) {
        
        PGGemNode *gem = [PGGemNode gemWithType:kGemTypeOrange];
        gem.position = CGPointMake(positionX - BLOCK_WIDTH*2.5, positionY + BLOCK_HEIGHT / 2);
        gem.zPosition = 1;
        [self.world addChild:gem];
    }
    
    return YES;
}

- (void) createRowAtPosition:(NSInteger)position withType:(PGNodeType)nodeType {
    
    float positionX = MARGIN_LEFT;
    
    for (int i = 0; i < 6; i++) {
        
        SKSpriteNode *node = [self createNodeWithType:nodeType];
        
        if (i == 0)
            positionX += node.size.width / 2;
        
        node.position = CGPointMake(positionX, position);
        
        [self.world addChild:node];
        
        positionX += node.size.width;
    }
}

- (PGNodeType) typeFromKey:(NSString*)key {
    
    if ([key isEqualToString:@"d"])
        return kNodeTypeDirt;
    else if ([key isEqualToString:@"g"])
        return kNodeTypeGrass;
    else if ([key isEqualToString:@"b"])
        return kNodeTypeBrick;
    else if ([key isEqualToString:@"s"])
        return kNodeTypeStone;
    else if ([key isEqualToString:@"w"])
        return kNodeTypeWater;
    else if ([key isEqualToString:@"h"])
        return kNodeTypeWood;
    
    return kNodeTypePlain;
}

- (SKSpriteNode*) createNodeWithType:(PGNodeType)nodeType
{
    NSString *texture = @"plain";
    
    switch (nodeType) {
        case kNodeTypeDirt:
            texture = @"dirt";
            break;
        case kNodeTypeGrass:
            texture = @"grass";
            break;
        case kNodeTypeStone:
            texture = @"stone";
            break;
        case kNodeTypeBrick:
            texture = @"brick";
            break;
        case kNodeTypeWater:
            texture = @"water";
            break;
        case kNodeTypeWood:
            texture = @"wood";
            break;
        case kNodeTypeTreeItem:
            texture = @"tree";
            break;
        case kNodeTypeRockItem:
            texture = @"rock";
            break;
        default:
            break;
    }
    
    texture = [texture stringByAppendingString:@".png"];
    
    return [[SKSpriteNode alloc] initWithImageNamed:texture];
}

- (void) centerOnNode:(SKNode*)node
{
    CGPoint cameraPositionInScene = [node.scene convertPoint:node.position fromNode:node.parent];
    node.parent.position = CGPointMake(node.parent.position.x - cameraPositionInScene.x, node.parent.position.y - cameraPositionInScene.y);
}

#pragma mark - SKSceneDelegate

- (void) didSimulatePhysics
{
    [self centerOnNode:[self childNodeWithName:@"//camera"]];
}

- (void) update:(CFTimeInterval)currentTime {
    
    self.camera.position = CGPointMake(self.camera.position.x, self.camera.position.y + 2.0f);
}

- (void) generateWorld {
    
    NSInteger terrainThreshold = 2;
    NSInteger terrainCounter = 0;
    
    NSInteger turnThreshold = 5;
    NSInteger turnCounter = 0;
    
    NSInteger newStreetIdx = -1;
    NSInteger streetIdx = arc4random_uniform(5);

    PGNodeType terrainType = arc4random_uniform(2) ? kNodeTypeWater : kNodeTypeGrass;
    PGNodeType streetType = (terrainType == kNodeTypeGrass ? kNodeTypePlain : kNodeTypeStone);
    
    for (int i = 100; i >= 0; i--) {
    
        float       positionX = MARGIN_LEFT;
        float       positionY = (i + 1.0f) * (BLOCK_HEIGHT / 2.0f);
        
        if (turnCounter > (turnThreshold - 2) && newStreetIdx == -1) {
            
            NSInteger streetDifference = arc4random_uniform(2) ? arc4random_uniform(3) : -arc4random_uniform(3);
            newStreetIdx = MIN(4, abs(streetIdx + streetDifference));
        }
        
        if (turnCounter > turnThreshold) {
            turnCounter = 0;
            
            streetIdx = newStreetIdx;
            newStreetIdx = -1;
        }
        
        if (terrainCounter > terrainThreshold) {
            
            terrainType = arc4random_uniform(2) ? kNodeTypeWater : kNodeTypeGrass;
            terrainCounter = 0;
            
            streetType = (terrainType == kNodeTypeGrass ? kNodeTypePlain : kNodeTypeStone);
        }
        
        for (int a = 0; a < 6; a++) {
            
            NSInteger nodeType = terrainType;
            
            if (a == streetIdx || a == streetIdx + 1)
                nodeType = streetType;
            
            if (newStreetIdx != -1 && (a == newStreetIdx || a == newStreetIdx + 1))
                nodeType = streetType;
            
            SKSpriteNode *node = [self createNodeWithType:nodeType];
            
            if (positionX == MARGIN_LEFT)
                positionX += node.size.width / 2;
            
            node.position = CGPointMake(positionX, positionY);
            
            if (nodeType == kNodeTypeGrass || nodeType == kNodeTypeWater) {
                
                //  Create random trees
                if (arc4random_uniform(50) % 7 == 0) {
                    
                    SKSpriteNode *treeNode = [self createNodeWithType:nodeType == kNodeTypeWater ? kNodeTypeRockItem : kNodeTypeTreeItem];
                    treeNode.position = CGPointMake(positionX, positionY + (BLOCK_HEIGHT / 4));
                    treeNode.zPosition = 10;
                    
                    [self.world addChild:treeNode];
                }
            }
            
            [self.world addChild:node];
            
            positionX += node.size.width;
        }
        
        turnCounter++;
        terrainCounter++;
    }
    
}

@end
