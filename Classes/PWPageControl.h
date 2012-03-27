//
//  PWPageControl.h
//  FlickrExplorer
//
//  Created by Patrik Weiskircher on 8.7.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PWPageControlSizeSmall,
    PWPageControlSizeBig
} PWPageControlSize;

//@class PWPageControl;
//
//@protocol PWPageControlDelegateProtocol <NSObject>
//- (CGRect) frameForPager:(PWPageControl*)pager withSize:(CGSize)size andPageControlSize:(PWPageControlSize)pageControlSize;
//@end


@interface PWPageControl : UIView {
    UILabel* currentPageView;
    UILabel* dividerView;
    UILabel* maxPageView;
    
    NSTimer* hideTimer;
    
    UIImageView* resizeImageView;
    CGPoint previousSmallPoint;
    
//    id<PWPageControlDelegateProtocol> delegate;
}
@property(nonatomic, readwrite, assign) int maxPages;
@property(nonatomic, readwrite, assign) int currentPage;
@property(nonatomic, readwrite, assign) PWPageControlSize pageControlSize;
@property(nonatomic, readwrite, assign) BOOL showPagerOnPageChange;
//@property(nonatomic, readwrite, assign) id<PWPageControlDelegateProtocol> delegate;

- (void) show;
- (void) hideWithAnimation:(BOOL)animation;

//- (void) makeBig;
//- (void) makeSmall;
@end
