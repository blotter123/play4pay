//
//  PGMyScene.m
//  Play4Pay
//
//  Created by Julian Offermann on 7/4/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import "PGMainScene.h"

#include <stdlib.h>

@interface PGMainScene ()

@property (nonatomic) NSInteger rowIndex;
@property (nonatomic) BOOL isDisabled;
@property (nonatomic) BOOL contentCreated;
@property (nonatomic, weak) SKLabelNode *welcomeNode;

@property (nonatomic, strong) SKSpriteNode *gridContent;
@property (nonatomic, strong) SKLabelNode *scoreLabel;

@end

@implementation PGMainScene

-(id)initWithSize:(CGSize)size {    
    
    if (self = [super initWithSize:size]) {

        //  Initial value is 2 - NOT zero based
        //  First row is deactivated
        self.rowIndex = 0;
        self.isDisabled = NO;
    }
    
    return self;
}

-(void) didMoveToView:(SKView *)view {
 
    //  DO NOT START GAME WITHOUT A GAME MODE
    if (!self.gameMode) return;
    
    if (!self.contentCreated) {
        
        self.backgroundColor = [SKColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
        
        self.gridContent = [[SKSpriteNode alloc] initWithColor:PRIMARY_COLOR size:self.size];
        self.gridContent.position = CGPointMake(0, 0);
        
        [self runSceneSetup];
        [self addScreenGrid];
        
        [self addChild:self.gridContent];
        
        self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        self.scoreLabel.text = [NSString stringWithFormat:@"Speed: %f", [self.gameMode movingSpeed]];
        self.scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - 50);
        self.scoreLabel.fontColor = [UIColor redColor];

        [self addChild:self.scoreLabel];
        
        [self setContentCreated:YES];
    }
}

#pragma mark - Methods

- (void) runSceneSetup {
    
    //  Fill screen by 4x4 sprites
    
    for (int i = 0; i < TOTAL_ROWS; i++) {
        [self addRowAtIndex:i];
    }
}

- (void) addRowAtIndex:(NSInteger)index {
    
    int randomIndex = arc4random() % TOTAL_COLUMNS;
    
    CGFloat width = self.size.width / TOTAL_COLUMNS,
    height = self.size.height / TOTAL_ROWS;
    
    for (int i = 0; i < TOTAL_COLUMNS; i++) {
        
        if (i % TOTAL_COLUMNS == 0 && i != 0)
            randomIndex = arc4random() % TOTAL_COLUMNS;
        
        NSInteger positionWithinContainer = (index * TOTAL_COLUMNS) + i;
        
        PGSpriteNode *sprite = [PGSpriteNode nodeWithSize:CGSizeMake(width, height) position:positionWithinContainer andColor:SECONDARY_COLOR];
        
        if (randomIndex == (i % TOTAL_COLUMNS))
            sprite.color = PRIMARY_COLOR;
        
        if (index == 0)
            sprite.color = INACTIVE_COLOR;
        else if (index >= 50)
            sprite.color = COMPLETE_COLOR;
        
        [self.gridContent addChild:sprite];
    }
}

-(void) moveToNextRow {
    
    self.rowIndex++;
    
    //  Increase size of grid content
    
    [self.gridContent setSize:CGSizeMake(self.size.width, self.gridContent.size.height + (self.size.height / TOTAL_COLUMNS))];
    
    //  Add row
    
    // 4 rows are always visible - zero based
    [self addRowAtIndex:self.rowIndex + 1];
    
    //  Define move action
    
    SKAction *moveAction = [SKAction moveByX:0.0f y:-(self.size.height / TOTAL_ROWS) duration:self.gameMode.movingSpeed];
    [self.gridContent runAction:moveAction];
}

-(void) resetGrid {
    
    //  Clear existing nodes
    
    for (SKNode *node in self.gridContent.children) {
        [node removeFromParent];
    }
    
    //  Reset container
    
    [self.gridContent setSize:self.size];
    [self.gridContent setPosition:CGPointMake(0, 0)];
    
    //  Reset score
    
    [self setRowIndex:0];
    [self setIsDisabled:NO];
    
    //  Run scene setup
    
    [self runSceneSetup];
}

- (void) moveAutomatically {
    
    self.scoreLabel.text = [NSString stringWithFormat:@"Speed: %f", self.gameMode.movingSpeed];
    
    SKAction *action = [SKAction sequence:@[[SKAction performSelector:@selector(moveToNextRow) onTarget:self],
                         [SKAction waitForDuration:self.gameMode.movingSpeed]]];

    [self runAction:action completion:^{
        [self moveAutomatically];
    }];
}

#pragma mark - Helper

- (void) addScreenGrid {
    
    CGFloat positionX = CGRectGetMinX(self.frame),
    positionY = CGRectGetMinY(self.frame),
    maxWidth = self.size.width,
    maxHeight = self.size.height;
    
    for (int i = 0; i < GRID_COUNT; i++) {
        
        BOOL isHorizontal = i < sqrt(GRID_COUNT);
        
        if (isHorizontal) {
            positionX = CGRectGetMinX(self.frame);
            positionY += self.size.height / TOTAL_ROWS;
        }
        else {
            positionX += self.size.width / TOTAL_COLUMNS;
            positionY = CGRectGetMinY(self.frame);
        }
        
        CGSize size;
        if (isHorizontal)
            size = CGSizeMake(maxWidth, 0.5f);
        else
            size = CGSizeMake(0.5f, maxHeight);
        
        SKSpriteNode *gridLine = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:size];
        gridLine.position = CGPointMake(positionX + size.width / 2.0f, positionY + size.height / 2.0f);
        gridLine.zPosition = 10.0f;
        
        [self addChild:gridLine];
    }
}

#pragma mark - Events

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.isDisabled) return;
    
    for (UITouch *touch in touches) {
        
        CGPoint location = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:location];
        
        if ([node isKindOfClass:[PGSpriteNode class]]) {
            
            NSInteger rowIndex = [(PGSpriteNode*)node rowIndex];
            
            PGGameStatus status = [self.gameMode statusForNode:(PGSpriteNode*)node inRow:rowIndex];
            
            if (status == kGameStatusFailed) {
                
                [(PGSpriteNode*)node alert];
                [self setIsDisabled:YES];
                [self performSelector:@selector(resetGrid) withObject:nil afterDelay:0.75f];
            }
            else if (status == kGameStatusValid) {
                
                [(PGSpriteNode*)node highlight];
                [self moveToNextRow];
            }
        }
    }
}

- (void) update:(CFTimeInterval)currentTime {
    NSLog(@"%f", currentTime);
}

@end
