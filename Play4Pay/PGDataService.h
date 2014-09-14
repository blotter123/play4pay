//
//  PGDataService.h
//  Play4Pay
//
//  Created by Benedikt Lotter on 7/27/14.
//  Copyright (c) 2014 Play4Pay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGDataService : NSObject

+ (id)sharedDataService;

- (void) writeProperty:(NSString*) propertyName withValue:(NSObject*) value;
- (id) readProperty:(NSString*) propertyName;
- (void) setCurrentUser:(NSString*) fbUserId;
- (NSString*) getCurrentUser;
- (void) initUserData:(NSString*) fbUserId withAccessToken:(NSString*) accessToken;


@end
