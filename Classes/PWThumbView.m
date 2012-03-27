//
//  PWThumbView.m
//  FlickrExplore
//
//  Created by Patrik Weiskircher on 11.12.2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PWThumbView.h"
#import <QuartzCore/QuartzCore.h>

const static int THUMBNAIL_MARGIN = 20;

@interface PWThumbView ()
- (void) commonInit;

- (int) rowForThumbnailWithIndex:(int)index;
- (int) columnForThumbnailWithIndex:(int)index;

- (CGRect) startingRectForRow:(int)row;
- (CGRect) endRectForRow:(int)row andColumn:(int)column;

- (CGFloat) widthOfThumbnailBox;
- (CGFloat) heightOfThumbnailBox;

- (int) thumbnailsPerRow;
- (int) thumbnailsPerColumn;
@end

@implementation PWThumbView
@synthesize delegate;

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

- (void) dealloc
{
	for (UIView* view in [thumbnailViews allValues])
		[view removeFromSuperview];
	[thumbnailViews release];
	[dictionaryEntries release];
	[super dealloc];
}


- (void) commonInit {
	thumbnailViews = [[NSMutableDictionary dictionary] retain];
	dictionaryEntries = [[NSMutableDictionary dictionary] retain];
}

- (void) addImage:(UIImage*)theImage withEntry:(NSDictionary*)theEntry withAnimation:(BOOL)animation withIndex:(int)index {
	[dictionaryEntries setObject:theEntry forKey:[NSNumber numberWithInt:index]];
	
	UIImageView* imageView = [[[UIImageView alloc] initWithImage:theImage] autorelease];
	imageView.tag = index;
	imageView.frame = [self startingRectForRow:[self rowForThumbnailWithIndex:index]];
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	imageView.userInteractionEnabled = YES;
	
	UIGestureRecognizer* tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)] autorelease];
	[imageView addGestureRecognizer:tapGesture];
	
	[self addSubview:imageView];
	
	CGRect endPosition = [self endRectForRow:[self rowForThumbnailWithIndex:index]
								   andColumn:[self columnForThumbnailWithIndex:index]];
	if (animation) {
		[UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionAllowUserInteraction
						 animations:^(void) {
							 imageView.frame = 	endPosition;
						 } 
						 completion:NULL];
	} else {
		imageView.frame = endPosition;
	}
	
	[thumbnailViews setObject:imageView forKey:[NSNumber numberWithInt:index]];
}

- (void) imageViewTapped:(UIGestureRecognizer*)recognizer {
	int index = recognizer.view.tag;
	if (delegate)
		[delegate thumbView:self
   userTappedImageWithEntry:[dictionaryEntries objectForKey:[NSNumber numberWithInt:index]]
					atIndex:index];
}

- (int) rowForThumbnailWithIndex:(int)index {
	return index / [self thumbnailsPerRow];
}

- (int) columnForThumbnailWithIndex:(int)index {
	return index - ((index / [self thumbnailsPerRow]) * [self thumbnailsPerRow]);
}

- (CGRect) startingRectForRow:(int)row {
	CGRect rect;
	rect.size.width = [self widthOfThumbnailBox];
	rect.size.height = [self heightOfThumbnailBox];
	rect.origin.x = self.frame.size.width + THUMBNAIL_MARGIN + rect.size.width;
	rect.origin.y = round(THUMBNAIL_MARGIN + row * (THUMBNAIL_MARGIN + rect.size.height));
	return rect;
}

- (CGRect) endRectForRow:(int)row andColumn:(int)column {
	CGRect rect = [self startingRectForRow:row];
	rect.origin.x = round(THUMBNAIL_MARGIN + column * (THUMBNAIL_MARGIN + rect.size.width));
	return rect;
}

- (int) thumbnailsPerRow {
	if (self.bounds.size.width < self.bounds.size.height)
		return 3;
	else
		return 4;
}

- (int) thumbnailsPerColumn {
	if (self.bounds.size.width < self.bounds.size.height)
		return 4;
	else
		return 3;
}

- (CGFloat) widthOfThumbnailBox {
	return round((self.bounds.size.width - (([self thumbnailsPerRow]+1) * THUMBNAIL_MARGIN)) / [self thumbnailsPerRow]);
}

- (CGFloat) heightOfThumbnailBox {
	return round((self.bounds.size.height - (([self thumbnailsPerColumn]+1) * THUMBNAIL_MARGIN)) / [self thumbnailsPerColumn]);
}

- (void)layoutSubviews {
	[UIView animateWithDuration:0.3 animations:^(void) {
		for (UIView* view in [thumbnailViews allValues]) {
			view.frame = [self endRectForRow:[self rowForThumbnailWithIndex:view.tag]
								   andColumn:[self columnForThumbnailWithIndex:view.tag]];
		}
	}];	
}

- (UIImage*) imageAtIndex:(int)index {
	return [[thumbnailViews objectForKey:[NSNumber numberWithInt:index]] image];
}

- (CGRect) locationOfImageAtIndex:(int)index {
	return [[thumbnailViews objectForKey:[NSNumber numberWithInt:index]] frame];
}

- (NSArray*) entries {
	return [[[dictionaryEntries allValues] retain] autorelease];
}

- (void) removeAllImages {
	for (UIView* view in thumbnailViews) {
		[view removeFromSuperview];
	}
	[thumbnailViews removeAllObjects];
	[dictionaryEntries removeAllObjects];
}

@end
