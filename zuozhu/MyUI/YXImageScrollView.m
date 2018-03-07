//
//  YXImageScrollView.m
//  XieJin
//
//  Created by zyhang on 12/16/13.
//  Copyright (c) 2013 zyhang. All rights reserved.
//

#import "YXImageScrollView.h"
#import "ZZPageControl.h"

@interface YXImageScrollView()<UIScrollViewDelegate>{
    NSArray *imageArray_;
    UIScrollView *scrollView_;
    ZZPageControl* _pageController;
    
    BOOL shouldFullScreen_;//是否可点击放大全屏
    BOOL shouldScale_;//是否可捏合放大
    BOOL bVertical_;
    int activeColor_;
}
@property (nonatomic, strong) UIScrollView *imageScrollView;

@end

@implementation YXImageScrollView
@synthesize imageScrollView = scrollView_;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (id)initWithParameter:(NSDictionary *)parameter {
    self = [self initWithFrame:CGRectMake(0, 0, 1024, 768)];
    if (self) {
        config_ = parameter;
        _imageArray = [NSMutableArray new];
        
        _bgview = [[UIView alloc]initWithFrame:self.bounds];
        _bgview.backgroundColor = [UIColor whiteColor];
        _bgview.alpha = 0.0f;
        [self addSubview:_bgview];
        
        [self getOldRect:parameter];
        
        scrollView_ = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:scrollView_];
        scrollView_.delegate = self;
        scrollView_.pagingEnabled = YES;
        
        shouldFullScreen_ = [[parameter objectForKey:@"fullscreen"] boolValue];
        shouldScale_ = [[parameter objectForKey:@"scale"] boolValue];
        bVertical_ = [[parameter objectForKey:@"vertical"] boolValue];
        
        if ([parameter objectForKey:@"image_prefix"]) {
            NSMutableArray *arr = [NSMutableArray array];
            int num = [[parameter objectForKey:@"image_num"] intValue];
            for (int i = 0; i < num; i++) {
                NSString *imageName = [NSString stringWithFormat:[parameter objectForKey:@"image_prefix"],i+1];
                [arr addObject:imageName];
            }
            imageArray_ = [NSArray arrayWithArray:arr];
        }else{
            imageArray_ = [parameter objectForKey:@"images"];
        }

        int i = 0;
        for (NSArray *name in imageArray_) {
            UIImageView *v = [[UIImageView alloc] initWithFrame:scrollView_.bounds];
            //v.contentMode = UIViewContentModeScaleAspectFit;
            if (shouldScale_) {
                UIScrollView *s = [[UIScrollView alloc] initWithFrame:v.bounds];
                [scrollView_ addSubview:s];
                [s addSubview:v];
                s.minimumZoomScale = 1.0;
                s.maximumZoomScale = 1.5;
                s.delegate = self;
                if (bVertical_) {
                    s.left = i * s.height;
                }else{
                    s.left = i * s.width;
                }
                s.tag = 10 + i;
                v.tag = 100;
            }else{
                [scrollView_ addSubview:v];
                if (bVertical_) {
                    v.left = i * v.height;
                }else{
                    v.left = i * v.width;
                }
                v.tag = i + 100;
            }
            
            if (shouldFullScreen_) {
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(tap:)];
                [v addGestureRecognizer:tap];
                v.userInteractionEnabled = YES;
            }
            [_imageArray addObject:v];
            i++;
        }
        if (bVertical_) {
            scrollView_.contentSize = CGSizeMake(0, imageArray_.count*scrollView_.height);
        }else{
            scrollView_.contentSize = CGSizeMake(imageArray_.count*scrollView_.width, 0);
        }
        
        [self refreshPage];
        
        _pageController = [[ZZPageControl alloc]initWithFrame:CGRectMake(0, 0, self.width, 20)];
        _pageController.bottom = self.height-20;
        _pageController.centerX = self.width/2;
        _pageController.numberOfPages = imageArray_.count;//指定页面个数
        _pageController.currentPage = 0;//指定pagecontroll的值，默认选中的小白点（第一个）
        _pageController.fitMode = ZZPageControlModeDots;
        _pageController.activeColor = [UIColor blueColor];
        activeColor_ = [[parameter objectForKey:@"activecolor"]intValue];
        if (activeColor_==1) {
            _pageController.activeColor = [UIColor redColor];
        }
        _pageController.inactiveColor = [UIColor grayColor];
        //[_pageController addTarget:self action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_pageController];
        _pageController.alpha = 0.0f;
        
        scrollView_.frame = oldRect;
        for (UIImageView* v in _imageArray) {
            v.size = scrollView_.size;
        }
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(onBig)];
        
        _bgview.alpha = MYALPHA;
        _pageController.alpha = 1.0f;
        scrollView_.frame = self.bounds;
        for (UIImageView* v in _imageArray) {
            v.size = scrollView_.size;
        }
        
        [UIView commitAnimations];
        
        //[self pageChanged:_pageController];
    }
    return self;
}

- (void)tap:(UITapGestureRecognizer *)gesture{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeSelf)];
    
    _bgview.alpha = 0.0f;
    _pageController.alpha = 0.0f;
    scrollView_.frame = oldRect;
    for (UIImageView* v in _imageArray) {
        v.size = scrollView_.size;
    }
    
    [UIView commitAnimations];
}

- (void)close:(UITapGestureRecognizer *)gesture{
    [gesture.view removeFromSuperview];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView_!=scrollView) {
        return;
    }
    _pageController.currentPage = scrollView.contentOffset.x/scrollView.width;
    [self refreshPage];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView_!=scrollView) {
        return;
    }
    
    if (!decelerate) {
        [self refreshPage];
    }
}

- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated{
    [scrollView_ setContentOffset:offset animated:animated];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    if (scrollView_==scrollView) {
        return nil;
    }
    
    if (shouldScale_) {
        int page = scrollView.contentOffset.x / scrollView.width;
        return [scrollView viewWithTag:page+100];
    }else{
        return nil;
    }
}

- (void)refreshPage{
    int page = scrollView_.contentOffset.x / scrollView_.width;
    for (int i = 0; i < imageArray_.count; i++) {
        if (shouldScale_) {
            UIScrollView *s = (UIScrollView *)[scrollView_ viewWithTag:i+10];
            UIImageView *v = (UIImageView *)[s viewWithTag:100];
            if (fabs(i - page)<=1) {
                NSString *imageName = [imageArray_ objectAtIndex:i];
                v.image = getBundleImage(imageName);
                if (v.image.size.width >= v.width || v.image.size.height >= v.height) {
                    v.contentMode = UIViewContentModeScaleAspectFit;
                } else {
                    v.contentMode = UIViewContentModeCenter;
                }
            }else{
                v.image = nil;
            }
        }else{
            UIImageView *v = (UIImageView *)[scrollView_ viewWithTag:i+100];
            if (fabs(i - page)<=1) {
                NSString *imageName = [imageArray_ objectAtIndex:i];
                v.image = getBundleImage(imageName);
                if (v.image.size.width >= v.width || v.image.size.height >= v.height) {
                    v.contentMode = UIViewContentModeScaleAspectFit;
                } else {
                    v.contentMode = UIViewContentModeCenter;
                }
            }else{
                v.image = nil;
            }
        }
    }
}

-(void)pageChanged:(UIPageControl*)pc {
    NSArray *subViews = pc.subviews;
    for (int i = 0; i < [subViews count]; i++) {
        UIImageView* dot = [subViews objectAtIndex:i];
        if(i == pc.currentPage){
            dot.backgroundColor = [UIColor blueColor];
            if (activeColor_==1) {
                _pageController.activeColor = [UIColor redColor];
            }
        } else
            dot.backgroundColor = [UIColor grayColor];
        }
}

@end
