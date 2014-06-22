//
//  HAMDBManager.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-2-19.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMDBManager.h"
#import "HAMFileTools.h"
#import "HAMTools.h"
#import "HAMLogTool.h"

#define DBNAME @"beacon.db"
static HAMDBManager* dbManager = nil;

@implementation HAMDBManager
{
    sqlite3* database;
    //TODO: this is very not safe. change to local instance
    sqlite3_stmt* statement;
    
    Boolean dbIsOpen;
}

#pragma mark - Singleton Methods

+ (HAMDBManager*)dbManager{
    @synchronized(self) {
        if (dbManager == nil)
            dbManager = [[HAMDBManager alloc] init];
    }
    
    return dbManager;
}

- (id)init{
    if (self = [super init]) {
        dbIsOpen = false;
    }
    
    return self;
}

#pragma mark - Open & Close

-(Boolean)openDatabase
{
    if (dbIsOpen)
    {
        [HAMLogTool warn:@"Trying to open database when database is already open!"];
        return true;
    }
    
    if (sqlite3_open([[HAMFileTools filePath:DBNAME] UTF8String], &database)
        != SQLITE_OK)
    {
        sqlite3_close(database);
        [HAMLogTool error:@"Fail to open database!"];
        return false;
    }
    
    dbIsOpen=YES;
    return true;
}

-(void)closeDatabase
{
    if (!dbIsOpen)
        return;
    
    if (statement)
    {
        sqlite3_finalize(statement);
        statement=nil;
    }
    sqlite3_close(database);
    dbIsOpen=NO;
}

#pragma mark - Common Methods

-(Boolean)isDatabaseExist
{
    int rc = sqlite3_open_v2([[HAMFileTools filePath:DBNAME] UTF8String], &database, SQLITE_OPEN_READWRITE, NULL);
    if (rc == 0)
        sqlite3_close(database);
    return rc == 0;
}

-(Boolean)runSQL:(NSString*)sql
{
    char *errorMsg;
    
    [self openDatabase];
    if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &errorMsg)!=SQLITE_OK)
    {
        [HAMLogTool error:[NSString stringWithFormat:@"Run SQL '%@' fail : %s",sql,errorMsg]];
        [self closeDatabase];
        return false;
    }
    [self closeDatabase];
    return true;
}

-(NSString*)stringAt:(int)column
{
    char* text=(char*)sqlite3_column_text(statement, column);
    
    if (text)
        return [NSString stringWithUTF8String:text];
    else
        return nil;
}

-(void)bindString:(NSString*)string at:(int)column{
    sqlite3_bind_text(statement, column, [string UTF8String], -1, NULL);
}

#pragma mark - Clear & Init

- (void)clear{
    [self runSQL:@"DELETE FROM COUPON;"];
//    [self runSQL:@"DROP TABLE IF EXISTS COUPON;"];
}

- (void)initDatabase{
    [self runSQL:@"CREATE TABLE IF NOT EXISTS TESTDATA(TESTID int, ACCURACY double, RSSI int);"];
}

/*
 #pragma mark - Coupon Methods

-(void)insertCoupon:(HAMCoupon*)coupon
{
    [self openDatabase];
    
    NSString* update=[NSString stringWithFormat:@"INSERT INTO COUPON (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);",DB_COUPON_ALLFIELD];
    
    if (sqlite3_prepare_v2(database, [update UTF8String], -1, &statement, nil)==SQLITE_OK)
    {
        [self bindString:coupon.idCoupon at:1];
        [self bindString:coupon.idBid at:2];
        sqlite3_bind_int(statement, 3, [coupon.idBmajor intValue]);
        sqlite3_bind_int(statement, 4, [coupon.idBminor intValue]);
        
        sqlite3_bind_int64(statement, 5, [HAMTools longLongFromDate:coupon.timeCreated]);
        sqlite3_bind_int64(statement, 6, [HAMTools longLongFromDate:coupon.timeUpdated]);
        
        [self bindString:coupon.title at:7];
        [self bindString:coupon.thumbNail at:8];
        [self bindString:coupon.descBrief at:9];
        [self bindString:coupon.descUrl at:10];
        
        int promote = coupon.promote ? 1 : 0;
        
        sqlite3_bind_int(statement, 11, promote);
    }
    
    if (sqlite3_step(statement)!= SQLITE_DONE)
        [HAMLogTool error:@"Fail to insert into coupon!"];
    
    [self closeDatabase];
}

-(HAMCoupon*)couponFromStatement{
    HAMCouponBuilder* couponBuilder = [[HAMCouponBuilder alloc] init];
    
    couponBuilder.idCoupon = [self stringAt:0];
    couponBuilder.idBid = [self stringAt:1];
    couponBuilder.idBmajor = [NSNumber numberWithInt:sqlite3_column_int(statement, 2)];
    couponBuilder.idBminor = [NSNumber numberWithInt:sqlite3_column_int(statement, 3)];
    
    long long timeCreatedSince1970 = sqlite3_column_int64(statement, 4);
    couponBuilder.timeCreated = [HAMTools dateFromLongLong:timeCreatedSince1970];
    long long timeUpdatedSince1970 = sqlite3_column_int64(statement, 5);
    couponBuilder.timeUpdated = [HAMTools dateFromLongLong:timeUpdatedSince1970];
    
    couponBuilder.title = [self stringAt:6];
    couponBuilder.thumbNail = [self stringAt:7];
    couponBuilder.descBrief = [self stringAt:8];
    couponBuilder.descUrl = [self stringAt:9];
    
    int promote = sqlite3_column_int(statement, 10);
    couponBuilder.promote = promote == 1 ? YES : NO;
    
    return [couponBuilder build];
}

-(HAMCoupon*)couponWithID:(NSString*)couponID
{
    [self openDatabase];
    
    NSString* query = [[NSString alloc]initWithFormat:@"SELECT * FROM COUPON WHERE %@ = '%@'", DB_COUPON_IDCOUPON, couponID];
    int result = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    if (result != SQLITE_OK)
    {
        [HAMLogTool error:@"Fail to select from Coupon!"];
        [self closeDatabase];
        return nil;
    }
    
    sqlite3_step(statement);
    return [self couponFromStatement];
}

-(HAMCoupon*)couponWithBeaconID:(NSString*)beaconID major:(NSNumber*)major minor:(NSNumber*)minor
{
    if (beaconID == nil || major == nil || minor == nil) {
        return nil;
    }
    
    [self openDatabase];
    
    NSString* query = [[NSString alloc]initWithFormat:@"SELECT * FROM COUPON WHERE %@ = '%@' AND %@ = %@ AND %@ = %@", DB_COUPON_IDBID, beaconID, DB_COUPON_IDBMAJOR, major, DB_COUPON_IDBMINOR, minor];
    int result = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    if (result != SQLITE_OK)
    {
        [HAMLogTool error:@"Fail to select from Coupon!"];
        [self closeDatabase];
        return nil;
    }

    sqlite3_step(statement);
    HAMCoupon* coupon = [self couponFromStatement];
    
    if (sqlite3_step(statement) == SQLITE_ROW) {
        [HAMLogTool warn:[NSString stringWithFormat: @"Duplicate coupon found with bid:%@ major:%@ minor:%@", beaconID, major, minor]];
    }
    
    return coupon;
}*/


#pragma mark - Beacon Methods

@end