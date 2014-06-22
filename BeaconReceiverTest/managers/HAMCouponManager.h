//
//  HAMCouponManager.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-2-20.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HAMCoupon;

@interface HAMCouponManager : NSObject

+ (HAMCouponManager*)couponManager;

+ (HAMCoupon*)couponWithID:(NSString*)couponID;
+ (HAMCoupon*)couponWithBeaconID:(NSString*)beaconID major:(NSNumber*)major minor:(NSNumber*)minor;

+ (void)syncWithServer;

@end
