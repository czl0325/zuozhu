//
//  DetailScrollView.m
//  zuozhu
//
//  Created by zhaoliang.chen on 13-11-8.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "DetailScrollView.h"
#import "DataManager.h"
#import "YXBaseView.h"

@implementation DetailScrollView

@synthesize status_;
@synthesize _seq;

#define LABELTAG    1000
#define SCROLLTAG   2000

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        status_ = eContainerStatus_Init;
        uiSetup_ = NO;
        lineType = -1;
        selectTag1 = 0;
        selectTag2 = 0;
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enable_scroll:) name:@"enable_scroll" object:nil];
    }
    return self;
}

- (id)initWithData:(CGRect)frame withNum:(int)seq {
    self = [self initWithFrame:frame];
    if (self) {
        // Initialization code
        _seq = seq;
        if (_seq>1000) {
            _detailArray = [[DataManager sharedManager]getIntroArray];
        } else {
            _detailArray = [[DataManager sharedManager]getDetailArray];
        }
        
        _detaildic = nil;
        for (int i=0; i<_detailArray.count; i++) {
            NSDictionary* d = [_detailArray objectAtIndex:i];
            if ([[d objectForKey:@"Seq"]intValue]==_seq) {
                _detaildic = d;
                break;
            }
        }
        if (!_detaildic) {
            return self;
        }
        if ([_detaildic objectForKey:@"linetype"]) {
            lineType = [[_detaildic objectForKey:@"linetype"]intValue];
        }
        textDistance = 20;
        if ([_detaildic objectForKey:@"distance"]) {
            textDistance = [[_detaildic objectForKey:@"distance"]intValue];
        }
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI {
    [self removeAllSubviews];
    if (!_detaildic) {
        return ;
    }
    
    NSArray* array = [_detaildic objectForKey:@"picarray"];
    for (NSDictionary *dic in array) {
        NSString *className = [dic objectForKey:@"class"];
        YXBaseView *v = [[NSClassFromString(className) alloc] initWithParameter:[dic objectForKey:@"parameter"]];
        [self addSubview:v];
    }
    
    if ([_detaildic objectForKey:@"btchina_x"]) {
        UIImageView* line = getImageViewByImageName(@"line.png");
        line.left = [[_detaildic objectForKey:@"btchina_x"]floatValue];
        line.centerY = [[_detaildic objectForKey:@"btchina_y"]floatValue];
        [self addSubview:line];
        if (lineType!=-1) {
            line.image = getBundleImage([NSString stringWithFormat:@"line%d.png",lineType]);
        }
        
        //btChina = getButtonByImageName(@"btchina.png");
        btChina = [UIButton buttonWithType:UIButtonTypeCustom];
        [btChina setImage:getBundleImage(@"btchina.png") forState:UIControlStateNormal];
        [btChina setFrame:CGRectMake(0, 0, 56, 56)];
        [btChina setContentMode:UIViewContentModeCenter];
        btChina.center = CGPointMake([[_detaildic objectForKey:@"btchina_x"]floatValue], [[_detaildic objectForKey:@"btchina_y"]floatValue]);
        btChina.tag = LABELTAG+1;
        [btChina addTarget:self action:@selector(onChangeText:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btChina];
        
        //btEnglish = getButtonByImageName(@"btenglish.png");
        btEnglish = [UIButton buttonWithType:UIButtonTypeCustom];
        [btEnglish setImage:getBundleImage(@"btenglish.png") forState:UIControlStateNormal];
        [btEnglish setFrame:CGRectMake(0, 0, 56, 56)];
        [btEnglish setContentMode:UIViewContentModeCenter];
        btEnglish.center = CGPointMake(line.centerX,btChina.centerY);
        btEnglish.tag = LABELTAG+2;
        [btEnglish addTarget:self action:@selector(onChangeText:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btEnglish];
        
        //btJapan = getButtonByImageName(@"btjapan.png");
        btJapan = [UIButton buttonWithType:UIButtonTypeCustom];
        [btJapan setImage:getBundleImage(@"btjapan.png") forState:UIControlStateNormal];
        [btJapan setFrame:CGRectMake(0, 0, 56, 56)];
        [btJapan setContentMode:UIViewContentModeCenter];
        btJapan.center = CGPointMake(line.right,btChina.centerY);
        btJapan.tag = LABELTAG+3;
        [btJapan addTarget:self action:@selector(onChangeText:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btJapan];
        
        _scroll1 = [[UIScrollView alloc]initWithFrame:CGRectMake(btChina.left+14, btChina.bottom+textDistance, 0, 0)];
        //_scroll1.pagingEnabled = YES;
        _scroll1.delegate = self;
        _scroll1.showsHorizontalScrollIndicator = NO;
        float w=0,h=0;
        _arrayScroll1 = [NSMutableArray new];
        for (int i=0; i<3; i++) {
            //TDImageScrollView* s;
            UIScrollView* s;
            if (i==0) {
                //s = [[TDImageScrollView alloc]initWithImageUI:getBundleImage([NSString stringWithFormat:@"detail_p%d_textCN.png",_seq])];
                s = createScrollImageViewByImage([NSString stringWithFormat:@"detail_p%d_textCN.png",_seq]);
            } else if (i==1) {
                //s = [[TDImageScrollView alloc]initWithImageUI:getBundleImage([NSString stringWithFormat:@"detail_p%d_textEN.png",_seq])];
                s = createScrollImageViewByImage([NSString stringWithFormat:@"detail_p%d_textEN.png",_seq]);
            } else if (i==2) {
                //s = [[TDImageScrollView alloc]initWithImageUI:getBundleImage([NSString stringWithFormat:@"detail_p%d_textJP.png",_seq])];
                s = createScrollImageViewByImage([NSString stringWithFormat:@"detail_p%d_textJP.png",_seq]);
            }
            if (s.size.width>w) {
                w=s.size.width;
            }
            if (s.size.height>h) {
                h=s.size.height;
            }
            s.tag = SCROLLTAG+i;
            s.delegate = self;
            [_arrayScroll1 addObject:s];
        }
        _scroll1.size = CGSizeMake(w, h);
        for (int i=0; i<_arrayScroll1.count; i++) {
            UIScrollView* s = [_arrayScroll1 objectAtIndex:i];
            s.left = i*_scroll1.width;
            s.size = _scroll1.size;
            [_scroll1 addSubview:s];
        }
        
        [self addSubview:_scroll1];
        if ([_detaildic objectForKey:@"scrollH1"]) {
            _scroll1.height = [[_detaildic objectForKey:@"scrollH1"]floatValue];
            _scroll1.bounces = YES;
        } else if (_scroll1.bottom>768) {
            _scroll1.height -= _scroll1.bottom-768;
        }
        UIScrollView* ss = [_arrayScroll1 objectAtIndex:0];
        float fh = ss.contentSize.height;
        _scroll1.contentSize = CGSizeMake(_scroll1.width, fh);
        if ([_detaildic objectForKey:@"right1"]) {
            _scroll1.right = btJapan.right-14;
        }
        if (ss.contentSize.height > _scroll1.height) {
            if (_tip) {
                [_tip removeFromSuperview];
                _tip = nil;
            }
            if ([[_detaildic objectForKey:@"scrollTip"]intValue]==1) {
                _tip = getImageViewByImageName(@"page_scrollIndicatorwhite.png");
            } else {
                _tip = getImageViewByImageName(@"page_scrollIndicator.png");
            }
            [self addSubview:_tip];
            _tip.centerX = _scroll1.centerX;
            _tip.top = _scroll1.bottom+5;
            _tip.tag = ss.tag+100;
            if (_scroll1.contentOffset.y + _scroll1.height >= _scroll1.contentSize.height) {
                [_tip setHidden:YES];
            } else {
                [_tip setHidden:NO];
            }
        } else {
            if (_tip) {
                [_tip removeFromSuperview];
                _tip = nil;
            }
        }
        [self onChangeText:btChina];
    }
    
    if ([_detaildic objectForKey:@"btchina_x2"]) {
        UIImageView* line = getImageViewByImageName(@"line.png");
        line.left = [[_detaildic objectForKey:@"btchina_x2"]floatValue];
        line.centerY = [[_detaildic objectForKey:@"btchina_y2"]floatValue];
        [self addSubview:line];
        
        //btChina2 = getButtonByImageName(@"btchina.png");
        btChina2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btChina2 setImage:getBundleImage(@"btchina.png") forState:UIControlStateNormal];
        [btChina2 setFrame:CGRectMake(0, 0, 56, 56)];
        [btChina2 setContentMode:UIViewContentModeCenter];
        btChina2.center = CGPointMake([[_detaildic objectForKey:@"btchina_x2"]floatValue], [[_detaildic objectForKey:@"btchina_y2"]floatValue]);
        btChina2.tag = LABELTAG+11;
        [btChina2 addTarget:self action:@selector(onChangeText2:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btChina2];
        
        //btEnglish2 = getButtonByImageName(@"btenglish.png");
        btEnglish2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btEnglish2 setImage:getBundleImage(@"btenglish.png") forState:UIControlStateNormal];
        [btEnglish2 setFrame:CGRectMake(0, 0, 56, 56)];
        [btEnglish2 setContentMode:UIViewContentModeCenter];
        btEnglish2.center = CGPointMake(line.centerX,btChina2.centerY);
        btEnglish2.tag = LABELTAG+12;
        [btEnglish2 addTarget:self action:@selector(onChangeText2:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btEnglish2];
        
        //btJapan2 = getButtonByImageName(@"btjapan.png");
        btJapan2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btJapan2 setImage:getBundleImage(@"btjapan.png") forState:UIControlStateNormal];
        [btJapan2 setFrame:CGRectMake(0, 0, 56, 56)];
        [btJapan2 setContentMode:UIViewContentModeCenter];
        btJapan2.center = CGPointMake(line.right,btChina2.centerY);
        btJapan2.tag = LABELTAG+13;
        [btJapan2 addTarget:self action:@selector(onChangeText2:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btJapan2];
        
        _scroll2 = [[UIScrollView alloc]initWithFrame:CGRectMake(btChina2.left+14, btChina2.bottom+textDistance, 0, 0)];
        _scroll2.pagingEnabled = YES;
        _scroll2.delegate = self;
        float w=0,h=0;
        _arrayScroll2 = [NSMutableArray new];
        for (int i=0; i<3; i++) {
            //TDImageScrollView* s;
            UIScrollView* s;
            if (i==0) {
                s = createScrollImageViewByImage([NSString stringWithFormat:@"detail_p%d_textCN2.png",_seq]);
            } else if (i==1) {
                s = createScrollImageViewByImage([NSString stringWithFormat:@"detail_p%d_textEN2.png",_seq]);
            } else if (i==2) {
                s = createScrollImageViewByImage([NSString stringWithFormat:@"detail_p%d_textJP2.png",_seq]);
            }
            if (s.size.width>w) {
                w=s.size.width;
            }
            if (s.size.height>h) {
                h=s.size.height;
            }
            s.tag = SCROLLTAG+i;
            s.delegate = self;
            [_arrayScroll2 addObject:s];
        }
        _scroll2.size = CGSizeMake(w, h);
        for (int i=0; i<_arrayScroll2.count; i++) {
            UIScrollView* s = [_arrayScroll2 objectAtIndex:i];
            s.left = i*_scroll2.width;
            s.size = _scroll2.size;
            [_scroll2 addSubview:s];
        }
        [self addSubview:_scroll2];
        
        if (_scroll2.bottom>768) {
            _scroll2.height -= (_scroll2.bottom-768)+30;
            _scroll2.bounces = YES;
        }
        UIScrollView* ss = [_arrayScroll2 objectAtIndex:0];
        float fh = ss.contentSize.height;
        _scroll2.contentSize = CGSizeMake(_scroll2.width, fh);
        [self onChangeText2:btChina2];
        
        if ([_detaildic objectForKey:@"right2"]) {
            _scroll2.right = btJapan2.right-14;
        }
        if (ss.contentSize.height > _scroll2.height) {
            if (_tip) {
                [_tip removeFromSuperview];
                _tip = nil;
            }
            if ([[_detaildic objectForKey:@"scrollTip"]intValue]==1) {
                _tip = getImageViewByImageName(@"page_scrollIndicatorwhite.png");
            } else {
                _tip = getImageViewByImageName(@"page_scrollIndicator.png");
            }
            [self addSubview:_tip];
            _tip.centerX = _scroll2.centerX;
            _tip.top = _scroll2.bottom+5;
            _tip.tag = ss.tag+100;
            if (_scroll1.contentOffset.y + _scroll2.height >= _scroll2.contentSize.height) {
                [_tip setHidden:YES];
            } else {
                [_tip setHidden:NO];
            }
        } else {
            if (_tip) {
                [_tip removeFromSuperview];
                _tip = nil;
            }
        }
        [self onChangeText2:btChina2];
    }
    
    if (_seq<1000) {
        int num = [[_detaildic objectForKey:@"collecttype"]intValue];
        UIButton* bt = getButtonByImageName(@"unfavorite1.png");
        NSArray* showqueue = [[DataManager sharedManager]getProducts];
        for (ProductObject* prdobj in showqueue) {
            if (prdobj.seq == _seq) {
                if (prdobj.isCollect) {
                    isCollect = YES;
                    [bt setBackgroundImage:getBundleImage(@"favorite.png") forState:UIControlStateNormal];
                } else {
                    isCollect = NO;
                    [bt setBackgroundImage:getBundleImage([NSString stringWithFormat:@"unfavorite%d.png",num]) forState:UIControlStateNormal];
                }
                break;
            }
        }
        bt.top = 60;
        bt.right = self.width-7;
        bt.tag = _seq;
        [bt addTarget:self action:@selector(onClickCollect:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:bt];
    }
}

- (void)onClickCollect:(id)sender {
    UIButton* b = (UIButton*)sender;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onCollect" object:[NSNumber numberWithInt:_seq]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeCollectArray" object:[NSNumber numberWithBool:YES]];
    if (isCollect) {
        isCollect = NO;
        int num = [[_detaildic objectForKey:@"collecttype"]intValue];
        [b setBackgroundImage:getBundleImage([NSString stringWithFormat:@"unfavorite%d.png",num]) forState:UIControlStateNormal];
    } else {
        isCollect = YES;
        [b setBackgroundImage:getBundleImage(@"favorite.png") forState:UIControlStateNormal];
    }
}

- (void)onChangeText:(id)sender {
    UIButton* b = (UIButton*)sender;
    
    [btChina setImage:getBundleImage(@"btchina.png") forState:UIControlStateNormal];
    [btEnglish setImage:getBundleImage(@"btenglish.png") forState:UIControlStateNormal];
    [btJapan setImage:getBundleImage(@"btjapan.png") forState:UIControlStateNormal];
    
    if (b==btChina) {
        [btChina setImage:getBundleImage(@"btchinahl.png") forState:UIControlStateNormal];
    } else if (b==btEnglish) {
        [btEnglish setImage:getBundleImage(@"btenglishhl.png") forState:UIControlStateNormal];
    } else if (b==btJapan) {
        [btJapan setImage:getBundleImage(@"btjapanhl.png") forState:UIControlStateNormal];
    }
    _scroll1.delegate = nil;
    _scroll1.delegate = self;
    selectTag1 = b.tag-LABELTAG-1;
    
    UIScrollView* s = [_arrayScroll1 objectAtIndex:selectTag1];
    _scroll1.contentSize = CGSizeMake(_scroll1.contentSize.width, s.contentSize.height);
    if (s.contentSize.height > _scroll1.height) {
        if (_tip) {
            [_tip removeFromSuperview];
            _tip = nil;
        }
        if ([[_detaildic objectForKey:@"scrollTip"]intValue]==1) {
            _tip = getImageViewByImageName(@"page_scrollIndicatorwhite.png");
        } else {
            _tip = getImageViewByImageName(@"page_scrollIndicator.png");
        }
        [self addSubview:_tip];
        _tip.centerX = _scroll1.centerX;
        _tip.top = _scroll1.bottom+5;
        _tip.tag = s.tag+100;
        if (_scroll1.contentOffset.y + _scroll1.height >= _scroll1.contentSize.height) {
            [_tip setHidden:YES];
        } else {
            [_tip setHidden:NO];
        }
    } else {
        if (_tip) {
            [_tip removeFromSuperview];
            _tip = nil;
        }
    }
    
    [UIView animateWithDuration:0.25 animations:^(){
        for (UIScrollView *v in _arrayScroll1) {
            v.transform = CGAffineTransformMakeTranslation(-_scroll1.width*selectTag1, 0);
        }
    }];
}

- (void)onChangeText2:(id)sender {
    UIButton* b = (UIButton*)sender;
    
    [btChina2 setImage:getBundleImage(@"btchina.png") forState:UIControlStateNormal];
    [btEnglish2 setImage:getBundleImage(@"btenglish.png") forState:UIControlStateNormal];
    [btJapan2 setImage:getBundleImage(@"btjapan.png") forState:UIControlStateNormal];
    
    if (b==btChina2) {
        [btChina2 setImage:getBundleImage(@"btchinahl.png") forState:UIControlStateNormal];
    } else if (b==btEnglish2) {
        [btEnglish2 setImage:getBundleImage(@"btenglishhl.png") forState:UIControlStateNormal];
    } else if (b==btJapan2) {
        [btJapan2 setImage:getBundleImage(@"btjapanhl.png") forState:UIControlStateNormal];
    }
    
    UIScrollView* s = [_arrayScroll2 objectAtIndex:selectTag2];
    _scroll1.contentSize = CGSizeMake(_scroll2.contentSize.width, s.contentSize.height);
    selectTag2 = b.tag-LABELTAG-11;
    
    if (s.contentSize.height > _scroll2.height) {
        if (_tip) {
            [_tip removeFromSuperview];
            _tip = nil;
        }
        if ([[_detaildic objectForKey:@"scrollTip"]intValue]==1) {
            _tip = getImageViewByImageName(@"page_scrollIndicatorwhite.png");
        } else {
            _tip = getImageViewByImageName(@"page_scrollIndicator.png");
        }
        [self addSubview:_tip];
        _tip.centerX = _scroll2.centerX;
        _tip.top = _scroll2.bottom+5;
        _tip.tag = s.tag+100;
        if (_scroll2.contentOffset.y + _scroll2.height >= _scroll2.contentSize.height) {
            [_tip setHidden:YES];
        } else {
            [_tip setHidden:NO];
        }
    } else {
        if (_tip) {
            [_tip removeFromSuperview];
            _tip = nil;
        }
    }
    
    [UIView animateWithDuration:0.25 animations:^(){
        for (UIScrollView *v in _arrayScroll2) {
            v.transform = CGAffineTransformMakeTranslation(-_scroll2.width*selectTag2, 0);
        }
    }];
}

- (void)setStatus_:(eContainerStatus)status{
    if (status==status_) {
        return;
    }
    switch (status) {
        case eContainerStatus_Appear:
            if (!uiSetup_) {
                [self setupUI];
                uiSetup_ = YES;
            }
            break;
        case eContainerStatus_Release: {
            [self removeAllSubviews];
            uiSetup_ =  NO;
        }
            break;
        case eContainerStatus_Disappear:
            if (!uiSetup_) {
                [self setupUI];
                uiSetup_ = YES;
            }
            break;
            
        default:
            break;
    }
    
    status_ = status;
}

- (void)enable_scroll:(NSNotification*)sender {
    //self.scrollEnabled = [(NSNumber*)sender.object boolValue];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView==_scroll1) {
        if (_scroll1.contentOffset.x != 0) {
            CGPoint offset = _scroll1.contentOffset;
            offset.x = selectTag1*_scroll1.width;
            _scroll1.contentOffset = offset;
        }
        
        int offset = selectTag1;//_scroll1.contentOffset.x/_scroll1.width;
        [btChina setImage:getBundleImage(@"btchina.png") forState:UIControlStateNormal];
        [btEnglish setImage:getBundleImage(@"btenglish.png") forState:UIControlStateNormal];
        [btJapan setImage:getBundleImage(@"btjapan.png") forState:UIControlStateNormal];
        
        if (offset==0) {
            [btChina setImage:getBundleImage(@"btchinahl.png") forState:UIControlStateNormal];
        } else if (offset==1) {
            [btEnglish setImage:getBundleImage(@"btenglishhl.png") forState:UIControlStateNormal];
        } else if (offset==2) {
            [btJapan setImage:getBundleImage(@"btjapanhl.png") forState:UIControlStateNormal];
        }
        UIScrollView* s = [_arrayScroll1 objectAtIndex:offset];
        _scroll1.contentSize = CGSizeMake(_scroll1.width, s.contentSize.height);
        
        if (s.contentSize.height > _scroll1.height) {
            if (_tip) {
                [_tip removeFromSuperview];
                _tip = nil;
            }
            if ([[_detaildic objectForKey:@"scrollTip"]intValue]==1) {
                _tip = getImageViewByImageName(@"page_scrollIndicatorwhite.png");
            } else {
                _tip = getImageViewByImageName(@"page_scrollIndicator.png");
            }
            [self addSubview:_tip];
            _tip.centerX = _scroll1.centerX;
            _tip.top = _scroll1.bottom+5;
            _tip.tag = s.tag+100;
            if (_scroll1.contentOffset.y + _scroll1.height >= _scroll1.contentSize.height) {
                [_tip setHidden:YES];
            } else {
                [_tip setHidden:NO];
            }
        } else {
            if (_tip) {
                [_tip removeFromSuperview];
                _tip = nil;
            }
        }
    } else if (scrollView==_scroll2) {
        if (_scroll2.contentOffset.x != 0) {
            CGPoint offset = _scroll2.contentOffset;
            offset.x = selectTag2*_scroll2.width;
            _scroll2.contentOffset = offset;
        }
        
        int offset = _scroll2.contentOffset.x/_scroll2.width;
        [btChina2 setImage:getBundleImage(@"btchina.png") forState:UIControlStateNormal];
        [btEnglish2 setImage:getBundleImage(@"btenglish.png") forState:UIControlStateNormal];
        [btJapan2 setImage:getBundleImage(@"btjapan.png") forState:UIControlStateNormal];
        
        if (offset==0) {
            [btChina2 setImage:getBundleImage(@"btchinahl.png") forState:UIControlStateNormal];
        } else if (offset==1) {
            [btEnglish2 setImage:getBundleImage(@"btenglishhl.png") forState:UIControlStateNormal];
        } else if (offset==2) {
            [btJapan2 setImage:getBundleImage(@"btjapanhl.png") forState:UIControlStateNormal];
        }
        UIScrollView* s = [_arrayScroll2 objectAtIndex:offset];
        _scroll2.contentSize = CGSizeMake(_scroll2.width, s.contentSize.height);
        
        if (s.contentSize.height > _scroll2.height) {
            if (_tip) {
                [_tip removeFromSuperview];
                _tip = nil;
            }
            if ([[_detaildic objectForKey:@"scrollTip"]intValue]==1) {
                _tip = getImageViewByImageName(@"page_scrollIndicatorwhite.png");
            } else {
                _tip = getImageViewByImageName(@"page_scrollIndicator.png");
            }
            [self addSubview:_tip];
            _tip.centerX = _scroll2.centerX;
            _tip.top = _scroll2.bottom+5;
            _tip.tag = s.tag+100;
            if (_scroll2.contentOffset.y + _scroll2.height >= _scroll2.contentSize.height) {
                [_tip setHidden:YES];
            } else {
                [_tip setHidden:NO];
            }
        } else {
            if (_tip) {
                [_tip removeFromSuperview];
                _tip = nil;
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == _scroll1) {
        if (_scroll1.contentOffset.x != 0) {
            CGPoint offset = _scroll1.contentOffset;
            offset.x = selectTag1*_scroll1.width;
            _scroll1.contentOffset = offset;
        }

        if (scrollView.contentOffset.y + scrollView.height >= scrollView.contentSize.height) {
            [_tip setHidden:YES];
        } else {
            [_tip setHidden:NO];
        }
    } else if (scrollView == _scroll2) {
        if (_scroll2.contentOffset.x != 0) {
            CGPoint offset = _scroll2.contentOffset;
            offset.x = selectTag2*_scroll2.width;
            _scroll2.contentOffset = offset;
        }
        
        if (scrollView.contentOffset.y + scrollView.height >= scrollView.contentSize.height) {
            [_tip setHidden:YES];
        } else {
            [_tip setHidden:NO];
        }
    } else {
        if (_scroll2.contentOffset.x != 0) {
            CGPoint offset = _scroll2.contentOffset;
            offset.x = selectTag2*_scroll2.width;
            _scroll2.contentOffset = offset;
        }
        if (scrollView.contentOffset.y + scrollView.height >= scrollView.contentSize.height) {
            [_tip setHidden:YES];
        } else {
            [_tip setHidden:NO];
        }
    }//15959213628
    
}









@end
