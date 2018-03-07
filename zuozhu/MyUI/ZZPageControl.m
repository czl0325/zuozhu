#import "ZZPageControl.h"

#define kUnitSize 6
#define kUnitSpacing 10
#define kPillLineWidth 2
#define kPillSpacing 1
#define kInactiveAlpha 0.3

@implementation ZZPageControl

@synthesize defersCurrentPageDisplay = _defersCurrentPageDisplay;
@synthesize activeColor = _activeColor;
@synthesize inactiveColor = _inactiveColor;

- (void)setupView {
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
    self.backgroundColor = [UIColor clearColor];
    self.primaryMode = ZZPageControlModeDots;
    self.fitMode = ZZPageControlModeProgress;
    self.inset = kPillLineWidth + kPillSpacing + kUnitSize / 2; // make sure that we fit for any mode by default
}

- (id)initWithFrame:(CGRect)aRect {
    if ((self = [super initWithFrame:aRect])) {
        [self setupView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupView];
}


- (void)addPillPathAroundRect:(CGRect)r toContext:(CGContextRef)ctx {
    if (r.size.width == 0) {
        return;
    }
    const CGFloat d = r.size.height / 2;
    CGContextMoveToPoint(ctx, r.origin.x, r.origin.y + r.size.height);
    CGContextAddArc(ctx, r.origin.x, r.origin.y + d, d, M_PI_2, -M_PI_2, 0);
    CGContextAddLineToPoint(ctx, r.origin.x + r.size.width, r.origin.y);
    CGContextAddArc(ctx, r.origin.x + r.size.width, r.origin.y + d, d, -M_PI_2, M_PI_2, 0);
    CGContextAddLineToPoint(ctx, r.origin.x, r.origin.y + r.size.height);
}

- (void)drawRect:(CGRect)rect {
    if (_numberOfPages == 0 || (_numberOfPages == 1 && _hidesForSinglePage)) {
        return;
    }
    UIColor *activeColor = self.activeColor ? self.activeColor : [UIColor whiteColor];
    UIColor *inactiveColor = self.inactiveColor ? self.inactiveColor : [activeColor colorWithAlphaComponent:kInactiveAlpha];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    const ZZPageControlMode mode = self.displayMode;
    if (mode == ZZPageControlModeDots || mode == ZZPageControlModeBlocks) {
        CGSize size = [self sizeForNumberOfPages:_numberOfPages];
        const CGFloat left = (self.bounds.size.width - size.width) / 2;
        const CGFloat top = (self.bounds.size.height - size.height) / 2;
        for (NSInteger page = 0; page < _numberOfPages; page++) {
            (page == _displayedPage) ? [activeColor set] : [inactiveColor set];
            if (mode == ZZPageControlModeDots) {
                CGContextAddEllipseInRect(ctx, CGRectMake(left + page * (kUnitSize + kUnitSpacing), top, kUnitSize, kUnitSize));
            } else if (mode == ZZPageControlModeBlocks) {
                CGContextAddRect(ctx, CGRectMake(left + page * (kUnitSize + kUnitSpacing), top, kUnitSize, kUnitSize));
            }
            CGContextFillPath(ctx);
        }
    } else if (mode == ZZPageControlModeProgress ||
               mode == ZZPageControlModeBlock ||
               mode == ZZPageControlModePill)
    {
        CGRect r = self.bounds;
        r.origin.x += self.inset;
        r.size.width -= self.inset * 2;
        r.origin.y = (r.size.height - kUnitSize) / 2;
        r.size.height = kUnitSize;
        float progress = (_numberOfPages > 1) ? (float)_displayedPage / (float)(_numberOfPages - 1) : 0;
        if (mode == ZZPageControlModeProgress) {
            [inactiveColor set];
            [self addPillPathAroundRect:r toContext:ctx];
            CGContextFillPath(ctx);
            r.size.width *= progress;
            [activeColor set];
            [self addPillPathAroundRect:r toContext:ctx];
            CGContextFillPath(ctx);
        } else if (mode == ZZPageControlModeBlock) {
            [inactiveColor set];
            CGContextAddRect(ctx, r);
            CGContextFillPath(ctx);
            r.size.width *= progress;
            [activeColor set];
            CGContextAddRect(ctx, r);
            CGContextFillPath(ctx);
        } else if (mode == ZZPageControlModePill) {
            [activeColor set];
            CGRect b = CGRectInset(r, -kPillSpacing / 2, -(kPillLineWidth + kPillSpacing));
            [self addPillPathAroundRect:b toContext:ctx];
            CGContextSetLineWidth(ctx, kPillLineWidth);
            CGContextStrokePath(ctx);
            r.size.width *= progress;
            [self addPillPathAroundRect:r toContext:ctx];
            CGContextFillPath(ctx);
        }
    }
}

- (void)updateCurrentPageDisplay {
    if (_displayedPage != _currentPage) {
        _displayedPage = _currentPage;
        [self setNeedsDisplay];
    }
}

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount {
    if (pageCount == 0 || (pageCount == 1 && _hidesForSinglePage)) {
        return CGSizeZero;
    }
    return CGSizeMake((kUnitSize + kUnitSpacing) * pageCount - kUnitSpacing, kUnitSize);
}

- (NSInteger)numberOfPages {
    return _numberOfPages;
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    if (numberOfPages < 0) {
        numberOfPages = 0;
    }
    if (_numberOfPages == numberOfPages) {
        return;
    }
    _numberOfPages = numberOfPages;
    if (_currentPage >= _numberOfPages) {
        _currentPage = _numberOfPages - 1;
    }
    if (_currentPage < 0) {
        _currentPage = 0;
    }
    if (_displayedPage >= _numberOfPages) {
        _displayedPage = _numberOfPages - 1;
    }
    if (_displayedPage < 0) {
        _displayedPage = 0;
    }
    [self setNeedsDisplay];
}

- (NSInteger)currentPage {
    return _currentPage;
}

- (void)setCurrentPage:(NSInteger)currentPage {
    if (currentPage >= _numberOfPages) {
        currentPage = _numberOfPages - 1;
    }
    if (currentPage < 0) {
        currentPage = 0;
    }
    if (_currentPage == currentPage) {
        return;
    }
    _currentPage = currentPage;
    _displayedPage = currentPage;
    [self setNeedsDisplay];
}

- (BOOL)hidesForSinglePage {
    return _hidesForSinglePage;
}

- (void)setHidesForSinglePage:(BOOL)hidesForSinglePage {
    if (_hidesForSinglePage != hidesForSinglePage) {
        return;
    }
    _hidesForSinglePage = hidesForSinglePage;
    [self setNeedsDisplay];
}

- (ZZPageControlMode)primaryMode {
    return _primaryMode;
}

- (void)setPrimaryMode:(ZZPageControlMode)mode {
    if (_primaryMode != mode) {
        _primaryMode = mode;
        [self setNeedsDisplay];
    }
}

- (ZZPageControlMode)fitMode {
    return _fitMode;
}

- (void)setFitMode:(ZZPageControlMode)mode {
    if (_fitMode != mode) {
        _fitMode = mode;
        [self setNeedsDisplay];
    }
}

- (ZZPageControlMode)displayMode {
    if (self.primaryMode == ZZPageControlModeDots || self.primaryMode == ZZPageControlModeBlocks) {
        CGSize size = [self sizeForNumberOfPages:_numberOfPages];
        if (kUnitSpacing + size.width + kUnitSpacing > self.bounds.size.width) {
            return self.fitMode;
        }
    }
    return self.primaryMode;
}

- (CGFloat)inset {
    return _inset;
}

- (void)setInset:(CGFloat)inset {
    if (_inset != inset) {
        _inset = inset;
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_numberOfPages == 0 || (_numberOfPages == 1 && _hidesForSinglePage)) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    BOOL updated = NO;
    CGFloat displayedX = self.bounds.size.width / 2;
    
    const ZZPageControlMode mode = self.displayMode;
    if (mode == ZZPageControlModeDots || mode == ZZPageControlModeBlocks) {
        CGSize size = [self sizeForNumberOfPages:_numberOfPages];
        const CGFloat left = (self.bounds.size.width - size.width) / 2;
        displayedX = left + (kUnitSize + kUnitSpacing) * _displayedPage + kUnitSize / 2;
    } else if (mode == ZZPageControlModeProgress ||
               mode == ZZPageControlModeBlock ||
               mode == ZZPageControlModePill)
    {
        CGRect r = self.bounds;
        r.origin.x += self.inset;
        r.size.width -= self.inset * 2;
        float progress = (_numberOfPages > 1) ? (float)_displayedPage / (float)(_numberOfPages - 1) : 0;
        displayedX = r.origin.x + progress * r.size.width;
    }
    
    if (location.x < displayedX && _displayedPage > 0) {
        _currentPage = _displayedPage - 1;
        updated = YES;
    }
    if (location.x > displayedX && _displayedPage < (_numberOfPages - 1)) {
        _currentPage = _displayedPage + 1;
        updated = YES;
    }
    if (updated) {
        if (!_defersCurrentPageDisplay) {
            [self updateCurrentPageDisplay];
        }
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    [super touchesEnded:touches withEvent:event];
}

@end