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

@property (nonatomic) NSInteger rowCount;
@property (nonatomic) NSInteger rowIndex;

@property (nonatomic) BOOL isRunning;
@property (nonatomic) BOOL isDisabled;
@property (nonatomic) BOOL contentCreated;
@property (nonatomic, weak) SKLabelNode *welcomeNode;

@property (nonatomic, strong) SKSpriteNode *gridContent;
@property (nonatomic, strong) SKLabelNode *scoreLabel;

@property (nonatomic) float lastPosition;

@end

@implementation PGMainScene

-(id)initWithSize:(CGSize)size {    
    
    if (self = [super initWithSize:size]) {

        self.rowIndex = 0;
        self.rowCount = 0;
        self.isDisabled = NO;
        self.isRunning = NO;
        self.lastPosition = -1.0f;
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
        self.scoreLabel.text = [NSString stringWithFormat:@"Speed: %f", [self.gameMode movementSpeed]];
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

- (void) addRowOnTop {
    [self addRowAtIndex:self.rowCount];
}

- (void) addRowAtIndex:(NSInteger)rowIndex {
    
    if (self.gameMode && [self.gameMode respondsToSelector:@selector(statusForIndexPath:)] && self.isRunning) {
        
        PGGameStatus status = [self.gameMode statusForIndexPath:[NSIndexPath indexPathForItem:-1 inSection:rowIndex]];

        if (status == kGameStatusFailed) {
            
            //  Inform user about score
            
            NSString *score = [NSString stringWithFormat:@"Score: %d", self.rowIndex];
            [[[UIAlertView alloc] initWithTitle:@"Complete" message:score delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            
            //  Restart game
            
            [self setIsRunning:NO];
            [self setIsDisabled:YES];
            [self performSelector:@selector(resetGrid) withObject:nil afterDelay:0.75f];
        }
    }
    
    CGFloat width = self.size.width / TOTAL_COLUMNS,
    height = self.size.height / TOTAL_ROWS;
    
    for (int i = 0; i < TOTAL_COLUMNS; i++) {
        
        NSInteger positionWithinContainer = (rowIndex * TOTAL_COLUMNS) + i;
        
        UIColor *nodeColor = [self.gameMode colorAtIndexPath:[NSIndexPath indexPathForItem:i inSection:rowIndex]];
        
        PGSpriteNode *sprite = [PGSpriteNode nodeWithSize:CGSizeMake(width, height) position:positionWithinContainer andColor:nodeColor];
        [self.gridContent addChild:sprite];
    }
    
    self.rowCount++;
}

-(void) moveToNextRow {
    
    self.rowIndex++;
    
    //  Increase size of grid content
    
    [self.gridContent setSize:CGSizeMake(self.size.width, self.gridContent.size.height + (self.size.height / TOTAL_COLUMNS))];
    
    //  Add row
    
    [self addRowOnTop];
    
    if ([self.gameMode animationSpeed] > 0.0f) {

        //  Run move action
        SKAction *moveAction = [SKAction moveByX:0.0f y:-(self.size.height / TOTAL_ROWS) duration:[self.gameMode animationSpeed]];
        [self.gridContent runAction:moveAction];
    }
}

-(void) resetGrid {
    
    //  Clear existing nodes
    
    for (SKNode *node in self.gridContent.children) {
        [node removeFromParent];
    }
    
    //  Reset container
    
    [self.gridContent setSize:self.size];
    [self.gridContent setPosition:CGPointMake(0, 0)];
    
    [self setRowCount:0];
    [self setRowIndex:0];
    [self setIsDisabled:NO];
    [self setLastPosition:-1.0f];
    
    //  Run scene setup
    
    [self runSceneSetup];
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
                
                //  Stop game from running
                
                self.isRunning = NO;
                
                //  Alert node
                
                [(PGSpriteNode*)node alert];
                [self setIsDisabled:YES];
                [self performSelector:@selector(resetGrid) withObject:nil afterDelay:0.75f];
            }
            else if (status == kGameStatusValid) {
                
                //  Indicate that the game has started
                
                if (!self.isRunning)
                    self.isRunning = YES;
                
                //  Highlight node
                
                [(PGSpriteNode*)node highlight];
                
                if ([self.gameMode movementSpeed] <= 0.0f)
                    [self moveToNextRow];
            }
            else if (status == kGameStatusComplete) {
                
                //  Stop game from running
                
                self.isRunning = NO;
                
                //  Inform user about score
                
                [[[UIAlertView alloc] initWithTitle:@"Complete" message:@"Success!!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
        }
    }
}

- (void) update:(CFTimeInterval)currentTime {

    //  Following implementation for timed modes only
    
    if (self.gameMode && [self.gameMode respondsToSelector:@selector(didTick:)] && self.isRunning) {
       
        PGGameStatus status = [self.gameMode didTick:currentTime];
        if (status == kGameStatusComplete) {
            
            //  Stop game from running
            
            self.isRunning = NO;
            
            //  Inform user about score
            
            NSString *score = [NSString stringWithFormat:@"Score: %d", self.rowIndex];
            [[[UIAlertView alloc] initWithTitle:@"Complete" message:score delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            
            //  Restart game
            
            [self setIsDisabled:YES];
            [self performSelector:@selector(resetGrid) withObject:nil afterDelay:0.75f];
        }
    }
    
    //  Following implementation for automatic modes only
    
    if ([self.gameMode movementSpeed] > 0.0f && self.isRunning) {
        
        self.gridContent.position = CGPointMake(self.gridContent.position.x, self.gridContent.position.y - [self.gameMode movementSpeed]);
        
        if (self.lastPosition == -1.0f) {
            [self addRowOnTop];
            self.lastPosition = 0.0f;
        }
        
        self.lastPosition += [self.gameMode movementSpeed];
        
        float delta = fabs(self.lastPosition - 0.0f);
        float rowHeight = (self.size.height / TOTAL_ROWS);
        
        if (delta >= rowHeight) {
            self.lastPosition = 0.0f;
            [self addRowOnTop];
        }
    }
}

@end
