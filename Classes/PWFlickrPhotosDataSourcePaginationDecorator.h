//
//  PWFlickrPhotosDataSourcePaginationDecorator.h
//  FlickrExplore
//
//  Created by Patrik Weiskircher on 12/14/10.
//  Copyright 2010 INQNET. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PWFlickrPhotosDataSourceProtocol.h"

@interface PWFlickrPhotosDataSourcePaginationDecorator : NSObject {
	id<PWFlickrPhotosDataSourceProtocol> dataSource;
	int imagesPerPage;
}
@property(nonatomic, readwrite, assign) int imagesPerPage;

- (id) initWithDataSource:(id<PWFlickrPhotosDataSourceProtocol>)dataSource;

- (int) numberOfPages;
- (NSArray*) entriesForPage:(int)page;
- (UIImage*) imageForPage:(int)thePage atIndex:(int)index;
- (NSDictionary*) entryForPage:(int)thePage atIndex:(int)index;
- (int) indexForEntry:(NSDictionary*)entry onPage:(int)page;
- (void) setImage:(UIImage*)image forPage:(int)thePage atIndex:(int)index;

- (int) indexForPage:(int)page andIndex:(int)index;
- (void) page:(int*)page andIndex:(int*)index forOriginalIndex:(int)originalIndex;
- (NSIndexSet*) indexSetForPage:(int)pageIndex;
@end
