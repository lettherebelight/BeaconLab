//
//  HAMCouponManager.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-2-20.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMCouponManager.h"

#import "HAMCoupon.h"

#import "HAMWebTool.h"
#import "HAMDBManager.h"
#import "HAMTools.h"
#import "HAMLogTool.h"

static NSString* const kURLCoupon = @"http://115.28.129.14/1/coupons";

static HAMCouponManager* couponManager = nil;

@implementation HAMCouponManager

#pragma mark - Singleton Methods

+ (HAMCouponManager*)couponManager{
    @synchronized(self) {
        if (couponManager == nil)
            couponManager = [[HAMCouponManager alloc] init];
    }
    
    return couponManager;
}

- (id)init{
    if (self = [super init]) {
    }
    
    return self;
}

#pragma mark - Coupon Methods

+ (HAMCoupon*)couponWithID:(NSString*)couponID{
    HAMDBManager* dbManager = [HAMDBManager dbManager];
    HAMCoupon* coupon = [dbManager couponWithID:couponID];
    if (coupon == nil)
        [HAMLogTool warn:[NSString stringWithFormat: @"Coupon not found with id : %@", couponID]];
    return coupon;
}

+ (HAMCoupon*)couponWithBeaconID:(NSString*)beaconID major:(NSNumber*)major minor:(NSNumber*)minor{
    HAMDBManager* dbManager = [HAMDBManager dbManager];
    HAMCoupon* coupon = [dbManager couponWithBeaconID:beaconID major:major minor:minor];
    if (coupon == nil)
        [HAMLogTool warn:[NSString stringWithFormat: @"Coupon not found with beaconID : %@", beaconID]];
    return coupon;
}

#pragma mark - Sync Methods

+ (void)syncWithServer{
    if (!couponManager) {
        [HAMCouponManager couponManager];
    }
    
    [couponManager syncWithServer];
}

- (void)syncWithServer{
    [HAMLogTool info:@"Start sync coupon data."];
    
    [HAMWebTool fetchDataFromUrl:kURLCoupon sel:@selector(parseCouponData:) handle:self];
    
    //NSString* mockCoupons = @"[{\"id_coupon\": 1,\"id_bid\": \"beacon id 111\",\"id_bmajor\": \"beacon major id 111\",\"id_bminor\": \"beacon minor id 111\",\"time_created\": 1390199981160,\"time_updated\": 1390199983160,\"title\": \"D22狂欢夜\",\"thumbnail\": \"http://www.icoupon.com/coupon/111/thumbnail\",\"desc_brief\": \"D22狂欢夜，凭卷免单一杯啤酒，女士免费入场\",\"desc_url\": \"http://www.icoupon.com/coupon/111\",\"promote\": true},{\"id_coupon\": 2,\"id_bid\": \"beacon id 222\",\"id_bmajor\": \"beacon major id 222\",\"id_bminor\": \"beacon minor id 222\",\"time_created\": 1390199961160,\"time_updated\": 1390199973160,\"title\": \"刺猬专场\",\"thumbnail\": \"http://www.icoupon.com/coupon/222/thumbnail\",\"desc_brief\": \"刺猬专场，凭卷消费85折\",\"desc_url\": \"http://www.icoupon.com/coupon/222\"}]";
    
//    [self parseCouponData:[mockCoupons dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)parseCouponData:(NSData*)data{
    [HAMLogTool info:@"Got coupon data from server. Start parsing."];
    NSDictionary* dictionary = [HAMTools jsonFromData:data];
    
    [HAMLogTool info:@"Got parsed coupon data. Start clear & insert into database."];
    HAMDBManager* dbManager = [HAMDBManager dbManager];
    //TODO: move to appdelegate
    [dbManager clear];
    [dbManager initDatabase];
    
    NSEnumerator *enumerator = [dictionary objectEnumerator];
    NSDictionary* couponDictionary;
    
    NSMutableArray* couponArray = [NSMutableArray array];
    
    while ((couponDictionary = [enumerator nextObject])) {
        HAMCoupon* coupon = [HAMCoupon couponFromJSON:couponDictionary];
        if (coupon != nil)
            [couponArray addObject:coupon];
        else{
            [HAMLogTool warn:@"Sync faild : Coupon data not valid."];
            return;
        }
    }
    
    for (HAMCoupon* coupon in couponArray) {
        [dbManager insertCoupon:coupon];
    }
    [HAMLogTool info:@"Sync coupon data succeeded."];
}

@end
