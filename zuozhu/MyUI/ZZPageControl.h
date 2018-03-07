#import <UIKit/UIKit.h>

typedef enum {
    ZZPageControlModeDots = 0, // like system control
    ZZPageControlModeBlocks,   // squares instead of dots
    ZZPageControlModeProgress, // rectangular progress bar with round corners
    ZZPageControlModeBlock,    // rectangular progress bar
    ZZPageControlModePill      // bordered progress bar with round corners
} ZZPageControlMode;

@interface ZZPageControl : UIControl {
@private
    NSInteger _numberOfPages;
    NSInteger _currentPage;
    NSInteger _displayedPage;
    BOOL _hidesForSinglePage;
    BOOL _defersCurrentPageDisplay;
    UIColor *_activeColor;
    UIColor *_inactiveColor;
    ZZPageControlMode _primaryMode;
    ZZPageControlMode _fitMode;
    CGFloat _inset;
}

@property(nonatomic) NSInteger numberOfPages; // default is 0
@property(nonatomic) NSInteger currentPage; // default is 0. value pinned to 0..numberOfPages-1
@property(nonatomic) BOOL hidesForSinglePage; // hide the the indicator if there is only one page. default is NO
@property(nonatomic) BOOL defersCurrentPageDisplay; // if set, clicking to a new page won't update the currently
// displayed page until -updateCurrentPageDisplay is called.
// default is NO

@property(nonatomic, strong) UIColor *activeColor; // default is white
@property(nonatomic, strong) UIColor *inactiveColor; // default is semitransparent active color

@property(nonatomic, assign) ZZPageControlMode primaryMode; // dots is default
@property(nonatomic, assign) ZZPageControlMode fitMode; // progress is default; used if primary mode is dots or blocks
// and they don't fit in bounds (too many pages);
// in most cases you want this to be progress, block or pill
@property(nonatomic, readonly) ZZPageControlMode displayMode; // primary or fit mode depending on bounds and pages count

@property(nonatomic, assign) CGFloat inset; // for progress bar modes

- (void)updateCurrentPageDisplay; // update page display to match the currentPage.
// ignored if defersCurrentPageDisplay is NO.
// setting the page value directly will update immediately

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount; // returns minimum size required to display dots for given page count.
// can be used to size control if page count could change

@end