//
//  YXPopupView.h
//  zuozhu
//
//  Created by zyhang on 2/17/14.
//  Copyright (c) 2014 zhaoliang.chen. All rights reserved.
//

#import "YXBaseView.h"
#import "TDImageScrollView.h"

@interface YXPopupView : YXBaseView{
    NSDictionary *config_;
    UIButton *button_;
    UIView *popup_;
}

- (id)initWithParameter:(NSDictionary*)dic;

@end
