//
//  HAMDBManager.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-2-19.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class HAMCoupon;

@interface HAMDBManager : NSObject

+(HAMDBManager*)dbManager;

- (void)clear;
- (void)initDatabase;

- (Boolean)runSQL:(NSString*)sql;

@end