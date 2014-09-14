//
//  PGTileGenerator.m
//  Play4Pay
//
//  Created by Benedikt Lotter on 9/13/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import "PGTileGenerator.h"

@interface PGTileGenerator()


typedef enum{
    FOLLOW,
    LEFT,
    RIGHT
} PGPathStepType;

typedef enum {
    
    //non-path
    kNodeTypeGrass = 1,
    kNodeTypeWater = 2,
    
    //transition between non-path types
    kNodeTypeDirt = 3,
    
    //path
    kNodeTypeStone = 4,
    kNodeTypeBrick = 5,
    kNodeTypePlain = 6,
    kNodeTypeWood = 7,
    
    kNodeTypeTreeItem   = 8,
    kNodeTypeRockItem   = 9,
    
} PGNodeType;

@property NSInteger step;
@property PGNodeType pathType;
@property PGNodeType terrainType;
@property NSMutableArray* pathBlockAhead;

@end

@implementation PGTileGenerator


-(void) initializeConfigurations{
    self.step = 0;
    self.terrainType = [self randomTerrainType];
    self.pathType = [self randomPathTypeForTerrain:self.terrainType];
    self.pathBlockAhead = [[NSMutableArray alloc]init];
    NSArray* initalPath = [NSArray arrayWithObjects:[NSNumber numberWithInteger:2], [NSNumber numberWithInteger:3], nil];
    for (int i = 0; i <4; i++) {
        [self.pathBlockAhead addObject:initalPath];
    }
}


- (NSArray*) nextPathStep{
    if (self.step != 0 && (self.step % 4) == 0 ) {
        self.pathBlockAhead = [self updatePath];
        [self updateWorld];
    }
    NSArray* row = [self generateRowFromPathAhead:self.pathBlockAhead atIndex:(self.step % 4)];
    self.step = self.step + 1;
    return row;
}

-(NSArray*) generateRowFromPathAhead:(NSMutableArray*)pathAhead atIndex:(NSInteger) index{
    NSMutableArray* row = [[NSMutableArray alloc]init];
    NSArray* pathBounds = [pathAhead objectAtIndex:index];
    NSNumber* left = [pathBounds objectAtIndex:0];
    NSNumber* right = [pathBounds objectAtIndex:1];
    for (int i = 0; i < [left intValue]; i++) {
        [row addObject:[NSNumber numberWithInt:self.terrainType]];
    }
    for (int i = [left intValue]; i <= [right intValue]; i++) {
        [row addObject:[NSNumber numberWithInt:self.pathType]];
    }
    for (int i = [right intValue]+1; i <= 5; i++) {
        [row addObject:[NSNumber numberWithInt:self.terrainType]];
    }
    return row;
}

- (NSArray*) fillRow:(NSNumber*) left rightBound:(NSNumber*) right{
    NSMutableArray* row = [[NSMutableArray alloc]init];
    for (int i = 0; i < [left intValue]; i++) {
        [row addObject:[NSNumber numberWithInt:self.terrainType]];
    }
    for (int i = [left intValue]; i <= [right intValue]; i++) {
        [row addObject:[NSNumber numberWithInt:self.pathType]];
    }
    for (int i = [right intValue]+1; i <= 5; i++) {
        [row addObject:[NSNumber numberWithInt:self.terrainType]];
    }
    return row;
}




- (NSMutableArray*) updatePath{
    bool turn = [self shouldSwapWithProbability:0.5];
    PGPathStepType nextDirection = FOLLOW;
    NSArray* lastPath = [self.pathBlockAhead objectAtIndex:3];
    NSNumber* lastLeft = [lastPath objectAtIndex:0];
    NSNumber* lastRight = [lastPath objectAtIndex:1];
    if (turn) {
        nextDirection = [self randomDirection:lastLeft andRight:lastRight];
    }
    return [self generateNextBlock:nextDirection fromPath:lastPath];
}

- (NSMutableArray*) generateNextBlock:(PGPathStepType)direction fromPath:(NSArray*) lastPath{
    NSMutableArray* nextPathBlock = [[NSMutableArray alloc]init];
    NSNumber* lastLeft = [lastPath objectAtIndex:0];
    NSNumber* lastRight = [lastPath objectAtIndex:1];
    if(direction == FOLLOW){
        for (int i = 0; i <4; i++) {
            [nextPathBlock addObject:[NSArray arrayWithObjects:lastLeft, lastRight, nil]];
        }
    }
    else{
        NSInteger offset = 1;
        if ([self shouldSwapWithProbability:0.5]) {
            offset = 2;
        }
        if (direction == RIGHT) {
            [nextPathBlock addObject:[NSArray arrayWithObjects:lastLeft, lastRight, nil]];
            lastRight = [NSNumber numberWithInteger:[lastRight integerValue]+offset];
            [nextPathBlock addObject:[NSArray arrayWithObjects:lastLeft, lastRight, nil]];
            [nextPathBlock addObject:[NSArray arrayWithObjects:lastLeft, lastRight, nil]];
            lastLeft = [NSNumber numberWithInteger:[lastLeft integerValue]+offset];
            [nextPathBlock addObject:[NSArray arrayWithObjects:lastLeft, lastRight, nil]];
        }
        else if(direction == LEFT){
            [nextPathBlock addObject:[NSArray arrayWithObjects:lastLeft, lastRight, nil]];
            lastLeft = [NSNumber numberWithInteger:[lastLeft integerValue]-offset];
            [nextPathBlock addObject:[NSArray arrayWithObjects:lastLeft, lastRight, nil]];
            [nextPathBlock addObject:[NSArray arrayWithObjects:lastLeft, lastRight, nil]];
            lastRight = [NSNumber numberWithInteger:[lastRight integerValue]-offset];
            [nextPathBlock addObject:[NSArray arrayWithObjects:lastLeft, lastRight, nil]];
        }
    }
    
    return nextPathBlock;
}

- (void) updateWorld{
    bool change = [self shouldSwapWithProbability:0.5];
    if (change) {
        self.terrainType = [self randomTerrainType];
        self.pathType = [self randomPathTypeForTerrain:self.terrainType];
    }
}


- (PGNodeType) randomTerrainType{
    PGNodeType terrainType = arc4random_uniform(2) ? kNodeTypeWater : kNodeTypeGrass;
    return terrainType;
}

- (PGNodeType) randomPathTypeForTerrain:(PGNodeType) terrainType{
    //int rndValue = arc4random_uniform(11);
    if (terrainType == kNodeTypeWater) {
            return kNodeTypeStone;

    }else{
            return kNodeTypePlain;
    }
}

- (BOOL) shouldSwapWithProbability:(float)prob{
    int lowerBound = 0;
    int upperBound = 100;
    int rndValue = lowerBound + arc4random() % (upperBound - lowerBound);
    if (rndValue <= prob*100) {
        return true;
    }
    else{
        return false;
    }
}

- (PGPathStepType) randomDirection:(NSNumber*) lastLeft andRight:(NSNumber*) lastRight{
    PGPathStepType direction = FOLLOW;
    if (([lastLeft integerValue]-2) < 0) {
        direction = RIGHT;
    }
    else if ([lastRight integerValue]+2 > 6){
        direction = LEFT;
    }
    else{
        direction = LEFT;
        if ([self shouldSwapWithProbability:0.5]) {
            direction = RIGHT;
        }
    }
    return direction;
}

@end
