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
- (void) completedMode:(PGGameModeType) type withScore:(float)score andPlayingTime:(float)time{
    float percentScore = 0.0f;
    float currHighPercent = 0.0f;

    switch (type) {
        case classic:
            currHighPercent = [self getFloatForVariable:@"classic_high_percent"];
            //% for time is the LOWER_BOUND / score
            percentScore = RAW_CLASSIC_LOWER_TIME_BOUND/score;
            if (percentScore > currHighPercent) {
                [self writeValue:percentScore forVariable:@"classic_high_percent"];
            }else{
                // define behavior
            }
            break;
            
        case arcade:
            currHighPercent = [self getFloatForVariable:@"arcade_high_percent"];
            //% for distance is the score / UPPER_BOUND
            percentScore = score/RAW_ARCADE_UPPER_ROW_BOUND;
            if (percentScore > currHighPercent) {
                [self writeValue:percentScore forVariable:@"arcade_high_percent"];
            }else{
                // define behavior
            }
            break;
        
        case zen:
            currHighPercent = [self getFloatForVariable:@"zen_high_percent"];
            //% for distance is the score / UPPER_BOUND
            percentScore = score/RAW_ZEN_UPPER__ROW_BOUND;
            if (percentScore > currHighPercent) {
                [self writeValue:percentScore forVariable:@"zen_high_percent"];
                [self calculateHighScore];
            }else{
               // define behavior
            }
            break;
    }
    
}

#pragma mark Calculation Helper Methods

- (void) calculateHighScore{
    
    float classicHighPercent = [self getFloatForVariable:@"classic_high_percent"];
    float arcadeHighPercent = [self getFloatForVariable:@"arcade_high_percent"];
    float zenHighPercent = [self getFloatForVariable:@"zen_high_percent"];
    
    float percentSum = classicHighPercent + arcadeHighPercent + zenHighPercent;
    
    pointsAvailable = (percentSum * POINT_SCALE_FACTOR) + [self getFloatForVariable:@"points_constant"];
    
    float classicWeight = classicHighPercent / percentSum;
    float arcadeWeight = arcadeHighPercent /percentSum;
    float zenWeight = zenHighPercent / percentSum;
    
    float classicPoints = classicWeight * pointsAvailable;
    float arcadePoints = arcadeWeight * pointsAvailable;
    float zenPoints = zenWeight * pointsAvailable;

    self.highScore = (classicWeight*classicPoints) + (arcadeWeight*arcadePoints) + (zenWeight*zenPoints);
    [self writeValue:self.highScore forVariable:@"high_score"];
}

-(void) updatePlayingTime:(float) incrementTime{
    float currentTime =[self getFloatForVariable:@"playing_time"];
    float newTime = currentTime + incrementTime;
    [self writeValue:newTime forVariable:@"playing_time"];
}

-(float) getFloatForVariable:(NSString*) variable{
    PGDataService* dataService = [PGDataService sharedDataService];
    NSNumber* variableNumber = (NSNumber*)[dataService readProperty:variable];
    return [variableNumber floatValue];
}

-(void) writeValue:(float) value forVariable:(NSString*) variable{
    PGDataService* dataService = [PGDataService sharedDataService];
    NSNumber* variableNumber = [NSNumber numberWithFloat:value];
    [dataService writeProperty:variable withValue:variableNumber];
}




@end
