//
//  HAMBeaconManager.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-2-26.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol HAMBeaconObserver <NSObject>

@optional
-(void)didStartRanging;
-(void)didRangeBeacons:(NSArray *)beacons ofUUID:(NSString*)uuid;
-(void)didRangeBeacon:(CLBeacon*)beacon;
-(void)didExitRegionOfUUID:(NSString*)uuid;

@end

@interface HAMBeaconManager : NSObject <CLLocationManagerDelegate>
{}

@property CLLocationManager* locationManager;
@property id<HAMBeaconObserver> observer;

+ (HAMBeaconManager*)beaconManager;

- (void)startRanging;
- (void)startRangingWithUUID:(NSString*)beaconID;

- (void)registerObserverForAll:(id<HAMBeaconObserver>)observer;
- (void)registerObserver:(id<HAMBeaconObserver>)observer forUUID:(NSString*)uuid major:(NSNumber*)major minor:(NSNumber*)minor;

- (NSString*)descriptionOfUUID:(NSString*)uuid;

@end