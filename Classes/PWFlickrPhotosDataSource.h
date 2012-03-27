//
//  PWFlickrPhotosDataSource.h
//  FlickrExplore
//
//  Created by Patrik Weiskircher on 12/13/10.
//  Copyright 2010 INQNET. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PWFlickrPhotosDataSourceProtocol.h"

@interface PWFlickrPhotosDataSource : NSObject <OFFlickrAPIRequestDelegate, PWFlickrPhotosDataSourceProtocol> {
	id<PWFlickrPhotosDataSourceFetchResultDelegate> fetchResultDelegate;
	NSMutableArray* data;
}
- (id) initWithEntries:(NSArray*)theEntries;

- (void) addEntries:(NSArray*)entries;
- (void) fetchEntries;
@end
