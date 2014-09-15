//
//  PGTileGenerator.h
//  Play4Pay
//
//  Created by Benedikt Lotter on 9/13/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGTileGenerator : NSObject

- (void) initializeConfigurations;
- (NSArray*) nextPathStep;
- (NSDictionary*) rowTrees:(NSArray*) row;



@end
