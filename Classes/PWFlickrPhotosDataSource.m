//
//  PWFlickrPhotosDataSource.m
//  FlickrExplore
//
//  Created by Patrik Weiskircher on 12/13/10.
//  Copyright 2010 INQNET. All rights reserved.
//

#import "PWFlickrPhotosDataSource.h"

static NSString * const kEntryKey = @"kEntryKey";
static NSString * const kImageKey = @"kImageKey";

@implementation PWFlickrPhotosDataSource
@synthesize fetchResultDelegate;

- (id) initWithEntries:(NSArray*)theEntries {
	self = [super init];
	if (self != nil) {		
		data = [[NSMutableArray arrayWithCapacity:[theEntries count]] retain];
		[self addEntries:theEntries];
	}
	return self;
}

- (void) dealloc
{
	[data release];
	[super dealloc];
}

- (void) fetchEntries {
    OFFlickrAPIRequest* request = [[OFFlickrAPIRequest alloc] initWithAPIContext:[PWFlickrContext sharedContext]];
    [request setDelegate:self];
    [request callAPIMethodWithGET:@"flickr.interestingness.getList"
                        arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"500", @"per_page", @"owner_name", @"extras", nil]];
}

- (void) flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary {
	NSArray* entries = [inResponseDictionary valueForKeyPath:@"photos.photo"];
	[self addEntries:entries];
	[fetchResultDelegate photosDataSource:self fetchedEntries:entries];
	[inRequest autorelease];
}

- (void) flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError {
	[fetchResultDelegate photosDataSourceFailedToFetchEntries:self];
	[inRequest autorelease];
}

- (void) addEntries:(NSArray*)entries {
	for (NSDictionary* entry in entries) {
		[data addObject:[NSMutableDictionary dictionaryWithObject:entry forKey:kEntryKey]];
	}	
}

- (int) count {
	return [data count];
}

- (UIImage*) imageForIndex:(int)index {
	return [[data objectAtIndex:index] objectForKey:kImageKey];
}

- (NSDictionary*) entryForIndex:(int)index {
	return [[data objectAtIndex:index] objectForKey:kEntryKey];
}

- (int) indexForEntry:(NSDictionary*)entry {
	int i = 0;
	for (NSDictionary* dict in data) {
		if ([[dict objectForKey:kEntryKey] isEqualToDictionary:entry])
			return i;
		i++;
	}
	return -1;
}

- (void) setImage:(UIImage*)image forIndex:(int)index {
	[[data objectAtIndex:index] setObject:image forKey:kImageKey];
}

- (void) cleanupImagesExcept:(NSIndexSet*)indexSet {
	int i = 0;
	for (NSMutableDictionary* entry in data) {
		if (![indexSet containsIndex:i] && [entry objectForKey:kImageKey] != nil) {
			[entry removeObjectForKey:kImageKey];
		}
		i++;
	}
}

@end
