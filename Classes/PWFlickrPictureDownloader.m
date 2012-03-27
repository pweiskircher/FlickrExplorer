//
//  PWFlickrPictureDownloader.m
//  FlickrExplore
//
//  Created by Patrik Weiskircher on 11.12.2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PWFlickrPictureDownloader.h"
#import "ASIHTTPRequest.h"

@interface PWFlickrPictureDownloader ()
- (void) queueEntry:(NSDictionary*)entry intoQueue:(NSOperationQueue*)theQueue;
@end

@implementation PWFlickrPictureDownloader
@synthesize delegate, sizeIdentifier;

- (PWFlickrPictureDownloader*) initWithPictureSize:(NSString*)theSizeIdentifier andDelegate:(id<PWFlickrPictureDownloaderDelegate>)aDelegate {
	self = [super init];
	if (self != nil) {
		self.sizeIdentifier = theSizeIdentifier;
		self.delegate = aDelegate;
		
		queue = [[NSOperationQueue alloc] init];
		[queue setMaxConcurrentOperationCount:1];
		
		priorityQueue = [[NSOperationQueue alloc] init];
		[queue setMaxConcurrentOperationCount:1];
	}
	return self;
}

- (void) dealloc
{
	for (ASIHTTPRequest* request in [queue operations]) {
		request.delegate = nil;
	}
	
	[self cancel];
	[sizeIdentifier release];
	[queue release];
	[super dealloc];
}

- (void) priorityQueuePictureDownloadWithDictionaryEntry:(NSDictionary*)aDictionaryEntry {
	[self queueEntry:aDictionaryEntry intoQueue:priorityQueue];
}

- (void) queuePictureDownloadWithDictionaryEntry:(NSDictionary*)aDictionaryEntry {
	[self queueEntry:aDictionaryEntry intoQueue:queue];
}

- (void) queueEntry:(NSDictionary*)aDictionaryEntry intoQueue:(NSOperationQueue*)theQueue {
	ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[[PWFlickrContext sharedContext] photoSourceURLFromDictionary:aDictionaryEntry
																													  size:self.sizeIdentifier]];
	request.userInfo = aDictionaryEntry;
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(requestFinished:)];
	[request setDidFailSelector:@selector(requestFailed:)];
	[theQueue addOperation:request];
}

- (void) cancel {
	[queue cancelAllOperations];
}

- (void) requestFinished:(ASIHTTPRequest*)request {
    NSDictionary* currentEntry = request.userInfo;
    if (request.responseStatusCode != 200) {
        [delegate flickrPictureDownloader:self
  failedToDownloadImageForDictionaryEntry:currentEntry
                                withError:PWFlickrPictureDownloaderErrorHttp];
        return;
    }
	UIImage* image = [UIImage imageWithData:[request responseData]];
	static int r = 0;
	r++;
	if (image) {
		[delegate flickrPictureDownloader:self
							 fetchedImage:image
					   forDictionaryEntry:currentEntry];
	} else {
		[delegate flickrPictureDownloader:self failedToDownloadImageForDictionaryEntry:currentEntry withError:PWFlickrPictureDownloaderErrorImageFailedToDecode];
	}
}

- (void) requestFailed:(ASIHTTPRequest*)request {
	if ([request.error.domain isEqualToString:@"ASIHTTPRequestErrorDomain"] && request.error.code == ASIRequestCancelledErrorType) {
		return;
	}
	NSDictionary* currentEntry = request.userInfo;
	[delegate flickrPictureDownloader:self failedToDownloadImageForDictionaryEntry:currentEntry withError:PWFlickrPictureDownloaderErrorHttp];
}


@end
