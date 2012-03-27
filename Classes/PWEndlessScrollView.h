//
//  PWEndlessScrollingView.h
//  FlickrExplore
//
//  Created by Patrik Weiskircher on 12/14/10.
//  Copyright 2010 INQNET. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PWEndlessScrollView;

typedef enum {
	PWEndlessScrollViewViewTypePrevious,
	PWEndlessScrollViewViewTypeCurrent,
	PWEndlessScrollViewViewTypeNext
} PWEndlessScrollViewViewType;

typedef enum {
	PWEndlessScrollCurrentPositionLeft,
	PWEndlessScrollCurrentPositionMiddle,
	PWEndlessScrollCurrentPositionRight
} PWEndlessScrollCurrentPosition;

@protocol PWEndlessScrollViewDataSource
- (BOOL) endlessScrollViewPreviousAvailable:(PWEndlessScrollView*)scrollView;
- (BOOL) endlessScrollViewNextAvailable:(PWEndlessScrollView*)scrollView;

- (void) endlessScrollView:(PWEndlessScrollView*)scrollView needsView:(UIView*)theView updatedForType:(PWEndlessScrollViewViewType)theType;
@end

@protocol PWEndlessScrollViewDelegate

- (void) endlessScrollView:(PWEndlessScrollView*)scrollView didChangeIndex:(int)indexChange;
- (void) endlessScrollViewUserStartedScrolling:(PWEndlessScrollView*)scrollView;
- (void) endlessScrollViewUserStoppedScrolling:(PWEndlessScrollView*)scrollView;

@end


@interface PWEndlessScrollView : UIScrollView <UIScrollViewDelegate> {
	UIView* prevView;
	UIView* currentView;
	UIView* nextView;
	
	UIView* contentView;
	
	id<PWEndlessScrollViewDataSource> dataSource;
	id<PWEndlessScrollViewDelegate> endlessDelegate;
	
	PWEndlessScrollCurrentPosition currentPosition;
    
    BOOL dragging;
}
@property(nonatomic, readwrite, assign) id<PWEndlessScrollViewDataSource> dataSource;
@property(nonatomic, readwrite, assign) id<PWEndlessScrollViewDelegate> endlessDelegate;
- (void) reloadData;
@end
