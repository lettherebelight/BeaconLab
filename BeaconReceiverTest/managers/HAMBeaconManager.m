//
//  HAMBeaconManager.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-2-26.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMBeaconManager.h"
#import "HAMDBManager.h"
#import "HAMTools.h"
#import "HAMLogTool.h"

#import <AVOSCloud/AVOSCloud.h>

@interface HAMBeaconManager()
{}

@property NSString* observingUUID;
@property NSNumber* observingMajor;
@property NSNumber* observingMinor;

@property id startRangingTarget;
@property SEL startRangingCallback;

@property NSMutableDictionary* descriptionDictionary;
@property NSMutableArray* rangingRegionArray;

@end

static HAMBeaconManager* beaconManager = nil;

@implementation HAMBeaconManager

@synthesize locationManager;
@synthesize descriptionDictionary;

+ (HAMBeaconManager*)beaconManager{
    @synchronized(self) {
        if (beaconManager == nil)
            beaconManager = [[HAMBeaconManager alloc] init];
    }
    
    return beaconManager;
}

-(id)init{
    if (self = [super init]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        self.observingUUID = nil;
        self.observingMajor = nil;
        self.observingMinor = nil;
        
        self.descriptionDictionary = [NSMutableDictionary dictionary];
    }
    
    return self;
}

#pragma mark - Start Ranging

- (void)startRanging{
    if (self.rangingRegionArray != nil) {
        for (int i = 0; i < self.rangingRegionArray.count; i++) {
            CLBeaconRegion* region = self.rangingRegionArray[i];
            
            [locationManager stopMonitoringForRegion:region];
            [locationManager stopRangingBeaconsInRegion:region];
            
            [self locationManager:locationManager didExitRegion:region];
        }
    }
    
    [self queryBeaconsWithTarget:beaconManager callBack:@selector(startRangingWithBeacons:error:)];
}

- (void)queryBeaconsWithTarget:(id)target callBack:(SEL)callback{
    
    //TODO: change to unique
    //TODO: change to cached
    
//    if ([HAMTools isWebAvailable]) {
    AVQuery *query = [AVQuery queryWithClassName:@"BeaconUUID"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    query.maxCacheAge = 24*3600;
    [query selectKeys:@[@"proximityUUID",@"description"]];

    [query findObjectsInBackgroundWithTarget:target selector:callback];
//    }
}

- (void)startRangingWithBeacons:(NSArray*)uuidInfoArray error:(NSError*)error{
    if (!error) {
        self.descriptionDictionary = [NSMutableDictionary dictionary];
        NSMutableArray* beaconUUIDArray = [NSMutableArray array];
        
        //parse data
        for (int i = 0; i < uuidInfoArray.count; i++) {
            AVObject* beacon = uuidInfoArray[i];
            NSString* beaconUUID = [beacon objectForKey:@"proximityUUID"];
            
            NSString* description = [beacon objectForKey:@"description"];
            if (description == nil) {
                description = @"未知品牌";
            }
            
            [self.descriptionDictionary setObject:description forKey:beaconUUID];
            [beaconUUIDArray addObject:beaconUUID];
        }

        //start ranging
        self.rangingRegionArray = [NSMutableArray array];
        for (int i = 0; i < beaconUUIDArray.count; i++) {
            [self startRangingWithUUID:beaconUUIDArray[i]];
        }
        
        if (self.observer != nil) {
            [self.observer didStartRanging];
        }
    } else {
        [HAMLogTool error:[NSString stringWithFormat:@"%@ %@", error, [error userInfo]]];
    }
}

- (void)startRangingWithUUID:(NSString*)beaconID{
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:beaconID];
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:beaconID];
    
    if (region == nil) {
        //Illegal UUID
        return;
    }
    
    [self.rangingRegionArray addObject:region];
    region.notifyEntryStateOnDisplay = YES;
    [self.locationManager startMonitoringForRegion:region];
    [self.locationManager startRangingBeaconsInRegion:region];
}

#pragma mark - Observer Mode

- (void)registerObserver:(id<HAMBeaconObserver>)observer forUUID:(NSString *)uuid major:(NSNumber *)major minor:(NSNumber *)minor{
    self.observer = observer;
    self.observingUUID = uuid;
    self.observingMajor = major;
    self.observingMinor = minor;
}

- (void)registerObserverForAll:(id<HAMBeaconObserver>)observer{
    self.observer = observer;
    self.observingUUID = nil;
    self.observingMajor = nil;
    self.observingMinor = nil;
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    CLBeaconRegion* beaconRegion = (CLBeaconRegion*)region;
    NSString* regionUUID = [beaconRegion.proximityUUID UUIDString];
    if (self.observingUUID != nil) {
        //return if observing one specific beacon
//        if (![regionUUID isEqualToString:self.observingUUID]) {
            return;
//        }
    }
    
    [self.observer didExitRegionOfUUID:regionUUID];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
    if (beacons.count == 0) {
        return;
    }
    
    if (self.observer == nil) {
        return;
    }
    
    NSString* regionUUID = [region.proximityUUID UUIDString];
    if (self.observingUUID != nil) {
        if (![regionUUID isEqualToString:self.observingUUID]) {
            return;
        }
    }
    
    if (self.observingMajor != nil && self.observingMinor != nil) {
        //Observing one specific beacon
        for (int i = 0; i < beacons.count; i++) {
            CLBeacon* beacon = beacons[i];
            if ([beacon.major isEqualToNumber:self.observingMajor] && [beacon.minor isEqualToNumber:self.observingMinor]) {
                [self.observer didRangeBeacon:beacon];
                return;
            }
        }
    }
    else{
        //Observing all beacons
        [self.observer didRangeBeacons:beacons ofUUID:regionUUID];
    }
}

#pragma mark - Description of UUID

- (NSString*)descriptionOfUUID:(NSString*)uuid{
    return [self.descriptionDictionary objectForKey:uuid];
}

@end
