//
//  ProductObject.h
//  zuozhu
//
//  Created by qucheng on 9/4/13.
//  Copyright (c) 2013 zhaoliang.chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductObject : NSObject

//@property(nonatomic,assign)int Seq;
@property(nonatomic,assign)BOOL isCollect;
@property(nonatomic,assign)int seq;
@property(nonatomic,strong)UIImage* img;
@property(nonatomic,assign)int type;

@end
