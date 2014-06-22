//
//  HAMCoupon.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-2-19.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HAMTools.h"

@interface HAMCoupon : NSObject
{
}

@property NSString* idCoupon;
@property NSString* idBid;
@property NSNumber* idBmajor;
@property NSNumber* idBminor;

@property NSDate* timeCreated;
@property NSDate* timeUpdated;

@property NSString* title;
@property NSString* thumbNail;
@property NSString* descBrief;
@property NSString* descUrl;

@property Boolean promote;

+ (HAMCoupon*) couponFromJSON:(NSDictionary*)json;

@end

@interface HAMCouponBuilder : NSObject
{
}

@property NSString* idCoupon;
@property NSString* idBid;
@property NSNumber* idBmajor;
@property NSNumber* idBminor;

@property NSDate* timeCreated;
@property NSDate* timeUpdated;

@property NSString* title;
@property NSString* thumbNail;
@property NSString* descBrief;
@property NSString* descUrl;

@property Boolean promote;

- (HAMCoupon*) build;

@end