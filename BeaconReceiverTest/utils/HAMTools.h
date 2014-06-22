//
//  HAMTools.h
//  iosapp
//
//  Created by daiyue on 13-7-30.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HAMTools : NSObject
{}

+(void)setObject:(id)object toMutableArray:(NSMutableArray*)array atIndex:(int)pos;

+(NSDictionary*)jsonFromData:(NSData*)data;

+(NSNumber*)intNumberFromString:(NSString*)string;

+(NSString*)stringFromDate:(NSDate*)date;
+(NSDate*)dateFromString:(NSString*)dateString;
+(NSDate*)dateFromLongLong:(long long)msSince1970;
+(long long)longLongFromDate:(NSDate*)date;

+(void)showAlert:(NSString*)text title:(NSString*)title delegate:(id)target;
+(void)showAlert:(NSString*)text title:(NSString*)title buttonTitle:(NSString*)buttonTitle delegate:(id)target;

+(Boolean)isWebAvailable;

@end
