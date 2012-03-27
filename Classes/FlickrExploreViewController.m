//
//  FlickrExploreViewController.m
//  FlickrExplore
//
//  Created by Patrik Weiskircher on 11.12.2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FlickrExploreViewController.h"
#import "PWFlickrContext.h"
#import "PWThumbView.h"
#import "PWCGRectAdditions.h"
#import "PWPreferences.h"
#import "PWHelper.h"


@interface FlickrExploreViewController ()
- (void) loadPageWithIndex:(int)pageIndex;
- (void) createThumbViewForPageWithIndex:(int)pageIndex;
- (CGRect) rectForThumbViewWithPage:(int)pageIndex;
- (CGRect) contentViewRectWithNumberOfPages:(int)pageCount;
- (void) createThumbViewAndQueueImageDownloadsForPage:(int)pageIndex;
- (void) openFullscreenViewerWithIndex:(int)index;
- (void) openFullscreenViewerWithPage:(int)page andIndex:(int)index;

- (CGRect) pagerFrameWithSize:(CGSize)size;
@end


@implementation FlickrExploreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    failCount = 0;
    
    aboutScreen = [[PWAboutScreen alloc] initWithViewController:self];
	downloader = [[PWFlickrPictureDownloader alloc] initWithPictureSize:OFFlickrSmallSize
															andDelegate:self];
    loadingMessage = [[PWLoadingMessage alloc] initWithFrame:CGRectZero];
	[loadingMessage sizeToFit];
	[self.view addSubview:loadingMessage];
	loadingMessage.frame = CGRectWithCenter(self.view.bounds, loadingMessage.frame.size);
	loadingMessage.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [self.view bringSubviewToFront:pager];
    
    UIPanGestureRecognizer* panGestures = [[[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(pan:)] autorelease];
    panGestures.minimumNumberOfTouches = 2;
    panGestures.maximumNumberOfTouches = 2;
    [scrollView addGestureRecognizer:panGestures];
    
    [pager sizeToFit];
    pager.frame = [self pagerFrameWithSize:pager.bounds.size];
    
    [self reinitialize];
}

- (void) reinitialize {
    [downloader cancel];
    
    [thumbViews release];
	thumbViews = [[NSMutableDictionary dictionary] retain];
    
    [dataSource release];
	dataSource = [[PWFlickrPhotosDataSource alloc] initWithEntries:nil];
	dataSource.fetchResultDelegate = self;
    
    [paginatedDataSource release];
	paginatedDataSource = [[PWFlickrPhotosDataSourcePaginationDecorator alloc] initWithDataSource:dataSource];
    
    [contentView removeFromSuperview];
	[contentView release];
    contentView = nil;
	
    currentPage = 0;
    
	scrollView.scrollEnabled = NO;
	[dataSource fetchEntries];
    
    [loadingMessage startAnimating];
}

- (void) pan:(UIPanGestureRecognizer*)panGesture {
    if (scrollView.scrollEnabled == NO)
        // don't fast scroll if we don't scroll at all
        return;
    
    [pager show];
    
    int newPage = currentPage + (pager.maxPages / self.view.bounds.size.width) * [panGesture translationInView:scrollView].x;
    if (newPage < 0)
        newPage = 0;
    if (newPage >= pager.maxPages)
        newPage = pager.maxPages - 1;
    pager.currentPage = newPage;
    
    if (panGesture.state == UIGestureRecognizerStateEnded) {
        [self loadPageWithIndex:pager.currentPage];
        [scrollView setContentOffset:CGPointMake([self rectForThumbViewWithPage:currentPage+1].origin.x, 0) animated:YES];
        [pager hideWithAnimation:YES];        
    }
}

- (CGRect) frameForPager:(PWPageControl *)pager withSize:(CGSize)size andPageControlSize:(PWPageControlSize)pageControlSize {
    if (pageControlSize == PWPageControlSizeBig) {
        return CGRectWithCenter(self.view.bounds, size);
    } else {
        return [self pagerFrameWithSize:size];
    }
}

- (void) saveState {
	if ([dataSource count] > 0) {
		// we save the first entry to decide if we should go back to the previous state or just start fresh
		// if the data changes that we receive from flickr, there is no use to go to the previous page the user selected
        [PWPreferences storePageState:[dataSource entryForIndex:0]
                       andCurrentPage:currentPage
               andHasFullscreenViewer:fullscreenImageViewer != nil];

		if (fullscreenImageViewer) {
            [PWPreferences storeFullscreenState:fullscreenImageViewer.currentIndex andIsTopBarVisible:fullscreenImageViewer.isTopBarVisible];
		}
	} else {
		[PWPreferences resetStoredState];
	}
}

- (void) restoreState {
	restore = YES;
}

- (void) reset {
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)theScrollView {
	int newPageIndex = scrollView.contentOffset.x / self.view.bounds.size.width;
    if (newPageIndex == 0) {
        currentPage = -1;
        return;
    }
	if (currentPage != newPageIndex-1) {
		[self loadPageWithIndex:newPageIndex-1];
	}
}

- (void) loadPageWithIndex:(int)pageIndex {
	currentPage = pageIndex;
	pager.currentPage = pageIndex;
		
	[downloader cancel];
		
	[self createThumbViewAndQueueImageDownloadsForPage:pageIndex];
    
    if ([[[thumbViews objectForKey:[NSNumber numberWithInt:pageIndex]] entries] count] == 0) {
        [loadingMessage startAnimating];
    }
	
    
	if (pageIndex + 1 < [paginatedDataSource numberOfPages]) {
		[self createThumbViewAndQueueImageDownloadsForPage:pageIndex + 1];
	}
	if (pageIndex - 1 >= 0) {
		[self createThumbViewAndQueueImageDownloadsForPage:pageIndex - 1];
	}
}

- (void) createThumbViewAndQueueImageDownloadsForPage:(int)pageIndex {
	if ([thumbViews objectForKey:[NSNumber numberWithInt:pageIndex]] == nil) {
		[self createThumbViewForPageWithIndex:pageIndex];
	}
	
	NSArray* displayedEntries = [[thumbViews objectForKey:[NSNumber numberWithInt:pageIndex]] entries];
	
	for (NSDictionary* entry in [paginatedDataSource entriesForPage:pageIndex]) {
		if ([displayedEntries containsObject:entry]) {
			continue;
        }
		[downloader queuePictureDownloadWithDictionaryEntry:entry];
	}	
}

- (void) createThumbViewForPageWithIndex:(int)pageIndex {
	CGRect pageViewFrame = [self rectForThumbViewWithPage:pageIndex+1];
	
	PWThumbView* thumbView = [[[PWThumbView alloc] initWithFrame:pageViewFrame] autorelease];
	thumbView.delegate = self;
	[contentView addSubview:thumbView];
	
	[thumbViews setObject:thumbView forKey:[NSNumber numberWithInt:pageIndex]];
}

- (CGRect) rectForThumbViewWithPage:(int)pageIndex {
	CGRect rect;
	rect.origin.x = self.view.bounds.size.width * pageIndex;
	rect.origin.y = 0;
	rect.size.width = self.view.bounds.size.width;
	rect.size.height = self.view.bounds.size.height;
	return rect;
}

- (void) photosDataSource:(id <PWFlickrPhotosDataSourceProtocol>)aDataSource fetchedEntries:(NSArray *)entries {
	[loadingMessage stopAnimating];
	
	int numberOfPages = [paginatedDataSource numberOfPages];
	contentView = [[UIView alloc] initWithFrame:[self contentViewRectWithNumberOfPages:numberOfPages+1]];
    [contentView addSubview:aboutScreen.view];
	[scrollView addSubview:contentView];
	scrollView.contentSize = contentView.frame.size;	
	
	scrollView.scrollEnabled = YES;
    pager.maxPages = numberOfPages;
	
	int pageToLoad = 0;
	if (restore) {
		if ([[dataSource entryForIndex:0] isEqualToDictionary:[PWPreferences storedFirstEntry]]) {
			pageToLoad = [PWPreferences storedCurrentPage];
		} else {
			restore = NO;
		}
	}

	[self loadPageWithIndex:pageToLoad];
	
    scrollView.contentOffset = CGPointMake([self rectForThumbViewWithPage:pageToLoad+1].origin.x, 0);
	
	if (restore && [PWPreferences hasFullscreenImageViewerStored]) {
		[self openFullscreenViewerWithIndex:[PWPreferences storedFullscreenImageViewerIndex]];
		if ([PWPreferences hasTopBarVisible])
			[fullscreenImageViewer queueShowTopBar];
	}
	
	// remove the settings just in case these are crashing the app.
    [PWPreferences resetStoredState];
    [PWPreferences setEntriesLastFetched];
	
	restore = NO;
    
    [scrollView flashScrollIndicators];
}

- (void) photosDataSourceFailedToFetchEntries:(id <PWFlickrPhotosDataSourceProtocol>)dS {
    [dataSource fetchEntries];
}

- (CGRect) contentViewRectWithNumberOfPages:(int)pageCount {
	return CGRectMake(0, 0, pageCount * self.view.bounds.size.width, self.view.bounds.size.height);
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	contentView.frame = [self contentViewRectWithNumberOfPages:[paginatedDataSource numberOfPages]+1];
	scrollView.contentSize = contentView.frame.size;
	scrollView.contentOffset = [self rectForThumbViewWithPage:currentPage+1].origin;
	for (NSNumber* index in [thumbViews allKeys]) {
		UIView* view = [thumbViews objectForKey:index];
		view.frame = [self rectForThumbViewWithPage:[index intValue]+1];
	}
    aboutScreen.view.frame = [self rectForThumbViewWithPage:0];
    pager.frame = [self pagerFrameWithSize:pager.bounds.size];
    [scrollView flashScrollIndicators];
}

- (CGRect) pagerFrameWithSize:(CGSize)size {
    return CGRectMake(round(self.view.bounds.size.width/2 - pager.bounds.size.width/2),
                             round(self.view.bounds.size.height - pager.bounds.size.height-6),
                             size.width,
                             size.height);
}

- (void) addImage:(UIImage*)theImage forEntry:(NSDictionary*)dictionary {
	int page, index, origIndex;
	origIndex = [dataSource indexForEntry:dictionary];
    if (origIndex == -1) {
        // ignore stale request, happens when we reinitialize and there's still a old request being delivered.
        return;
    }
	[paginatedDataSource page:&page andIndex:&index forOriginalIndex:origIndex];
	[dataSource setImage:theImage forIndex:origIndex];
	
    if (page == currentPage)
        [loadingMessage stopAnimating];
    
	[[thumbViews objectForKey:[NSNumber numberWithInt:page]] addImage:theImage
															withEntry:dictionary
														withAnimation:currentPage == page
															withIndex:index];	
}

- (void) flickrPictureDownloader:(PWFlickrPictureDownloader *)downloader fetchedImage:(UIImage *)theImage forDictionaryEntry:(NSDictionary *)dictionary {
	[self addImage:theImage forEntry:dictionary];
    failCount = 0;
    [reachability release], reachability = nil;
}

- (void) flickrPictureDownloader:(PWFlickrPictureDownloader *)theDownloader failedToDownloadImageForDictionaryEntry:(NSDictionary *)dictionary withError:(PWFlickrPictureDownloaderError)error {
	if (error == PWFlickrPictureDownloaderErrorImageFailedToDecode) {
		[self addImage:[PWImages downloadFailedPlaceholderImage] forEntry:dictionary];
		return;
	}
    
    failCount++;
	[downloader priorityQueuePictureDownloadWithDictionaryEntry:dictionary];
    
    if (failCount == 10) {
        [reachability release], reachability = nil;
        reachability = [[PWFlickrReachabilityChecker alloc] init];
        [reachability checkReachability];
    }
}

- (void) thumbView:(PWThumbView *)thumbView userTappedImageWithEntry:(NSDictionary *)entry atIndex:(int)index {
	[self openFullscreenViewerWithPage:currentPage andIndex:index];
}

- (void) openFullscreenViewerWithPage:(int)page andIndex:(int)index {
	[self openFullscreenViewerWithIndex:[paginatedDataSource indexForPage:page andIndex:index]];
}

- (void) openFullscreenViewerWithIndex:(int)index {
	fullscreenImageViewer = [[PWFullscreenImageViewer alloc] initWithDataSource:dataSource
															  withStartingIndex:index
																	andDelegate:self
                                                        andParentViewController:self];
	
	
	
	[self.view addSubview:fullscreenImageViewer];
	[fullscreenImageViewer goFullscreen];	
}

- (void) fullscreenImageViewerWantsToClose:(PWFullscreenImageViewer *)fiv {
	[fullscreenImageViewer goSmallAndHide];
}

- (void) fullscreenImageViewerDidClose:(PWFullscreenImageViewer *)fiv {
	[fullscreenImageViewer removeFromSuperview];
	[fullscreenImageViewer autorelease];
	fullscreenImageViewer = nil;
}

- (void) fullscreenImageViewer:(PWFullscreenImageViewer *)fullscreenImageViewer wantsToSendLinkPerEmail:(NSURL *)url withPictureName:(NSString*)pictureName byAuthor:(NSString*)authorName {
    if (![PWHelper checkCanSendMailAndShowError])
        return;
    
    MFMailComposeViewController* mailComposeViewController = [[[MFMailComposeViewController alloc] init] autorelease];
    mailComposeViewController.mailComposeDelegate = self;
    mailComposeViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    [mailComposeViewController setSubject:[NSString stringWithFormat:NSLocalizedString(@"Flickr Link for '%@' by %@", "email subject"), pictureName, authorName]];
    
    NSString* message = [NSString stringWithFormat:NSLocalizedString(@"Check out this picture: <a href=\"%@\">%@</a>", "mail message content"), url, pictureName];
    [mailComposeViewController setMessageBody:message isHTML:YES];
    [self presentModalViewController:mailComposeViewController animated:YES];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissModalViewControllerAnimated:YES];
}

- (CGRect) positionForImageThumbWithIndex:(int)theIndex {
	int page, index;
	[paginatedDataSource page:&page andIndex:&index forOriginalIndex:theIndex];
	CGRect rect = [[thumbViews objectForKey:[NSNumber numberWithInt:page]] locationOfImageAtIndex:index];
	return rect;
}

- (void) fullscreenImageView:(PWFullscreenImageViewer*)fullscreenImageViewer changedToIndex:(int)theIndex {
	int page, index;
	[paginatedDataSource page:&page andIndex:&index forOriginalIndex:theIndex];
	if (page != currentPage) {
		[self loadPageWithIndex:page];
		scrollView.contentOffset = CGPointMake([self rectForThumbViewWithPage:page+1].origin.x, 0);
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void) didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	
	// we purge everything except the current page
	[dataSource cleanupImagesExcept:[paginatedDataSource indexSetForPage:currentPage]];
	NSMutableArray* keyArray = [NSMutableArray arrayWithArray:[thumbViews allKeys]];
	[keyArray removeObject:[NSNumber numberWithInt:currentPage]];
	for (NSNumber* key in keyArray) {
		[[thumbViews objectForKey:key] removeFromSuperview];
	}
	[thumbViews removeObjectsForKeys:keyArray];
}

- (void)viewDidUnload {
    [pager release];
    pager = nil;
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [pager release];
    [super dealloc];
}

@end
