//
//  UITools.h
//  PetClaw
//
//  Created by yihang zhuang on 11/1/12.
//  Copyright (c) 2012 ZQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "NSDate-Utilities.h"

//UINavigationController *gNav;

UIFont *getDefaultFont( int size );

NSString *getBundlePath(NSString *fileName);

UIImage *getBundleImage(NSString *imageName);
UIImageView *getImageViewByImageName( NSString *fileName );
UIScrollView *createScrollImageViewByImage(NSString *imageName);
//UIButton
UIButton *createButton(NSString *imageName);
UIButton *createButtonBySize(CGSize size, UIView *superView);
UIButton *createButtonByImage(NSString *imageName, UIView *superView);
UIButton *createButtonByPortrait(UIImageView *v);
UIButton *getButtonByImageName( NSString *fileName );
UIButton *getButtonBigResponse( NSString *fileName, float big );

//UIImageView
UIImageView *createImageViewByImage(NSString *imageName);
UIImageView *createPortraitView( int size );
UIImageView * createPortraitViewRadius( int size );
UIImageView *createPortraitView1( int size, UIColor* color );
UIImageView *createPortraitView2( CGSize size, UIColor* color );
UIImageView *createPortraitView3(int size);

//UILabel
UILabel* createLabel(NSString* str);
UILabel* createNavTitle(NSString* str);
UILabel* createButtonLabel(NSString* str);

//UIColor
UIColor *getRandomColor();
UIColor *getColor( int r, int g, int b, int a );

//UITextField
UITextField* createTextField();

//date
NSString *formatDateToString( NSDate *date );
NSString *formatDateToStringALL( NSDate *date );
NSDate *formatStringToDate( NSString *string );
NSDate *formatStringToDateEx( NSString *string );


NSString *get_cache_directory();
NSString *get_thumbPic_Path();
BOOL file_exists( NSString *filePath );

NSString* getPicNameALL(NSString* str) ;


NSString *genRandomString(int length);

UIImage *roundCorners(UIImage* img);
void addRoundedRectToPath(CGContextRef context, CGRect rect,
                          float ovalWidth,float ovalHeight);


CGRect getFrame(NSDictionary* dic);

void RunBlockAfterDelay(NSTimeInterval delay, void (^block)(void));
