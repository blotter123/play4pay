//
//  PGScoreCalculator.m
//  Play4Pay
//
//  Created by Benedikt Lotter on 7/24/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import "Flurry.h"

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
    NSMutableDictionary *modeCompletionParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          [self gameModeToString:type], @"game_mode",
                                          [NSString stringWithFormat:@"%f", score], @"score",
                                          [NSString stringWithFormat:@"%f", time], @"playing_time",
                                          nil];
    
    
    float percentScore = 0.0f;
    float currHighPercent = 0.0f;

    switch (type) {
        case kGameModeTypeClassic:
            currHighPercent = [self getFloatForVariable:@"classic_high_percent"];
            //% for time is the LOWER_BOUND / score
            percentScore = RAW_CLASSIC_LOWER_TIME_BOUND/score;
            if (percentScore > currHighPercent) {
                [self writeValue:percentScore forVariable:@"classic_high_percent"];
                
                [modeCompletionParams setValue:@"true" forKey:@"new_high_score"];
                [modeCompletionParams setValue:[NSString stringWithFormat:@"%f",[self calculateHighScore]] forKey:@"new_high_score_value"];
                
            }else{
                [modeCompletionParams setValue:@"false" forKey:@"new_high_score"];
            }
            [Flurry logEvent:@"completed_classic_game_mode" withParameters:modeCompletionParams];
            break;
            
        case kGameModeTypeArcade:
            currHighPercent = [self getFloatForVariable:@"arcade_high_percent"];
            //% for distance is the score / UPPER_BOUND
            percentScore = score/RAW_ARCADE_UPPER_ROW_BOUND;
            if (percentScore > currHighPercent) {
                [self writeValue:percentScore forVariable:@"arcade_high_percent"];
                
                [modeCompletionParams setValue:@"true" forKey:@"new_high_score"];
                [modeCompletionParams setValue:[NSString stringWithFormat:@"%f",[self calculateHighScore]] forKey:@"new_high_score_value"];
                
            }else{
                [modeCompletionParams setValue:@"false" forKey:@"new_high_score"];
            }
            [Flurry logEvent:@"completed_arcade_game_mode" withParameters:modeCompletionParams];
            break;
        
        case kGameModeTypeZen:
            currHighPercent = [self getFloatForVariable:@"zen_high_percent"];
            //% for distance is the score / UPPER_BOUND
            percentScore = score/RAW_ZEN_UPPER__ROW_BOUND;
            if (percentScore > currHighPercent) {
                [self writeValue:percentScore forVariable:@"zen_high_percent"];
                
                [modeCompletionParams setValue:@"true" forKey:@"new_high_score"];
                [modeCompletionParams setValue:[NSString stringWithFormat:@"%f",[self calculateHighScore]] forKey:@"new_high_score_value"];
                
            }else{
               [modeCompletionParams setValue:@"false" forKey:@"new_high_score"];
            }
            [Flurry logEvent:@"completed_zen_game_mode" withParameters:modeCompletionParams];
            break;
    }
    
}

#pragma mark Calculation Helper Methods

- (float) calculateHighScore{
    
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
    return self.highScore;
}

-(void) updatePlayingTime:(float) incrementTime{
    float currentTime =[self getFloatForVariable:@"playing_time"];
    float newTime = currentTime + incrementTime;
    [self writeValue:newTime forVariable:@"playing_time"];
    NSDictionary *playingTimeParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSString stringWithFormat:@"%f", incrementTime],@"increment_time",
                                       [NSString stringWithFormat:@"%f", newTime],@"new_total_time",
                                       nil];
    [Flurry logEvent:@"updated_playing_time" withParameters:playingTimeParams];
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

#pragma mark Utility Helper Methods

- (NSString*)gameModeToString:(PGGameModeType)gameMode {
    NSString *result = nil;
    
    switch(gameMode) {
        case kGameModeTypeClassic:
            result = @"classic";
            break;
        case kGameModeTypeArcade:
            result = @"arcade";
            break;
        case kGameModeTypeZen:
            result = @"zen";
            break;
        default:
            result = @"Unknown_Type";
    }
    return result;
}


@end
