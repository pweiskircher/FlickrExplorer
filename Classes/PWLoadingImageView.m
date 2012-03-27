//
//  PWLoadingImageView.m
//  FlickrExplore
//
//  Created by Patrik Weiskircher on 12.12.2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PWLoadingImageView.h"


@implementation PWLoadingImageView
@synthesize loadingDelegate;

- (void) setEntry:(NSDictionary*)theEntry withThumbImage:(UIImage*)theImage andHiResImage:(UIImage*)hiResImage {
	if ([theEntry isEqualToDictionary:entry])
		return;
	
	[entry release];
	entry = [theEntry retain];
	if (hiResImage) {
		self.image = hiResImage;
		[self hideLoadingMessage];
	} else {
		
		if (theImage) {
			self.image = theImage;
		} else {
			self.image = nil;
		}
		
		if (!downloader) {
			downloader = [[PWFlickrPictureDownloader alloc] initWithPictureSize:OFFlickrLargeSize
																	andDelegate:self];
		}
		[downloader queuePictureDownloadWithDictionaryEntry:entry];
		[loadingDelegate loadingImageView:self startedLoadingHiResImageForEntry:entry];
		[self showLoadingMessageWithAnimation:![loadingDelegate loadingImageView:self asksIfSomeoneStartedDownloadingHiResImageForEntry:entry]];
	}
}

- (void) processImage:(UIImage*)theImage forDictionaryEntry:(NSDictionary*)dictionary {
	[loadingDelegate loadingImageView:self downloadedHiResImage:theImage forEntry:dictionary];
	if ([entry isEqualToDictionary:dictionary]) {
		self.image = theImage;
		[self hideLoadingMessage];
	}	
}

- (void) flickrPictureDownloader:(PWFlickrPictureDownloader *)downloader fetchedImage:(UIImage *)theImage forDictionaryEntry:(NSDictionary *)dictionary {
	[self processImage:theImage forDictionaryEntry:dictionary];
}

- (void) flickrPictureDownloader:(PWFlickrPictureDownloader *)aDownloader failedToDownloadImageForDictionaryEntry:(NSDictionary *)dictionary withError:(PWFlickrPictureDownloaderError)error {
	if (error == PWFlickrPictureDownloaderErrorImageFailedToDecode) {
		[self processImage:[PWImages downloadFailedPlaceholderImage] forDictionaryEntry:dictionary];
		return;
	}
	[downloader priorityQueuePictureDownloadWithDictionaryEntry:dictionary];
}

- (void) setImage:(UIImage *)theImage {
	[super setImage:theImage];
}

- (void) showLoadingMessageWithAnimation:(BOOL)animation {
	if (!loadingMessage) {
		loadingMessage = [[PWLoadingMessage alloc] initWithFrame:CGRectZero];
		loadingMessage.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
		[loadingMessage sizeToFit];
		[self addSubview:loadingMessage];
	}
	loadingMessage.frame = CGRectMake(round(self.bounds.size.width/2 - loadingMessage.bounds.size.width/2),
									  round(self.bounds.size.height/2 - loadingMessage.bounds.size.height/2),
									  loadingMessage.bounds.size.width,
									  loadingMessage.bounds.size.height);
	[loadingMessage startAnimatingWithFadeInAnimation:animation];	
}

- (void) showLoadingMessage {
	return [self showLoadingMessageWithAnimation:YES];
}

- (void) hideLoadingMessage {
	[loadingMessage stopAnimating];
}

- (void) dealloc
{
	[entry release];
	[downloader cancel];
	[downloader release];
	[loadingMessage removeFromSuperview];
	[loadingMessage release];
	[super dealloc];
}

@end