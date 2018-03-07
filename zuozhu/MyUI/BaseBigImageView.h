//
//  BaseBigImageView.h
//  XieJin
//
//  Created by zhaoliang.chen on 13-12-6.
//  Copyright (c) 2013年 zyhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXBaseView.h"

@interface BaseBigImageView : YXBaseView
<UIGestureRecognizerDelegate>{
    UIImageView* _bigImageView;
    
    //手势专用参数
    float lastScale;
    float lastRotate;
    float lastX;
    float lastY;
    float totalScale_;
    float currentRotate;
}


@end
