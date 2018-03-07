//
//  DataManager.m
//  zuozhu
//
//  Created by qucheng on 9/4/13.
//  Copyright (c) 2013 zhaoliang.chen. All rights reserved.
//

#import "DataManager.h"
#import "ProductObject.h"

static DataManager *_sharedManager = nil;
@interface DataManager(){
    
    NSMutableArray* products_;
    
    //收藏的队列
    NSMutableArray *collectQueue_;
    NSMutableArray *collectShow_;
    
    //产品的队列
    NSMutableArray *productQueue_;
    NSMutableArray *productShow_;
    
    NSMutableDictionary *blankdict_;
    
    int changeFlag_;
    NSArray* detailArray_;
    NSArray* introArray_;
    NSArray* airConditionArray_;
    NSArray* carArray_;
    NSArray* allArray_;
    NSArray* currentArray_;
    
    BOOL isShowCollect_;
}

@end

@implementation DataManager

+ (DataManager *)sharedManager {
    @synchronized( [DataManager class] ){
        if(!_sharedManager)
            _sharedManager = [[self alloc] init];
        return _sharedManager;
    }
    return nil;
}

+ (id)alloc {
    @synchronized ([DataManager class]){
        NSAssert(_sharedManager == nil,
                 @"Attempted to allocated a second instance");
        _sharedManager = [super alloc];
        return _sharedManager;
    }
    return nil;
}

- (id)init {
    self = [super init];
    if (self) {
        srand((unsigned int)time(NULL));
        //0表示所有产品，1表示收藏产品
        changeFlag_ =0;
        collectQueue_=[[NSMutableArray alloc]init];
        collectShow_=[[NSMutableArray alloc]init];
        productQueue_=[[NSMutableArray alloc]init];
        productShow_=[[NSMutableArray alloc]init];
        products_=[[NSMutableArray alloc]init];
        
        NSString *bundlePath = [self getBundleCollectPath];
        NSString *localPath = [self getCollectPath];
        if (![[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
            NSError *err = nil;
            [[NSFileManager defaultManager] copyItemAtPath:bundlePath toPath:localPath error:&err];
        }
        isShowCollect_ = NO;
    }
    return self;
}

- (NSString *)getCollectPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *path = [docDir stringByAppendingPathComponent:@"collect.plist"];
    return path;
}

- (NSString *)getBundleCollectPath{
    return [[NSBundle mainBundle] pathForResource:@"collect" ofType:@"plist"];
}
#pragma mark - 详细产品函数
-(ProductObject*)getProductBySeq:(int)seq{
    
    return [products_ objectAtIndex:seq-1];
}

-(void)setProudcts:(NSMutableArray*)products{
    
    products_ = products;
    
}

-(void)setProductCollect:(int)Seq{
    
    ProductObject* tmp = [products_ objectAtIndex:Seq-1];
    
    tmp.isCollect = !tmp.isCollect;
    
}

-(NSArray*)getProducts {
    return products_ ;
}

#pragma mark - 收藏函数
-(void)setCollectProducts:(NSMutableArray*)collects{
    
    collectQueue_ = collects;    
}

-(NSMutableArray*)getCollect{
    
    return collectQueue_;
}


-(void)addCollectProducts:(NSMutableDictionary*)collect{
    [collectQueue_ addObject:collect];
}


-(void)removeCollectProducts:(NSMutableDictionary*)collect{
    int idx = 0;
    
    for (NSDictionary* collectdict in collectShow_) {
        if ([[collectdict objectForKey:@"Seq"]intValue]==[[collect objectForKey:@"Seq"]intValue]) {
            [collectShow_ removeObjectAtIndex:idx];
            break;
        }
        idx ++;
    }
    idx = 0;
    
    for (NSDictionary* collectdict in collectQueue_) {
        if ([[collectdict objectForKey:@"Seq"]intValue]==[[collect objectForKey:@"Seq"]intValue]) {
            [collectQueue_ removeObjectAtIndex:idx];
            break;
        }
        idx ++;
    }
}


-(void)fillcollectQueue:(int)cnt{
    
    
}


#pragma mark - 产品队列函数
-(void)setProductsQueue:(NSMutableArray*)datas{
    
    productQueue_ = datas;
    
}

-(NSMutableArray*)getProductsQueue{
    
    return productQueue_;
}

-(NSMutableArray*)getProductsShow{
    
    return productShow_;
}


-(void)addProductsQueue:(NSMutableDictionary*)collect{
    
    [productQueue_ addObject:collect];
    
}

#pragma mark - 滑动队列函数
-(BOOL)changeFlag:(int)flag{
    
    if (changeFlag_!=flag) {
        changeFlag_ = flag;
        
        
        if (changeFlag_==1) {
            [collectQueue_ addObjectsFromArray:collectShow_];
            [collectShow_ removeAllObjects];
        }
        else{
            
            [productQueue_ addObjectsFromArray:productShow_];
            [productShow_ removeAllObjects];
            
        }
        
        return YES;

    }
    
    return NO;
        
}

-(void)resetArray:(int)type {
    [productQueue_ removeAllObjects];
    if (type==1) {
        if (isShowCollect_) {
            for (int i=0; i<airConditionArray_.count; i++) {
                NSDictionary* dic = [airConditionArray_ objectAtIndex:i];
                BOOL is = NO;
                for (NSDictionary* dd in  collectQueue_) {
                    if ([[dic objectForKey:@"Seq"]intValue]==[[dd objectForKey:@"Seq"]intValue]) {
                        is = YES;
                        break;
                    }
                }
                if (is) {
                    [productQueue_ addObject:dic];
                }
            }
        } else {
            [productQueue_ addObjectsFromArray:airConditionArray_];
        }
    } else if (type==2) {
        if (isShowCollect_) {
            for (int i=0; i<carArray_.count; i++) {
                NSDictionary* dic = [carArray_ objectAtIndex:i];
                BOOL is = NO;
                for (NSDictionary* dd in  collectQueue_) {
                    if ([[dic objectForKey:@"Seq"]intValue]==[[dd objectForKey:@"Seq"]intValue]) {
                        is = YES;
                        break;
                    }
                }
                if (is) {
                    [productQueue_ addObject:dic];
                }
            }
        } else {
            [productQueue_ addObjectsFromArray:carArray_];
        }
    } else if (type==0) {
        if (isShowCollect_) {
            [productQueue_ addObjectsFromArray:collectQueue_];
//            for (int i=0; i<allArray_.count; i++) {
//                NSDictionary* dic = [allArray_ objectAtIndex:i];
//                BOOL is = NO;
//                for (NSDictionary* dd in  collectQueue_) {
//                    if ([[dic objectForKey:@"Seq"]intValue]==[[dd objectForKey:@"Seq"]intValue]) {
//                        is = YES;
//                        break;
//                    }
//                }
//                if (is) {
//                    [productQueue_ addObject:dic];
//                }
//            }
        } else {
            [productQueue_ addObjectsFromArray:allArray_];
        }
    } else if (type==1000) {
        [productQueue_ addObjectsFromArray:collectQueue_];
    }
    if (currentArray_) {
        currentArray_ = nil;
    }
    currentArray_ = [NSArray arrayWithArray:productQueue_];
    //[productShow_ removeAllObjects];
}

-(void)addQueueItem:(NSMutableDictionary*)item{
    
    //if (changeFlag_==0) {
        [self addProductsQueue:item];
    //}
    //else{
    //    [self addCollectProducts:item];
    //}
    
}

-(void)addShowQueueItem:(NSMutableDictionary*)item{
    
    //if (changeFlag_==0) {
        [productShow_ addObject:item];
    //}
    //else{
    //    [collectShow_ addObject:item];
    //}
    
}

-(NSMutableArray*)getShowQueue{
    
    //if (changeFlag_==0) {
        return productShow_;
    //}
    //else{
    //    return collectShow_;
    //}
}

-(NSMutableArray*)getQueue{
    
    //if (changeFlag_==0) {
        return productQueue_;
    //}
    //else{
    //    return collectQueue_;
    //}
}

-(NSMutableDictionary*)getQueueByindex:(int)index{
    
//    if (changeFlag_==0) {
        
        if (productQueue_.count>0) {
            return [productQueue_ objectAtIndex:index];
        }
//        
//    }
//    else{
//        if(collectQueue_.count>0){
//            return [collectQueue_ objectAtIndex:index];
//        }
//    }

    return nil;
}

-(void)removeQueueByindex:(int)index{
//    if (changeFlag_==0) {
        return [productQueue_ removeObjectAtIndex:index];
//    }
//    else{
//        return [collectQueue_ removeObjectAtIndex:index];
//    }
}


-(NSDictionary*)getCellImageFromQueue{
    NSMutableDictionary* imgD = [self getQueueByindex:0];
    //加入显示的数组中
    if (imgD) {
        [ self addShowQueueItem:imgD];
        //从未显示队列中移除
        [self removeQueueByindex:0];
    }
    return imgD;
}

#pragma mark 找到对应的type
- (NSDictionary*)getProByType {
    NSMutableDictionary* imgD = nil;
    if (productQueue_.count>0) {
        imgD = [productQueue_ objectAtIndex:0];
        //加入显示的数组中
        if (imgD) {
            [productShow_ addObject:imgD];
            //从未显示队列中移除
            [productQueue_ removeObjectAtIndex:0];
        }
    }
    return imgD;
}

-(NSMutableDictionary*)getBlankdic{
    if (!blankdict_) {
        blankdict_ = [[NSMutableDictionary alloc] init];
        
        [blankdict_ setObject:[NSNumber numberWithBool:NO]  forKey:@"Collect"];
        [blankdict_ setObject:[NSNumber numberWithInt:0]  forKey:@"Seq"];
    }
    int r = rand()%6+1;
    [blankdict_ setObject:[UIImage imageNamed:[NSString stringWithFormat:@"pic%d.jpg",r]] forKey:@"Image"];
    
    return  blankdict_;
}

-(void)saveData:(NSMutableArray*)datas{
    //建立文件管理
    //NSFileManager *fm = [NSFileManager defaultManager];
    //找到Documents文件所在的路径
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //取得第一个Documents文件夹的路径
    NSString *filePath = [path objectAtIndex:0];
    //把TestPlist文件加入
    NSString* plistPath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"collect.plist"]];
    
    //开始创建文件
    //[fm createFileAtPath:plistPath contents:nil attributes:nil];
    [datas writeToFile:plistPath atomically:YES];
}

-(NSMutableArray*)ReadFromPlist{
    //建立文件管理
    //NSFileManager *fm = [NSFileManager defaultManager];
    //找到Documents文件所在的路径
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //取得第一个Documents文件夹的路径
    NSString *filePath = [path objectAtIndex:0];
    //把TestPlist文件加入
    NSString* plistPath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"collect.plist"]];
    
    NSMutableArray* data = [[NSMutableArray alloc]initWithContentsOfFile:plistPath];
    
    if (!data) {
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm createFileAtPath:plistPath contents:nil attributes:nil];
    }
    return data;
}

-(NSArray*)getDetailArray {
    return detailArray_;
}

-(void)setDetailArray:(NSArray*)array {
    detailArray_ = array;
}

-(NSArray*)getIntroArray {
    return introArray_;
}

-(void)setIntroArray:(NSArray*)array {
    introArray_ = array;
}


//空调的队列
-(NSArray*)getAirConditionArray {
    return airConditionArray_;
}

-(void)setAirConditionArray:(NSArray*)array {
    airConditionArray_ = array;
}

//汽车的队列
-(NSArray*)getCarArray {
    return carArray_;
}

-(void)setCarArray:(NSArray*)array {
    carArray_ = array;
}

-(NSArray*)getAllprodic {
    return allArray_;
}

-(void)setAllprodic:(NSArray*)array {
    allArray_ = array;
}

-(BOOL)getIsShowCollect {
    return isShowCollect_;
}

-(void)setIsShowCollect:(BOOL)is {
    isShowCollect_ = is;
}

-(NSArray*)getCurrentArray {
    return currentArray_;
}

-(void)setCurrentArray:(NSArray*)array {
    currentArray_ = array;
}

@end
