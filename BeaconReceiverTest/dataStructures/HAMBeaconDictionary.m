//
//  HAMBeaconDictionary.m
//  BeaconReceiverTest
//
//  Created by Dai Yue on 14-5-11.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMBeaconDictionary.h"

@interface HAMBeaconDictionary(){
    
}

@property NSMutableDictionary* uuidDictionary;

@end

@implementation HAMBeaconDictionary

- (id)init{
    if (self = [super init]) {
        self.uuidDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setValue:(id)value forBeacon:(CLBeacon *)beacon{
    NSString* uuid = beacon.proximityUUID.UUIDString;
    NSNumber* major = beacon.major;
    NSNumber* minor = beacon.minor;
    
    NSMutableDictionary* majorDictionary = [self.uuidDictionary objectForKey:uuid];
    if (majorDictionary == nil) {
        majorDictionary = [NSMutableDictionary dictionary];
        [self.uuidDictionary setObject:majorDictionary forKey:uuid];
    }
    
    NSMutableDictionary* minorDictionary = [majorDictionary objectForKey:major];
    if (minorDictionary == nil) {
        minorDictionary = [NSMutableDictionary dictionary];
        [majorDictionary setObject:minorDictionary forKey:major];
    }
    
    [minorDictionary setObject:value forKey:minor];
}

- (id)objectForBeacon:(CLBeacon *)beacon{
    NSString* uuid = beacon.proximityUUID.UUIDString;
    NSNumber* major = beacon.major;
    NSNumber* minor = beacon.minor;
    
    NSMutableDictionary* majorDictionary = [self.uuidDictionary objectForKey:uuid];
    if (majorDictionary == nil) {
        return nil;
    }
    
    NSMutableDictionary* minorDictionary = [majorDictionary objectForKey:major];
    if (minorDictionary == nil) {
        return nil;
    }
    
    return [minorDictionary objectForKey:minor];
}

@end
