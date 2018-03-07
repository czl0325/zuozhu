//
//  UITools.m
//  PetClaw
//
//  Created by yihang zhuang on 11/1/12.
//  Copyright (c) 2012 ZQ. All rights reserved.
//

#import "UITools.h"

#pragma mark UIFont
UIFont *getDefaultFont( int size ){
    return [UIFont systemFontOfSize:size];
}

NSString *getBundlePath(NSString *fileName){
    NSString *filePath = [[NSBundle mainBundle]
                          pathForResource:fileName ofType:nil];
    return  filePath;
}

#pragma mark UIImage
UIImage *getBundleImage(NSString *imageName){
    NSString *path = getBundlePath(imageName);
    UIImage *img = [UIImage imageWithContentsOfFile:path];
    return img;
}

UIImageView *getImageViewByImageName( NSString *fileName ){
    UIImage *img = getBundleImage(fileName);
    return [[UIImageView alloc] initWithImage:img];
}

#pragma mark UIButton
UIButton *createButton(NSString *imageName){
    NSString *path = [[NSBundle mainBundle] pathForResource:imageName
                                                     ofType:nil];
    UIImage *img = [UIImage imageWithContentsOfFile:path];
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    [b setImage:img forState:UIControlStateNormal];
    
    return b;
}

UIButton *createButtonBySize(CGSize size, UIView *superView){
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.frame = CGRectMake(0, 0, size.width, size.height);
    [superView addSubview:b];
    
    //todo: temp color
    b.backgroundColor = [UIColor grayColor];
    
    return b;
}

UIButton *createButtonByImage(NSString *imageName, UIView *superView){
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = getBundleImage(imageName);
    b.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    [b setImage:img forState:UIControlStateNormal];
    [superView addSubview:b];
    return b;
}

UIButton *createButtonByPortrait(UIImageView *v) {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.frame = CGRectMake(0, 0, v.frame.size.width, v.frame.size.height);
    b.backgroundColor = [UIColor clearColor];
    [b setBackgroundImage:v.image forState:UIControlStateNormal];
    return b;
}

UIButton *getButtonByImageName( NSString *fileName ){
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = getBundleImage(fileName);
    b.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    [b setBackgroundImage:img forState:UIControlStateNormal];
    return b;
}

UIButton *getButtonBigResponse( NSString *fileName, float big ){
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = getBundleImage(fileName);
    b.frame = CGRectMake(0, 0, img.size.width+big, img.size.height+big);
    [b setImage:img forState:UIControlStateNormal];
    return b;
}

#pragma mark UIImageView
UIImageView *createImageViewByImage(NSString *imageName){
    UIImage *img = getBundleImage(imageName);
    UIImageView *imageV = [[UIImageView alloc] initWithImage:img];
    return imageV;
}

UIScrollView *createScrollImageViewByImage(NSString *imageName){
    UIImage *img = getBundleImage(imageName);
    UIImageView *imageV = [[UIImageView alloc] initWithImage:img];
    UIScrollView *s = [[UIScrollView alloc] initWithFrame:imageV.bounds];
    [s addSubview:imageV];
    s.contentSize = CGSizeMake(imageV.width, imageV.height);
    s.bounces = NO;
    return s;
}

UIImageView *createPortraitView( int size ){
    UIImageView *v = [[UIImageView alloc] initWithFrame:
                      CGRectMake(0, 0, size, size)];
    v.layer.borderWidth = 1;
    v.layer.borderColor = [UIColor clearColor].CGColor;
    //v.layer.cornerRadius = size/6;
    v.clipsToBounds = YES;
    return v;
}

UIImageView *createPortraitViewRadius( int size ){
    UIImageView *v = [[UIImageView alloc] initWithFrame:
                      CGRectMake(0, 0, size, size)];
    v.layer.borderWidth = 1;
    v.layer.borderColor = [UIColor clearColor].CGColor;
    v.layer.cornerRadius = size/6;
    v.clipsToBounds = YES;
    return v;
}

UIImageView *createPortraitView1( int size, UIColor* color ){
    UIImageView *v = [[UIImageView alloc] initWithFrame:
                      CGRectMake(0, 0, size, size)];
    v.layer.borderWidth = 1;
    v.layer.borderColor = color.CGColor;
    v.layer.cornerRadius = size/6;
    v.clipsToBounds = YES;
    return v;
}

UIImageView *createPortraitView2( CGSize size, UIColor* color ) {
    UIImageView *v = [[UIImageView alloc] initWithFrame:
                       CGRectMake(0, 0, size.width, size.height)];
    v.layer.borderWidth = 1;
    v.layer.borderColor = color.CGColor;
    v.layer.cornerRadius = size.width/40;
    v.clipsToBounds = YES;
    return v;
}

UIImageView *createPortraitView3(int size) {
    UIImageView *v = [[UIImageView alloc] initWithFrame:
                       CGRectMake(0, 0, size, size)];
    v.clipsToBounds = YES;
    return v;
}

#pragma mark UILabel
UILabel* createLabel(NSString* str){
    UILabel *l = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 15)];
    l.font = [UIFont boldSystemFontOfSize:15];
    l.backgroundColor = [UIColor clearColor];
    l.textColor = [UIColor whiteColor];
    l.textAlignment = NSTextAlignmentLeft;
    l.text = str;
    return l;
}

UILabel* createNavTitle(NSString* str){    
    UILabel* title = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 26)];
    title.backgroundColor = [UIColor clearColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont fontWithName:@"Helvetica-Bold" size:22];
    title.shadowColor = [UIColor whiteColor];
    title.shadowOffset = CGSizeMake(0, -1.0);
    title.text = str;
    return title;
}

UILabel* createButtonLabel(NSString* str) {
    UILabel* title = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 26)];
    title.backgroundColor = [UIColor clearColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor grayColor];
    title.font = [UIFont systemFontOfSize:22];
    title.text = str;
    title.width = [title.text sizeWithFont:title.font].width;
    return title;
}


#pragma mark UIColor
UIColor *getRandomColor(){
    float r = arc4random()%255/255.0;
    float g = arc4random()%255/255.0;
    float b = arc4random()%255/255.0;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

UIColor *getColor( int r, int g, int b, int a ){
    float fr = r%255/255.0;
    float fg = g%255/255.0;
    float fb = b%255/255.0;
    
    return [UIColor colorWithRed:fr green:fg blue:fb alpha:1.0];
}

#pragma mark UITextField
UITextField* createTextField() {
    UITextField* t = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 230, 30)];
    [t setBorderStyle:UITextBorderStyleNone]; //外框类型
    t.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    return t;
}

#pragma mark date
NSString *formatDateToString( NSDate *date ){
    NSString *s = [NSString stringWithFormat:@"%04d-%02d-%02d",
                   date.year,date.month,date.day];
    return s;
}

NSString *formatDateToStringALL( NSDate *date ){
    NSString *s = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d",
                   date.year,date.month,date.day,date.hour,date.minute,date.seconds];
    return s;
}

NSDate *formatStringToDate( NSString *string ){
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:string];
    return date;
}

NSDate *formatStringToDateEx( NSString *string ){
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormat dateFromString:string];
    
    return date;
}

NSString *get_cache_directory() {
    NSString*path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                         NSUserDomainMask, YES) lastObject];
    path = [NSString stringWithFormat:@"%@/save",path];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

NSString *get_thumbPic_Path() {
    NSString*path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES) lastObject];
    path = [NSString stringWithFormat:@"%@/activity",path];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}


BOOL file_exists( NSString *filePath ) {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:filePath];
}

NSString* getPicNameALL(NSString* str) {
    if (str.length == 0) {
        return str;
    }
    
    if ([str hasPrefix:@"/Users"] || [str hasPrefix:@"/var"]) {
        return str;
    }
    
    NSString* s = [NSString stringWithFormat:@"http://121.199.53.25/dayetang/%@",str];
    s = [s stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return s;
}


NSString *genRandomString(int length){
    static NSString* list = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *str = [NSMutableString string];
    for (int i = 0; i < length; i++) {
        NSString *s = [list substringWithRange:NSMakeRange(arc4random()%list.length, 1)];
        [str appendString:s];
    }
    
    return str;
}


UIImage *roundCorners(UIImage* img){
    int w = img.size.width;
    int h = img.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    CGContextBeginPath(context);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    addRoundedRectToPath(context, rect, 10, 10);
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return [UIImage imageWithCGImage:imageMasked];
}

void addRoundedRectToPath(CGContextRef context, CGRect rect,
                                 float ovalWidth,float ovalHeight) {
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect),
                           CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

CGRect getFrame(NSDictionary* dic) {
    return CGRectMake([[dic objectForKey:@"x"]floatValue], [[dic objectForKey:@"y"]floatValue], [[dic objectForKey:@"width"]floatValue], [[dic objectForKey:@"height"]floatValue]);
}

void RunBlockAfterDelay(NSTimeInterval delay, void (^block)(void)){
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*delay),
                   dispatch_get_current_queue(), block);
}