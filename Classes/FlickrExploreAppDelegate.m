//
//  FlickrExploreAppDelegate.m
//  FlickrExplore
//
//  Created by Patrik Weiskircher on 11.12.2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FlickrExploreAppDelegate.h"
#import "FlickrExploreViewController.h"
#import "PWPreferences.h"

#import "SHKConfiguration.h"
#import "SHKFacebook.h"

#import "PWShareKitConfiguration.h"

const int kFeedRefreshTime = -12*60*60;

@implementation FlickrExploreAppDelegate

@synthesize window;
@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    PWShareKitConfiguration *configurator = [[PWShareKitConfiguration alloc] init];
    [SHKConfiguration sharedInstanceWithConfigurator:configurator];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DefaultConfig" ofType:@"plist"]]];
    
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	
    // Override point for customization after app launch. 
    [self.window addSubview:viewController.view];
    [self.window makeKeyAndVisible];

	return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	[viewController saveState];

    if (reachability) {
        [reachability release], reachability = nil;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void) applicationWillEnterForeground:(UIApplication *)application {
    // we refresh every 12 hours.
    if ([[PWPreferences timeWhenEntriesWereLastFetched] timeIntervalSinceNow] < kFeedRefreshTime) {
        [PWPreferences resetStoredState];
        [viewController reinitialize];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[viewController restoreState];
    
    
    if (reachability == nil) {
        reachability = [[PWFlickrReachabilityChecker alloc] init];
    }
    if (![reachability checkReachability])
        // don't annoy the user with yet another text box if he can't even use the app.
        return;
    
    [PWPreferences recordLaunch];
    if ([PWPreferences canShowFastNavigationHint] && [PWPreferences numberOfLaunches] >= 3) {
        [PWPreferences setDontShowFastNavigationHint];
        UIAlertView* alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Faster Navigation!", "faster navigation title")
                                                             message:NSLocalizedString(@"To move quickly between pages, slide 2 fingers to the left or right.", "faster navigation message")
                                                            delegate:nil
                                                   cancelButtonTitle:NSLocalizedString(@"Ok", "faster navigation cancel button")
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

- (BOOL)handleOpenURL:(NSURL*)url
{
    NSString* scheme = [url scheme];
    NSString* prefix = [NSString stringWithFormat:@"fb%@", SHKCONFIG(facebookAppId)];
    if ([scheme hasPrefix:prefix])
        return [SHKFacebook handleOpenURL:url];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation 
{
    return [self handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url 
{
    return [self handleOpenURL:url];  
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
