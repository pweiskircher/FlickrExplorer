//
//  PWPageControl.m
//  FlickrExplorer
//
//  Created by Patrik Weiskircher on 8.7.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PWPageControl.h"
#import "PWDrawHelper.h"
#import <QuartzCore/QuartzCore.h>

@interface PWPageControl ()
- (void) commonInit;
+ (CGSize) sizeForSize:(PWPageControlSize)size;
+ (CGFloat) marginForSize:(PWPageControlSize)size;
- (void) showAndHideWithAnimation:(BOOL)animation;
- (void) hideWithAnimation:(BOOL)animation;
@end

@implementation PWPageControl
@synthesize maxPages;
@synthesize currentPage;
@synthesize pageControlSize;
@synthesize showPagerOnPageChange;
//@synthesize delegate;

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void) commonInit {
    currentPageView = [[UILabel alloc] initWithFrame:CGRectZero];
    dividerView = [[UILabel alloc] initWithFrame:CGRectZero];
    dividerView.text = @"/";
    maxPageView = [[UILabel alloc] initWithFrame:CGRectZero];
    
    currentPageView.backgroundColor = [UIColor clearColor];
    dividerView.backgroundColor = [UIColor clearColor];
    maxPageView.backgroundColor = [UIColor clearColor];
    
    currentPageView.textColor = [UIColor whiteColor];
    dividerView.textColor = [UIColor whiteColor];
    maxPageView.textColor = [UIColor whiteColor];
    
    currentPageView.textAlignment = UITextAlignmentRight;
    dividerView.textAlignment = UITextAlignmentCenter;
    maxPageView.textAlignment = UITextAlignmentCenter;

    [self addSubview:currentPageView];
    [self addSubview:dividerView];
    [self addSubview:maxPageView];
    
    self.pageControlSize = PWPageControlSizeSmall;
    
    [self layoutSubviews];
    
    [self hideWithAnimation:NO];
}

+ (CGSize) sizeForSize:(PWPageControlSize)size {
    if (size == PWPageControlSizeSmall) {
        return CGSizeMake(50, 30);
    } else if (size == PWPageControlSizeBig) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            return CGSizeMake(440, 264);
        } else {
            return CGSizeMake(276, 165);
        }
    }
    return CGSizeZero;
}

+ (CGFloat) marginForSize:(PWPageControlSize)size {
    if (size == PWPageControlSizeSmall) {
        return 2;
    } else if (size == PWPageControlSizeBig) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            return 10;
        } else {
            return 4;
        }
    }
    return 0;
}

- (void) drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (CGSize) sizeThatFits:(CGSize)size {
    return [PWPageControl sizeForSize:self.pageControlSize];
}

- (void) layoutSubviews {
    CGFloat margin = [PWPageControl marginForSize:self.pageControlSize];
    
    CGFloat y;
    CGFloat textWidth;
    CGFloat height;
    CGFloat dividerWidth;
    CGFloat fontSize;
    if (self.pageControlSize == PWPageControlSizeSmall) {
        y = 4;
        textWidth = 19;
        height = 22;
        dividerWidth = 4;
        fontSize = 14;
    } else if (self.pageControlSize == PWPageControlSizeBig) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            height = 200;
            y = 34;
            textWidth = 175;
            dividerWidth = 50;
            fontSize = 155;
        } else {
            height = 130;
            y = 16;
            textWidth = 115;
            dividerWidth = 30;
            fontSize = 90;
        }
    }
    
    currentPageView.frame = CGRectMake(margin, y, textWidth, height);
    dividerView.frame = CGRectMake(currentPageView.frame.origin.x + currentPageView.frame.size.width + margin,
                                   y,
                                   dividerWidth, height);
    maxPageView.frame = CGRectMake(self.bounds.size.width - textWidth - margin,
                                   y,
                                   textWidth, height);
    
    UIFont* font = [UIFont systemFontOfSize:fontSize];
    currentPageView.font = font;
    dividerView.font = font;
    maxPageView.font = font;
}

- (void) showAndHideWithAnimation:(BOOL)animation {
    [hideTimer invalidate], [hideTimer release];
    hideTimer = [[NSTimer scheduledTimerWithTimeInterval:2.5
                                                  target:self
                                                selector:@selector(hide:)
                                                userInfo:[NSNumber numberWithBool:animation] repeats:NO] retain];
    
    if (animation) {
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:0
                         animations:^(void) {
                             self.alpha = 1;
                         } completion:^(BOOL finished) {

                         }];
    } else {
        self.alpha = 1;
    }
}

- (void) hide:(NSTimer*)timer {
    BOOL animation = [[timer userInfo] boolValue];
    [self hideWithAnimation:animation];
}

- (void) hideWithAnimation:(BOOL)animation {
    if (animation) {
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:0
                         animations:^(void) {
                             self.alpha = 0;
                         } completion:^(BOOL finished) {
                             
                         }];
    } else {
        self.alpha = 0;
    }
}

- (void) show {
    [UIView animateWithDuration:0.2
                     animations:^(void) {
                         self.alpha = 1;
                     }];
}

- (void) setMaxPages:(int)value {
    maxPages = value;
    maxPageView.text = [NSString stringWithFormat:@"%d", value];
}

- (void) setCurrentPage:(int)value {
    currentPage = value;
    currentPageView.text = [NSString stringWithFormat:@"%02d", value+1];
    
    if (showPagerOnPageChange)
        [self showAndHideWithAnimation:YES];
}

- (UIImage*) createImage {
    UIGraphicsBeginImageContext(self.frame.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void) addResizeImageViewWithImage:(UIImage*)image {
    [resizeImageView removeFromSuperview];
    [resizeImageView release];
    resizeImageView = [[UIImageView alloc] initWithImage:image];
    resizeImageView.contentMode = UIViewContentModeScaleAspectFit;
    resizeImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:resizeImageView];
    resizeImageView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [self bringSubviewToFront:resizeImageView];
}

//- (void) makeBig {
//    if (self.pageControlSize != PWPageControlSizeSmall || resizeImageView != nil || delegate == nil)
//        return;
//    
//    CGRect currentFrame = self.frame;
//    previousSmallPoint = self.frame.origin;
//    
//    self.alpha = 1;
//    self.pageControlSize = PWPageControlSizeBig;
//    [self sizeToFit];
//    
//    UIImage* image = [self createImage];
//    
//    self.alpha = 0;
//    self.pageControlSize = PWPageControlSizeSmall;
//    [self sizeToFit];
//    self.frame = currentFrame;
//   
//    [self addResizeImageViewWithImage:image];
//    
//    currentPageView.hidden = dividerView.hidden = maxPageView.hidden = YES;
//    
//    UIColor* previousColor = self.backgroundColor;
//    self.backgroundColor = [UIColor clearColor];
//    
//    [UIView animateWithDuration:0.2
//                          delay:0.0
//                        options:0
//                     animations:^(void) {
//                         self.alpha = 1;
//                         self.frame = [delegate frameForPager:self withSize:[PWPageControl sizeForSize:PWPageControlSizeBig] andPageControlSize:PWPageControlSizeBig];
//                     } completion:^(BOOL finished) {
//                          self.pageControlSize = PWPageControlSizeBig;
//                         [self layoutSubviews];
//                         [resizeImageView removeFromSuperview];
//                         [resizeImageView release], resizeImageView = nil;
//                         
//                         currentPageView.hidden = dividerView.hidden = maxPageView.hidden = NO;
//                         self.backgroundColor = previousColor;
//                     }];
//}
//
//- (void) makeSmall {
//    if (self.pageControlSize != PWPageControlSizeBig || resizeImageView != nil || delegate == nil)
//        return;
//    
//    self.alpha = 1;
//    UIImage* image = [self createImage];
//    
//    [self addResizeImageViewWithImage:image];
//    
//    currentPageView.hidden = dividerView.hidden = maxPageView.hidden = YES;
//    
//    UIColor* previousColor = self.backgroundColor;
//    self.backgroundColor = [UIColor clearColor];
//    
//    [UIView animateWithDuration:0.2
//                          delay:0.0
//                        options:0
//                     animations:^(void) {
//                         CGSize smallSize = [PWPageControl sizeForSize:PWPageControlSizeSmall];
//                         self.frame = [delegate frameForPager:self withSize:smallSize andPageControlSize:PWPageControlSizeSmall];
//                     } completion:^(BOOL finished) {
//                         [resizeImageView removeFromSuperview];
//                         [resizeImageView release], resizeImageView = nil;
//                         
//                         self.pageControlSize = PWPageControlSizeSmall;
//                         [self layoutSubviews];
//                         
//                         currentPageView.hidden = dividerView.hidden = maxPageView.hidden = NO;
//                         self.backgroundColor = previousColor;
//                     }];
//}

- (void)dealloc
{
    [currentPageView release], currentPageView = nil;
    [dividerView release], dividerView = nil;
    [maxPageView release], maxPageView = nil;
    [hideTimer invalidate], [hideTimer release], hideTimer = nil;
    [super dealloc];
}

@end
