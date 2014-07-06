//
//  PGMenuCell.m
//  Play4Pay
//
//  Created by Benedikt Lotter on 7/6/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import "PGMenuCell.h"

@implementation PGMenuCell



- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"initWithCoder called");
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        // change to our custom selected background view
        UILabel *label = [UILabel init];
        label.text = @"Hello World";
        [self.contentView addSubview:label];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
