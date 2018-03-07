//
//  YXBaseView.h
//  zuozhu
//
//  Created by zhaoliang.chen on 13-12-16.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YXBaseView : UIView {
    UIView* _bgview;
    CGRect oldRect;
}

- (id)initWithParameter:(NSDictionary*)dic;
- (void)getOldRect:(NSDictionary*)parameter;
- (void)removeSelf;

@end
