//
//  DWGridView.h
//  Grid
//
//  Created by Alvin Nutbeij on 12/14/12.
//  Copyright (c) 2013 Devwire. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWGridViewCell.h"
@class DWGridView;

typedef struct{
    NSInteger row;
    NSInteger column;
}DWPosition;

static inline DWPosition DWPositionMake(NSInteger row, NSInteger column);

@protocol DWGridViewDelegate <NSObject>
@required
-(DWGridViewCell *)gridView:(DWGridView *)gridView cellAtPosition:(DWPosition)position;
-(NSMutableDictionary *)gridViewDict:(DWGridView *)gridView cellAtPosition:(DWPosition)position;
-(void)collect:(DWGridView *)gridView collectPosition:(DWPosition)position;
-(void)collect:(int)seq;
-(NSMutableDictionary *)gridViewDict:(DWGridView *)gridView cellByIndex:(int)index;
@optional
-(BOOL)gridView:(DWGridView *)gridView shouldScrollCell:(DWGridViewCell *)cell atPosition:(DWPosition)position;
-(void)gridView:(DWGridView *)gridView willMoveCell:(DWGridViewCell *)cell fromPosition:(DWPosition)fromPosition toPosition:(DWPosition)toPosition;
-(void)gridView:(DWGridView *)gridView didMoveCell:(DWGridViewCell *)cell fromPosition:(DWPosition)fromPosition toPosition:(DWPosition)toPosition isCollect:(BOOL)isCollect;
@end

@protocol DWGridViewDataSource <NSObject>
@required
-(NSInteger)numberOfRowsInGridView:(DWGridView *)gridView;
-(NSInteger)numberOfColumnsInGridView:(DWGridView *)gridView;
@optional
-(NSInteger)numberOfVisibleRowsInGridView:(DWGridView *)gridView;
-(NSInteger)numberOfVisibleColumnsInGridView:(DWGridView *)gridView;


@end

@interface DWGridView : UIView <UIGestureRecognizerDelegate,UIScrollViewDelegate>{
    NSInteger _numberOfRowsInGrid;
    NSInteger _numberOfColumnsInGrid;
    
    NSInteger _numberOfVisibleRowsInGrid;
    NSInteger _numberOfVisibleColumnsInGrid;
    
    UIPanGestureRecognizer *_panRecognizer;
    UITapGestureRecognizer *_tapRecognizer;
    
    BOOL _isMovingVertically;
    BOOL _isMovingHorizontally;
    
    NSTimer *_easeOutTimer;
    
    NSThread *_easeThread;
}

@property (nonatomic,strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic,strong) UITapGestureRecognizer *tapRecognizer;

@property (nonatomic,assign) id<DWGridViewDataSource>dataSource;
@property (nonatomic,assign) id<DWGridViewDelegate>delegate;

-(void)reloadData;
-(DWPosition)normalizePosition:(DWPosition)position;
-(BOOL)outsidePosition:(DWPosition)position;
@end

