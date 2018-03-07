//
//  ViewObject.h
//  zuozhu
//
//  Created by zhaoliang.chen on 13-7-29.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViewObject : NSObject

@property(nonatomic,assign)CGPoint oldPt;
@property(nonatomic,strong)UIImageView* view;
@property(nonatomic,assign)int tag;
@property(nonatomic,assign)BOOL isCollect;

@end
