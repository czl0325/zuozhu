//
//  YXBigImageView.h
//  XieJin
//
//  Created by zhaoliang.chen on 13-12-10.
//  Copyright (c) 2013年 zyhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXBaseView.h"

@interface YXBigImageView : YXBaseView {
    UIImageView* imageView;
    NSDictionary* _dic;
    NSDictionary* _event;
}

- (id)initWithParameter:(NSDictionary*)dic;

@end
