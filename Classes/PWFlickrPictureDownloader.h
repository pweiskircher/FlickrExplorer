//
//  PWFlickrPictureDownloader.h
//  FlickrExplore
//
//  Created by Patrik Weiskircher on 11.12.2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PWFlickrPictureDownloader;

typedef enum {
	PWFlickrPictureDownloaderErrorImageFailedToDecode,
	PWFlickrPictureDownloaderErrorHttp
} PWFlickrPictureDownloaderError;

@protocol PWFlickrPictureDownloaderDelegate
- (void) flickrPictureDownloader:(PWFlickrPictureDownloader*)downloader 
					fetchedImage:(UIImage*)theImage
			  forDictionaryEntry:(NSDictionary*)dictionary;
- (void) flickrPictureDownloader:(PWFlickrPictureDownloader*)downloader failedToDownloadImageForDictionaryEntry:(NSDictionary*)dictionary 
						withError:(PWFlickrPictureDownloaderError)error;
@end

@interface PWFlickrPictureDownloader : NSObject {
	NSString* sizeIdentifier;
	id<PWFlickrPictureDownloaderDelegate> delegate;
	
	NSOperationQueue* queue;
	NSOperationQueue* priorityQueue;
}
@property(nonatomic, readwrite, assign) id<PWFlickrPictureDownloaderDelegate> delegate;
@property(nonatomic, readwrite, retain) NSString* sizeIdentifier;

- (PWFlickrPictureDownloader*) initWithPictureSize:(NSString*)theSizeIdentifier andDelegate:(id<PWFlickrPictureDownloaderDelegate>)aDelegate;

- (void) queuePictureDownloadWithDictionaryEntry:(NSDictionary*)aDictionaryEntry;
- (void) priorityQueuePictureDownloadWithDictionaryEntry:(NSDictionary*)aDictionaryEntry;
- (void) cancel;
@end
