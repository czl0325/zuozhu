//
//  DWExampleGridViewController.m
//  Grid
//
//  Created by Alvin Nutbeij on 2/19/13.
//  Copyright (c) 2013 NCIM Groep. All rights reserved.
//

#import "DWExampleGridViewController.h"
#import "ProductObject.h"
#import "DataManager.h"

@interface DWExampleGridViewController ()

@end

@implementation DWExampleGridViewController

- (id)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showFullScreenView:) name:@"showFullScreenView" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideFullScreenView:) name:@"hideFullScreenView" object:nil];
        
        
        
        NSMutableArray* productarr= [[NSMutableArray alloc]init];
        
        NSMutableArray* config = [[DataManager sharedManager] ReadFromPlist];
        
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"detail" ofType:@"plist"];
        NSArray* array = [NSArray arrayWithContentsOfFile:plistPath];
        [[DataManager sharedManager] setDetailArray:array];
        
        plistPath = [[NSBundle mainBundle] pathForResource:@"intro" ofType:@"plist"];
        array = [NSArray arrayWithContentsOfFile:plistPath];
        [[DataManager sharedManager] setIntroArray:array];
        
        NSMutableArray* airConditionArray = [NSMutableArray new];
        NSMutableArray* carArray = [NSMutableArray new];
        NSMutableArray* allArray = [NSMutableArray new];
        
        if (config) {
            
            for (NSDictionary* dict in config) {
                UIImage *image = getBundleImage([NSString stringWithFormat:@"image_p%@_thumb.jpg",[ dict objectForKey:@"Seq"]]);
                NSMutableDictionary *imgdict = [[NSMutableDictionary alloc] init];
                
                [imgdict setObject:[ dict objectForKey:@"Collect"] forKey:@"Collect"];
                [imgdict setObject:[ dict objectForKey:@"Seq"] forKey:@"Seq"];
                [imgdict setObject:image forKey:@"Image"];
                [imgdict setObject:[ dict objectForKey:@"type"] forKey:@"type"];
                
                //加入队列
                [[DataManager sharedManager]addProductsQueue:imgdict];
                ProductObject* prd = [[ProductObject alloc]init];
                
                prd.img = image;
                prd.seq = [[ dict objectForKey:@"Seq"]intValue];
                prd.isCollect = [[ dict objectForKey:@"Collect"]boolValue];
                prd.type = [[dict objectForKey:@"type"]intValue];

                //如果有收藏则加入收藏队列
                if(prd.isCollect){
                    [[DataManager sharedManager]addCollectProducts:imgdict];
                }
                [productarr addObject:prd];
                
                if (prd.type==1) {
                    [airConditionArray addObject:imgdict];
                } else if (prd.type==2) {
                    [carArray addObject:imgdict];
                }
                [allArray addObject:imgdict];
            }
        }
        else{
            //图片另外存储
            NSArray* arr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"collect" ofType:@"plist"]];
            
            for (NSDictionary* dict in arr) {
                UIImage *image = getBundleImage([NSString stringWithFormat:@"image_p%@_thumb.jpg",[ dict objectForKey:@"Seq"]]);
                NSMutableDictionary *imgdict = [[NSMutableDictionary alloc] init];
                
                [imgdict setObject:[ dict objectForKey:@"Collect"] forKey:@"Collect"];
                [imgdict setObject:[ dict objectForKey:@"Seq"] forKey:@"Seq"];
                [imgdict setObject:image forKey:@"Image"];
                [imgdict setObject:[ dict objectForKey:@"type"] forKey:@"type"];
                
                //加入队列
                [[DataManager sharedManager]addProductsQueue:imgdict];
                ProductObject* prd = [[ProductObject alloc]init];
                
                prd.img = image;
                prd.isCollect = [[ dict objectForKey:@"Collect"]boolValue];
                prd.type = [[dict objectForKey:@"type"]intValue];
                
                [productarr addObject:prd];
                
                if (prd.type==1) {
                    [airConditionArray addObject:imgdict];
                } else if (prd.type==2) {
                    [carArray addObject:imgdict];
                }
                [allArray addObject:imgdict];
            }
        }
        [[DataManager sharedManager]setProudcts:productarr];
        [[DataManager sharedManager]setAirConditionArray:airConditionArray];
        [[DataManager sharedManager]setCarArray:carArray];
        [[DataManager sharedManager]setAllprodic:allArray];
        [[DataManager sharedManager]resetArray:0];
        
        //构建Cell
        NSDictionary* outerImgDict = [[DataManager sharedManager] getCellImageFromQueue];
    
        for(int row = 0; row < 6; row++){
            for(int col = 0; col < 6; col++){
                DWGridViewCell *cell = [[DWGridViewCell alloc] init];
                [cell setBackgroundColor:[UIColor clearColor]];
                //UIImage *image = getBundleImage([NSString stringWithFormat:@"%d.jpeg",idx]);
                
                //只有需要图片显示时才加入Cell
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                
                UIImage* cellimg;
                BOOL isCollect = NO;
                if (row<4&&col<4) {
                    NSDictionary * imageDict = [[DataManager sharedManager] getCellImageFromQueue];
                    cellimg =[imageDict objectForKey:@"Image"];
                    [dict setObject:imageDict forKey:@"ImagDict"];
                    if ([[imageDict objectForKey:@"Collect"]intValue]==1) {
                        isCollect = YES;
                    } else {
                        isCollect = NO;
                    }
                }
                else
                {
                    cellimg =[outerImgDict objectForKey:@"Image"];
                    [dict setObject:outerImgDict forKey:@"ImagDict"];
                    if ([[outerImgDict objectForKey:@"Collect"]intValue]==1) {
                        isCollect = YES;
                    } else {
                        isCollect = NO;
                    }
                }
                
                UIImageView *iv = [[UIImageView alloc] initWithImage:cellimg];
                [iv setContentMode:UIViewContentModeScaleAspectFill];
                iv.clipsToBounds = YES;
                iv.tag = 100;
                //[iv setTranslatesAutoresizingMaskIntoConstraints:NO];
                [cell addSubview:iv];
                
                [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[iv]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(iv)]];
                [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[iv]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(iv)]];
                [dict setObject:[NSNumber numberWithInt:row] forKey:@"Row"];
                [dict setObject:[NSNumber numberWithInt:col] forKey:@"Column"];
                [dict setObject:cell forKey:@"Cell"];
                [self.cells addObject:dict];
                
//                if (isCollect) {
//                    UIImageView* collect = getImageViewByImageName(@"favorite.png");
//                    collect.top = 5;
//                    collect.right = cell.width-5;
//                    [cell addSubview:collect];
//                }
            }
        }
    }
    return self;
}


#pragma mark - GridView datasource
-(NSInteger)numberOfColumnsInGridView:(DWGridView *)gridView{
    return 6;
}

-(NSInteger)numberOfRowsInGridView:(DWGridView *)gridView{
    return 6;
}

-(NSInteger)numberOfVisibleRowsInGridView:(DWGridView *)gridView{
    return 4;
}

-(NSInteger)numberOfVisibleColumnsInGridView:(DWGridView *)gridView{
    return 4;
}

-(NSInteger)numberOfMaxItemInGridView{
    return 40;
}


- (void)showFullScreenView:(NSNotification*)notification{
    self.gridView.panRecognizer.enabled = NO;
    self.gridView.tapRecognizer.enabled = NO;
    [self.view.superview addSubview:notification.object];
}

- (void)hideFullScreenView:(NSNotification*)notification{
    self.gridView.panRecognizer.enabled = YES;
    self.gridView.tapRecognizer.enabled = YES;
}


#pragma mark - private methods
//-(void)saveData:(NSMutableArray*)datas{
//    //建立文件管理
//    //NSFileManager *fm = [NSFileManager defaultManager];
//    //找到Documents文件所在的路径
//    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    //取得第一个Documents文件夹的路径
//    NSString *filePath = [path objectAtIndex:0];
//    //把TestPlist文件加入
//    NSString* plistPath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"collect.plist"]];
//    
//    //开始创建文件
//    //[fm createFileAtPath:plistPath contents:nil attributes:nil];
//    [datas writeToFile:plistPath atomically:YES];
//}
//
//-(NSArray*)ReadFromPlist{
//    //建立文件管理
//    //NSFileManager *fm = [NSFileManager defaultManager];
//    //找到Documents文件所在的路径
//    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    //取得第一个Documents文件夹的路径
//    NSString *filePath = [path objectAtIndex:0];
//    //把TestPlist文件加入
//    NSString* plistPath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"collect.plist"]];
//    
//    NSArray* data = [[NSMutableArray alloc]initWithContentsOfFile:plistPath];
//    
//    if (!data) {
//        NSFileManager *fm = [NSFileManager defaultManager];
//        [fm createFileAtPath:plistPath contents:nil attributes:nil];
//    }
//    
//    return data;
//
//}

@end
