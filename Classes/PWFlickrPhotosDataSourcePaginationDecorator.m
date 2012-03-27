//
//  PWFlickrPhotosDataSourcePaginationDecorator.m
//  FlickrExplore
//
//  Created by Patrik Weiskircher on 12/14/10.
//  Copyright 2010 INQNET. All rights reserved.
//

#import "PWFlickrPhotosDataSourcePaginationDecorator.h"


@implementation PWFlickrPhotosDataSourcePaginationDecorator
@synthesize imagesPerPage;

- (id) initWithDataSource:(id<PWFlickrPhotosDataSourceProtocol>)theDataSource {
	self = [super init];
	if (self != nil) {
		dataSource = [theDataSource retain];
		self.imagesPerPage = 12;
	}
	return self;
}

- (int) indexForPage:(int)page andIndex:(int)index {
	int i = self.imagesPerPage * page + index;
	NSAssert(i < [dataSource count], @"converted index for page/index bigger than count");
	return i;
}

- (void) page:(int*)page andIndex:(int*)index forOriginalIndex:(int)originalIndex {
	*page = originalIndex / self.imagesPerPage;
	*index = originalIndex - (*page * self.imagesPerPage);
}

- (int) numberOfPages {
	return ceil((float)[dataSource count] / (float)self.imagesPerPage);
}

- (NSArray*) entriesForPage:(int)page {
	NSIndexSet* set = [self indexSetForPage:page];
	
	NSMutableArray* entries = [NSMutableArray arrayWithCapacity:self.imagesPerPage];
	for (int i = [set firstIndex]; i < [set lastIndex]; i++) {
		[entries addObject:[dataSource entryForIndex:i]];
	}
	return entries;
}

- (NSIndexSet*) indexSetForPage:(int)pageIndex {
	int start = (pageIndex * self.imagesPerPage);
	int end = start + self.imagesPerPage;
	
	if ([dataSource count] < start) {
		NSLog(@"Page %d requested, not enough entries (have %d, want %d-%d)", pageIndex, [dataSource count], start, end);
		return nil;
	}
	if ([dataSource count] < end) {
		end = [dataSource count];
	}
	
	return [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(start, end - start + 1)];
}

- (UIImage*) imageForPage:(int)thePage atIndex:(int)index {
	return [dataSource imageForIndex:[self indexForPage:thePage andIndex:index]];
}

- (NSDictionary*) entryForPage:(int)thePage atIndex:(int)index {
	return [dataSource entryForIndex:[self indexForPage:thePage andIndex:index]];
}

- (int) indexForEntry:(NSDictionary*)entry onPage:(int)page {
	int i = 0;
	for (NSDictionary* e in [self entriesForPage:page]) {
		if ([e isEqualToDictionary:entry])
			return i;
		i++;
	}
	return -1;
}

- (void) setImage:(UIImage*)image forPage:(int)thePage atIndex:(int)index {
	[dataSource setImage:image forIndex:[self indexForPage:thePage andIndex:index]];
}

@end
