//
//  PGMyScene.m
//  Play4Pay
//
//  Created by Julian Offermann on 7/4/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import "PGMainScene.h"
#import "PGSpriteNode.h"

#include <stdlib.h>

@interface PGMainScene ()

@property (nonatomic) CGFloat movingSpeed;

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
        self.rowIndex = 2;
        self.isDisabled = NO;
        
        self.movingSpeed = ROW_MOVE_SPEED * 5;
    }
    
    return self;
}

-(void) didMoveToView:(SKView *)view {
 
    if (!self.contentCreated) {
        
        self.backgroundColor = [SKColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
        
        self.gridContent = [[SKSpriteNode alloc] initWithColor:PRIMARY_COLOR size:self.size];
        self.gridContent.position = CGPointMake(0, 0);
        
        [self fillScreen];
        [self addScreenGrid];
        
        [self addChild:self.gridContent];
        
        self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        self.scoreLabel.text = [NSString stringWithFormat:@"Speed: %f", self.movingSpeed];
        self.scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - 50);
        self.scoreLabel.fontColor = [UIColor redColor];

        [self addChild:self.scoreLabel];
        
        [self setContentCreated:YES];
    }
}

#pragma mark - Methods

-(void) addScreenGrid {
    
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

-(void) fillScreen {
    
    //  Fill screen by 4x4 sprites
    
    for (int i = 0; i < TOTAL_ROWS; i++) {
        [self addRowAtIndex:i active:(i > 0)];
    }
}

-(void) randomizeScreen {
    
    int randomIndex = arc4random() % TOTAL_COLUMNS;
    
    for (int i = 0; i < TOTAL_ROWS * TOTAL_COLUMNS; i++) {
        
        if (i % TOTAL_COLUMNS == 0 && i != 0)
            randomIndex = arc4random() % TOTAL_COLUMNS;

        SKSpriteNode *node = (SKSpriteNode*)[self childNodeWithName:[NSString stringWithFormat:@"%@%d", SPRITE_NAME, i]];
        
        if (randomIndex == (i % TOTAL_COLUMNS))
            [node setColor:[SKColor blackColor]];
        else
            [node setColor:[SKColor whiteColor]];
    }
}

-(void) addRowAtIndex:(NSInteger)index active:(BOOL)isActive {
    
    int randomIndex = arc4random() % TOTAL_COLUMNS;
    
    CGFloat width = self.size.width / TOTAL_COLUMNS,
            height = self.size.height / TOTAL_ROWS;
    
    for (int i = 0; i < TOTAL_COLUMNS; i++) {
        
        if (i % TOTAL_COLUMNS == 0 && i != 0)
            randomIndex = arc4random() % TOTAL_COLUMNS;
        
        NSInteger gridPosition = (index * TOTAL_COLUMNS) + i;
        
        PGSpriteNode *sprite = [PGSpriteNode nodeWithSize:CGSizeMake(width, height) gridPosition:gridPosition andColor:SECONDARY_COLOR];
        
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
        [label setUserInteractionEnabled:NO];
        [label setPosition:sprite.position];
        [label setFontColor:PRIMARY_COLOR];
        [label setText:sprite.name];
        [label setFontSize:16.0f];
        
        if (randomIndex == (i % TOTAL_COLUMNS)) {
            sprite.color = PRIMARY_COLOR;
            label.fontColor = SECONDARY_COLOR;
        }
        
        if (!isActive)
            sprite.color = INACTIVE_COLOR;
        
        [self.gridContent addChild:sprite];
        //[self.gridContent addChild:label];
    }
}

-(void) moveToNextRow {
    
    self.rowIndex++;
    
    //  Increase size of grid content
    
    [self.gridContent setSize:CGSizeMake(self.size.width, self.gridContent.size.height + (self.size.height / TOTAL_COLUMNS))];
    
    //  Add row
    
    [self addRowAtIndex:self.rowIndex + 1 active:YES]; // 4 rows are always visible - zero based
    
    //  Define move action
    
    SKAction *moveAction = [SKAction moveByX:0.0f y:-(self.size.height / TOTAL_ROWS) duration:self.movingSpeed];
    [self.gridContent runAction:moveAction];
    
    self.movingSpeed -= 0.01;
}

-(void) resetGrid {
    
    for (SKNode *node in self.gridContent.children) {
        [node removeFromParent];
    }
    
    [self.gridContent setSize:self.size];
    [self.gridContent setPosition:CGPointMake(0, 0)];
    
    [self fillScreen];
    
    [self setRowIndex:2];
    
    [self setIsDisabled:NO];
}

- (void) disableGrid {
    [self setIsDisabled:YES];
}

- (void) moveAutomatically {
    
    NSLog(@"%f", self.movingSpeed);
    self.scoreLabel.text = [NSString stringWithFormat:@"Speed: %f", self.movingSpeed];
    
    SKAction *action = [SKAction sequence:@[[SKAction performSelector:@selector(moveToNextRow) onTarget:self],
                         [SKAction waitForDuration:self.movingSpeed]]];

    [self runAction:action completion:^{
        [self moveAutomatically];
    }];
}

#pragma mark - Events

static BOOL isActivated = NO;
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (isActivated) return;
    [self moveAutomatically];
    isActivated = YES;
    return;
    
    if (self.isDisabled) return;
    
    for (UITouch *touch in touches) {
        
        CGPoint location = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:location];
        
        if ([node isKindOfClass:[PGSpriteNode class]]) {
            
            BOOL isHot = [(PGSpriteNode*)node isHot];
            
            if (!isHot) {
                [(PGSpriteNode*)node alert];
                [self disableGrid];
                [self performSelector:@selector(resetGrid) withObject:nil afterDelay:0.75f];
            }
            else {
                
                BOOL isInRow = [(PGSpriteNode*)node isInRow:self.rowIndex];

                if (isInRow) {
                    [(PGSpriteNode*)node highlight];
                    [self moveToNextRow];
                }
            }
        }
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
