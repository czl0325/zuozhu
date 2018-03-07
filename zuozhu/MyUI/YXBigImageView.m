//
//  YXBigImageView.m
//  XieJin
//
//  Created by zhaoliang.chen on 13-12-10.
//  Copyright (c) 2013年 zyhang. All rights reserved.
//

#import "YXBigImageView.h"
#import "BaseBigImageView.h"

@implementation YXBigImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithParameter:(NSDictionary*)dic {
    _dic = dic;
    _event = nil;
    NSString* w = [dic objectForKey:@"width"];
    UIImage* img = getBundleImage([dic objectForKey:@"image"]);
    if (w) {
        self = [self initWithFrame:getFrame(dic)];
    } else {
        self = [self initWithFrame:CGRectZero];
        self.left = [[dic objectForKey:@"x"]floatValue];
        self.top = [[dic objectForKey:@"y"]floatValue];
        self.width = img.size.width;
        self.height = img.size.height;
    }
    if (self) {
        imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        imageView.image = getBundleImage([dic objectForKey:@"image"]);
        imageView.userInteractionEnabled = YES;
        [self addSubview:imageView];
        _event = [dic objectForKey:@"event"];
        if (_event) {
            if (![_event objectForKey:@"notip"]) {
                NSString *className = [_event objectForKey:@"class"];
                if ([className isEqualToString:@"YXImageScrollView"] || [className isEqualToString:@"PicturesAtias"]) {
                    UIImageView* shou = createImageViewByImage(@"touchIcon1.png");
                    if ([_event objectForKey:@"adjustbt"]) {
                        shou.center = CGPointMake(imageView.right-10, imageView.bottom-10);
                    } else {
                        shou.right = imageView.width-10;
                        shou.bottom = imageView.height-5;
                    }
                    [imageView addSubview:shou];
                } else if ([className isEqualToString:@"TDPerspective"]||[className isEqualToString:@"TDRotateView"]) {
                    UIImageView* shou = createImageViewByImage(@"touchIcon2.png");
                    if ([_event objectForKey:@"adjustbt"]) {
                        shou.center = CGPointMake(imageView.right-10, imageView.bottom-10);
                    } else {
                        shou.right = imageView.width-10;
                        shou.bottom = imageView.height-5;
                    }
                    [imageView addSubview:shou];
                }
            }
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ontag)];
            [imageView addGestureRecognizer:tap];
        }
    }
    return self;
}

- (void)ontag {
    NSString *className = [_event objectForKey:@"class"];
    YXBaseView *v = [[NSClassFromString(className) alloc] initWithParameter:[_event objectForKey:@"parameter"]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showEffect" object:v];
}

@end
