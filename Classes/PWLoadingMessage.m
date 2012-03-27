//
//  PWLoadingMessage.m
//  FlickrExplore
//
//  Created by Patrik Weiskircher on 12.12.2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PWLoadingMessage.h"
#import "PWDrawHelper.h"

static const int W_MARGIN = 8;
static const int H_MARGIN = 8;
static const int CORNER_RADIUS = 3;

@implementation PWLoadingMessage
@synthesize message, hidesWhenStopped;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		self.message = @"Loading...";
		activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		label = [[UILabel alloc] initWithFrame:CGRectZero];
		label.text = self.message;
		label.textColor = [UIColor whiteColor];
		label.backgroundColor = [UIColor clearColor];
		label.opaque = NO;
		[label sizeToFit];
		font = [[UIFont boldSystemFontOfSize:18] retain];
		
		self.hidesWhenStopped = YES;
		self.hidden = YES;
		
		[self addSubview:activityView];
		[self addSubview:label];
		
		[self setNeedsLayout];
		
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void) startAnimating {
	return [self startAnimatingWithFadeInAnimation:YES];
}

- (void) startAnimatingWithFadeInAnimation:(BOOL)animation {
	if (self.hidesWhenStopped) {
		self.hidden = NO;
		if (animation) {
			self.alpha = 0;
			[UIView animateWithDuration:0.05
							 animations:^(void) {
								 self.alpha = 1;
							 }];
		} else {
			self.alpha = 1;
		}
	}
	[activityView startAnimating];	
}

- (void) stopAnimating {
	if (self.hidesWhenStopped) {
		[UIView animateWithDuration:0.2
						animations:^(void) {
							self.alpha = 0;
						}
						 completion:^(BOOL finished) {
							 		self.hidden = YES;
									[activityView stopAnimating];
						 }];
	} else {
		[activityView stopAnimating];
	}
}

- (void)layoutSubviews {
	activityView.frame = CGRectMake(W_MARGIN, round(self.bounds.size.height / 2 - activityView.bounds.size.height/2),
									activityView.bounds.size.width, activityView.bounds.size.height);
	label.frame = CGRectMake(activityView.frame.origin.x + W_MARGIN + activityView.frame.size.width,
							 round(self.bounds.size.height/2 - label.bounds.size.height/2),
							 label.bounds.size.width, label.bounds.size.height);
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	CGContextRef myContext = UIGraphicsGetCurrentContext();
	CGContextSetRGBFillColor(myContext, 0.2, 0.2, 0.2, 0.8);
    
    [PWDrawHelper drawRoundedRectangleUsing:myContext
                                  andBounds:self.bounds
                                 withRadius:CORNER_RADIUS];
}

- (CGSize)sizeThatFits:(CGSize)size {
	CGFloat height = round(H_MARGIN + MAX(activityView.frame.size.height, label.bounds.size.height) + H_MARGIN);
	if (((int)height) % 2 != 0)
		height++;
	return CGSizeMake(W_MARGIN + activityView.frame.size.width + W_MARGIN + label.bounds.size.width + W_MARGIN,
					 height);
}

- (void)dealloc {
	[message release];
	[activityView release];
    [super dealloc];
}


@end
