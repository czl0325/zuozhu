//
//  WaitTooles.h
//  YueXingKong
//
//  Created by zhaoliang.chen on 12-11-28.
//  Copyright (c) 2012年 YueXingKong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface WaitTooles : NSObject

+ (NSString *)Date2StrV:(NSDate *)indate;
+ (NSString *)Date2Str:(NSDate *)indate;
+ (void)MsgBox:(NSString *)msg;

+ (NSDateComponents *)DateInfo:(NSDate *)indate;

+ (void)OpenUrl:(NSString *)inUrl;

+ (void)showHUD:(NSString *)msg;
+ (void)showHUD:(NSString *)msg detail:(NSString *)detail;
+ (void)showHUDLoading:(NSString *)msg;
+ (void)removeHUD;

@end
