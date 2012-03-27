//
//  PWFlickrPhotosDataSourceProtocol.h
//  FlickrExplore
//
//  Created by Patrik Weiskircher on 12/14/10.
//  Copyright 2010 INQNET. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PWPhotosDataSourceFetchResultDelegate.h"

@protocol PWFlickrPhotosDataSourceProtocol <NSObject>
@property (nonatomic, readwrite, assign) id<PWFlickrPhotosDataSourceFetchResultDelegate> fetchResultDelegate;

- (int) count;

- (UIImage*) imageForIndex:(int)index;
- (NSDictionary*) entryForIndex:(int)index;

- (int) indexForEntry:(NSDictionary*)entry;

- (void) setImage:(UIImage*)image forIndex:(int)index;

- (void) cleanupImagesExcept:(NSIndexSet*)indexSet;
@end
