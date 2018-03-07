//
//  DataManager.h
//  zuozhu
//
//  Created by qucheng on 9/4/13.
//  Copyright (c) 2013 zhaoliang.chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductObject.h"

@interface DataManager : NSObject

+ (DataManager *)sharedManager;


//根据序号获得产品对象
-(ProductObject*)getProductBySeq:(int)seq;

//设置产品
-(void)setProudcts:(NSMutableArray*)products;
-(NSArray*)getProducts;

-(void)saveData:(NSMutableArray*)datas;
-(NSMutableArray*)ReadFromPlist;

//设置收藏内容
-(NSMutableArray*)getCollect;
-(void)setCollectProducts:(NSMutableArray*)collects;
//添加收藏元素
-(void)addCollectProducts:(NSMutableDictionary*)collect;
-(void)removeCollectProducts:(NSMutableDictionary*)collect;
-(void)setProductCollect:(int)Seq;

////////////////
//产品队列函数
//设置产品队列
-(void)setProductsQueue:(NSMutableArray*)datas;
//获取产品队列
-(NSMutableArray*)getProductsQueue;
//获取显示的产品
-(NSMutableArray*)getProductsShow;
//添加产品队列
-(void)addProductsQueue:(NSMutableDictionary*)collect;

//////////
//滑动函数
-(BOOL)changeFlag:(int)flag;
//元素加入队列中
-(void)addQueueItem:(NSMutableDictionary*)item;
//元素加入显示队列中
-(void)addShowQueueItem:(NSMutableDictionary*)item;
//获取显示的队列
-(NSMutableArray*)getShowQueue;
//获取未显示队列
-(NSMutableArray*)getQueue;
//按索引获取未显示队列数据
-(NSMutableDictionary*)getQueueByindex:(int)index;
//将元素移除未显示队列
-(void)removeQueueByindex:(int)index;
//从队列中获取元素
-(NSDictionary*)getCellImageFromQueue;
//获得空元素
-(NSMutableDictionary*)getBlankdic;

//获取详细页面的列表
-(NSArray*)getDetailArray;
-(void)setDetailArray:(NSArray*)array;

//获取公司简介的列表
-(NSArray*)getIntroArray;
-(void)setIntroArray:(NSArray*)array;

//空调的队列
-(NSArray*)getAirConditionArray;
-(void)setAirConditionArray:(NSArray*)array;

//汽车的队列
-(NSArray*)getCarArray;
-(void)setCarArray:(NSArray*)array;

- (NSDictionary*)getProByType;
-(void)resetArray:(int)type;

-(NSArray*)getAllprodic;
-(void)setAllprodic:(NSArray*)array;

-(BOOL)getIsShowCollect;
-(void)setIsShowCollect:(BOOL)is;

-(NSArray*)getCurrentArray;
-(void)setCurrentArray:(NSArray*)array;

@end
