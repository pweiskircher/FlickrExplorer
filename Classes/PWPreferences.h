//
//  PWPreferences.h
//  FlickrExplorer
//
//  Created by Patrik Weiskircher on 13.7.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTMOAuthAuthentication.h"

@interface PWPreferences : NSObject {
    
}
+ (void) recordLaunch;
+ (int) numberOfLaunches;

+ (void) setDontShowFastNavigationHint;
+ (BOOL) canShowFastNavigationHint;

+ (void) resetStoredState;
+ (void) storePageState:(NSDictionary*)firstEntry andCurrentPage:(int)currentPage andHasFullscreenViewer:(BOOL)hasFullscreenViewer;
+ (void) storeFullscreenState:(int)currentIndex andIsTopBarVisible:(BOOL)isTopBarVisible;

+ (NSDictionary*) storedFirstEntry;
+ (int) storedCurrentPage;

+ (BOOL) hasFullscreenImageViewerStored;
+ (int) storedFullscreenImageViewerIndex;
+ (BOOL) hasTopBarVisible;

+ (void) setEntriesLastFetched;
+ (NSDate*) timeWhenEntriesWereLastFetched;

+ (NSString*) version;
+ (NSString*) supportEmail;

+ (GTMOAuthAuthentication*) authentication;
+ (NSURL*) flickrRequestUrl;
+ (NSURL*) flickrAccessUrl;
+ (NSURL*) flickrAuthorizeUrl;
+ (NSString*) flickrAppServiceName;

+ (NSString*) databasePath;
+ (NSURL*) flickrRequestUrlWithMethod:(NSString*)method andArguments:(NSDictionary*)arguments;

@end
