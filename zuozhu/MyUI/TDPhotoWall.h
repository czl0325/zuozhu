//
//  TDPhotoWall.h
//  MyUIOne
//
//  Created by zhaoliang.chen on 13-11-1.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXBaseView.h"

@interface TDPhotoWall : UIScrollView
<UIScrollViewDelegate,UIGestureRecognizerDelegate> {
    NSArray* picArray;
    UIImageView* m_ImageView;
    BOOL isBig;
    BOOL isChange;
    BOOL isBigPic;
    
    UIImageView* rope;
    UIImageView* clip;
    
    NSMutableArray *subArray;//存放叠在一起的图片中，位于底层的图
}

- (id)initWithParameter:(NSDictionary *)parameter;

@end
