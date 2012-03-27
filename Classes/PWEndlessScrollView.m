//
//  PWEndlessScrollingView.m
//  FlickrExplore
//
//  Created by Patrik Weiskircher on 12/14/10.
//  Copyright 2010 INQNET. All rights reserved.
//

#import "PWEndlessScrollView.h"

@interface PWEndlessScrollView ()
- (void) commonInit;
- (void) layoutScrollView;
@end


@implementation PWEndlessScrollView
@synthesize dataSource, endlessDelegate;

- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self != nil) {
		[self commonInit];
	}
	return self;
}

- (id) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self != nil) {
		[self commonInit];
	}
	return self;
}

- (void) commonInit {
	self.pagingEnabled = YES;
	self.delegate = self;
	self.showsVerticalScrollIndicator = NO;
	self.showsHorizontalScrollIndicator = NO;
	
	contentView = [[UIView alloc] initWithFrame:CGRectZero];
	contentView.backgroundColor = [UIColor blackColor];
	
	prevView = [[UIView alloc] initWithFrame:CGRectZero];
	currentView = [[UIView alloc] initWithFrame:CGRectZero];
	nextView = [[UIView alloc] initWithFrame:CGRectZero];
	
	[self addSubview:contentView];
	[contentView addSubview:prevView];
	[contentView addSubview:currentView];
	[contentView addSubview:nextView];
}

- (void) layoutScrollView {
	CGFloat x = self.bounds.size.width;
	currentPosition = PWEndlessScrollCurrentPositionMiddle;
	if ([dataSource endlessScrollViewNextAvailable:self] == NO && [dataSource endlessScrollViewPreviousAvailable:self] == NO) {
		[NSException raise:NSInternalInconsistencyException format:@"no next, no prev available. not supported."];
		return;
	}
	if (![dataSource endlessScrollViewPreviousAvailable:self]) {
		x = 0;
		currentPosition = PWEndlessScrollCurrentPositionLeft;
	} else if (![dataSource endlessScrollViewNextAvailable:self]) {
		x = self.bounds.size.width * 2;
		currentPosition = PWEndlessScrollCurrentPositionRight;
	}
	
	self.contentOffset = CGPointMake(x, 0);
	
	switch (currentPosition) {
		case PWEndlessScrollCurrentPositionLeft:
			[dataSource endlessScrollView:self needsView:currentView updatedForType:PWEndlessScrollViewViewTypeNext];
			[dataSource endlessScrollView:self needsView:prevView updatedForType:PWEndlessScrollViewViewTypeCurrent];
			break;
		case PWEndlessScrollCurrentPositionMiddle:
			[dataSource endlessScrollView:self needsView:currentView updatedForType:PWEndlessScrollViewViewTypeCurrent];
			[dataSource endlessScrollView:self needsView:prevView updatedForType:PWEndlessScrollViewViewTypePrevious];
			[dataSource endlessScrollView:self needsView:nextView updatedForType:PWEndlessScrollViewViewTypeNext];
			break;
		case PWEndlessScrollCurrentPositionRight:
			[dataSource endlessScrollView:self needsView:nextView updatedForType:PWEndlessScrollViewViewTypeCurrent];
			[dataSource endlessScrollView:self needsView:currentView updatedForType:PWEndlessScrollViewViewTypePrevious];
			break;
	}
}

- (void) reloadData {
	[self layoutScrollView];
}

- (void) layoutSubviews {
	[super layoutSubviews];
	
	contentView.frame = CGRectMake(0, 0, self.bounds.size.width*3, self.bounds.size.height);
	self.contentSize = contentView.bounds.size;
	prevView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
	currentView.frame = CGRectMake(self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height);
	nextView.frame = CGRectMake(self.bounds.size.width*2, 0, self.bounds.size.width, self.bounds.size.height);
	
	if (!dragging) {
		CGFloat x = 0;
		switch (currentPosition) {
			case PWEndlessScrollCurrentPositionLeft: x = 0; break;
			case PWEndlessScrollCurrentPositionMiddle: x = self.bounds.size.width; break;
			case PWEndlessScrollCurrentPositionRight: x = self.bounds.size.width*2; break;
		}
		self.contentOffset = CGPointMake(x, 0);
	}
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[endlessDelegate endlessScrollViewUserStartedScrolling:self];
    dragging = YES;
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    dragging = NO;
	PWEndlessScrollCurrentPosition newPosition;
	if (fabs(0 - self.contentOffset.x) <= 1.0) {
		newPosition = PWEndlessScrollCurrentPositionLeft;
	} else if (fabs(self.bounds.size.width - self.contentOffset.x) <= 1.0) {
		newPosition = PWEndlessScrollCurrentPositionMiddle;
	} else {
		newPosition = PWEndlessScrollCurrentPositionRight;
	}
	
	int indexChange = 0;
	if (newPosition > currentPosition)
		indexChange = 1;
	else if (newPosition < currentPosition)
		indexChange = -1;
	
	[endlessDelegate endlessScrollView:self didChangeIndex:indexChange];
	[endlessDelegate endlessScrollViewUserStoppedScrolling:self];
	[self layoutScrollView];
}

- (void) dealloc
{
	[contentView release];
	[prevView release];
	[currentView release];
	[nextView release];
	[super dealloc];
}


@end
