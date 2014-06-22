//
//  HAMBeaconDictionary.h
//  BeaconReceiverTest
//
//  Created by Dai Yue on 14-5-11.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface HAMBeaconDictionary : NSObject
{}

-(void)setValue:(id)value forBeacon:(CLBeacon *)beacon;
-(id)objectForBeacon:(CLBeacon*)beacon;

@end
