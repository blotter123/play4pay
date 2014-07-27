//
//  PGScoreCalculator.m
//  Play4Pay
//
//  Created by Benedikt Lotter on 7/24/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import "PGScoreCalculator.h"
#import "PGDataService.h"

@implementation PGScoreCalculator

/*
 Flow
 
 1. completedWithScore called from some GameMode
 2. calculate %score relative to constant UPPER_BOUND definitions
 3. compare to current HighPercent scores for respective mode
 4. If HighPercent for mode exceeded, write new % high scores to pList and calculate new total highScore
 5. calculateHighScore retrieves current % high scores and points_constant that can be could have changed somewhere else through achievements/time elapsed
 
*/

double pointsAvailable;
//to be stored in PList


#pragma mark PGScoreDelegate Implementation
- (void) completedMode:(PGGameModeType) type withScore:(float)score{
    double percentScore = 0.0f;
    double currHighPercent = 0.0f;

    switch (type) {
        case classic:
            currHighPercent = [self getDoubleForVariable:@"classic_high_percent"];
            //% for time is the LOWER_BOUND / score
            percentScore = RAW_CLASSIC_LOWER_TIME_BOUND/score;
            if (percentScore > currHighPercent) {
                [self writeValue:percentScore ForVariable:@"classic_high_percent"];
            }else{
                // define behavior
            }
            break;
            
        case arcade:
            currHighPercent = [self getDoubleForVariable:@"arcade_high_percent"];
            //% for distance is the score / UPPER_BOUND
            percentScore = score/RAW_ARCADE_UPPER_ROW_BOUND;
            if (percentScore > currHighPercent) {
                [self writeValue:percentScore ForVariable:@"arcade_high_percent"];
            }else{
                // define behavior
            }
            break;
        
        case zen:
            currHighPercent = [self getDoubleForVariable:@"zen_high_percent"];
            //% for distance is the score / UPPER_BOUND
            percentScore = score/RAW_ZEN_UPPER__ROW_BOUND;
            if (percentScore > currHighPercent) {
                [self writeValue:percentScore ForVariable:@"zen_high_percent"];
                [self calculateHighScore];
            }else{
               // define behavior
            }
            break;
    }
}

#pragma mark Calculation Helper Methods

- (void) calculateHighScore{
    
    double classicHighPercent = [self getDoubleForVariable:@"classic_high_percent"];
    double arcadeHighPercent = [self getDoubleForVariable:@"arcade_high_percent"];
    double zenHighPercent = [self getDoubleForVariable:@"zen_high_percent"];
    
    float percentSum = classicHighPercent + arcadeHighPercent + zenHighPercent;
    
    pointsAvailable = (percentSum * POINT_SCALE_FACTOR) + [self getDoubleForVariable:@"points_constant"];
    
    float classicWeight = classicHighPercent / percentSum;
    float arcadeWeight = arcadeHighPercent /percentSum;
    float zenWeight = zenHighPercent / percentSum;
    
    float classicPoints = classicWeight * pointsAvailable;
    float arcadePoints = arcadeWeight * pointsAvailable;
    float zenPoints = zenWeight * pointsAvailable;

    self.highScore = (classicWeight*classicPoints) + (arcadeWeight*arcadePoints) + (zenWeight*zenPoints);
    [self writeValue:self.highScore ForVariable:@"high_score"];
}

-(double) getDoubleForVariable:(NSString*) variable{
    PGDataService* dataService = [PGDataService sharedDataService];
    NSNumber* variableNumber = (NSNumber*)[dataService readProperty:variable];
    return [variableNumber doubleValue];
}

-(void) writeValue:(double) value ForVariable:(NSString*) variable{
    PGDataService* dataService = [PGDataService sharedDataService];
    NSNumber* variableNumber = [NSNumber numberWithDouble:value];
    [dataService writeProperty:variable withValue:variableNumber];
}


@end
