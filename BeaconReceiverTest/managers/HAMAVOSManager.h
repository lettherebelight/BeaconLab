//
//  HAMAVOSManager.h
//  BeaconReceiverTest
//
//  Created by Dai Yue on 14-7-1.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVOSCloud/AVOSCloud.h>

@interface HAMAVOSManager : NSObject

+ (void)clearCache;

+ (void)saveBeaconUUID:(NSString*)uuid description:(NSString*)description withTarget:(id)target callback:(SEL)callback;

@end
