//
//  PWFullscreenImageViewer.m
//  FlickrExplore
//
//  Created by Patrik Weiskircher on 12/13/10.
//  Copyright 2010 INQNET. All rights reserved.
//

#import "PWFullscreenImageViewer.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "SHK.h"
#import "PWPreferences.h"
#import "GTMOAuthViewControllerTouch.h"
#import "PWFlickrAuthenticationHandler.h"
#import "PWFavoriteController.h"
#import "SHKActivityIndicator.h"

@interface PWFullscreenImageViewer ()
- (void) hideScrollViewShowImageView;
- (void) showScrollViewHideImageView;

- (void) updateTopBarWithName;
- (void) sendFavoriteRequest:(GTMOAuthAuthentication*)auth;
- (BOOL) isCurrentPhotoFavorited;
- (void) updateFavoriteButton;
@end

@implementation PWFullscreenImageViewer
@synthesize delegate, currentIndex;

- (id) initWithDataSource:(id<PWFlickrPhotosDataSourceProtocol>)theDataSource 
        withStartingIndex:(int)theIndex
              andDelegate:(id<PWFullscreenImageViewerDelegate>)theDelegate
  andParentViewController:(UIViewController*)theParentViewController {
	self = [super initWithFrame:[theDelegate positionForImageThumbWithIndex:theIndex]];
	if (self != nil) {
		dataSource = [theDataSource retain];
		currentIndex = theIndex;
		self.delegate = theDelegate;
		
		endlessScrollView = [[PWEndlessScrollView alloc] initWithFrame:self.bounds];
		endlessScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		endlessScrollView.endlessDelegate = self;
		endlessScrollView.dataSource = self;
		endlessScrollView.hidden = YES;
		[self addSubview:endlessScrollView];
		
		// all this image view is used for is going fullscreen and shrinking back down.
		// if we do this with the endlessScrollView it just doesn't look right.
		loadingImageView = [[UIImageView alloc] initWithImage:[theDataSource imageForIndex:theIndex]];
		loadingImageView.frame = self.bounds;
		loadingImageView.contentMode = UIViewContentModeScaleAspectFit;
		loadingImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:loadingImageView];
		
		topBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
		topBar.barStyle = UIBarStyleBlack;
		topBar.hidden = YES;
		topBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
		[self addSubview:topBar];
		        
        title = [[UIBarButtonItem alloc] initWithTitle:@"stuff" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        favoriteItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"favorite"]
                                                                                              style:UIBarButtonItemStylePlain
                                                                                             target:self
                                                                                             action:@selector(favoritePressed:)];
		UIBarButtonItem* shareItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																					target:self
																					action:@selector(actionButtonPressed:)] autorelease];
        UIBarButtonItem* closeItem1 = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", "full screen viewer close button")
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self
                                                                       action:@selector(shrinkFullscreen:)] autorelease];
		topBarItems = [[NSArray arrayWithObjects:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
						title, [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease], favoriteItem, shareItem, closeItem1, nil] retain];
		[topBar setItems:topBarItems];
		
		self.backgroundColor = [UIColor clearColor];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		hiresPictures = [[NSMutableDictionary alloc] init];
		downloadingHiResPictures = [[NSMutableArray alloc] init];

		
		UIPinchGestureRecognizer* pinchCloseRecognizer = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(maybeShrinkFullscreen:)] autorelease];
		[endlessScrollView addGestureRecognizer:pinchCloseRecognizer];
		
		UITapGestureRecognizer* closeFullscreenViewerRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shrinkFullscreen:)] autorelease];
		closeFullscreenViewerRecognizer.numberOfTouchesRequired = 2;
		[endlessScrollView addGestureRecognizer:closeFullscreenViewerRecognizer];

		UIGestureRecognizer* showTopBarRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self
																							 action:@selector(userTapped:)] autorelease];
		[endlessScrollView addGestureRecognizer:showTopBarRecognizer];
        
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(releaseMemory)
													 name:UIApplicationDidReceiveMemoryWarningNotification
												   object:nil];
        
        parentViewController = [theParentViewController retain];
	}
	return self;
}

- (BOOL) isTopBarVisible {
	return topBar.hidden == NO;
}

- (void) shrinkFullscreen:(id)stuff {
    if (actionSheet) {
        [actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex animated:NO];
    }
	[delegate fullscreenImageViewerWantsToClose:self];
}

- (void) maybeShrinkFullscreen:(UIPinchGestureRecognizer*)pinchGestureRecognizer {
	if (pinchGestureRecognizer.velocity < -0.5) {
		[delegate fullscreenImageViewerWantsToClose:self];
	}
}

- (void) hideTopBarWithCompletionBlock:(void (^)())completionBlock {
	if (topBar.hidden) {
		completionBlock();
		return;
	}
	[self hideScrollViewShowImageView];
	[UIView animateWithDuration:0.4
					 animations:^(void) {
						 topBar.frame = CGRectMake(0, -topBar.bounds.size.height, topBar.bounds.size.width, topBar.bounds.size.height);
						 loadingImageView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
					 }
					 completion:^(BOOL finished) {
						 topBar.hidden = YES;
						 endlessScrollView.frame = loadingImageView.frame;
						 [self showScrollViewHideImageView];
						 completionBlock();
					 }];
}

- (void) showTopBar {
	[self hideScrollViewShowImageView];
	topBar.frame = CGRectMake(0, -topBar.bounds.size.height, topBar.bounds.size.width, topBar.bounds.size.height);
	topBar.hidden = NO;
	[UIView animateWithDuration:0.4
					 animations:^(void) {
						 topBar.frame = CGRectMake(0, 0, topBar.bounds.size.width, topBar.bounds.size.height);
						 CGRect fullscreenRect = CGRectMake(0, topBar.bounds.size.height, self.bounds.size.width, self.bounds.size.height - topBar.bounds.size.height);
						 loadingImageView.frame = fullscreenRect;
					 }
					 completion:^(BOOL finished) {
						 endlessScrollView.frame = loadingImageView.frame;
						 [self showScrollViewHideImageView];
					 }];
}

- (void) userTapped:(UIGestureRecognizer*)gestureRecognizer {
	if (topBar.hidden == YES) {
		[self showTopBar];
	} else {
		[self hideTopBarWithCompletionBlock:^(void) {}];
	}
}

- (void) layoutSubviews {
    [super layoutSubviews];
    [self updateTopBarWithName];
}

- (void) actionButtonPressed:(id)actionButton {
    NSDictionary* entry = [dataSource entryForIndex:currentIndex];
    NSURL* pictureUrl = [[PWFlickrContext sharedContext] photoWebPageURLFromDictionary:entry];
    SHKItem *item = [SHKItem URL:pictureUrl title:[NSString stringWithFormat:@"%@ by %@", [entry objectForKey:@"title"], [entry objectForKey:@"ownername"]]];
    
    SHKActionSheet *shActionSheet = [SHKActionSheet actionSheetForItem:item];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        [shActionSheet showInView:self];
    else
        [shActionSheet showFromBarButtonItem:actionButton animated:YES];
                     
    
    /*
	if (actionSheet)
		return;
	actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Choose an action:", "choose an action action sheet")
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"Cancel", "fullscreen action view cancel")
											   destructiveButtonTitle:nil
													otherButtonTitles:
                   NSLocalizedString(@"Open in Browser", "open flickr page in browser action sheet button"), 
                   NSLocalizedString(@"Email Link", "send flickr page by email"),
                   NSLocalizedString(@"Copy Link", "copy link"), nil];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        [actionSheet showInView:self];
    else
        [actionSheet showFromBarButtonItem:actionButton animated:YES];
     */
}

- (void) actionSheet:(UIActionSheet *)theActionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSDictionary* entry = [dataSource entryForIndex:currentIndex];
    NSURL* pictureUrl = [[PWFlickrContext sharedContext] photoWebPageURLFromDictionary:entry];
    
	if (buttonIndex == actionSheet.firstOtherButtonIndex) {
		[[UIApplication sharedApplication] openURL:pictureUrl];
	} else if (buttonIndex == actionSheet.firstOtherButtonIndex+1) {
        [delegate fullscreenImageViewer:self
                wantsToSendLinkPerEmail:pictureUrl
                        withPictureName:[entry objectForKey:@"title"]
                               byAuthor:[entry objectForKey:@"ownername"]];
    } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 2) {
        NSMutableDictionary* items = [[[NSMutableDictionary alloc] init] autorelease];
        [items setValue:pictureUrl forKey:(NSString*)kUTTypeURL];
        [items setValue:[pictureUrl absoluteString] forKey:(NSString*)kUTTypeUTF8PlainText];
        [UIPasteboard generalPasteboard].items = [NSArray arrayWithObject:items];
    }
	[actionSheet release], actionSheet = nil;
}

- (void) updateTopBarWithName {
    NSDictionary* entry = [dataSource entryForIndex:currentIndex];
    title.width = self.bounds.size.width-120;
    title.title = [NSString stringWithFormat:@"%@ by %@ ", [entry objectForKey:@"title"], [entry objectForKey:@"ownername"]];
    
    [self updateFavoriteButton];
}

- (void) updateFavoriteButton {
    UIImage* image = [UIImage imageNamed:@"favorite"];
    if ([self isCurrentPhotoFavorited])
        image = [UIImage imageNamed:@"favorite_filled"];
    favoriteItem.image = image;
}

- (BOOL) isCurrentPhotoFavorited {
    NSDictionary* entry = [dataSource entryForIndex:currentIndex];
    return [[PWFavoriteController defaultFavoriteController] isPhotoFavorited:[[entry objectForKey:@"id"] longLongValue]];
}

- (void) endlessScrollView:(PWEndlessScrollView *)scrollView didChangeIndex:(int)indexChange {
	currentIndex += indexChange;
	if (currentIndex < 0)
		currentIndex = 0;
	if (currentIndex >= [dataSource count])
		currentIndex = [dataSource count] - 1;

	[self updateTopBarWithName];
	[delegate fullscreenImageView:self changedToIndex:currentIndex];
}

- (void) endlessScrollViewUserStartedScrolling:(PWEndlessScrollView *)scrollView {
	[topBar setItems:nil animated:YES];
}

- (void) endlessScrollViewUserStoppedScrolling:(PWEndlessScrollView *)scrollView {
	[topBar setItems:topBarItems animated:YES];
}

- (UIImage*) imageForIndex:(int)index {
	UIImage* image = [hiresPictures objectForKey:[dataSource entryForIndex:index]];
	if (image == nil) {
		image = [dataSource imageForIndex:index];
	}
	return image;
}

- (void) loadingImageView:(PWLoadingImageView *)imageView downloadedHiResImage:(UIImage *)hiResImage forEntry:(NSDictionary *)theEntry {
	[hiresPictures setObject:hiResImage forKey:theEntry];
	[downloadingHiResPictures removeObject:theEntry];
}

- (void) loadingImageView:(PWLoadingImageView *)imageView startedLoadingHiResImageForEntry:(NSDictionary *)theEntry {
	[downloadingHiResPictures addObject:theEntry];
}

- (BOOL) loadingImageView:(PWLoadingImageView*)imageView asksIfSomeoneStartedDownloadingHiResImageForEntry:(NSDictionary*)theEntry {
	return [downloadingHiResPictures containsObject:theEntry];
}

- (void) endlessScrollView:(PWEndlessScrollView *)scrollView needsView:(UIView *)theView updatedForType:(PWEndlessScrollViewViewType)theType {
	if ([theView viewWithTag:123] == nil) {
		PWLoadingImageView* imageView = [[[PWLoadingImageView alloc] initWithFrame:theView.bounds] autorelease];
		imageView.contentMode = UIViewContentModeScaleAspectFit;
		imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		imageView.tag = 123;
		imageView.loadingDelegate = self;
		[theView addSubview:imageView];
	}
	
	PWLoadingImageView* imageView = (PWLoadingImageView*)[theView viewWithTag:123];
	int index = 0;
	switch (theType) {
		case PWEndlessScrollViewViewTypePrevious:
			index = currentIndex - 1;
			break;
		case PWEndlessScrollViewViewTypeCurrent:
			index = currentIndex;
			break;
		case PWEndlessScrollViewViewTypeNext:
			index = currentIndex + 1;
			break;
	}
	[imageView setEntry:[dataSource entryForIndex:index] 
		 withThumbImage:[dataSource imageForIndex:index]
		  andHiResImage:[hiresPictures objectForKey:[dataSource entryForIndex:index]]];
}

- (void) queueShowTopBar {
	queueShowTopBar = YES;
}

- (BOOL) endlessScrollViewNextAvailable:(PWEndlessScrollView *)scrollView {
	if (currentIndex == [dataSource count] - 1)
		return NO;
	return YES;
}

- (BOOL) endlessScrollViewPreviousAvailable:(PWEndlessScrollView *)scrollView {
	if (currentIndex == 0)
		return NO;
	return YES;
}

- (CGRect) fullscreenImageRect {
	if ([dataSource imageForIndex:currentIndex] == nil)
		return CGRectMake(0, 0, self.superview.bounds.size.width, self.superview.bounds.size.height);
	CGSize fullSize = self.superview.bounds.size;
	CGSize imageSize = [dataSource imageForIndex:currentIndex].size;
	
	CGSize calculatedSize = CGSizeMake(fullSize.width,
									   (imageSize.height / imageSize.width) * fullSize.width);
	if (calculatedSize.height > self.superview.bounds.size.height) {
		calculatedSize = CGSizeMake((imageSize.width / imageSize.height) * fullSize.height, fullSize.height);
	}
	
	return CGRectMake(round(fullSize.width/2 - calculatedSize.width/2),
					  round(fullSize.height/2 - calculatedSize.height/2),
					  calculatedSize.width, calculatedSize.height);
}

- (void) goFullscreen {
	[self updateTopBarWithName];
	[UIView animateWithDuration:0.4
					 animations:^(void) {
						 self.frame = [self fullscreenImageRect];
					 } 
					 completion:^(BOOL finished) {
						 [UIView animateWithDuration:0.2 
										  animations:^(void) {
											  self.backgroundColor = [UIColor blackColor];
											  self.frame = self.superview.bounds;
										  }
										  completion:^(BOOL finished) {
											  [self showScrollViewHideImageView];
											  
											  if (queueShowTopBar) {
												  [self showTopBar];
												  queueShowTopBar = NO;
											  }
										  }];
					 }
	 ];
}

- (void) showScrollViewHideImageView {
	endlessScrollView.hidden = NO;
	[endlessScrollView reloadData];
	loadingImageView.hidden = YES;
}

- (void) hideScrollViewShowImageView {
	loadingImageView.image = [self imageForIndex:currentIndex];
	loadingImageView.hidden = NO;
	endlessScrollView.hidden = YES;
}

- (void) goSmallAndHide {
	if (shrinking)
		return;
	shrinking = YES;
	[self hideTopBarWithCompletionBlock:^(void) {
		[self hideScrollViewShowImageView];
		
		[UIView animateWithDuration:0.2 animations:^(void) {
			self.frame = [self fullscreenImageRect];
		}
						 completion:^(BOOL finished) {
							 self.backgroundColor = [UIColor clearColor];		
							 [UIView animateWithDuration:0.4
											  animations:^(void) {
												  self.frame = [delegate positionForImageThumbWithIndex:currentIndex];
											  }
											  completion:^(BOOL finished) {
												  self.hidden = YES;
												  shrinking = NO;
												  [delegate fullscreenImageViewerDidClose:self];
											  }];						 
						 }];		
	}];
}

- (void) releaseMemory {
	[hiresPictures removeAllObjects];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[endlessScrollView removeFromSuperview];
	[endlessScrollView release];
	
	[dataSource release];
	[loadingImageView removeFromSuperview];
	[loadingImageView release];
	[hiresPictures release];
	[downloadingHiResPictures release];
	
	[topBar removeFromSuperview];
	[topBar release];
	[topBarItems release];
	
	[actionSheet release];
    
    [parentViewController release];
    [super dealloc];
}


- (void) favoritePressed:(id)sender {
    GTMOAuthAuthentication* auth = [PWPreferences authentication];
    if (![auth canAuthorize]) {
        if (doesAuth)
            return;
        doesAuth = YES;
        PWFlickrAuthenticationHandler* handler = [[PWFlickrAuthenticationHandler alloc] init];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [handler presentFromBarButtonItem:sender 
                              withMaximumSize:self.bounds.size
                                    withBlock:^(BOOL success) {
                if (success)
                    [self sendFavoriteRequest:[PWPreferences authentication]];
                [handler autorelease];
                doesAuth = NO;
            }];
        } else {
            [handler presentInViewController:parentViewController
                                   withBlock:^(BOOL success) {
                               if (success)
                                   [self sendFavoriteRequest:[PWPreferences authentication]];
                               [handler autorelease];
                               doesAuth = NO;      
                           }];
        }
    } else {
        [self sendFavoriteRequest:auth];
    }
}

- (void) sendFavoriteRequest:(GTMOAuthAuthentication*)auth {
    if ([self isCurrentPhotoFavorited]) {
        [[SHKActivityIndicator currentIndicator] displayActivity:NSLocalizedString(@"Removing ...", "unfavoriting picture")];
        [[PWFavoriteController defaultFavoriteController] unfavoritePhotoWithId:[[[dataSource entryForIndex:currentIndex] objectForKey:@"id"] longLongValue]
                                                                      usingAuth:auth
                                                                          block:^(_Bool success) {
                                                                              [self updateFavoriteButton];
                                                                              if (success)
                                                                                  [[SHKActivityIndicator currentIndicator] displayCompleted:NSLocalizedString(@"Removed.", "unfavorited picture")];        
                                                                              else
                                                                                  [[SHKActivityIndicator currentIndicator] displayCompleted:NSLocalizedString(@"Failed.", "failed to favorite.")];
                                                                          }];                
    } else {
        [[SHKActivityIndicator currentIndicator] displayActivity:NSLocalizedString(@"Favoriting ...", "favoriting picture")];
        [[PWFavoriteController defaultFavoriteController] favoritePhotoWithId:[[[dataSource entryForIndex:currentIndex] objectForKey:@"id"] longLongValue]
                                                                    usingAuth:auth
                                                                        block:^(_Bool success) {
                                                                              [self updateFavoriteButton];
                                                                            if (success)
                                                                                [[SHKActivityIndicator currentIndicator] displayCompleted:NSLocalizedString(@"Favorited.", "favorited picture")];        
                                                                            else
                                                                                [[SHKActivityIndicator currentIndicator] displayCompleted:NSLocalizedString(@"Failed.", "failed to favorite.")];
                                                                        }];        
    }
}


@end
