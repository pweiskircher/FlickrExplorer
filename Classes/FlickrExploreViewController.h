//
//  FlickrExploreViewController.h
//  FlickrExplore
//
//  Created by Patrik Weiskircher on 11.12.2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PWFlickrPictureDownloader.h"
#import "PWThumbView.h"
#import "PWFullscreenImageViewer.h"
#import "PWFlickrPhotosDataSource.h"
#import "PWFlickrPhotosDataSourcePaginationDecorator.h"
#import "PWPhotosDataSourceFetchResultDelegate.h"
#import "PWLoadingMessage.h"
#import <MessageUI/MessageUI.h>
#import "PWPageControl.h"
#import "PWAboutScreen.h"
#import "PWFlickrReachabilityChecker.h"

@interface FlickrExploreViewController : UIViewController <PWFullscreenImageViewerDelegate, PWFlickrPictureDownloaderDelegate, UIScrollViewDelegate, PWThumbViewDelegate, PWFlickrPhotosDataSourceFetchResultDelegate, MFMailComposeViewControllerDelegate> {
	PWLoadingMessage* loadingMessage;
	
	PWFlickrPhotosDataSource* dataSource;
	PWFlickrPhotosDataSourcePaginationDecorator* paginatedDataSource;
	
	IBOutlet UIScrollView* scrollView;
	UIView* contentView;
    IBOutlet PWPageControl *pager;
	
	PWFlickrPictureDownloader* downloader;
	
	int currentPage;
	NSMutableDictionary* thumbViews;
	PWFullscreenImageViewer* fullscreenImageViewer;
	
	BOOL restore;
    
    PWAboutScreen* aboutScreen;
    
    int failCount;
    PWFlickrReachabilityChecker* reachability;
    
    NSTimer* pageSmallTimer;
}
- (void) saveState;
- (void) restoreState;
- (void) reinitialize;
@end

