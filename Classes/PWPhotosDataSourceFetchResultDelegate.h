//
//  PWPhotosDataSourceFetchResultDelegate.h
//  FlickrExplore
//
//  Created by Patrik Weiskircher on 12/14/10.
//  Copyright 2010 INQNET. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PWFlickrPhotosDataSourceProtocol;

@protocol PWFlickrPhotosDataSourceFetchResultDelegate
- (void) photosDataSource:(id<PWFlickrPhotosDataSourceProtocol>)dataSource fetchedEntries:(NSArray*)entries;
- (void) photosDataSourceFailedToFetchEntries:(id<PWFlickrPhotosDataSourceProtocol>)dataSource;
@end
