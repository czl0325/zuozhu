//
//  DWGridViewController.m
//  Grid
//
//  Created by Alvin Nutbeij on 12/14/12.
//  Copyright (c) 2013 Devwire. All rights reserved.
//

#import "DWGridViewController.h"
#import "DataManager.h"


@interface DWGridViewController (){
    BOOL reloadFlag;
}

-(NSMutableDictionary *)cellDictionaryAtPosition:(DWPosition)position;
-(DWPosition)normalizePosition:(DWPosition)position inGridView:(DWGridView *)gridView;
@end

@implementation DWGridViewController
@synthesize gridView = _gridView;
@synthesize cells = _cells;

-(id)init
{
    self = [super init];
    if(self)
    {
        _cells = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)loadView
{
    _gridView = [[DWGridView alloc] init];
    _gridView.delegate = self;
    _gridView.dataSource = self;
    _gridView.clipsToBounds = YES;
    self.view = _gridView;
}

- (void)viewDidLoad
{
    reloadFlag = NO;
    [super viewDidLoad];

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!reloadFlag) {
        [_gridView reloadData];
        reloadFlag = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GridView datasource
-(NSInteger)numberOfColumnsInGridView:(DWGridView *)gridView{
    return 0;
}

-(NSInteger)numberOfRowsInGridView:(DWGridView *)gridView{
    return 0;
}

-(NSInteger)numberOfVisibleRowsInGridView:(DWGridView *)gridView{
    return 0;
}

-(NSInteger)numberOfVisibleColumnsInGridView:(DWGridView *)gridView{
    return 0;
}
-(NSInteger)numberOfMaxItemInGridView{
    return 0;
}

#pragma mark - GridView delegate
-(void)gridView:(DWGridView *)gridView didMoveCell:(DWGridViewCell *)cell fromPosition:(DWPosition)fromPosition toPosition:(DWPosition)toPosition isCollect:(BOOL)isCollect{
    //moving vertically
    toPosition = [gridView normalizePosition:toPosition];
    //标志移出元素是否已经加入队列中，YES表示还未加入
    BOOL moveflag= YES;
    if(toPosition.column == fromPosition.column)
    {
        //How many places is the tile moved (can be negative!)
        NSInteger amount = toPosition.row - fromPosition.row;
        NSMutableDictionary *cellDict = [self cellDictionaryAtPosition:fromPosition];
        NSMutableDictionary *toCell;
        do
        {
            //Get the next cell
            toCell = [self cellDictionaryAtPosition:toPosition];
            
            //update the current cell
            [cellDict setObject:[NSNumber numberWithInt:toPosition.row] forKey:@"Row"];
            
            
            //移出边界时将图片元素加入队列中
            if ((toPosition.row==[self numberOfVisibleRowsInGridView:gridView]||toPosition.row==[self numberOfRowsInGridView:gridView]-1)&& moveflag) {
                
                
                int moveseq = [[[cellDict objectForKey:@"ImagDict"]objectForKey:@"Seq"]intValue];
                
                if (moveseq>0) {
                    [[DataManager sharedManager]addQueueItem: [cellDict objectForKey:@"ImagDict"]];
                    
                    //从显示的队列中移除
                    NSMutableArray* showqueue = [[DataManager sharedManager]getShowQueue];
                    
                    for (int k = 0; k< showqueue.count; k++) {
                        
                        int seq = [[[showqueue objectAtIndex:k]objectForKey:@"Seq"]intValue];
                        
                        if (moveseq == seq ) {
                            
                            [showqueue removeObjectAtIndex:k];
                        }
                        
                    }
                    
                }
                moveflag = NO;
                
            }
            
            //prepare the next cell
            cellDict = toCell;
            
            //calculate the next position
            toPosition.row += amount;
            
            toPosition = [gridView normalizePosition:toPosition];
            
        }while (toCell);
        
    }
    else //moving horizontally
    {
        //How many places is the tile moved (can be negative!)
        NSInteger amount = toPosition.column - fromPosition.column;
        NSMutableDictionary *cellDict = [self cellDictionaryAtPosition:fromPosition];
        NSMutableDictionary *toCell;
        do
        {
            //Get the next cell
            toCell = [self cellDictionaryAtPosition:toPosition];
            
            //update the current cell
            [cellDict setObject:[NSNumber numberWithInt:toPosition.column] forKey:@"Column"];
            
            
            //移出边界时将图片元素加入队列中
            if ((toPosition.column==[self numberOfVisibleColumnsInGridView:gridView]||toPosition.column==[self numberOfColumnsInGridView:gridView]-1)&& moveflag) {
                
                
                int moveseq = [[[cellDict objectForKey:@"ImagDict"]objectForKey:@"Seq"]intValue];
                
                if (moveseq>0) {
                    [[DataManager sharedManager]addQueueItem: [cellDict objectForKey:@"ImagDict"]];
                    //从显示的队列中移除
                    NSMutableArray* showqueue = [[DataManager sharedManager]getShowQueue];
                    
                    for (int k = 0; k< showqueue.count; k++) {
                        
                        int seq = [[[showqueue objectAtIndex:k]objectForKey:@"Seq"]intValue];
                        
                        if (moveseq == seq ) {
                            
                            [showqueue removeObjectAtIndex:k];
                        }
                        
                    }
                    
                }
                moveflag = NO;
        
            }

            
            //prepare the next cell
            cellDict = toCell;
            
            //calculate the next position
            toPosition.column += amount;
            toPosition = [gridView normalizePosition:toPosition];
        }while (toCell);
        
        
    }
    
    
    NSDictionary* outerImgDict = [[DataManager sharedManager] getCellImageFromQueue];
    
    for(int row = 0; row < [self numberOfRowsInGridView:gridView]; row++){
        for(int col = 0; col < [self numberOfColumnsInGridView:gridView]; col++){
            
            if (row>=[self numberOfVisibleRowsInGridView:gridView]||col>=[self numberOfVisibleColumnsInGridView:gridView]) {
                
                for(NSMutableDictionary *cellDict in _cells){
                    
                    if([[cellDict objectForKey:@"Row"] intValue] == row){
                        
                        if([[cellDict objectForKey:@"Column"] intValue] == col){
                            
                            if (!outerImgDict) {
                                
                                outerImgDict = [[DataManager sharedManager] getBlankdic];

                            }
                            
                            [cellDict setObject:outerImgDict forKey:@"ImagDict"];
                            
                            UIImageView* celliv = (UIImageView*)[[cellDict objectForKey:@"Cell"]viewWithTag:100];
                            
                            celliv.image = [outerImgDict objectForKey:@"Image"];
                            
                        }else{
                            continue;
                        }
                    }else{
                        continue;
                    }
                }
            }
        }
    }
}

-(NSMutableDictionary *)gridViewDict:(DWGridView *)gridView cellByIndex:(int)index{
    
    for(NSMutableDictionary *cellDict in _cells){
        //在边界外的取候选队列中第一个
        NSDictionary *d = [cellDict objectForKey:@"ImagDict"];
        if([[d objectForKey:@"Seq"] intValue] == index){
                return cellDict;
        }
    }
    
    return nil;
}

-(DWGridViewCell *)gridView:(DWGridView *)gridView cellAtPosition:(DWPosition)position{
    NSMutableDictionary *dict = [self cellDictionaryAtPosition:position];

    DWGridViewCell *cell = [dict objectForKey:@"Cell"];
    
    //在边界外的取候选队列中第一个
//    if (flag) {
//        NSMutableDictionary* imgDict = [_datas objectAtIndex:0];
//        
//        
//        
//        UIImage *img = getBundleImage([dict objectForKey:@"img"]);
//        
//        UIImageView* imgV = (UIImageView*)[cell viewWithTag:100];
//        
//        imgV.image = img;
//        
//    }
    
    
    if(!cell){
        cell = [[DWGridViewCell alloc] init];
    }
    return cell;
}

-(NSMutableDictionary *)gridViewDict:(DWGridView *)gridView cellAtPosition:(DWPosition)position{
    NSMutableDictionary *dict = [self cellDictionaryAtPosition:position];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    return dict;
}

-(void)collect:(DWGridView *)gridView collectPosition:(DWPosition)position {
    position = [self normalizePosition:position inGridView:_gridView];
    NSMutableArray* saveData = [[NSMutableArray alloc]init];
    for(NSMutableDictionary *cellDict in _cells){
        if([[cellDict objectForKey:@"Row"] intValue] == position.row){
            if([[cellDict objectForKey:@"Column"] intValue] == position.column){
                NSMutableDictionary* imgDict = [cellDict objectForKey:@"ImagDict"];
                if ([[imgDict objectForKey:@"Collect"]boolValue]) {
                    [[DataManager sharedManager]removeCollectProducts:imgDict];
                    UIImageView* cellimg = (UIImageView*) [[cellDict objectForKey:@"Cell"] viewWithTag:100];
                    cellimg.image = [[[DataManager sharedManager]getBlankdic]objectForKey:@"Image"];
                } else {
                    [[DataManager sharedManager]addCollectProducts:imgDict];
                }
                [[DataManager sharedManager]setProductCollect:[[imgDict objectForKey:@"Seq"]intValue]];
                
                [imgDict setObject:[NSNumber numberWithBool:![[imgDict objectForKey:@"Collect"]boolValue]]forKey:@"Collect"];
            }
        }
    }
    
    NSArray* showqueue = [[DataManager sharedManager]getProducts];

    int idx = 1;
    for (ProductObject* prdobj in showqueue) {
        
        NSMutableDictionary* tmpcell = [[NSMutableDictionary alloc]init];
        
        [tmpcell setObject:[NSNumber numberWithBool: prdobj.isCollect ]forKey:@"Collect"];
        [tmpcell setObject:[NSNumber numberWithInt:idx ] forKey:@"Seq"];
        [tmpcell setObject:[NSNumber numberWithInt:prdobj.type ] forKey:@"type"];
        
        [saveData addObject:tmpcell];
        
        idx++;
        
    }


    [[DataManager sharedManager] saveData:saveData];

}

-(void)collect:(int)seq {
    NSArray* showqueue = [[DataManager sharedManager]getProducts] ;
    
    NSMutableArray* saveData = [[NSMutableArray alloc]init];
    
    NSMutableDictionary* touchdic=[[NSMutableDictionary alloc] init];
    for (ProductObject *cellDict in showqueue) {
        if (cellDict.seq==seq) {
            if (cellDict.isCollect) {
                UIImage *image = [[[DataManager sharedManager]getBlankdic]objectForKey:@"Image"];
                [touchdic setObject:[NSNumber numberWithBool:NO] forKey:@"Collect"];
                [touchdic setObject:[NSNumber numberWithInt:cellDict.seq] forKey:@"Seq"];
                [touchdic setObject:image forKey:@"Image"];
                [touchdic setObject:[NSNumber numberWithInt:cellDict.type] forKey:@"type"];
                [[DataManager sharedManager]removeCollectProducts:touchdic];
            } else {
                UIImage *image = getBundleImage([NSString stringWithFormat:@"image_p%d_thumb.jpg",cellDict.seq]);
                [touchdic setObject:[NSNumber numberWithBool:YES] forKey:@"Collect"];
                [touchdic setObject:[NSNumber numberWithInt:cellDict.seq] forKey:@"Seq"];
                [touchdic setObject:image forKey:@"Image"];
                [touchdic setObject:[NSNumber numberWithInt:cellDict.type] forKey:@"type"];
                [[DataManager sharedManager]addCollectProducts:touchdic];
            }
            break;
        }
    }
    [[DataManager sharedManager]setProductCollect:[[touchdic objectForKey:@"Seq"]intValue]];
    
    int idx = 1;
    for (ProductObject* prdobj in showqueue) {
        
        NSMutableDictionary* tmpcell = [[NSMutableDictionary alloc]init];
        
        [tmpcell setObject:[NSNumber numberWithBool: prdobj.isCollect ]forKey:@"Collect"];
        [tmpcell setObject:[NSNumber numberWithInt:idx ] forKey:@"Seq"];
        [tmpcell setObject:[NSNumber numberWithInt:prdobj.type ] forKey:@"type"];
        
        [saveData addObject:tmpcell];
        
        idx++;
        
    }
    
    
    [[DataManager sharedManager] saveData:saveData];
}


#pragma mark - Screen rotation

-(BOOL)shouldAutorotate{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - Private methods
-(DWPosition)normalizePosition:(DWPosition)position inGridView:(DWGridView *)gridView{
    return [gridView normalizePosition:position];
}

-(BOOL)outsidePosition:(DWPosition)position inGriddView:(DWGridView*)gridView{
    
    return [gridView outsidePosition:position];
}

-(NSMutableDictionary *)cellDictionaryAtPosition:(DWPosition)position{
    
    //判断是否在屏幕内的点
    position = [self normalizePosition:position inGridView:_gridView];
    
    for(NSMutableDictionary *cellDict in _cells){
        //在边界外的取候选队列中第一个
        if([[cellDict objectForKey:@"Row"] intValue] == position.row){
            
            if([[cellDict objectForKey:@"Column"] intValue] == position.column){
                return cellDict;
            }else{
                continue;
            }
        }else{
            continue;
        }
    }
    
    return nil;
}



@end
