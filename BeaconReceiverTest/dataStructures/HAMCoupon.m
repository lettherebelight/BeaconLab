//
//  HAMCoupon.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-2-19.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMCoupon.h"
#import "HAMLogTool.h"

#define JSON_COUPON_IDCOUPON @"id_coupon"
#define JSON_COUPON_IDBID @"id_bid"
#define JSON_COUPON_IDBMAJOR @"id_bmajor"
#define JSON_COUPON_IDBMINOR @"id_bminor"

#define JSON_COUPON_TIMECREATED @"time_created"
#define JSON_COUPON_TIMEUPDATED @"time_updated"

#define JSON_COUPON_TITLE @"title"
#define JSON_COUPON_THUMBNAIL @"tumbnail"
#define JSON_COUPON_DESCBRIEF @"desc_brief"
#define JSON_COUPON_DESCURL @"desc_url"

#define JSON_COUPON_PROMOTE @"promote"

@implementation HAMCoupon

@synthesize idCoupon;
@synthesize idBid;
@synthesize idBmajor;
@synthesize idBminor;

@synthesize timeCreated;
@synthesize timeUpdated;

@synthesize title;
@synthesize thumbNail;
@synthesize descBrief;
@synthesize descUrl;

@synthesize promote;

#pragma mark - Build Methods

+ (HAMCoupon*) couponFromJSON:(NSDictionary*)dic{
    HAMCouponBuilder* builder = [[HAMCouponBuilder alloc] init];
    
    builder.idCoupon = [[dic objectForKey:JSON_COUPON_IDCOUPON] stringValue];
    //TODO: remove this
    builder.idBid = [[dic objectForKey:JSON_COUPON_IDBID] uppercaseString];
    builder.idBmajor = [HAMTools intNumberFromString:[dic objectForKey:JSON_COUPON_IDBMAJOR]];
    builder.idBminor = [HAMTools intNumberFromString:[dic objectForKey:JSON_COUPON_IDBMINOR]];
    
    long long timeCreatedSince1970 = [[dic objectForKey:JSON_COUPON_TIMECREATED] longLongValue];
    builder.timeCreated = [HAMTools dateFromLongLong:timeCreatedSince1970];
    long long timeUpdatedSince1970 = [[dic objectForKey:JSON_COUPON_TIMEUPDATED] longLongValue];
    builder.timeUpdated = [HAMTools dateFromLongLong:timeUpdatedSince1970];
    
    builder.title = [dic objectForKey:JSON_COUPON_TITLE];
    builder.thumbNail = [dic objectForKey:JSON_COUPON_THUMBNAIL];
    builder.descBrief = [dic objectForKey:JSON_COUPON_DESCBRIEF];
    builder.descUrl = [dic objectForKey:JSON_COUPON_DESCURL];
    
    id promote = [dic objectForKey:JSON_COUPON_PROMOTE];
    builder.promote = (promote == nil || [promote integerValue] != 1)? NO : YES;
    
    HAMCoupon* coupon = [builder build];
    if (coupon == nil) {
        [HAMLogTool warn:[NSString stringWithFormat: @"Build coupon from JSON failed. JSON : %@",dic]];
    }
    return coupon;
}

@end

@implementation HAMCouponBuilder

@synthesize idCoupon;
@synthesize idBid;
@synthesize idBmajor;
@synthesize idBminor;

@synthesize timeCreated;
@synthesize timeUpdated;

@synthesize title;
@synthesize thumbNail;
@synthesize descBrief;
@synthesize descUrl;

@synthesize promote;

- (id)init{
    if (self = [super init]) {
        promote = NO;
    }
    return self;
}

- (Boolean) isValidCoupon{
    if (!idBid || !idBmajor || !idBminor || !idCoupon)
        return false;
    
    if (!timeCreated || !timeUpdated)
        return false;
    
    if ([timeUpdated compare:timeCreated] == NSOrderedAscending){
        [HAMLogTool warn:@"Coupon timeUpdated is before timeCreated."];
        timeUpdated = timeCreated;
    }
    
    return true;
}

- (HAMCoupon*) build{
    if (![self isValidCoupon]){
        [HAMLogTool warn:@"Fail to build coupon."];
        return nil;
    }
    
    HAMCoupon* coupon = [[HAMCoupon alloc] init];
    
    coupon.idCoupon = idCoupon;
    coupon.idBid = idBid;
    coupon.idBmajor = idBmajor;
    coupon.idBminor = idBminor;
    
    coupon.timeCreated = timeCreated;
    coupon.timeUpdated = timeUpdated;
    
    coupon.title = title;
    coupon.thumbNail = thumbNail;
    coupon.descBrief = descBrief;
    coupon.descUrl = descUrl;
    
    coupon.promote = promote;
    
    return coupon;
}

@end
