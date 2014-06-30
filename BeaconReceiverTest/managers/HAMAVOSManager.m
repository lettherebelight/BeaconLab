//
//  HAMAVOSManager.m
//  BeaconReceiverTest
//
//  Created by Dai Yue on 14-7-1.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMAVOSManager.h"

#import "HAMLogTool.h"

@implementation HAMAVOSManager

#pragma mark - Cache

#pragma mark - Clear Cache

+ (void)clearCache{
    [AVQuery clearAllCachedResults];
}

#pragma mark - BeaconUUID

#pragma mark - BeaconUUID Save

+ (void)saveBeaconUUID:(NSString*)uuid description:(NSString*)description withTarget:(id)target callback:(SEL)callback{
    NSUUID* uuidCheck = [[NSUUID alloc] initWithUUIDString:uuid];
    if (uuidCheck == nil) {
        [HAMLogTool warn:@"illegal uuid"];
        return;
    }
    
    AVObject* uuidObject = [AVObject objectWithClassName:@"BeaconUUID"];
    [uuidObject setObject:[uuidCheck UUIDString] forKey:@"proximityUUID"];
    [uuidObject setObject:description forKey:@"description"];
    
    [self clearCache];
    [uuidObject save];
    
    //perform callback
    if (target == nil) {
        return;
    }
    
    [uuidObject saveInBackgroundWithTarget:target selector:callback];
}

@end
