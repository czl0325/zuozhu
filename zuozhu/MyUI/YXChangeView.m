//
//  YXChangeView.m
//  zuozhu
//
//  Created by zhaoliang.chen on 14-2-7.
//  Copyright (c) 2014年 zhaoliang.chen. All rights reserved.
//

#import "YXChangeView.h"

@implementation YXChangeView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithParameter:(NSDictionary*)dic {
    NSString* w = [dic objectForKey:@"width"];
    _dicArray = [dic objectForKey:@"array"];
    NSDictionary* d = [_dicArray objectAtIndex:0];
    UIImage* img = getBundleImage([d objectForKey:@"image"]);
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
        bigImage = [[UIImageView alloc]initWithFrame:self.bounds];
        bigImage.contentMode = UIViewContentModeScaleAspectFill;
        bigImage.userInteractionEnabled = YES;
        [self addSubview:bigImage];
        
        float btX = [[dic objectForKey:@"btX"]floatValue];
        float btY = [[dic objectForKey:@"btY"]floatValue];
        
        for (int i=0; i<_dicArray.count; i++) {
            NSDictionary* dd = [_dicArray objectAtIndex:i];
            
            UIImageView* thumb = [[UIImageView alloc]initWithImage:getBundleImage([dd objectForKey:@"thumb"])];
            thumb.left = btX;
            thumb.top = btY;
            thumb.tag = 101+i;
            thumb.userInteractionEnabled = YES;
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onChangeImage:)];
            [thumb addGestureRecognizer:tap];
            [self addSubview:thumb];
            
            btX = thumb.right+10;
            if (i==0) {
                [self onChangeImage:tap];
            }
        }
    }
    return self;
}

- (void)onChangeImage:(UITapGestureRecognizer*)sender {
    int tag = sender.view.tag;
    NSDictionary* dic = [_dicArray objectAtIndex:tag-101];
    bigImage.image = getBundleImage([dic objectForKey:@"image"]);
}

@end
