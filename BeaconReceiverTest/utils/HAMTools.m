//
//  HAMTools.m
//  iosapp
//
//  Created by daiyue on 13-7-30.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMTools.h"
#import "HAMLogTool.h"
#import "Reachability.h"

#define COMMON_DATEFORMAT @"yyyy-MM-dd HH:mm:ss zzz"
#define JSON_DATEFORMAT @""

@implementation HAMTools

#pragma mark - Collection

+(void)setObject:(id)object toMutableArray:(NSMutableArray*)array atIndex:(int)pos
{
    long i;
    for (i = [array count]; i < pos; i++)
        [array addObject:[NSNull null]];
    [array setObject:object atIndexedSubscript:pos];
}

#pragma mark - Data Formatting

+(NSDictionary*)jsonFromData:(NSData*)data
{
    NSError* error;
    NSDictionary* dic = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:kNilOptions
                          error:&error];
    
    if (error)
        [HAMLogTool error:[NSString stringWithFormat:@"Json parse failed : %@", error]];
    
    return dic;
}

+(NSNumber*)intNumberFromString:(NSString*)string{
    return [NSNumber numberWithInt:[string intValue]];
};

+(NSString*)stringFromDate:(NSDate*)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:COMMON_DATEFORMAT];
    
    return [dateFormatter stringFromDate:date];
}

+(NSDate*)dateFromString:(NSString*)dateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:COMMON_DATEFORMAT];
    
    return [dateFormatter dateFromString:dateString];
}

+(NSDate*)dateFromLongLong:(long long)msSince1970{
    return [NSDate dateWithTimeIntervalSince1970:msSince1970 / 1000];
}

+(long long)longLongFromDate:(NSDate*)date{
    return [date timeIntervalSince1970] * 1000;
}

+(Boolean)Number:(NSNumber*)number isEqualToInt:(int)intNumber{
    return number.intValue == intNumber;
}

#pragma mark - View

+(void)showAlert:(NSString*)text title:(NSString*)title delegate:(id)target{
    UIAlertView* alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:text
                          delegate:target
                          cancelButtonTitle:@"返回"
                          otherButtonTitles:nil];
    [alert show];
}

+(void)showAlert:(NSString*)text title:(NSString*)title buttonTitle:(NSString*)buttonTitle delegate:(id)target{
    UIAlertView* alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:text
                          delegate:target
                          cancelButtonTitle:@"返回"
                          otherButtonTitles:buttonTitle,nil];
    [alert show];
}

#pragma mark - Web Methods

+(Boolean) isWebAvailable {
    return ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus] != NotReachable);
}

@end