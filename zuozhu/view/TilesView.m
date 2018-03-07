//
//  TilesView.m
//  Test
//
//  Created by zhuang yihang on 5/5/13.
//  Copyright (c) 2013 yx. All rights reserved.
//

#import "TilesView.h"
#import "ViewObject.h"

typedef enum {
    eDirection_Up,
    eDirection_Down,
    eDirection_Left,
    eDirection_Right,
}eDirection;

@interface TilesView(){
    int column_;
    int row_;
    
    int dataRow_;
    int dataColumn_;
    
    float boardX_;
    float boardY_;
    
    NSArray *tiles_;
    
    UIView *tileView_;
    UIView *backView_;
    UIImageView *chooseView_;
    
    int dir_;
    int initDir_;
    
    CGPoint velocity_;
    double velocityOffset_;
    double velocityFactor_;
    double tmpCount_;
    NSTimer *timer_;
    
    CGPoint tmpPoint_;
    NSMutableArray *movingArray_;
    NSMutableArray *collectArray;
    BOOL isMoveing;
    BOOL isMoveOut;
    BOOL isScroll;  //是否手指滑动
    BOOL isShowLeftView;
    BOOL isShowCollect;
    
    float stopTime; //停止所需要的秒数
    ViewObject* chooseObject;
    
    UIImageView* switchBG;
}

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSArray *tiles;
@property (nonatomic, strong) NSMutableArray *movingArray;
@property (nonatomic, strong) NSMutableArray *allViewArray;
@property (nonatomic, strong) UIImageView* leftView;

@end

@implementation TilesView
@synthesize tiles = tiles_;
@synthesize movingArray = movingArray_;
@synthesize timer = timer_;
@synthesize allViewArray;
@synthesize leftView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clipsToBounds = YES;
        allViewArray = [NSMutableArray new];
        collectArray = [NSMutableArray new];
        srand((unsigned)time(0));
        
        tileView_ = [[UIView alloc] initWithFrame:frame];
        tileView_.backgroundColor = [UIColor clearColor];
        tileView_.clipsToBounds = YES;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [tileView_ addGestureRecognizer:pan];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [tileView_ addGestureRecognizer:tap];
        [self addSubview:tileView_];        
        
        leftView = getImageViewByImageName(@"navBG.png");
        leftView.top = 10;
        leftView.userInteractionEnabled = YES;
        [self addSubview:leftView];
        UIButton* b1 = getButtonByImageName(@"btMenuOne.png");
        b1.center = CGPointMake(leftView.width/2, 120);
        [b1 addTarget:self action:@selector(restore) forControlEvents:UIControlEventTouchUpInside];
        [leftView addSubview:b1];
        UIButton* b2 = getButtonByImageName(@"btMenuTwo.png");
        b2.center = CGPointMake(leftView.width/2, 220);
        [b2 addTarget:self action:@selector(rotota) forControlEvents:UIControlEventTouchUpInside];
        [leftView addSubview:b2];
        UIButton* b3 = getButtonByImageName(@"btMenuThree.png");
        b3.center = CGPointMake(leftView.width/2, 320);
        [b3 addTarget:self action:@selector(moveAndRotota) forControlEvents:UIControlEventTouchUpInside];
        [leftView addSubview:b3];
        UIButton* b4 = getButtonByImageName(@"btMenuFour.png");
        b4.center = CGPointMake(leftView.width/2, 420);
        [b4 addTarget:self action:@selector(testbt:) forControlEvents:UIControlEventTouchUpInside];
        [leftView addSubview:b4];
        leftView.right = 0;
        
        switchBG = getImageViewByImageName(@"switchBG.png");
        switchBG.userInteractionEnabled = YES;
        UITapGestureRecognizer* tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onShowLeftView:)];
        [switchBG addGestureRecognizer:tap1];
        [self addSubview:switchBG];
        
        UIImageView* swi = getImageViewByImageName(@"switch.png");
        swi.center = CGPointMake(switchBG.width/2-6, switchBG.height/2-8);
        [switchBG addSubview:swi];
        
        UIImageView* off = getImageViewByImageName(@"switchON.png");
        off.left = 3;
        off.top = 38;
        off.tag = 100;
        off.contentMode = UIViewContentModeCenter;
        [switchBG addSubview:off];
        
        UIImageView* on = getImageViewByImageName(@"switchOFF.png");
        on.left = 42;
        on.top = 2;
        on.tag = 101;
        on.contentMode = UIViewContentModeCenter;
        [switchBG addSubview:on];
        
        UIImageView* key = getImageViewByImageName(@"switchKey.png");
        key.center = CGPointMake(18, 32);
        key.tag = 99;
        [switchBG addSubview:key];
        
        isShowLeftView = NO;
        isShowCollect = NO;
        isMoveing = NO;
        isMoveOut = NO;
        isScroll = NO;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withRow:(int)row withColumn:(int)column{
    self = [self initWithFrame:frame];
    if (self) {
        row_ = row;
        column_ = column;
        boardX_ = 10;
        boardY_ = 5;
    }
    return self;
}

- (void)dealloc{
    self.timer = nil;
    self.movingArray = nil;
    self.tiles = nil;
}

- (void)onShowLeftView:(UITapGestureRecognizer*)sender {
    if (!isShowLeftView) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(onSwitchStop)];
        leftView.left = 0;
        UIImageView* v1 = (UIImageView*)[sender.view viewWithTag:99];
        v1.center = CGPointMake(32, 18);
        [UIView commitAnimations];
    } else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(onSwitchStop)];
        leftView.right = 0;
        UIImageView* v1 = (UIImageView*)[sender.view viewWithTag:99];
        v1.center = CGPointMake(18, 32);
        [UIView commitAnimations];
    }
    isShowLeftView = !isShowLeftView;
}

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

- (void)setupDatawithRow:(int)row withColumn:(int)column{
    dataRow_ = row;
    dataColumn_ = column;
    
    [tileView_.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //float width = self.bounds.size.width/column_ - boardX_;
    //float height = self.bounds.size.height/row_ - boardY_;
    for (int i = 0; i < row * column; i++) {
        
        int rPos = i / column;
        int cPos = i % column;
        
        UIImageView *v = getImageViewByImageName([NSString stringWithFormat:@"pic%d.png",rand()%3+1]);
        [tileView_ addSubview:v];
        v.tag = rPos * 100 + cPos;
        v.userInteractionEnabled = NO;
        
        float left = boardX_ + cPos * (v.width + boardX_);
        float top = boardY_ + rPos * (v.height + boardY_);
        v.frame = CGRectMake(left, top, v.width, v.height);
        
        UIImageView* mark = getImageViewByImageName([NSString stringWithFormat:@"logo%d.png",arc4random()%3+1]);
        mark.center = CGPointMake(v.width/2, v.height/2);
        [v addSubview:mark];
        
        ViewObject* one = [[ViewObject alloc]init];
        one.view = v;
        one.oldPt = v.center;
        one.tag = v.tag;
        one.isCollect = NO;
        [allViewArray addObject:one];
    }
}

- (int)calcRowPosition:(CGPoint)p{
    float height = self.bounds.size.height/row_ - boardY_;
    
    int row = -1;
    
    for (int i = 0; i < row_; i++) {
        float first = boardY_/2 + i * (height + boardY_);
        float second = boardY_/2 + (i+1) * (height + boardY_);
        if (p.y > first && p.y < second) {
            row = i;
            break;
        }
    }
    
    return row;
}

- (int)calcColumnPosition:(CGPoint)p{
    float width = self.bounds.size.width/column_ - boardX_;
    //int col = (p.x-boardX_/2)/(width+boardX_);
    int col = -1;
    for (int i = 0; i < column_; i++) {
        float first = boardX_/2 + i * (width + boardX_);
        float second = boardX_/2 + (i+1) * (width + boardX_);
        if (p.x > first && p.x < second) {
            col = i;
            break;
        }
    }
    
    return col;
}


#pragma mark 判断手指滑动的方向
- (int)getDirection:(UIPanGestureRecognizer *)gesture{

    int dir = -1;
    CGPoint velocity = [gesture velocityInView:tileView_];
    if (fabs(velocity.x)<fabs(velocity.y)) {
        if (velocity.y<0) {
            dir = eDirection_Up;
        }else{
            dir = eDirection_Down;
        }
    }else{
        if (velocity.x<0) {
            dir = eDirection_Left;
        }else{
            dir = eDirection_Right;
        }
    }
    return dir;
}

- (void)adjustTilePosition{
    float width = self.bounds.size.width/column_ - boardX_;
    float height = self.bounds.size.height/row_ - boardY_;
    
    //根据移动方向，将移出屏幕的tile放到移动方向的后方，这样达到循环的效果
    for (UIView *v in self.movingArray) {
        if (dir_==eDirection_Down) {
            if (v.frame.origin.y > self.frame.size.height) {
                v.center = CGPointMake(v.center.x, v.center.y-(self.movingArray.count)*(height+boardY_));
            }
        }else if(dir_==eDirection_Up){
            if (v.frame.origin.y+v.frame.size.height< 0) {
                v.center = CGPointMake(v.center.x, v.center.y+(self.movingArray.count)*(height+boardY_));
            }
        }else if(dir_==eDirection_Right){
            if (v.frame.origin.x > self.frame.size.width) {
                v.center = CGPointMake(v.center.x-(self.movingArray.count)*(width+boardX_), v.center.y);
            }
        }else if(dir_==eDirection_Left){
            if (v.frame.origin.x+v.frame.size.width < 0) {
                v.center = CGPointMake(v.center.x+(self.movingArray.count)*(width+boardX_), v.center.y);
            }
        }
    }
}

#pragma mark 手势的回调函数
- (void)pan:(UIPanGestureRecognizer *)gesture{
    if (isMoveOut || isMoveing) {
        return ;
    }
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (self.timer != nil) {
            [self move:velocityOffset_];
        }
        [self.timer invalidate];
        self.timer = nil;
        
        tmpCount_ = 0;
        tmpPoint_ = CGPointMake(0, 0);
        
        initDir_ = [self getDirection:gesture];
        
        //获取当前点击位置是在第几行，第几排
        CGPoint p = [gesture locationInView:gesture.view];

        int clickRow = [self calcRowPosition:p];
        int clickCol = [self calcColumnPosition:p];
        
        self.movingArray = [NSMutableArray array];
        for (UIView *v in tileView_.subviews) {
            if (initDir_==eDirection_Down || initDir_ == eDirection_Up) {
                int col = [self calcColumnPosition:v.center];
                if (col == clickCol) {
                    [self.movingArray addObject:v];
                }
            }else{
                int row = [self calcRowPosition:v.center];
                if (row == clickRow) {
                    [self.movingArray addObject:v];
                }
            }
        }
        isScroll = YES;
    }
    
    CGPoint velocity = [gesture velocityInView:tileView_];
    if (initDir_ == eDirection_Up || initDir_ == eDirection_Down) {
        if (velocity.y<0) {
            dir_ = eDirection_Up;
        }else{
            dir_ = eDirection_Down;
        }
    }else{
        if (velocity.x<0) {
            dir_ = eDirection_Left;
        }else{
            dir_ = eDirection_Right;
        }

    }

    CGPoint p = [gesture translationInView:tileView_];
    CGPoint offset = CGPointMake(p.x-tmpPoint_.x, p.y-tmpPoint_.y);
    tmpPoint_ = p;    
    
    //遍历 行/列 的所有tile，移动位置
    for (UIView *v in self.movingArray) {
        if (dir_==eDirection_Down || dir_ == eDirection_Up) {
            v.center = CGPointMake(v.center.x, v.center.y+offset.y);
        }else{
            v.center = CGPointMake(v.center.x+offset.x, v.center.y);
        }
    }
    
    if (dir_==eDirection_Down || dir_ == eDirection_Up) {
        tmpCount_+=offset.y;
    }else{
        tmpCount_+=offset.x;
    }
    
    [self adjustTilePosition];
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        velocity_ = velocity;
        if (dir_==eDirection_Down || dir_ == eDirection_Up) {
            float height = self.bounds.size.height/row_;
            
            int number = tmpCount_/height;
            tmpCount_ = tmpCount_ - number * height;
            if (dir_==eDirection_Up) {
                tmpCount_ = - height - tmpCount_;
                if (velocity_.y <= -1500) {
                    tmpCount_ += ceil(velocity_.y/200) * height;
                }
            }else{
                tmpCount_ = height - tmpCount_;
                if (velocity_.y >= 1500) {
                    tmpCount_ += ceil(velocity_.y/200) * height;
                }
            }
        }else{
            
            float width = self.bounds.size.width/column_;
            
            int number = tmpCount_/width;
            tmpCount_ = tmpCount_ - number * width;
            if (dir_==eDirection_Left) {
                tmpCount_ = - width - tmpCount_;
                if (velocity_.x <= -1500) {
                    tmpCount_ += ceil(velocity_.x/200) * width;
                }
            }else{
                tmpCount_ = width - tmpCount_;
                if (velocity_.x >= 1500) {
                    tmpCount_ += ceil(velocity_.x/200) * width;
                }
            }
        }
        
        velocityOffset_ = tmpCount_;
        velocityFactor_ = 0.8;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.025 target:self selector:@selector(inertia) userInfo:nil repeats:YES];
        
    }
}

- (void)updateViewArray {
    [allViewArray removeAllObjects];
    for (UIImageView* v in tileView_.subviews) {
        ViewObject* one = [[ViewObject alloc]init];
        one.oldPt = v.center;
        one.view = v;
        one.tag = v.tag;
        one.isCollect = NO;
        [allViewArray addObject:one];
    }
}

- (void)tap:(UITapGestureRecognizer*)sender {
    CGPoint p = [sender locationInView:sender.view];
    if (isMoveing || isMoveOut || isScroll) {
        return ;
    }
    isMoveing = YES;
    if (self.timer != nil) {
        [self move:velocityOffset_];
    }
    [self updateViewArray];
    chooseObject = nil;
    chooseView_ = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, tileView_.width, tileView_.height)];
    for (int i=0;i<allViewArray.count;i++)  {
        ViewObject* one = [allViewArray objectAtIndex:i];
        if (CGRectContainsPoint(one.view.frame, p)) {
            chooseView_.image = one.view.image;
            chooseObject = one;
            break;
        }
    }
    UIButton* btCollect = [UIButton buttonWithType:UIButtonTypeContactAdd];
    btCollect.right = chooseView_.width-20;
    btCollect.centerY = chooseView_.height/2;
    [btCollect addTarget:self action:@selector(onCollect) forControlEvents:UIControlEventTouchUpInside];
    [chooseView_ addSubview:btCollect];
    
    [tileView_ addSubview:chooseView_];
    [tileView_ sendSubviewToBack:chooseView_];
    for (int i=0;i<allViewArray.count;i++) {
        ViewObject* one = [allViewArray objectAtIndex:i];
        //NSLog(@"%f,%f,%f",one.view.center.x,one.view.center.y,one.view.layer.position.y);
        if (CGRectContainsPoint(tileView_.frame, one.view.center)) {
        int clickRow = [self calcRowPosition:one.view.center];
        int clickCol = [self calcColumnPosition:one.view.center];
            
            //*************用CABasicAnimation的方法****************************//
//            CABasicAnimation* move    = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
//            move.duration = 1.0f;
//            move.autoreverses = NO;
//            move.removedOnCompletion = NO;
//            move.repeatCount = 1;  //"forever"
//            if (clickCol%2!=0) {//往上移动
//                move.fromValue = [NSNumber numberWithInt: 0];
//                move.toValue = [NSNumber numberWithInt: -(one.view.frame.size.height*2+tileView_.frame.size.height)];
//                for (int j=0; j<row_; j++) {
//                    if (clickRow == j) {
//                        move.beginTime = CACurrentMediaTime()+j*0.2f;
//                        break;
//                    }
//                }
//            } else {
//                move.fromValue = [NSNumber numberWithInt: 0];
//                move.toValue = [NSNumber numberWithInt: (one.view.frame.size.height*2+tileView_.frame.size.height)];
//                for (int j=0; j<row_; j++) {
//                    if (clickRow == j) {
//                        move.beginTime = CACurrentMediaTime()+(row_-j-1)*0.2f;
//                        break;
//                    }
//                }
//            }
//            [one.view.layer addAnimation:move forKey:nil];
            //*************用UIView的方法****************************//
            one.oldPt = one.view.center;
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:1.0f];
            if (clickRow==row_-1&&clickCol==column_-1) {
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDidStopSelector:@selector(onMoveOut)];
            }
            if (clickCol%2!=0) {//往上移动
                for (int j=0; j<row_; j++) {
                    if (clickRow == j) {
                        [UIView setAnimationDelay:j*0.2f];
                        break;
                    }
                }
                one.view.center = CGPointMake(one.view.center.x, one.view.center.y-(one.view.frame.size.height*2+tileView_.frame.size.height));
            } else {
                for (int j=0; j<row_; j++) {
                    if (clickRow == j) {
                        [UIView setAnimationDelay:(row_-j-1)*0.2f];
                        break;
                    }
                }
                one.view.center = CGPointMake(one.view.center.x, one.view.center.y+(one.view.frame.size.height*2+tileView_.frame.size.height));
            }
            [UIView commitAnimations];
        }
    }
}

- (void)onMoveOut {
    isMoveOut = YES;
    isMoveing = NO;
}

- (void)onCollect {
    BOOL isCollect = NO;
    for (ViewObject * v in collectArray) {
        if (v.tag == chooseObject.tag) {
            isCollect = YES;
            break;
        }
    }
    if (isCollect) {
        return ;
    }
    [collectArray addObject:chooseObject];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"收藏图片成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

#pragma mark 处理手指滑动后的惯性
- (void)inertia{
    
    double offset = velocityOffset_*(1-velocityFactor_);
//    double offset;
//    if (dir_==eDirection_Left) {
//        offset = velocity_.x * 0.025;
//        velocity_.x += 100.0f;
//        NSLog(@"%f,%f",velocity_.x,offset);
//    } else if (dir_==eDirection_Right) {
//        offset = velocity_.x * 0.025;
//        velocity_.x -= 100.0f;
//    } else if (dir_==eDirection_Up) {
//        offset = velocity_.y * 0.025;
//        velocity_.y += 100.0f;
//    } else {
//        offset = velocity_.y * 0.025;
//        velocity_.y -= 100.0f;
//    }
    
//    if (offset > 1) {
//        offset = 1;
//    }else{
//        
//    }
    if (fabs(velocityOffset_)<500) {
        velocityFactor_ *= 0.005;
    } else {
        velocityFactor_ *= 0.99;
    }
    
    [self move:offset];
    NSLog(@"%f",offset);
    
    [self adjustTilePosition];
    
    velocityOffset_ -= offset;
    
//    if (dir_==eDirection_Left) {
//        if (velocity_.x>=0) {
//            [self stopScroll];
//            [self.timer invalidate];
//            self.timer = nil;
//            isScroll = NO;
//        }
//    } else if (dir_==eDirection_Right) {
//        if (velocity_.x<=0) {
//            [self stopScroll];
//            [self.timer invalidate];
//            self.timer = nil;
//            isScroll = NO;
//        }
//    } else if (dir_==eDirection_Up) {
//        if (velocity_.y>=0) {
//            [self stopScroll];
//            [self.timer invalidate];
//            self.timer = nil;
//            isScroll = NO;
//        }
//    } else {
//        if (velocity_.y<=0) {
//            [self stopScroll];
//            [self.timer invalidate];
//            self.timer = nil;
//            isScroll = NO;
//        }
//    }
    
    if (fabs(velocityOffset_) <= 0.1) {
        [self move:velocityOffset_];
        
        [self.timer invalidate];
        self.timer = nil;
        isScroll = NO;
    }
}

- (void)stopScroll {
    float distant = 0.0f;
    if (dir_ == eDirection_Left) {
        for (UIView* v in self.movingArray) {
            if (v.center.x >= 0 && v.center.x <= v.frame.size.width) {
                distant = v.center.x-v.frame.size.width/2;
                break;
            }
        }
        for (UIView* v in self.movingArray) {
            v.center = CGPointMake(v.center.x-distant, v.center.y);
        }
    } else if (dir_ == eDirection_Right) {
        for (UIView* v in self.movingArray) {
            if (v.center.x >= 0 && v.center.x <= v.frame.size.width) {
                distant = v.frame.size.width/2-v.center.x;
                break;
            }
        }
        for (UIView* v in self.movingArray) {
            v.center = CGPointMake(v.center.x+distant, v.center.y);
        }
    } else if (dir_ == eDirection_Up) {
        for (UIView* v in self.movingArray) {
            if (v.center.y >= 0 && v.center.y <= v.frame.size.height) {
                distant = v.center.y-v.frame.size.height/2;
                break;
            }
        }
        for (UIView* v in self.movingArray) {
            v.center = CGPointMake(v.center.x, v.center.y-distant);
        }
    } else {
        for (UIView* v in self.movingArray) {
            if (v.center.y >= 0 && v.center.y < v.frame.size.height) {
                distant = v.frame.size.height/2-v.center.y;
                break;
            }
        }
        for (UIView* v in self.movingArray) {
            v.center = CGPointMake(v.center.x, v.center.y+distant);
        }
    }
}

- (void)move:(float)offset{
    if (initDir_ == eDirection_Up || initDir_==eDirection_Down) {
        for (UIView *v in self.movingArray) {
            v.center = CGPointMake(v.center.x, v.center.y+offset);
        }
    }else{
        for (UIView *v in self.movingArray) {
            v.center = CGPointMake(v.center.x+offset, v.center.y);
        }
    }
}

- (void)restore {
    if (!isMoveOut || isMoveing) {
        return ;
    }
    isMoveing = YES;
    for (int i=0; i<allViewArray.count; i++) {
        ViewObject* one = [allViewArray objectAtIndex:i];
        int clickRow = [self calcRowPosition:one.oldPt];
        int clickCol = [self calcColumnPosition:one.oldPt];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1.0f];
//        if (i==allViewArray.count-1) {
//            [UIView setAnimationDelegate:self];
//            [UIView setAnimationDidStopSelector:@selector(onMoveRestore)];
//        }
        if (clickCol%2!=0) {
            for (int j=0; j<row_; j++) {
                if (clickRow == j) {
                    [UIView setAnimationDelay:(row_-j-1)*0.2f];
                    break;
                }
            }
        } else {//第0行
            for (int j=0; j<row_; j++) {
                if (clickRow == j) {
                    [UIView setAnimationDelay:j*0.2f];
                    break;
                }
            }
        }
        one.view.center = one.oldPt;
        [UIView commitAnimations];
    }
    [self performSelector:@selector(onMoveRestore) withObject:nil afterDelay:1.8];
}

- (void)onMoveRestore {
    isMoveOut = NO;
    isMoveing = NO;
    if (chooseView_) {
        [chooseView_ removeFromSuperview];
        chooseView_ = nil;
    }
}

- (void)rotota {
    if (isMoveing || isMoveOut) {
        return ;
    }
    [self updateViewArray];
    float du = 0.0f;
    for (int i=0; i<row_; i++) {
        for (int j=0; j<column_; j++) {
            for (int k=0; k<allViewArray.count; k++) {
                ViewObject* one = [allViewArray objectAtIndex:k];
                int clickRow = [self calcRowPosition:one.oldPt];
                int clickCol = [self calcColumnPosition:one.oldPt];
                if (clickRow==i&&clickCol==j) {
                    du += 0.02f;
                    CABasicAnimation *a2 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
                    a2.fromValue = [NSNumber numberWithFloat:0.0];
                    a2.toValue = [NSNumber numberWithFloat:M_PI];
                    //a2.autoreverses = NO;
                    //a2.repeatCount = NSUIntegerMax;
                    a2.duration = 0.5f;
                    [a2 setBeginTime:CACurrentMediaTime()+du];
                    //NSLog(@"%f",CACurrentMediaTime());
                    [one.view.layer addAnimation:a2 forKey:@"y"];
                    if (!isShowCollect) {
                        BOOL is = NO;
                        for (ViewObject* v in collectArray) {
                            if (v.tag == one.tag) {
                                is = YES;
                                break;
                            }
                        }
                        if (!is) {
                            one.isCollect = NO;
                        } else {
                            one.isCollect = YES;
                        }
                    } 
                    break;
                }
            }
        }
    }
    [self performSelector:@selector(onRototaStop:) withObject:[NSNumber numberWithBool:isShowCollect] afterDelay:0.8];
}

- (void)onRototaStop:(NSNumber*)sender {
    BOOL is = [sender boolValue];
    if (!is) {
        for (ViewObject* v in allViewArray) {
            if (v.isCollect) {
                v.view.hidden = NO;
            } else {
                v.view.hidden = YES;
            }
        }
    } else {
        for (ViewObject* v in allViewArray) {
            v.view.hidden = NO;
        }
    }
    isShowCollect = !isShowCollect;
}

- (void)moveAndRotota {
    if (!isMoveOut || isMoveing) {
        return ;
    }
//    for (int i=0; i<allViewArray.count; i++) {
//        ViewObject* one = [allViewArray objectAtIndex:i];
//        int clickRow = [self calcRowPosition:one.oldPt];
//        int clickCol = [self calcColumnPosition:one.oldPt];
//        CAAnimation* myAnimationRotate    = [self animationRotate];
//        CAAnimation* myAnimationFallingDown  = [self animationMove:one];
//        CAAnimationGroup* m_pGroupAnimation = [CAAnimationGroup animation];        
//        m_pGroupAnimation.removedOnCompletion = NO;
//        m_pGroupAnimation.duration = 1.0f;
//        m_pGroupAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//        m_pGroupAnimation.repeatCount = 1;
//        m_pGroupAnimation.fillMode = kCAFillModeForwards;
//        m_pGroupAnimation.animations = [NSArray arrayWithObjects:myAnimationRotate,
//                                                    myAnimationFallingDown,
//                                                    nil];
//        if (clickCol%2!=0) {
//            for (int j=0; j<row_; j++) {
//                if (clickRow == j) {
//                    m_pGroupAnimation.beginTime = CACurrentMediaTime()+(row_-j-1)*0.1f;
//                    break;
//                }
//            }
//        } else {//第0行
//            for (int j=0; j<row_; j++) {
//                if (clickRow == j) {
//                    m_pGroupAnimation.beginTime = CACurrentMediaTime()+j*0.1f;
//                    break;
//                }
//            }
//        }
//        if (i==allViewArray.count-1) {
//            m_pGroupAnimation.delegate = self;
//        }
//        //对视图自身的层添加组动画
//        [one.view.layer addAnimation:m_pGroupAnimation forKey:nil];
//    }
    t
    for (int i=0; i<allViewArray.count; i++) {
        ViewObject* one = [allViewArray objectAtIndex:i];
        int clickRow = [self calcRowPosition:one.oldPt];
        int clickCol = [self calcColumnPosition:one.oldPt];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1.0f];
        if (i==allViewArray.count-1) {
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(onMoveRestore)];
        }
        if (clickCol%2!=0) {
            for (int j=0; j<row_; j++) {
                if (clickRow == j) {
                    [UIView setAnimationDelay:(row_-j-1)*0.2f];
                    break;
                }
            }
        } else {//第0行
            for (int j=0; j<row_; j++) {
                if (clickRow == j) {
                    [UIView setAnimationDelay:j*0.2f];
                    break;
                }
            }
        }
        one.view.layer.transform = CATransform3DConcat(one.view.layer.transform, CATransform3DMakeRotation(M_PI,0.0,1.0,0.0));
        one.view.layer.transform = CATransform3DConcat(one.view.layer.transform, CATransform3DMakeRotation(M_PI,0.0,1.0,0.0));
//        CABasicAnimation* animation;
//        animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
//        animation.fromValue = [NSNumber numberWithFloat:0.0];
//        animation.toValue   = [NSNumber numberWithFloat:M_PI];
//        animation.duration = 1.0f;
//        [one.view.layer addAnimation:animation forKey:nil];
        one.view.center = one.oldPt;
        [UIView commitAnimations];
    }
}

- (CAAnimation *)animationRotate {
    // rotate animation
    CABasicAnimation* animation;
    animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    animation.fromValue = [NSNumber numberWithFloat:0.0];
    animation.toValue   = [NSNumber numberWithFloat:M_PI];
    animation.duration          = 1.0f;
    //animation.cumulative        = YES;
    animation.repeatCount		= FLT_MAX;  //"forever"
    //设置开始时间，能够连续播放多组动画
    //animation.beginTime        = 0.5;
    //设置动画代理
    //animation.delegate        = self;
    return animation;
}

- (CAAnimation *)animationMove:(ViewObject*)one {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    //animation.fromValue = [NSValue valueWithCGPoint:one.view.center];
    //animation.toValue = [NSValue valueWithCGPoint:one.oldPt];
    animation.autoreverses			= NO;
	animation.removedOnCompletion	= NO;
    animation.repeatCount			= FLT_MAX;  //"forever"
	animation.fromValue				= [NSNumber numberWithInt: 0];
	animation.toValue				= [NSNumber numberWithInt: one.oldPt.y-one.view.center.y];
    //one.view.center = one.oldPt;
    animation.duration = 1.0f;//动画持续时间
    return animation;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    isMoveOut = NO;
    isMoveing = NO;
//    for (int i=0; i<allViewArray.count; i++) {
//        ViewObject* one = [allViewArray objectAtIndex:i];
//        one.view.center = one.oldPt;
//    }
}

- (void)testbt:(id)sender {
    UIButton* b = (UIButton*)sender;
    CABasicAnimation* move    = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    move.fromValue = [NSValue valueWithCGPoint:b.center];
    move.toValue = [NSValue valueWithCGPoint:CGPointMake(b.center.x, b.center.y+150)];
    move.duration = 1.5f;
    CABasicAnimation *scale= [CABasicAnimation animationWithKeyPath:@"transform.scale"];    
    scale.toValue = [NSNumber numberWithDouble:12];    
    scale.duration = 1.5f;
    scale.autoreverses = YES;
    CAAnimationGroup* m_pGroupAnimation = [CAAnimationGroup animation];
    m_pGroupAnimation.duration = 1.5f;
    m_pGroupAnimation.animations = [NSArray arrayWithObjects:move,scale,nil];
    //对视图自身的层添加组动画
    [b.layer addAnimation:m_pGroupAnimation forKey:nil];
}

@end
