//
//  PWLoadingImageView.h
//  FlickrExplore
//
//  Created by Patrik Weiskircher on 12.12.2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PWLoadingMessage.h"
#import "PWFlickrPictureDownloader.h"

@class PWLoadingImageView;

@protocol PWLoadingImageViewDelegate
- (void) loadingImageView:(PWLoadingImageView*)imageView downloadedHiResImage:(UIImage*)hiResImage forEntry:(NSDictionary*)theEntry;
- (void) loadingImageView:(PWLoadingImageView*)imageView startedLoadingHiResImageForEntry:(NSDictionary*)theEntry;
- (BOOL) loadingImageView:(PWLoadingImageView*)imageView asksIfSomeoneStartedDownloadingHiResImageForEntry:(NSDictionary*)theEntry;
@end

@interface PWLoadingImageView : UIImageView <PWFlickrPictureDownloaderDelegate> {
	PWLoadingMessage* loadingMessage;
	
	NSDictionary* entry;
	PWFlickrPictureDownloader* downloader;
	
	id<PWLoadingImageViewDelegate> loadingDelegate;
}
@property(nonatomic, readwrite, assign) id<PWLoadingImageViewDelegate> loadingDelegate;

- (void) setEntry:(NSDictionary*)theEntry withThumbImage:(UIImage*)theImage andHiResImage:(UIImage*)hiResImage;
- (void) showLoadingMessageWithAnimation:(BOOL)animation;
- (void) showLoadingMessage;
- (void) hideLoadingMessage;
@end