//
//  PWThumbView.h
//  FlickrExplore
//
//  Created by Patrik Weiskircher on 11.12.2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PWThumbView;

@protocol PWThumbViewDelegate
- (void) thumbView:(PWThumbView*)thumbView userTappedImageWithEntry:(NSDictionary*)entry atIndex:(int)index;
@end

@interface PWThumbView : UIView {
	NSMutableDictionary* thumbnailViews;
	NSMutableDictionary* dictionaryEntries;
	
	id<PWThumbViewDelegate> delegate;
}
@property(nonatomic, assign) id<PWThumbViewDelegate> delegate;

- (void) addImage:(UIImage*)theImage withEntry:(NSDictionary*)theEntry withAnimation:(BOOL)animation withIndex:(int)index;

- (UIImage*) imageAtIndex:(int)index;
- (CGRect) locationOfImageAtIndex:(int)index;

- (void) removeAllImages;
- (NSArray*) entries;
@end
