//
//  WaitTooles.m
//  YueXingKong
//
//  Created by zhaoliang.chen on 12-11-28.
//  Copyright (c) 2012年 YueXingKong. All rights reserved.
//

#import "WaitTooles.h"

#define MsgBox(msg) [self MsgBox:msg]

@implementation WaitTooles

static MBProgressHUD *HUD = nil;
//程序中使用的，将日期显示成  2011年4月4日 星期一
+ (NSString *) Date2StrV:(NSDate *)indate{    
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]]; //setLocale 方法将其转为中文的日期表达
	dateFormatter.dateFormat = @"yyyy '-' MM '-' dd ' ' EEEE";
	NSString *tempstr = [dateFormatter stringFromDate:indate];
	return tempstr;
}

//程序中使用的，提交日期的格式
+ (NSString *) Date2Str:(NSDate *)indate{	
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
	dateFormatter.dateFormat = @"yyyyMMdd";
	NSString *tempstr = [dateFormatter stringFromDate:indate];
	return tempstr;
}

//提示窗口
+ (void)MsgBox:(NSString *)msg{
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg
												   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

//获得日期的具体信息，本程序是为获得星期，注意！返回星期是 int 型，但是和中国传统星期有差异
+ (NSDateComponents *) DateInfo:(NSDate *)indate{
    
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	//NSDateComponents *comps = [[NSDateComponents alloc] init];
	NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
	NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
	NSDateComponents *comps = [calendar components:unitFlags fromDate:indate];
	
	return comps;
    
    //	week = [comps weekday];
    //	month = [comps month];
    //	day = [comps day];
    //	hour = [comps hour];
    //	min = [comps minute];
    //	sec = [comps second];
    
}


//打开一个网址
+ (void) OpenUrl:(NSString *)inUrl{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:inUrl]];
}



//MBProgressHUD 的使用方式，只对外两个方法，可以随时使用(但会有警告！)，其中窗口的 alpha 值 可以在源程序里修改。
+ (void)showHUD:(NSString *)msg{
	if (HUD) {
        return;
    }
    
	HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    HUD.mode = MBProgressHUDModeText;
	[[UIApplication sharedApplication].keyWindow addSubview:HUD];
	HUD.labelText = msg;
	[HUD show:YES];
}

+ (void)showHUD:(NSString *)msg detail:(NSString *)detail{
	if (HUD) {
        return;
    }
    
	HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    HUD.mode = MBProgressHUDModeText;
	[[UIApplication sharedApplication].keyWindow addSubview:HUD];
	HUD.labelText = msg;
    HUD.detailsLabelText = detail;
	[HUD show:YES];
}

+ (void)showHUDLoading:(NSString *)msg{
	if (HUD) {
        return;
    }
    
	HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    HUD.mode = MBProgressHUDModeIndeterminate;
	[[UIApplication sharedApplication].keyWindow addSubview:HUD];
	HUD.labelText = msg;
	[HUD show:YES];
}


+ (void)removeHUD{	
	[HUD hide:YES];
	[HUD removeFromSuperViewOnHide];
    HUD = nil;
}


@end
