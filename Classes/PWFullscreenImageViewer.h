//
//  PWFullscreenImageViewer.h
//  FlickrExplore
//
//  Created by Patrik Weiskircher on 12/13/10.
//  Copyright 2010 INQNET. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PWFlickrPhotosDataSourceProtocol.h"
#import "PWFlickrPictureDownloader.h"
#import "PWEndlessScrollView.h"
#import "PWLoadingImageView.h"
#import "PWImageDescriptionLabel.h"

@class PWFullscreenImageViewer;

@protocol PWFullscreenImageViewerDelegate <NSObject>
- (CGRect) positionForImageThumbWithIndex:(int)theIndex;
- (void) fullscreenImageView:(PWFullscreenImageViewer*)fullscreenImageViewer changedToIndex:(int)index;
- (void) fullscreenImageViewerWantsToClose:(PWFullscreenImageViewer*)fullscreenImageViewer;
- (void) fullscreenImageViewerDidClose:(PWFullscreenImageViewer*)fullscreenImageViewer;
- (void) fullscreenImageViewer:(PWFullscreenImageViewer *)fullscreenImageViewer wantsToSendLinkPerEmail:(NSURL *)url withPictureName:(NSString*)pictureName byAuthor:(NSString*)authorName;
@end

@interface PWFullscreenImageViewer : UIView <PWEndlessScrollViewDelegate, PWEndlessScrollViewDataSource, PWLoadingImageViewDelegate, UIActionSheetDelegate> {
	id<PWFlickrPhotosDataSourceProtocol> dataSource;
	int currentIndex;

	PWEndlessScrollView* endlessScrollView;
	UIImageView* loadingImageView;
	
	id<PWFullscreenImageViewerDelegate> delegate;
	
	NSMutableDictionary* hiresPictures;
	NSMutableArray* downloadingHiResPictures;
	
	UIToolbar* topBar;
    UIBarButtonItem* title;
	NSArray* topBarItems;
	
	BOOL shrinking;
	UIActionSheet* actionSheet;
	
	BOOL queueShowTopBar;
    
    BOOL doesAuth;
    UIViewController* parentViewController;
    
    UIBarButtonItem* favoriteItem;
}
@property(nonatomic, readwrite, assign) id<PWFullscreenImageViewerDelegate> delegate;
@property(nonatomic, readonly, assign) int currentIndex;
@property(nonatomic, readonly, assign) BOOL isTopBarVisible;

- (id) initWithDataSource:(id<PWFlickrPhotosDataSourceProtocol>)theDataSource 
        withStartingIndex:(int)theIndex 
              andDelegate:(id<PWFullscreenImageViewerDelegate>)theDelegate
  andParentViewController:(UIViewController*)theParentViewController;
- (void) goFullscreen;
- (void) goSmallAndHide;

- (void) releaseMemory;
- (void) queueShowTopBar;

@end
