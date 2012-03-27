//
//  PWPreferences.m
//  FlickrExplorer
//
//  Created by Patrik Weiskircher on 13.7.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PWPreferences.h"
#import "GTMOAuthViewControllerTouch.h"
#import "PWAccessKeys.h"

static NSString * const kNumberOfLaunches = @"kNumberOfLaunches";
static NSString * const kCanShowFastNavigationHint = @"kCanShowFastNavigationHint";
static NSString * const kFirstEntry = @"kFirstEntry";
static NSString * const kCurrentPage = @"kCurrentPage";
static NSString * const kHasFullscreenViewer = @"kHasFullscreenViewer";
static NSString * const kFullscreenCurrentIndex = @"kFullscreenCurrentIndex";
static NSString * const kFullscreenTopBarVisible = @"kFullscreenTopBarVisible";
static NSString * const kEntriesLastFetched = @"kEntriesLastFetched";

@implementation PWPreferences
+ (NSString*) databasePath {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                        NSUserDomainMask,
                                                         YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"database.sqlite"];
}

+ (void) recordLaunch {
    int launchNumber = [PWPreferences numberOfLaunches];
    [[NSUserDefaults standardUserDefaults] setInteger:launchNumber+1 forKey:kNumberOfLaunches];
}

+ (int) numberOfLaunches {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfLaunches];
}

+ (void) setDontShowFastNavigationHint {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kCanShowFastNavigationHint];
}

+ (BOOL) canShowFastNavigationHint {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kCanShowFastNavigationHint];
}

+ (void) resetStoredState {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kFirstEntry];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCurrentPage];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kHasFullscreenViewer];
}

+ (void) storePageState:(NSDictionary*)firstEntry andCurrentPage:(int)currentPage andHasFullscreenViewer:(BOOL)hasFullscreenViewer {
    [[NSUserDefaults standardUserDefaults] setObject:firstEntry forKey:kFirstEntry];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:currentPage] forKey:kCurrentPage];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:hasFullscreenViewer] forKey:kHasFullscreenViewer];
}

+ (void) storeFullscreenState:(int)currentIndex andIsTopBarVisible:(BOOL)isTopBarVisible {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:currentIndex]
                                              forKey:kFullscreenCurrentIndex];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isTopBarVisible]
                                              forKey:kFullscreenTopBarVisible]; 
}

+ (NSDictionary*) storedFirstEntry {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kFirstEntry];
}

+ (int) storedCurrentPage {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kCurrentPage];
}

+ (BOOL) hasFullscreenImageViewerStored {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHasFullscreenViewer];
}

+ (int) storedFullscreenImageViewerIndex {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kFullscreenCurrentIndex];
    
}

+ (BOOL) hasTopBarVisible {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kFullscreenTopBarVisible];
}

+ (void) setEntriesLastFetched {
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kEntriesLastFetched];
}

+ (NSDate*) timeWhenEntriesWereLastFetched {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kEntriesLastFetched];
}

+ (NSString*) version {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (NSString*) supportEmail {
    return @"flickr.explorer@weiskircher.name";
}

+ (GTMOAuthAuthentication*) flickrAuthObject {
    GTMOAuthAuthentication *auth;
    auth = [[[GTMOAuthAuthentication alloc] initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1
                                                        consumerKey:[PWAccessKeys flickrConsumerKey]
                                                         privateKey:[PWAccessKeys flickrSecret]] autorelease];
    
    // setting the service name lets us inspect the auth object later to know
    // what service it is for
    auth.serviceProvider = @"Flickr Auth Service";
    
    return auth;
}

+ (GTMOAuthAuthentication*) authentication {
    GTMOAuthAuthentication *auth = [self flickrAuthObject];
    if (auth) {
        [GTMOAuthViewControllerTouch authorizeFromKeychainForName:[self flickrAppServiceName]
                                                   authentication:auth];
    }

    return auth;
}

+ (NSURL*) flickrRequestUrl {
    return [NSURL URLWithString:@"http://www.flickr.com/services/oauth/request_token"];
}
+ (NSURL*) flickrAccessUrl {
    return [NSURL URLWithString:@"http://www.flickr.com/services/oauth/access_token"];
}
+ (NSURL*) flickrAuthorizeUrl {
    return [NSURL URLWithString:@"http://www.flickr.com/services/oauth/authorize"];
}
+ (NSString*) flickrAppServiceName {
    return @"FlickrExplorer: Flickr Service";
}

+ (NSURL*) flickrRequestUrlWithMethod:(NSString*)method andArguments:(NSDictionary*)arguments {
    NSMutableString* url = [NSMutableString stringWithString:@"http://api.flickr.com/services/rest/?method="];
    [url appendString:method];
    [url appendFormat:@"&api_key=%@", [PWAccessKeys flickrConsumerKey]];
    
    for (NSString* key in [arguments allKeys]) {
        [url appendFormat:@"&%@=%@", key, [arguments objectForKey:key]];
    }
    
    return [NSURL URLWithString:url];
}
@end
