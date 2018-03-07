//
//  DWGridView.m
//  Grid
//
//  Created by Alvin Nutbeij on 12/14/12.
//  Copyright (c) 2013 Devwire. All rights reserved.
//

#import "DWGridView.h"
#import "UITools.h"
#import "DataManager.h"
#import "DetailScrollView.h"
#import "YXBaseView.h"
#import "ZZPageControl.h"

#define ALLPRODUCT  9

@interface DWGridView ()
{
    UIImageView* leftView;
    UIImageView *chooseView_;
    UIScrollView* scrollImageView_;
    UIImageView* switchBG;
    UIView* centerView;
    BOOL isMoveing;             //是否正在移动
    BOOL isMoveOut;             //是否移动出去
    BOOL isScroll;              //是否手指滑动
    BOOL isShowLeftView;
    BOOL isRotota;              //是否旋转
    BOOL isShowCollect;         //是否显示收藏
    BOOL isShowAircondition;    //是否显示空调
    BOOL isShowCar;             //是否显示汽车
    int selectType;             //记录显示空调还是汽车
    BOOL isMoveOutAndShowCollect;//是否移动出去而且是在收藏状态下
    BOOL isCollectArrayChange;  //收藏的数组是否改变了
    NSMutableDictionary *touchCell;
    CGPoint oldPoint;
    CGPoint newPoint;
    
    UIButton* onebt;
    UIButton* twobt;
    UIButton* threebt;
    UIImageView* bgV;
    UIImageView* introImage;
    NSMutableArray* arraybt;
    NSMutableArray *subPages_;  //页面集合
    NSMutableArray *introPages_;//介绍的页面集合
    UIScrollView* introScroll;
    ZZPageControl* introPageController;
}

@property (nonatomic, strong) UIImageView* leftView;
@property (nonatomic, strong) UIView* centerView;

-(void)panGestureDetected:(UIGestureRecognizer *)gestureRecognizer;
-(void)initCells;
/**
 *  This method will always generate a unique tag for a view based on row and column.
 *
 *  @warning *Important* This will only work if the row and column counter start at 0.
 *
 *  @param position The cell's position
 *
 *  @return The tag
 */
-(NSInteger)tagForPosition:(DWPosition)position;
@end

@implementation DWGridView
@synthesize leftView;
@synthesize centerView;
@synthesize delegate;
@synthesize dataSource;
@synthesize panRecognizer = _panRecognizer;
@synthesize tapRecognizer = _tapRecognizer;

static const CGFloat stepSize = 300.0;
static const NSInteger outerOffset = 1;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //self can't have tag 0 because there is a tile with tag 0 which will conflict when moving
        srand((unsigned int)time(NULL));
        self.tag = 1337;
        subPages_ = [NSMutableArray new];
        introPages_ = [NSMutableArray new];
        
        centerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1024, 768)];
        bgV = getImageViewByImageName(@"bg1.png");
        [self addSubview:bgV];
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOneCell:)];
        [ centerView addGestureRecognizer:_tapRecognizer];
        _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDetected:)];
        [centerView addGestureRecognizer:_panRecognizer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enable_scroll:) name:@"enable_scroll" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showEffect:) name:@"showEffect" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCollect:) name:@"onCollect" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideLeftView:) name:@"hideLeftView" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCollectArray:) name:@"changeCollectArray" object:nil];
        
        
        [self addSubview:centerView];
        [self setupLeftNav];

    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:CGRectMake(0, 0, 1023, 768)];
}

//创建左边导航栏
- (void)setupLeftNav
{
    // Initialization code
    
    leftView = getImageViewByImageName(@"navBG.png");
    leftView.top = 0;
    leftView.userInteractionEnabled = YES;
    [self addSubview:leftView];
    onebt = getButtonByImageName(@"btMenuOneON.png");
    onebt.center = CGPointMake(leftView.width/2, 120);
    [onebt addTarget:self action:@selector(restore) forControlEvents:UIControlEventTouchUpInside];
    [leftView addSubview:onebt];
    twobt = getButtonByImageName(@"btMenuTwo.png");
    twobt.center = CGPointMake(leftView.width/2, 220);
    [twobt addTarget:self action:@selector(showFirstPic) forControlEvents:UIControlEventTouchUpInside];
    [leftView addSubview:twobt];
    threebt = getButtonByImageName(@"btMenuThree.png");
    threebt.center = CGPointMake(leftView.width/2, 320);
    [threebt addTarget:self action:@selector(moveAndRotota) forControlEvents:UIControlEventTouchUpInside];
    [leftView addSubview:threebt];
    //leftView.right = 0;
    
    switchBG = getImageViewByImageName(@"switchBG.png");
    switchBG.userInteractionEnabled = YES;
    UITapGestureRecognizer* tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onShowLeftView:)];
    [switchBG addGestureRecognizer:tap1];
//    UIPanGestureRecognizer* pan1 = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(onShowLeftViewByPan:)];
//    [switchBG addGestureRecognizer:pan1];
    switchBG.bottom = leftView.height;
    [self addSubview:switchBG];
    
    UIImageView* key = getImageViewByImageName(@"switchKey.png");
    //key.center = CGPointMake(switchBG.width/2-25, switchBG.height/2-3);
    key.center = CGPointMake(switchBG.width/2+3, switchBG.height/2+24);
    key.tag = 99;
    [switchBG addSubview:key];
    
    isShowLeftView = YES;
    isShowCollect = NO;
    isMoveing = NO;
    isMoveOut = NO;
    isScroll = NO;
    isRotota = NO;
    isShowAircondition = NO;
    isShowCar = NO;
    selectType = 1000;
    isMoveOutAndShowCollect = NO;
    isCollectArrayChange = NO;
    
    arraybt = [NSMutableArray new];
    NSString* leftClassify[3] = {@"classifyOFF.png", @"classifyBLUEOFF.png", @"classifyREDOFF.png"};
    for (int i=0; i<3; i++) {
        UIButton* b = getButtonBigResponse(leftClassify[i],40);
        b.tag = 1000+i;
        [b addTarget:self action:@selector(onChangeBG:) forControlEvents:UIControlEventTouchUpInside];
        b.center = CGPointMake(leftView.width/2, 480+i*80);
        [leftView addSubview:b];
        if (i==0) {
            [b setImage:getBundleImage(@"classifyON.png") forState:UIControlStateNormal];
        }
        [arraybt addObject:b];
    }
    introImage = getImageViewByImageName(@"intro.png");
    introImage.contentMode = UIViewContentModeCenter;
    introImage.width*=1.2;
    introImage.height*=2;
    introImage.backgroundColor = [UIColor clearColor];
    
    introImage.centerX = leftView.width/2;
    introImage.top = 0;
    introImage.userInteractionEnabled = YES;
    [leftView addSubview:introImage];
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onShowIntro)];
    [introImage addGestureRecognizer:tap];
    
    [self onShowIntro];
}


-(void)reloadData
{
    //fetch total grid size
    _numberOfRowsInGrid = [self.dataSource numberOfRowsInGridView:self];
    _numberOfColumnsInGrid = [self.dataSource numberOfColumnsInGridView:self];
   
    //fetch the visible grid size
    if([self.dataSource respondsToSelector:@selector(numberOfVisibleRowsInGridView:)])
        _numberOfVisibleRowsInGrid = [self.dataSource numberOfVisibleRowsInGridView:self];
    else
        _numberOfVisibleRowsInGrid = _numberOfRowsInGrid;
    
    if([self.dataSource respondsToSelector:@selector(numberOfVisibleColumnsInGridView:)])
        _numberOfVisibleColumnsInGrid = [self.dataSource numberOfVisibleColumnsInGridView:self];
    else
        _numberOfVisibleColumnsInGrid = _numberOfColumnsInGrid;
    
    [self initCells];
    
    if (introScroll) {
        [centerView bringSubviewToFront:introScroll];
        [centerView bringSubviewToFront:introPageController];
    }
    
    if (scrollImageView_) {
        [centerView bringSubviewToFront:scrollImageView_];
    }
    //[self bringSubviewToFront:leftView];
}

-(void)initCells
{
    //remove all subviews
    //[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //fetch the bounds, will be used to position the cells
    CGRect myFrame = self.bounds;
    
    //[centerView removeAllSubviews];
    
    //loop through the rows with 2 above and 2 below the screen
    for(int row = -outerOffset; row < _numberOfVisibleRowsInGrid+outerOffset; row++)
    {
        //loop through the columns with 2 left and 2 right of the screen
        for(int column = -outerOffset; column < _numberOfVisibleColumnsInGrid+outerOffset; column++)
        {
            //fetch the cell for the current position
            DWPosition cellPosition = DWPositionMake(row, column);
            DWGridViewCell *cell = [self.delegate gridView:self cellAtPosition:cellPosition];

            
            cell.tag = [self tagForPosition:cellPosition];
            
            //create the frame based on the current position, the view's bounds and the grid's size
            CGRect cellFrame;
            cellFrame.size.width = myFrame.size.width / _numberOfVisibleColumnsInGrid;
            cellFrame.size.height = myFrame.size.height / _numberOfVisibleRowsInGrid;
            cellFrame.origin.x = column * cellFrame.size.width;
            cellFrame.origin.y = row * cellFrame.size.height;
            cell.frame = cellFrame;
            
            //由加入cell图片的tag来决定
            UIImageView* cellimg = (UIImageView*)[cell viewWithTag:100];
            
            cellimg.width = cell.width -15;
            cellimg.height = cell.height -15;
            
            cellimg.left = 7.5;
            cellimg.top = 7.5;
            
            
            //add the cell to the grid view
            [centerView addSubview:cell];
            
            //if the cell is on screen bring it to the front
            if(row >= 0 && row < _numberOfVisibleRowsInGrid && column >= 0 && column < _numberOfVisibleColumnsInGrid)
            {
                [centerView bringSubviewToFront:cell];
            }
            //if the cell is off screen send it to the bck
            else
            {
                //[centerView sendSubviewToBack:cell];
                [centerView sendSubviewToBack:cell];
                //[cell setOrigin:CGPointMake(0, 0) ];
            }
        }
    }
}

-(NSInteger)tagForPosition:(DWPosition)position
{
    NSInteger tag = position.row * _numberOfColumnsInGrid + position.column;
//    if ([self outsidePosition:position]) {
//        tag=-1;
//    }

    //tag 0 gives issues with moving (for some reason?)
    //Therefor we set it to INT_MAX, as that will never be reached
    if(tag == 0)
    {
        tag = INT_MAX;
    }
    return tag;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - DWPosition

static inline DWPosition DWPositionMake(NSInteger row, NSInteger column) {
    return (DWPosition) {row, column};
}

//根据点来确定这个点是在哪一个cell里
-(DWPosition)determinePositionAtPoint:(CGPoint)point{
    DWPosition position;
    CGFloat height = self.bounds.size.height;
    CGFloat posY = point.y;
    CGFloat rowHeight = height / _numberOfVisibleRowsInGrid;
    position.row = floor(posY / rowHeight);
    
    CGFloat width = self.bounds.size.width;
    CGFloat posX = point.x;
    CGFloat columnWidth = width / _numberOfVisibleColumnsInGrid;
    position.column = floor(posX / columnWidth);
    
    return position;
}

//计算位置，超过一行或一列最多cell数量的循环计算到正确位置，但只有一次，没有循环？
-(DWPosition)normalizePosition:(DWPosition)position{
    
    if(position.row < 0){
        position.row += _numberOfRowsInGrid;
    }else if(position.row >= _numberOfRowsInGrid){
        position.row -= _numberOfRowsInGrid;
    }
    
    if(position.column < 0){
        position.column += _numberOfColumnsInGrid;
    }else if(position.column >= _numberOfColumnsInGrid){
        position.column -= _numberOfColumnsInGrid;
    }
    
//    if(position.row < 0||position.row >= _numberOfVisibleRowsInGrid){
//        position.row = -1;
//    }
//    
//    if(position.column < 0||position.column >= _numberOfVisibleColumnsInGrid){
//        position.column = -1;
//    }
    
    return position;
}

-(BOOL)outsidePosition:(DWPosition)position{
   
    if (position.row<0||position.row>=_numberOfVisibleRowsInGrid||position.column<0||position.column>=_numberOfVisibleColumnsInGrid) {
        return YES;
    }
    return NO;
}

#pragma mark - Gestures
//拖动检测到的方法，当手指滑动时开始入口
-(void)panGestureDetected:(UIPanGestureRecognizer *)gestureRecognizer{
    CGPoint velocity = [gestureRecognizer velocityInView:self];

	if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        if(_easeOutTimer){
            [_easeOutTimer invalidate];
            //[_easeOutTimer finalize];
            _easeOutTimer = nil;
        }
        
        if(_easeThread){
            [_easeThread cancel];
            _easeThread = nil;
        }

        [self reloadData];
        _isMovingHorizontally = NO;
        _isMovingVertically = NO;
	}
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        //horizontal
        if(fabsf(velocity.x) > fabsf(velocity.y) && !_isMovingVertically)
        {
            _isMovingHorizontally = YES;
            //接触的cell位置
            DWPosition touchPosition = [self determinePositionAtPoint:[gestureRecognizer locationInView:self]];
            //得到偏移量
            CGPoint translation = [gestureRecognizer translationInView:self];
            [self moveCellAtPosition:touchPosition horizontallyBy:velocity.x withTranslation:translation reloadingData:YES];
            //要设置为0否则会累加
            [gestureRecognizer setTranslation:CGPointZero inView:self];
        }
        //vertical、、classify
        else if(!_isMovingHorizontally)
        {
            _isMovingVertically = YES;
            DWPosition touchPosition = [self determinePositionAtPoint:[gestureRecognizer locationInView:self]];
            CGPoint translation = [gestureRecognizer translationInView:self];
            [self moveCellAtPosition:touchPosition verticallyBy:velocity.y withTranslation:translation reloadingData:YES];
            [gestureRecognizer setTranslation:CGPointZero inView:self];
        }
        
        if (introScroll) {
            [centerView bringSubviewToFront:introScroll];
            [centerView bringSubviewToFront:introPageController];
        }
        
	}
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        DWPosition touchPosition = [self determinePositionAtPoint:[gestureRecognizer locationInView:self]];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[NSNumber numberWithFloat:velocity.x] forKey:@"VelocityX"];
        [dict setObject:[NSNumber numberWithFloat:velocity.y] forKey:@"VelocityY"];
        [dict setObject:[NSNumber numberWithFloat:touchPosition.row] forKey:@"TouchRow"];
        [dict setObject:[NSNumber numberWithFloat:touchPosition.column] forKey:@"TouchColumn"];
        _easeOutTimer = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(easeOut:) userInfo:dict repeats:NO];
    }

}

-(void)moveCellSelector:(NSDictionary *)params
{
    CGFloat velocity = [[params objectForKey:@"velocity"] floatValue];
    BOOL reloadingData = [[params objectForKey:@"reloadingData"] boolValue];
    CGPoint translation = CGPointMake([[params objectForKey:@"translationX"] floatValue], [[params objectForKey:@"translationY"] floatValue]);
    BOOL isMovingHorizontally = [[params objectForKey:@"isMovingHorizontally"] boolValue];
    DWPosition position = DWPositionMake([[params objectForKey:@"positionX"] intValue], [[params objectForKey:@"positionY"] intValue]);
    
    if(isMovingHorizontally)
    {
        [self moveCellAtPosition:position horizontallyBy:velocity withTranslation:translation reloadingData:reloadingData];
    }
    else
    {
        [self moveCellAtPosition:position verticallyBy:velocity withTranslation:translation reloadingData:reloadingData];
    }
}

-(void)easeRow:(NSDictionary *)params
{
    CGPoint velocity = CGPointMake([[params objectForKey:@"VelocityX"] floatValue], [[params objectForKey:@"VelocityY"] floatValue]);
    DWPosition touchPosition = DWPositionMake([[params objectForKey:@"TouchRow"] floatValue], [[params objectForKey:@"TouchColumn"] floatValue]);
    
    CGFloat width = self.bounds.size.width;
    CGFloat columnWidth = width / _numberOfVisibleColumnsInGrid;
    
    if( fabsf(velocity.x) < columnWidth)
    {
        if (velocity.x < 0 )
        {
            velocity.x = -columnWidth;
        }
        else
        {
            velocity.x = columnWidth;
        }
    }
    
    CGFloat direction = velocity.x / stepSize;
    if(velocity.x < 0) //moving left
    {
        for(CGFloat i = 0; ![[NSThread currentThread] isCancelled]; i+=fabsf(direction))
        {
            if( i >= fabsf(velocity.x) - columnWidth)
            {
                DWGridViewCell *cell = [self.delegate gridView:self cellAtPosition:DWPositionMake(touchPosition.row, 0)];
                if((int)roundf(cell.frame.origin.x) % (int)roundf(columnWidth) == 0)
                {
                    if(cell.frame.origin.x != 0)
                    {
                        direction = cell.frame.origin.x - columnWidth;
                        
                        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithFloat:velocity.x], @"velocity",
                                              [NSNumber numberWithBool:YES], @"reloadingData",
                                              [NSNumber numberWithFloat:direction], @"translationX",
                                              [NSNumber numberWithFloat:0], @"translationY",
                                              [NSNumber numberWithBool:YES], @"isMovingHorizontally",
                                              [NSNumber numberWithInt:touchPosition.row], @"positionX",
                                              [NSNumber numberWithInt:0], @"positionY",
                                              nil];
                        [self performSelectorOnMainThread:@selector(moveCellSelector:) withObject:dict waitUntilDone:YES];
                    }
                    break;
                }
            }
            direction = (velocity.x + i) / stepSize;
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithFloat:velocity.x], @"velocity",
                                  [NSNumber numberWithBool:YES], @"reloadingData",
                                  [NSNumber numberWithFloat:direction], @"translationX",
                                  [NSNumber numberWithFloat:0], @"translationY",
                                  [NSNumber numberWithBool:YES], @"isMovingHorizontally",
                                  [NSNumber numberWithInt:touchPosition.row], @"positionX",
                                  [NSNumber numberWithInt:touchPosition.column], @"positionY",
                                  nil];
            [self performSelectorOnMainThread:@selector(moveCellSelector:) withObject:dict waitUntilDone:YES];
            [NSThread sleepForTimeInterval:0.001];
        }
    }
    else //moving right
    {
        for(CGFloat i = 0; ![[NSThread currentThread] isCancelled]; i+=fabsf(direction))
        {
            if( i >= fabsf(velocity.x) - columnWidth)
            {
                DWGridViewCell *cell = [self.delegate gridView:self cellAtPosition:DWPositionMake(touchPosition.row, 0)];
                if((int)roundf(cell.frame.origin.x) % (int)roundf(columnWidth) == 0)
                {
                    if(cell.frame.origin.x != 0)
                    {
                        direction = columnWidth - cell.frame.origin.x;
                        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithFloat:velocity.x], @"velocity",
                                              [NSNumber numberWithBool:YES], @"reloadingData",
                                              [NSNumber numberWithFloat:direction], @"translationX",
                                              [NSNumber numberWithFloat:0], @"translationY",
                                              [NSNumber numberWithBool:YES], @"isMovingHorizontally",
                                              [NSNumber numberWithInt:touchPosition.row], @"positionX",
                                              [NSNumber numberWithInt:0], @"positionY",
                                              nil];
                        [self performSelectorOnMainThread:@selector(moveCellSelector:) withObject:dict waitUntilDone:YES];
                    }
                    break;
                }
            }
           
            direction = (velocity.x - i) / stepSize;
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat:velocity.x], @"velocity",
                              [NSNumber numberWithBool:YES], @"reloadingData",
                              [NSNumber numberWithFloat:direction], @"translationX",
                              [NSNumber numberWithFloat:0], @"translationY",
                              [NSNumber numberWithBool:YES], @"isMovingHorizontally",
                              [NSNumber numberWithInt:touchPosition.row], @"positionX",
                              [NSNumber numberWithInt:touchPosition.column], @"positionY",
                              nil];
            
            [self performSelectorOnMainThread:@selector(moveCellSelector:) withObject:dict waitUntilDone:YES];
            [NSThread sleepForTimeInterval:0.001];
        }
    }
    
    if(![[NSThread currentThread] isCancelled])
    {
        [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        if (_easeThread) {
            [_easeThread cancel];
            _easeThread = nil;
        }
    }
}

-(void)easeColumn:(NSDictionary *)params
{
    CGPoint velocity = CGPointMake([[params objectForKey:@"VelocityX"] floatValue], [[params objectForKey:@"VelocityY"] floatValue]);
    DWPosition touchPosition = DWPositionMake([[params objectForKey:@"TouchRow"] floatValue], [[params objectForKey:@"TouchColumn"] floatValue]);
    
    CGFloat height = self.bounds.size.height;
    CGFloat rowHeight = height / _numberOfVisibleRowsInGrid;
    
    if( fabsf(velocity.y) < rowHeight)
    {
        if (velocity.y < 0 )
        {
            velocity.y = -rowHeight;
        }
        else
        {
            velocity.y = rowHeight;
        }
    }
    
    CGFloat direction = velocity.y / stepSize;
    if(velocity.y < 0) //moving up
    {
        for(CGFloat i = 0; ![[NSThread currentThread] isCancelled]; i+=fabsf(direction))
        {
            if( i >= fabsf(velocity.y) - rowHeight)
            {
                DWGridViewCell *cell = [self.delegate gridView:self cellAtPosition:DWPositionMake(0, touchPosition.column)];
                if((int)roundf(cell.frame.origin.y) % (int)roundf(rowHeight) == 0)
                {
                    if(cell.frame.origin.y != 0)
                    {
                        direction = cell.frame.origin.y - rowHeight;
                        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithFloat:velocity.y], @"velocity",
                                              [NSNumber numberWithBool:YES], @"reloadingData",
                                              [NSNumber numberWithFloat:0], @"translationX",
                                              [NSNumber numberWithFloat:direction], @"translationY",
                                              [NSNumber numberWithBool:NO], @"isMovingHorizontally",
                                              [NSNumber numberWithInt:0], @"positionX",
                                              [NSNumber numberWithInt:touchPosition.column], @"positionY",
                                              nil];
                        [self performSelectorOnMainThread:@selector(moveCellSelector:) withObject:dict waitUntilDone:YES];
                    }
                    break;
                }
            }
            
            direction = (velocity.y + i) / stepSize;
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithFloat:velocity.y], @"velocity",
                                  [NSNumber numberWithBool:YES], @"reloadingData",
                                  [NSNumber numberWithFloat:0], @"translationX",
                                  [NSNumber numberWithFloat:direction], @"translationY",
                                  [NSNumber numberWithBool:NO], @"isMovingHorizontally",
                                  [NSNumber numberWithInt:touchPosition.row], @"positionX",
                                  [NSNumber numberWithInt:touchPosition.column], @"positionY",
                                  nil];
            [self performSelectorOnMainThread:@selector(moveCellSelector:) withObject:dict waitUntilDone:YES];
            [NSThread sleepForTimeInterval:0.001];
        }
    }
    else //moving down
    {
        for(CGFloat i = 0; ![[NSThread currentThread] isCancelled]; i+=fabsf(direction))
        {
            if( i >= fabsf(velocity.y) - rowHeight)
            {
                DWGridViewCell *cell = [self.delegate gridView:self cellAtPosition:DWPositionMake(0, touchPosition.column)];
                if((int)roundf(cell.frame.origin.y) % (int)roundf(rowHeight) == 0)
                {
                    if(cell.frame.origin.y != 0)
                    {
                        direction = rowHeight - cell.frame.origin.y;
                        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithFloat:velocity.y], @"velocity",
                                              [NSNumber numberWithBool:YES], @"reloadingData",
                                              [NSNumber numberWithFloat:0], @"translationX",
                                              [NSNumber numberWithFloat:direction], @"translationY",
                                              [NSNumber numberWithBool:NO], @"isMovingHorizontally",
                                              [NSNumber numberWithInt:0], @"positionX",
                                              [NSNumber numberWithInt:touchPosition.column], @"positionY",
                                              nil];
                        [self performSelectorOnMainThread:@selector(moveCellSelector:) withObject:dict waitUntilDone:YES];
                    }
                    break;
                }
            }
            
            direction = (velocity.y - i) / stepSize;
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithFloat:velocity.y], @"velocity",
                                  [NSNumber numberWithBool:YES], @"reloadingData",
                                  [NSNumber numberWithFloat:0], @"translationX",
                                  [NSNumber numberWithFloat:direction], @"translationY",
                                  [NSNumber numberWithBool:NO], @"isMovingHorizontally",
                                  [NSNumber numberWithInt:touchPosition.row], @"positionX",
                                  [NSNumber numberWithInt:touchPosition.column], @"positionY",
                                  nil];
            [self performSelectorOnMainThread:@selector(moveCellSelector:) withObject:dict waitUntilDone:YES];
            [NSThread sleepForTimeInterval:0.001];
                 
        }
    }
    
    if(![[NSThread currentThread] isCancelled])
    {
        [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        if (_easeThread) {
            [_easeThread cancel];
            _easeThread = nil;
        }
    }
}

-(void)easeOut:(NSTimer *)timer
{
    if(_isMovingHorizontally)
    {
        _easeThread = [[NSThread alloc] initWithTarget:self selector:@selector(easeRow:) object:timer.userInfo];
        [_easeThread start];
    }
    else
    {
        _easeThread = [[NSThread alloc] initWithTarget:self selector:@selector(easeColumn:) object:timer.userInfo];
        [_easeThread start];
    }
    _easeOutTimer = nil;
}

//确定position所在的行进行移动
-(void)moveCellAtPosition:(DWPosition)position horizontallyBy:(CGFloat)velocity withTranslation:(CGPoint)translation reloadingData:(BOOL)shouldReload{
    for(int i = -outerOffset; i< _numberOfVisibleColumnsInGrid+outerOffset; i++){
        UIView *cell = [self viewWithTag:[self tagForPosition:DWPositionMake(position.row, i)]];

        CGPoint center = cell.center;
        center.x += translation.x;
        cell.center = center;
    }
    
    UIView *cell = [self viewWithTag:[self tagForPosition:DWPositionMake(position.row, 0)]];
    CGFloat width = self.bounds.size.width;
    CGFloat columnWidth = width / _numberOfVisibleColumnsInGrid;
    CGFloat posX = cell.frame.origin.x;
    if(posX >= columnWidth){
        [self.delegate gridView:self didMoveCell:[self.delegate gridView:self cellAtPosition:position] fromPosition:position toPosition:DWPositionMake(position.row, position.column +1) isCollect:isShowCollect];
        if(shouldReload){
            [self reloadData];
        }
    }else if(posX <= 0-columnWidth){
        [self.delegate gridView:self didMoveCell:[self.delegate gridView:self cellAtPosition:position] fromPosition:position toPosition:DWPositionMake(position.row, position.column -1) isCollect:isShowCollect];
        if(shouldReload){
            [self reloadData];
        }
    }
}

-(void)moveCellAtPosition:(DWPosition)position verticallyBy:(CGFloat)velocity withTranslation:(CGPoint)translation reloadingData:(BOOL)shouldReload{
    for(int i = -outerOffset; i< _numberOfVisibleRowsInGrid+outerOffset; i++){
        UIView *cell = [self viewWithTag:[self tagForPosition:DWPositionMake(i, position.column)]];
        CGPoint center = cell.center;
        center.y += translation.y;
        cell.center = center;
    }
    
    UIView *cell = [self viewWithTag:[self tagForPosition:DWPositionMake(0, position.column)]];
    CGFloat height = self.bounds.size.height;
    CGFloat rowHeight = height / _numberOfVisibleRowsInGrid;
    CGFloat posY = cell.frame.origin.y;
    if(posY >= rowHeight){
        [self.delegate gridView:self didMoveCell:[self.delegate gridView:self cellAtPosition:position] fromPosition:position toPosition:DWPositionMake(position.row +1, position.column) isCollect:isShowCollect];
        if(shouldReload){
            [self reloadData];
        }
    }else if(posY <= 0-rowHeight){
        [self.delegate gridView:self didMoveCell:[self.delegate gridView:self cellAtPosition:position] fromPosition:position toPosition:DWPositionMake(position.row -1, position.column) isCollect:isShowCollect];
        if(shouldReload){
            [self reloadData];
        }
    }
}

#pragma mark - 以下是自己的方法

-(void)stopslide{
    
    if(_easeOutTimer){
        [_easeOutTimer invalidate];
        //[_easeOutTimer finalize];
        _easeOutTimer = nil;
    }
    
    if(_easeThread){
        [_easeThread cancel];
        _easeThread = nil;
    }
}

#pragma mark 刷新使图片停止移动
- (void)resetView {
    if(_easeOutTimer){
        [_easeOutTimer invalidate];
        //[_easeOutTimer finalize];
        _easeOutTimer = nil;
    }
    
    if(_easeThread){
        [_easeThread cancel];
        _easeThread = nil;
    }
    
    [self reloadData];
    _isMovingHorizontally = NO;
    _isMovingVertically = NO;
}

#pragma mark 点击某张图片使他移出
//点击某张图时显示具体产品信息
- (void)tapOneCell:(UITapGestureRecognizer*)sender {
    if (_easeOutTimer||_easeThread) {
        [self stopslide];
        [self reloadData];
        return;
    }
    
    
    DWPosition touchPosition = [self determinePositionAtPoint:[sender locationInView:self]];
    touchCell = [self.delegate gridViewDict:self cellAtPosition:touchPosition];
    int idx = [[[touchCell objectForKey:@"ImagDict"] objectForKey:@"Seq"]intValue];
    if (idx == 0) {
        return ;
    }
    if (idx == 40) {
        idx = 21;
    }
    [self goToDetail:idx];
}

- (void)goToDetail:(int)productIdx{
    if (isMoveing||isMoveOut ) {
        return ;
    }
    
    if (_easeOutTimer||_easeThread) {
        [self stopslide];
        [self reloadData];
    }
    else{
        //获取点击的图片内容
        if (isShowCollect) {
            isMoveOutAndShowCollect = YES;
        }
        isMoveing = YES;
        [_panRecognizer setEnabled:NO];
        
        //int chooseTag = [[[touchCell objectForKey:@"ImagDict"] objectForKey:@"Seq"]intValue];
        int chooseTag = productIdx;
        scrollImageView_ = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, centerView.width, centerView.height)];
        scrollImageView_.userInteractionEnabled = YES;
        scrollImageView_.pagingEnabled = YES;
        scrollImageView_.delegate = self;
        scrollImageView_.backgroundColor = [UIColor whiteColor];
        [centerView addSubview:scrollImageView_];
        
        int left = 0;
        int offsetX = 0;
        for (int i=0; i<[[DataManager sharedManager] getCurrentArray].count; i++) {
            if (((selectType==1002 || selectType==1000) && !isShowCollect) || [[DataManager sharedManager] getCurrentArray].count==40) {
                if (i==[[DataManager sharedManager]getCurrentArray].count-1) {
                    continue;
                }
            }
            NSDictionary* one = [[[DataManager sharedManager]getCurrentArray] objectAtIndex:i];
            
            DetailScrollView* v = [[DetailScrollView alloc]initWithData:
                                   CGRectMake(left*scrollImageView_.width, 0,
                                              scrollImageView_.width, scrollImageView_.height)
                                                                withNum:[[one objectForKey:@"Seq"]intValue]];
            v.tag = i;
            if ([[one objectForKey:@"Seq"]intValue] == chooseTag) {
                offsetX = left;
            }
            [scrollImageView_ addSubview:v];
            [subPages_ addObject:v];
            scrollImageView_.contentSize = CGSizeMake(v.right, scrollImageView_.height);
            left++;
        }
        [scrollImageView_ setContentOffset:CGPointMake(scrollImageView_.width*offsetX, 0)];
        
        [centerView sendSubviewToBack:scrollImageView_];
        
        if (!isShowCollect) {
            [self resetbt];
            [twobt setBackgroundImage:getBundleImage(@"btMenuTwoON.png") forState:UIControlStateNormal];
        }
        
        //开始做图片移动
        for(int row = 0; row < _numberOfVisibleRowsInGrid; row++)
        {
            //loop through the columns with 2 left and 2 right of the screen
            for(int column = 0; column < _numberOfVisibleColumnsInGrid; column++)
            {
                DWPosition cellPosition = DWPositionMake(row, column);
                DWGridViewCell *cell = [self.delegate gridView:self cellAtPosition:cellPosition];
                cell.tag = [self tagForPosition:cellPosition];
                //[centerView sendSubviewToBack:cell];
                
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.8f];
                
                if (column%2==0) {//往上移动
                    [UIView setAnimationDelay:row*0.1f];
                    //cell.origin = CGPointMake(cell.origin.x,0);
                    
                    cell.bottom = -cell.frame.size.height;
                    
                } else {
                    [UIView setAnimationDelay:(_numberOfVisibleRowsInGrid-row-1)*0.1f];
                    
                    cell.top = self.frame.size.height+cell.frame.size.height;
                    
                }
                [UIView commitAnimations];
                
            }
        }
        [self performSelector:@selector(refreshPage) withObject:nil afterDelay:0.5f];
        [self performSelector:@selector(onMoveOut) withObject:nil afterDelay:1.3];
    }
}

//点击结束时动作，为避免重复按重复动作而设置变量
- (void)onMoveOut {
    isMoveOut = YES;
    isMoveing = NO;
}

#pragma mark 点击收藏按钮
//收藏按钮
- (void)onCollect:(NSNotification*)sender {
    NSString * msg = @"取消产品收藏成功";
    touchCell = [self.delegate gridViewDict:self cellByIndex:[(NSNumber*)sender.object intValue]];
    if (![[[touchCell objectForKey:@"ImagDict"] objectForKey:@"Collect"]boolValue]) {
        msg = @"收藏产品成功";
    }

    //[self.delegate collect:self collectPosition:DWPositionMake([[touchCell objectForKey:@"Row"]intValue],[[touchCell objectForKey:@"Column"]intValue]) ];
    [self.delegate collect:[(NSNumber*)sender.object intValue]];
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//    [alert show];
    [WaitTooles showHUD:msg];
    RunBlockAfterDelay(1.0, ^(){
        [WaitTooles removeHUD];
    });
}

#pragma mark 左视图一些按钮点击事件
//显示左侧导航栏
- (void)onShowLeftView:(UITapGestureRecognizer*)sender {
    UIImageView* v1 = (UIImageView*)[sender.view viewWithTag:99];
    //UIImageView* v2 = (UIImageView*)[sender.view viewWithTag:200];
    if (!isShowLeftView) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(onSwitchStop)];
        leftView.left = 0;
        //v1.center = CGPointMake(v2.centerX+7, v2.centerY-5);//(32, 18);
        //v1.center = CGPointMake(sender.view.width/2+2, sender.view.height/2-19);
        v1.center = CGPointMake(switchBG.width/2+3, switchBG.height/2+24);
        [UIView commitAnimations];
    } else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(onSwitchStop)];
        leftView.right = 0;
        //v1.center = CGPointMake(v2.centerX-7, v2.centerY+9);//CGPointMake(18, 32);
        //v1.center = CGPointMake(sender.view.width/2-18, sender.view.height/2);
        v1.center = CGPointMake(switchBG.width/2-25, switchBG.height/2-3);
        [UIView commitAnimations];
    }
    isShowLeftView = !isShowLeftView;
}

- (void)hideLeftView:(NSNotification *)notification{
    UIImageView* v1 = (UIImageView*)[switchBG viewWithTag:99];
    //UIImageView* v2 = (UIImageView*)[sender.view viewWithTag:200];
    if (isShowLeftView) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(onSwitchStop)];
        leftView.right = 0;
        v1.center = CGPointMake(switchBG.width/2-25, switchBG.height/2-3);
        [UIView commitAnimations];
        
        isShowLeftView = !isShowLeftView;
    }
}

- (void)onShowLeftViewByPan:(UIPanGestureRecognizer*)sender {
    UIImageView* bg = (UIImageView*)sender.view;
    UIImageView* view = (UIImageView*)[sender.view viewWithTag:99];
    //UIImageView* v2 = (UIImageView*)[sender.view viewWithTag:200];
    if (sender.state == UIGestureRecognizerStateBegan) {
        oldPoint = [sender locationInView:sender.view];
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        newPoint = [sender locationInView:sender.view];
        view.center = newPoint;
//        if (view.centerX < v2.centerX-7) {
//            view.centerX = v2.centerX-7;
//        }
//        if (view.centerX > v2.centerX+7) {
//            view.centerX = v2.centerX+7;
//        }
//        view.centerY = v2.centerX-7+v2.centerX-7+14-view.centerX;
        if (view.centerX < bg.width/2-18) {
            view.centerX = bg.width/2-18;
        }
        if (view.centerX > bg.width/2+2) {
            view.centerX = bg.width/2+2;
        }
        view.centerY = bg.width/2-18+bg.width/2-18+18-view.centerX;
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        newPoint = [sender locationInView:sender.view];
        if (!isShowLeftView) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.3f];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(onSwitchStop)];
            leftView.left = 0;
            //view.center = CGPointMake(v2.centerX+7, v2.centerY-5);//(32, 18);
            view.center = CGPointMake(sender.view.width/2+2, sender.view.height/2-19);
            [UIView commitAnimations];
        } else {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.3f];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(onSwitchStop)];
            leftView.right = 0;
            //view.center = CGPointMake(v2.centerX-7, v2.centerY+9);//(18, 32);
            view.center = CGPointMake(sender.view.width/2-18, sender.view.height/2);
            [UIView commitAnimations];
        }
        isShowLeftView = !isShowLeftView;
    }
}

//按钮结束动作
- (void)onSwitchStop {
    if (isShowLeftView) {
        UIImageView* v2 = (UIImageView*)[switchBG viewWithTag:100];
        v2.image = getBundleImage(@"switchOFF.png");
        UIImageView* v3 = (UIImageView*)[switchBG viewWithTag:101];
        v3.image = getBundleImage(@"switchON.png");
    } else {
        UIImageView* v2 = (UIImageView*)[switchBG viewWithTag:100];
        v2.image = getBundleImage(@"switchON.png");
        UIImageView* v3 = (UIImageView*)[switchBG viewWithTag:101];
        v3.image = getBundleImage(@"switchOFF.png");
    }
}

- (void)changeCollectArray:(NSNotification*)sender {
    isCollectArrayChange = [(NSNumber*)sender.object boolValue];
}

#pragma mark 点击还原
//回到主目录界面时动画
- (void)restore {
    if (isMoveing) {
        return ;
    }
    [self resetbt];
    [onebt setBackgroundImage:getBundleImage(@"btMenuOneON.png") forState:UIControlStateNormal];
    
    //BOOL change = [[DataManager sharedManager]changeFlag:0];
    
    if (introScroll) {
        self.panRecognizer.enabled = YES;
        self.tapRecognizer.enabled = YES;
        [introPages_ removeAllObjects];
        [introScroll removeFromSuperview];
        introScroll = nil;
        if (introPageController) {
            [introPageController removeFromSuperview];
            introPageController = nil;
        }
    }
    if ((isRotota || isShowCollect) && !isMoveOut) {
        [self resetView];
        [[DataManager sharedManager] setIsShowCollect:NO];
        [[DataManager sharedManager] resetArray:selectType-1000];
        isMoveing = YES;
        //从收藏板块变化而来的动画
        [self stopslide];
        
        float du = 0.0f;
        
        for(int row = 0; row < _numberOfVisibleRowsInGrid; row++)
        {
            //loop through the columns with 2 left and 2 right of the screen
            for(int column = 0; column < _numberOfVisibleColumnsInGrid; column++)
            {
                DWPosition cellPosition = DWPositionMake(row, column);
                DWGridViewCell *cell = [self.delegate gridView:self cellAtPosition:cellPosition];
                NSMutableDictionary* dic = [self.delegate gridViewDict:self cellAtPosition:cellPosition];
                cell.tag = [self tagForPosition:cellPosition];
                
                UIImageView* cellimg = (UIImageView*) [cell viewWithTag:100];
                du = 0.1f*(row+column);
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                                       forView:cell cache:YES];
                [UIView setAnimationDuration:0.8];
                [UIView setAnimationDelay:du];

                
                //NSDictionary * imageDict = [[DataManager sharedManager] getCellImageFromQueue];
                NSDictionary * imageDict = [[DataManager sharedManager] getProByType];
                
                if (imageDict) {
                    cellimg.image =[imageDict objectForKey:@"Image"];
                    [dic setObject:imageDict forKey:@"ImagDict"];
                } else {
                    imageDict = [[DataManager sharedManager]getBlankdic];
                    cellimg.image =[imageDict objectForKey:@"Image"];
                    [dic setObject:imageDict forKey:@"ImagDict"];
                }
//                CGRect cellFrame;
//                cellFrame.size.width = self.bounds.size.width / _numberOfVisibleColumnsInGrid;
//                cellFrame.size.height = self.bounds.size.height / _numberOfVisibleRowsInGrid;
//                cellFrame.origin.x = column * cellFrame.size.width;
//                cellFrame.origin.y = row * cellFrame.size.height;
//                cell.frame = cellFrame;
                [UIView commitAnimations];
            }
        }
        
        //NSDictionary* outerImgDict = [[DataManager sharedManager] getCellImageFromQueue];
        NSDictionary * outerImgDict = [[DataManager sharedManager] getProByType];
        for(int row = 0; row < _numberOfRowsInGrid; row++)
        {
            for(int column = 0; column < _numberOfColumnsInGrid; column++)
            {
                
                if (row>=_numberOfVisibleRowsInGrid||column>=_numberOfVisibleColumnsInGrid) {
                    
                    DWPosition cellPosition = DWPositionMake(row, column);
                    DWGridViewCell *cell = [self.delegate gridView:self cellAtPosition:cellPosition];
                    NSMutableDictionary* dic = [self.delegate gridViewDict:self cellAtPosition:cellPosition];
                    cell.tag = [self tagForPosition:cellPosition];
                    
                    UIImageView* cellimg = (UIImageView*) [cell viewWithTag:100];
                    
                    if (outerImgDict) {
                        cellimg.image =[outerImgDict objectForKey:@"Image"];
                        [dic setObject:outerImgDict forKey:@"ImagDict"];
                    }
                    else{
                        outerImgDict = [[DataManager sharedManager]getBlankdic];
                        cellimg.image =[outerImgDict objectForKey:@"Image"];
                        [dic setObject:outerImgDict forKey:@"ImagDict"];
                    }
                    
                }
            }
        }
        [self performSelector:@selector(onRototaToNormalStop) withObject:nil afterDelay:1];
    }
    else if (isMoveOut) {
        //从详细页面板块变化而来的动画
        isMoveing = YES;
        if (isMoveOutAndShowCollect) {
            [[DataManager sharedManager] setIsShowCollect:NO];
            [[DataManager sharedManager] resetArray:selectType-1000];
            [self reloadData];
        }
        
        
        //开始做图片移动
        for(int row = 0; row < _numberOfVisibleRowsInGrid; row++)
        {
            //loop through the columns with 2 left and 2 right of the screen
            for(int column = 0; column < _numberOfVisibleColumnsInGrid; column++)
            {
                DWPosition cellPosition = DWPositionMake(row, column);
                DWGridViewCell *cell = [self.delegate gridView:self cellAtPosition:cellPosition];
                NSMutableDictionary* dic = [self.delegate gridViewDict:self cellAtPosition:cellPosition];
                cell.tag = [self tagForPosition:cellPosition];
                
                CGPoint tmpstore = cell.origin;
                
                
                //设置图片移动回来前外边位置
                if (column%2==0) {
                    cell.bottom = -cell.frame.size.height;
                } else {
                    cell.top = self.frame.size.height+cell.frame.size.height;
                }
                
                UIImageView* cellimg = (UIImageView*) [cell viewWithTag:100];
                
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:1.0f];

                if (column%2==0) {
                    [UIView setAnimationDelay:(_numberOfVisibleRowsInGrid-row-1)*0.2f];                    
                } else {                    
                    [UIView setAnimationDelay:row*0.2f];                    
                }
                
                if (isMoveOutAndShowCollect) {
                    //如果是从收藏的详细内容进来则要进行转换
                    NSDictionary * imageDict = [[DataManager sharedManager] getProByType];
                    if (imageDict) {
                        cellimg.image =[imageDict objectForKey:@"Image"];
                        [dic setObject:imageDict forKey:@"ImagDict"];
                    }
                    else{
                        imageDict = [[DataManager sharedManager]getBlankdic];
                        cellimg.image =[imageDict objectForKey:@"Image"];
                        [dic setObject:imageDict forKey:@"ImagDict"];
                    }
                    cell.origin = tmpstore;
                } else {
                    CGRect cellFrame;
                    cellFrame.size.width = self.bounds.size.width / _numberOfVisibleColumnsInGrid;
                    cellFrame.size.height = self.bounds.size.height / _numberOfVisibleRowsInGrid;
                    cellFrame.origin.x = column * cellFrame.size.width;
                    cellFrame.origin.y = row * cellFrame.size.height;
                    cell.frame = cellFrame;
                }
            
                [UIView commitAnimations];
            }
        }
        
        //if (change) {
            
//            NSDictionary* outerImgDict = [[DataManager sharedManager] getCellImageFromQueue];
//            for(int row = 0; row < _numberOfRowsInGrid; row++)
//            {
//                //loop through the columns with 2 left and 2 right of the screen
//                for(int column = 0; column < _numberOfColumnsInGrid; column++)
//                {
//                    
//                    if (row>=_numberOfVisibleRowsInGrid||column>=_numberOfVisibleColumnsInGrid) {
//                        
//                        DWPosition cellPosition = DWPositionMake(row, column);
//                        DWGridViewCell *cell = [self.delegate gridView:self cellAtPosition:cellPosition];
//                        NSMutableDictionary* dic = [self.delegate gridViewDict:self cellAtPosition:cellPosition];
//                        cell.tag = [self tagForPosition:cellPosition];
//                        
//                        UIImageView* cellimg = (UIImageView*) [cell viewWithTag:100];
//                        
//                        if (outerImgDict) {
//                            cellimg.image =[outerImgDict objectForKey:@"Image"];
//                            [dic setObject:outerImgDict forKey:@"ImagDict"];
//                        }
//                        else{
//                            outerImgDict = [[DataManager sharedManager]getBlankdic];
//                            
//                            cellimg.image =[outerImgDict objectForKey:@"Image"];
//                            [dic setObject:outerImgDict forKey:@"ImagDict"];
//                        }
//                        
//                    }
//                }
//            }
        //}
        
        //将底图设置为透明
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:2.0f];        
        chooseView_.alpha =0;
        scrollImageView_.alpha = 0;
        for (UIView* v in centerView.subviews) {
            if ([v isKindOfClass:[UIButton class]]) {
                v.alpha = 0;
            }
        }
        [UIView commitAnimations];
        [self performSelector:@selector(onMoveRestore:) withObject:[NSNumber numberWithBool:NO] afterDelay:2];
    }
}

//当回到主页面动画结束时调用，设置一些标志变量
- (void)onMoveRestore:(NSNumber*)is {
    [_panRecognizer setEnabled:YES];
    isMoveOut = NO;
    isMoveing = NO;
    isMoveOutAndShowCollect = NO;
    isShowCollect = [is boolValue];
    isRotota = [is boolValue];
    isCollectArrayChange = NO;
    if (chooseView_) {
        [chooseView_ removeFromSuperview];
        chooseView_ = nil;
    }
    if (scrollImageView_) {
        [scrollImageView_ removeFromSuperview];
        scrollImageView_ = nil;
    }
    [subPages_ removeAllObjects];
    for (UIView* v in centerView.subviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            [v removeFromSuperview];
        }
    }
}


//设置旋转动画
- (void)rotota {
    if (isMoveing || isShowCollect || isMoveOut) {
        return ;
    }
    isMoveing = YES;
    [self stopslide];
    [self reloadData];

    float du = 0.0f;
    //开始做图片旋转

    for(int row = 0; row < _numberOfVisibleRowsInGrid; row++)
    {
        //loop through the columns with 2 left and 2 right of the screen
        for(int column = 0; column <= _numberOfVisibleColumnsInGrid; column++)
        {
            DWPosition cellPosition = DWPositionMake(row, column);
            DWGridViewCell *cell = [self.delegate gridView:self cellAtPosition:cellPosition];
            NSDictionary* dic = [self.delegate gridViewDict:self cellAtPosition:cellPosition];
            cell.tag = [self tagForPosition:cellPosition];
            
            UIImageView* cellimg = (UIImageView*) [cell viewWithTag:100];
            du = 0.1f*(row+column);
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                                   forView:cell cache:YES];
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationDelay:du];
            
            if ([[[dic objectForKey:@"ImagDict"] objectForKey:@"Collect"]boolValue]==NO) {
                cellimg.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic3.png"]];
                //cellimg.backgroundColor = [UIColor grayColor];
            }
            
            [UIView commitAnimations];
        }
    }
    [self performSelector:@selector(onRototaToCollectStop) withObject:nil afterDelay:1];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
   
}

//旋转动画结束时的动作，设置一些标志变量和VIEW显示情况

//- (void)onRototaStop:(NSNumber*)sender {
//    isShowCollect = !isShowCollect;
//    isMoveing = NO;
//    isRotota = !isRotota;
//}

- (void)onRototaToCollectStop {
    isShowCollect = YES;
    isRotota = YES;
    isMoveing = NO;
    isCollectArrayChange = NO;
}

- (void)onRototaToNormalStop {
    isShowCollect = NO;
    isRotota = NO;
    isMoveing = NO;
}

- (void)resetbt {
    [onebt setBackgroundImage:getBundleImage(@"btMenuOne.png") forState:UIControlStateNormal];
    [twobt setBackgroundImage:getBundleImage(@"btMenuTwo.png") forState:UIControlStateNormal];
    [threebt setBackgroundImage:getBundleImage(@"btMenuThree.png") forState:UIControlStateNormal];
}

#pragma mark 点击顺序阅读
- (void)showFirstPic {
    if (isMoveing || _easeOutTimer || _easeThread) {
        return ;
    }
    if (introScroll) {
        self.panRecognizer.enabled = YES;
        self.tapRecognizer.enabled = YES;
        [introPages_ removeAllObjects];
        [introScroll removeFromSuperview];
        introScroll = nil;
    }
    if (introPageController) {
        [introPageController removeFromSuperview];
        introPageController = nil;
    }
    [self resetbt];
    [twobt setBackgroundImage:getBundleImage(@"btMenuTwoON.png") forState:UIControlStateNormal];
    if (isMoveOut) {
        if (isShowCollect) {
//            if ([[DataManager sharedManager] getCurrentArray].count > 0) {
//                NSDictionary* dic = [[[DataManager sharedManager] getCurrentArray] objectAtIndex:0];
//                int idx = [[dic objectForKey:@"Seq"]intValue];
//                
//                [scrollImageView_ setContentOffset:CGPointMake(idx*scrollImageView_.width, 0) animated:NO];
//                if (selectType == 1000) {
//                    isShowAircondition = NO;
//                    isShowCar = NO;
//                } else if (selectType == 1001) {
//                    isShowAircondition = YES;
//                    isShowCar = NO;
//                } else if (selectType == 1002) {
//                    isShowAircondition = NO;
//                    isShowCar = YES;
//                }
//            }
            isShowCollect = NO;
            [[DataManager sharedManager] setIsShowCollect:NO];
            [[DataManager sharedManager] resetArray:selectType-1000];
            [scrollImageView_ removeAllSubviews];
            [subPages_ removeAllObjects];
            for (int i=0; i<[[DataManager sharedManager] getCurrentArray].count; i++) {
                if ((selectType==1002||selectType==1000) && !isShowCollect) {
                    if (i==[[DataManager sharedManager] getCurrentArray].count-1) {
                        continue;
                    }
                }
                NSDictionary* one = [[[DataManager sharedManager]getCurrentArray] objectAtIndex:i];
                
                DetailScrollView* v = [[DetailScrollView alloc]initWithData:
                                       CGRectMake(i*scrollImageView_.width, 0,
                                                  scrollImageView_.width, scrollImageView_.height)
                                                                    withNum:[[one objectForKey:@"Seq"]intValue]];
                v.tag = i;
                [scrollImageView_ addSubview:v];
                [subPages_ addObject:v];
                scrollImageView_.contentSize = CGSizeMake(v.right, scrollImageView_.height);
                [scrollImageView_ setContentOffset:CGPointMake(0, 0) animated:NO];
            }
        } //else {
            if (selectType == 1000 || selectType == 1001) {
                if (selectType == 1000) {
                    isShowAircondition = NO;
                    isShowCar = NO;
                } else if (selectType == 1001) {
                    isShowAircondition = YES;
                    isShowCar = NO;
                }
            } else if (selectType == 1002) {
                //[scrollImageView_ setContentOffset:CGPointMake(21*scrollImageView_.width, 0) animated:NO];
                isShowAircondition = NO;
                isShowCar = YES;
            }
        //}
        [self refreshPage];
    } else {
        if (isShowCollect) {
//            if ([[DataManager sharedManager] getCurrentArray].count > 0) {
//                NSDictionary* dic = [[[DataManager sharedManager] getCurrentArray] objectAtIndex:0];
//                [self goToDetail:[[dic objectForKey:@"Seq"]intValue]];
//            }
            isShowCollect = NO;
            [[DataManager sharedManager] setIsShowCollect:NO];
            [[DataManager sharedManager] resetArray:selectType-1000];
            isMoveOutAndShowCollect = YES;
        } //else {
            if (selectType==1002) {
                [self goToDetail:22];
            } else {
                [self goToDetail:1];
            }
        //}
    }
}

#pragma mark 点击显示收藏板块
- (void)moveAndRotota {
    if (introScroll) {
        self.panRecognizer.enabled = YES;
        self.tapRecognizer.enabled = YES;
        [introPages_ removeAllObjects];
        [introScroll removeFromSuperview];
        introScroll = nil;
    }
    if (introPageController) {
        [introPageController removeFromSuperview];
        introPageController = nil;
    }
    
    if (isMoveing || (isShowCollect && !isMoveOut)) {
        return ;
    }
    
    [self resetbt];
    //[self reloadData];
    [threebt setBackgroundImage:getBundleImage(@"btMenuThreeON.png") forState:UIControlStateNormal];
    
    //BOOL change = [[DataManager sharedManager]changeFlag:1];
    
    [[DataManager sharedManager] setIsShowCollect:YES];
    if (!isShowCollect || isCollectArrayChange) {
        [[DataManager sharedManager] resetArray:selectType-1000];
        [self reloadData];
    }
    
    BOOL is = NO;
    int numCollect = [[DataManager sharedManager]getCollect].count;
    int numBlank = ALLPRODUCT-numCollect;
    if (numCollect<ALLPRODUCT) {
        is = YES;
    }
    
    if (isMoveOut) {
        isMoveing = YES;
        [self resetView];
        
        //开始做图片移动
        int showCollect = 0;
        int showBlank = 0;
        //int number = 0;
        for(int row = 0; row < _numberOfVisibleRowsInGrid; row++)
        {
            //loop through the columns with 2 left and 2 right of the screen
            for(int column = 0; column < _numberOfVisibleColumnsInGrid; column++)
            {
                DWPosition cellPosition = DWPositionMake(row, column);
                DWGridViewCell *cell = [self.delegate gridView:self cellAtPosition:cellPosition];
                NSMutableDictionary* dic = [self.delegate gridViewDict:self cellAtPosition:cellPosition];
                cell.tag = [self tagForPosition:cellPosition];
                
                CGPoint tmpstore = cell.origin;
                
                //设置图片移动回来前外边位置
                if (column%2==0) {
                    cell.bottom = -cell.frame.size.height;
                } else {
                    cell.top = self.frame.size.height+cell.frame.size.height;
                }
                
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:1.0f];
                
                if (column%2==0) {
                    [UIView setAnimationDelay:(_numberOfVisibleRowsInGrid-row-1)*0.2f];
                } else {
                    [UIView setAnimationDelay:row*0.2f];
                }
                UIImageView* cellimg = (UIImageView*) [cell viewWithTag:100];
                
                if (!isShowCollect || isCollectArrayChange) {
                    int r = rand()%2;
                    if (r == 0 && showCollect<numCollect && is && showBlank<numBlank ) {
                        NSDictionary* mydic = [[DataManager sharedManager]getBlankdic];
                        cellimg.image =[mydic objectForKey:@"Image"];
                        [dic setObject:mydic forKey:@"ImagDict"];
                        showBlank++;
                    } else {
                        NSDictionary * imageDict = [[DataManager sharedManager] getProByType];
                        
                        if (imageDict) {
                            cellimg.image =[imageDict objectForKey:@"Image"];
                            [dic setObject:imageDict forKey:@"ImagDict"];
                        }
                        else{
                            imageDict = [[DataManager sharedManager]getBlankdic];
                            
                            cellimg.image =[imageDict objectForKey:@"Image"];
                            [dic setObject:imageDict forKey:@"ImagDict"];
                        }
                    }
                    //}
                    
                    cell.origin = tmpstore;
                } else {
                    CGRect cellFrame;
                    cellFrame.size.width = self.bounds.size.width / _numberOfVisibleColumnsInGrid;
                    cellFrame.size.height = self.bounds.size.height / _numberOfVisibleRowsInGrid;
                    cellFrame.origin.x = column * cellFrame.size.width;
                    cellFrame.origin.y = row * cellFrame.size.height;
                    cell.frame = cellFrame;
                }
                
                cell.layer.transform = CATransform3DConcat(cell.layer.transform, CATransform3DMakeRotation(M_PI,0.0,1.0,0.0));
                cell.layer.transform = CATransform3DConcat(cell.layer.transform, CATransform3DMakeRotation(M_PI,0.0,1.0,0.0));
                
                [UIView commitAnimations];
            }
        }
        
        
        if (!isShowCollect || isCollectArrayChange) {
            NSDictionary * outerImgDict = [[DataManager sharedManager] getProByType];
            for(int row = 0; row < _numberOfRowsInGrid; row++)
            {
                //loop through the columns with 2 left and 2 right of the screen
                for(int column = 0; column < _numberOfColumnsInGrid; column++)
                {
                    if (row>=_numberOfVisibleRowsInGrid||column>=_numberOfVisibleColumnsInGrid) {
                        
                        DWPosition cellPosition = DWPositionMake(row, column);
                        DWGridViewCell *cell = [self.delegate gridView:self cellAtPosition:cellPosition];
                        NSMutableDictionary* dic = [self.delegate gridViewDict:self cellAtPosition:cellPosition];
                        cell.tag = [self tagForPosition:cellPosition];
                        
                        UIImageView* cellimg = (UIImageView*) [cell viewWithTag:100];
                        
                        if (outerImgDict) {
                            cellimg.image =[outerImgDict objectForKey:@"Image"];
                            [dic setObject:outerImgDict forKey:@"ImagDict"];
                        }
                        else{
                            outerImgDict = [[DataManager sharedManager]getBlankdic];
                            
                            cellimg.image =[outerImgDict objectForKey:@"Image"];
                            [dic setObject:outerImgDict forKey:@"ImagDict"];
                        }
                    }
                }
            }
        }
        
        //将底图设置为透明
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:2.0f];
        chooseView_.alpha =0;
        scrollImageView_.alpha=0;
        [UIView commitAnimations];    
        [self performSelector:@selector(onMoveRestore:) withObject:[NSNumber numberWithBool:YES] afterDelay:2];
    } else if (!isRotota) {
        isMoveing = YES;
        //[self stopslide];
        //[self reloadData];
        [self resetView];
        
        float du = 0.0f;
        
        //将队列数据在收藏和所有产品之间进行切换
        
        //开始做图片旋转
        int showCollect = 0;
        int showBlank = 0;
        for(int row = 0; row < _numberOfVisibleRowsInGrid; row++)
        {
            //loop through the columns with 2 left and 2 right of the screen
            for(int column = 0; column < _numberOfVisibleColumnsInGrid; column++)
            {
                DWPosition cellPosition = DWPositionMake(row, column);
                DWGridViewCell *cell = [self.delegate gridView:self cellAtPosition:cellPosition];
                NSMutableDictionary* dic = [self.delegate gridViewDict:self cellAtPosition:cellPosition];
                cell.tag = [self tagForPosition:cellPosition];
                
                UIImageView* cellimg = (UIImageView*) [cell viewWithTag:100];
                du = 0.1f*(row+column);
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                                       forView:cell cache:YES];
                [UIView setAnimationDuration:0.5];
                [UIView setAnimationDelay:du];
                
//                if ([[[dic objectForKey:@"ImagDict"] objectForKey:@"Collect"]boolValue]==NO) {
//                    cellimg.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic3.png" ]];
//                }

                int r = rand()%2;
                if (r == 0 && showCollect<numCollect && is && showBlank<numBlank ) {
                    NSDictionary* mydic = [[DataManager sharedManager]getBlankdic];
                    cellimg.image =[mydic objectForKey:@"Image"];
                    [dic setObject:mydic forKey:@"ImagDict"];
                    showBlank++;
                } else {
                    //NSDictionary * imageDict = [[DataManager sharedManager] getCellImageFromQueue];
                    NSDictionary * imageDict = [[DataManager sharedManager] getProByType];
                    
                    if (imageDict) {
                        cellimg.image =[imageDict objectForKey:@"Image"];
                        [dic setObject:imageDict forKey:@"ImagDict"];
                        showCollect++;
                    }
                    else{
                        imageDict = [[DataManager sharedManager]getBlankdic];
                        cellimg.image =[imageDict objectForKey:@"Image"];
                        [dic setObject:imageDict forKey:@"ImagDict"];
                    }
                }
                
                [UIView commitAnimations];
            }
            
        }
        
        //NSDictionary* outerImgDict = [[DataManager sharedManager] getCellImageFromQueue];
        NSDictionary * outerImgDict = [[DataManager sharedManager] getProByType];
        for(int row = 0; row < _numberOfRowsInGrid; row++)
        {
            //loop through the columns with 2 left and 2 right of the screen
            for(int column = 0; column < _numberOfColumnsInGrid; column++)
            {
                if (row>=_numberOfVisibleRowsInGrid||column>=_numberOfVisibleColumnsInGrid) {
                    
                    DWPosition cellPosition = DWPositionMake(row, column);
                    DWGridViewCell *cell = [self.delegate gridView:self cellAtPosition:cellPosition];
                    NSMutableDictionary* dic = [self.delegate gridViewDict:self cellAtPosition:cellPosition];
                    cell.tag = [self tagForPosition:cellPosition];
                    
                    UIImageView* cellimg = (UIImageView*) [cell viewWithTag:100];
                    
                    if (outerImgDict) {
                        cellimg.image =[outerImgDict objectForKey:@"Image"];
                        [dic setObject:outerImgDict forKey:@"ImagDict"];
                    }
                    else{
                        outerImgDict = [[DataManager sharedManager]getBlankdic];
                        
                        cellimg.image =[outerImgDict objectForKey:@"Image"];
                        [dic setObject:outerImgDict forKey:@"ImagDict"];
                    }
                }
            }
        }
        [self performSelector:@selector(onRototaToCollectStop) withObject:nil afterDelay:1];
    }
}

- (void)resetTypebt {
    for (int i=0; i<arraybt.count; i++) {
        UIButton* b1 = [arraybt objectAtIndex:i];
        if (b1.tag == 1000) {
            [b1 setImage:getBundleImage(@"classifyOFF.png") forState:UIControlStateNormal];
        } else if (b1.tag == 1001) {
            [b1 setImage:getBundleImage(@"classifyBLUEOFF.png") forState:UIControlStateNormal];
        } else if (b1.tag == 1002) {
            [b1 setImage:getBundleImage(@"classifyREDOFF.png") forState:UIControlStateNormal];
        }
    }
}

#pragma mark 显示空调或者汽车
- (void)onChangeBG:(id)sender {
    UIButton* b = (UIButton*)sender;
    if (isMoveing || (isShowAircondition && b.tag == 1001) || (isShowCar && b.tag == 1002) || (                                                                                               !isShowAircondition && !isShowCar && b.tag == 1000)) {
        return ;
    }
    if (b.tag == selectType) {
        return;
    }
    selectType = b.tag;
    if (introScroll) {
        self.panRecognizer.enabled = YES;
        self.tapRecognizer.enabled = YES;
        [introPages_ removeAllObjects];
        [introScroll removeFromSuperview];
        introScroll = nil;
    }
    if (introPageController) {
        [introPageController removeFromSuperview];
        introPageController = nil;
    }
    [self resetTypebt];
    if (b.tag==1000) {
        [b setImage:getBundleImage(@"classifyON.png") forState:UIControlStateNormal];
    } else if (b.tag==1001) {
        [b setImage:getBundleImage(@"classifyBLUE.png") forState:UIControlStateNormal];
    } else if (b.tag==1002) {
        [b setImage:getBundleImage(@"classifyRED.png") forState:UIControlStateNormal];
    }
    if (isMoveOut) {
        [scrollImageView_ removeAllSubviews];
        [subPages_ removeAllObjects];
        [[DataManager sharedManager] resetArray:b.tag-1000];
        for (int i=0; i<[[DataManager sharedManager] getCurrentArray].count; i++) {
            if (selectType==1002 && !isShowCollect) {
                if (i==[[DataManager sharedManager] getCurrentArray].count-1) {
                    continue;
                }
            }
            NSDictionary* one = [[[DataManager sharedManager]getCurrentArray] objectAtIndex:i];
            
            DetailScrollView* v = [[DetailScrollView alloc]initWithData:
                                   CGRectMake(i*scrollImageView_.width, 0,
                                              scrollImageView_.width, scrollImageView_.height)
                                                                withNum:[[one objectForKey:@"Seq"]intValue]];
            v.tag = i;
            [scrollImageView_ addSubview:v];
            [subPages_ addObject:v];
            scrollImageView_.contentSize = CGSizeMake(v.right, scrollImageView_.height);
        }
        [scrollImageView_ setContentOffset:CGPointMake(0, 0)];
        scrollImageView_.showsHorizontalScrollIndicator = YES;
        
        if (selectType == 1000) {
            isShowAircondition = NO;
            isShowCar = NO;
        } else if (selectType == 1001) {
            isShowAircondition = YES;
            isShowCar = NO;
        }else if (selectType == 1002) {
            isShowAircondition = NO;
            isShowCar = YES;
        }
        [self refreshPage];
    } else {
        bgV.image = getBundleImage([NSString stringWithFormat:@"bg%d.jpg",b.tag-1000+1]);
        
        [[DataManager sharedManager] resetArray:b.tag-1000];
        //开始显示
        isMoveing = YES;
        [self stopslide];
        [self reloadData];
        
        float du = 0.0f;
        
        //将队列数据在收藏和所有产品之间进行切换
        //开始做图片旋转
        for(int row = 0; row < _numberOfVisibleRowsInGrid; row++)
        {
            //loop through the columns with 2 left and 2 right of the screen
            for(int column = 0; column < _numberOfVisibleColumnsInGrid; column++)
            {
                DWPosition cellPosition = DWPositionMake(row, column);
                DWGridViewCell *cell = [self.delegate gridView:self cellAtPosition:cellPosition];
                NSMutableDictionary* dic = [self.delegate gridViewDict:self cellAtPosition:cellPosition];
                cell.tag = [self tagForPosition:cellPosition];
                
                UIImageView* cellimg = (UIImageView*) [cell viewWithTag:100];
                du = 0.1f*(row+column);
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                                       forView:cell cache:YES];
                [UIView setAnimationDuration:0.5];
                [UIView setAnimationDelay:du];
                
                NSDictionary * imageDict = [[DataManager sharedManager] getProByType];
                
                if (imageDict) {
                    cellimg.image =[imageDict objectForKey:@"Image"];
                    [dic setObject:imageDict forKey:@"ImagDict"];
                }
                else{
                    imageDict = [[DataManager sharedManager]getBlankdic];
                    
                    cellimg.image =[imageDict objectForKey:@"Image"];
                    [dic setObject:imageDict forKey:@"ImagDict"];
                }
                
                [UIView commitAnimations];
            }
            
        }
        
        NSDictionary* outerImgDict = [[DataManager sharedManager] getProByType];
        for(int row = 0; row < _numberOfRowsInGrid; row++)
        {
            //loop through the columns with 2 left and 2 right of the screen
            for(int column = 0; column < _numberOfColumnsInGrid; column++)
            {
                if (row>=_numberOfVisibleRowsInGrid||column>=_numberOfVisibleColumnsInGrid) {
                    
                    DWPosition cellPosition = DWPositionMake(row, column);
                    DWGridViewCell *cell = [self.delegate gridView:self cellAtPosition:cellPosition];
                    NSMutableDictionary* dic = [self.delegate gridViewDict:self cellAtPosition:cellPosition];
                    cell.tag = [self tagForPosition:cellPosition];
                    
                    UIImageView* cellimg = (UIImageView*) [cell viewWithTag:100];
                    
                    if (outerImgDict) {
                        cellimg.image =[outerImgDict objectForKey:@"Image"];
                        [dic setObject:outerImgDict forKey:@"ImagDict"];
                    }
                    else{
                        outerImgDict = [[DataManager sharedManager]getBlankdic];
                        
                        cellimg.image =[outerImgDict objectForKey:@"Image"];
                        [dic setObject:outerImgDict forKey:@"ImagDict"];
                    }
                }
            }
        }
        if (b.tag==1000) {
            [self performSelector:@selector(onShowAllStop) withObject:nil afterDelay:1];
        } else if (b.tag==1001) {
            [self performSelector:@selector(onShowAirconditionStop) withObject:nil afterDelay:1];
        } else if (b.tag==1002) {
            [self performSelector:@selector(onShowCarStop) withObject:nil afterDelay:1];
        }
    }
}

#pragma mark 点击显示企业介绍
- (void)onShowIntro {
    if (introScroll) {
        self.panRecognizer.enabled = YES;
        self.tapRecognizer.enabled = YES;
                [introPages_ removeAllObjects];
        [introScroll removeFromSuperview];
        introScroll = nil;
        if (introPageController) {
            [introPageController removeFromSuperview];
            introPageController = nil;
        }
    } else {
        if(_easeOutTimer){
            [_easeOutTimer invalidate];
            //[_easeOutTimer finalize];
            _easeOutTimer = nil;
        }
        
        if(_easeThread){
            [_easeThread cancel];
            _easeThread = nil;
        }
        
        //[self reloadData];
        _isMovingHorizontally = NO;
        _isMovingVertically = NO;
        
        introScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, centerView.width, centerView.height)];
        introScroll.userInteractionEnabled = YES;
        introScroll.pagingEnabled = YES;
        introScroll.delegate = self;
        introScroll.backgroundColor = [UIColor whiteColor];
        [centerView addSubview:introScroll];
        
        self.panRecognizer.enabled = NO;
        self.tapRecognizer.enabled = NO;
        
        NSArray* arr = [[DataManager sharedManager] getIntroArray];
        for (int i=0; i<arr.count; i++) {
            DetailScrollView* v = [[DetailScrollView alloc]initWithData:
                                   CGRectMake(i*introScroll.width, 0, introScroll.width, introScroll.height)                                                           withNum:i+1+1000];
            v.tag = i;
            [introScroll addSubview:v];
            [introPages_ addObject:v];
        }
        introScroll.contentSize = CGSizeMake(arr.count*introScroll.width, introScroll.height);
        
        introPageController = [[ZZPageControl alloc]initWithFrame:CGRectMake(0, 0, introScroll.width, 20)];
        introPageController.bottom = centerView.height-20;
        introPageController.centerX = centerView.width/2;
        introPageController.numberOfPages = arr.count;//指定页面个数
        introPageController.currentPage = 0;//指定pagecontroll的值，默认选中的小白点（第一个）
        introPageController.fitMode = ZZPageControlModeDots;
        introPageController.activeColor = [UIColor blueColor];
        introPageController.inactiveColor = [UIColor grayColor];
        introPageController.userInteractionEnabled = NO;
        [centerView addSubview:introPageController];
        
        [self refreshIntro];
    }
}

- (void)onShowAllStop {
    isMoveing = NO;
    isShowAircondition = NO;
    isShowCar = NO;
}

- (void)onShowAirconditionStop {
    isMoveing = NO;
    isShowCar = NO;
    isShowAircondition = YES;
}

- (void)onShowCarStop {
    isMoveing = NO;
    isShowAircondition = NO;
    isShowCar = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView == scrollImageView_) {
        [self refreshPage];
    } else if (scrollView == introScroll) {
        introPageController.currentPage = scrollView.contentOffset.x/scrollView.width;
        [self refreshIntro];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        if (scrollView == scrollImageView_) {
            [self refreshPage];
        } else if (scrollView == introScroll) {
            introPageController.currentPage = scrollView.contentOffset.x/scrollView.width;
            [self refreshIntro];
        }
    }
}

- (void)refreshPage{
    int page = scrollImageView_.contentOffset.x / scrollImageView_.width;
    for (DetailScrollView *c in subPages_) {
        if (c.tag == page) {
            [c setStatus_: eContainerStatus_Appear];
        }else if(fabs(c.tag-page)==1){
            [c setStatus_: eContainerStatus_Disappear];
        }else{
            [c setStatus_: eContainerStatus_Release];
        }
    }
}

- (void)refreshIntro {
    int page = introScroll.contentOffset.x / introScroll.width;
    for (DetailScrollView *c in introPages_) {
        if (c.tag == page) {
            [c setStatus_: eContainerStatus_Appear];
        }else if(fabs(c.tag-page)==1){
            [c setStatus_: eContainerStatus_Disappear];
        }else{
            [c setStatus_: eContainerStatus_Release];
        }
    }
}

- (void)enable_scroll:(NSNotification*)sender {
    scrollImageView_.scrollEnabled = [(NSNumber*)sender.object boolValue];
}

- (void)showEffect:(NSNotification*)sender {
    YXBaseView* v = (YXBaseView*)sender.object;
    [self addSubview:v];
}

- (BOOL)isAir:(NSDictionary*)dic{
    NSArray* air = [[DataManager sharedManager] getAirConditionArray];
    for (NSDictionary* dd in air) {
        if ([[dd objectForKey:@"Seq"]intValue]==[[dic objectForKey:@"Seq"]intValue]
            && [[dic objectForKey:@"type"]intValue]==1) {
            return YES;
        }
    }
    return NO;
}
@end