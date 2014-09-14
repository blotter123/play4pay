//
//  PGWorldViewController.m
//  Play4Pay
//
//  Created by Julian Offermann on 9/13/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import "PGWorldViewController.h"
#import "PGWorldScene.h"

@interface PGWorldViewController ()

@end

@implementation PGWorldViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SKView *skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    PGWorldScene * scene = [PGWorldScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

@end
