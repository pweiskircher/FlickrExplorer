//
//  PWShareKitConfiguration.m
//  FlickrExplorer
//
//  Created by Patrik Weiskircher on 27.3.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PWShareKitConfiguration.h"
#import "PWAccessKeys.h"

@implementation PWShareKitConfiguration
- (NSString*)appName {
	return @"Flickr Explorer";
}

- (NSString*)appURL {
	return @"http://flickrexplorer.weiskircher.name";
}

// Facebook - https://developers.facebook.com/apps
// SHKFacebookAppID is the Application ID provided by Facebook
// SHKFacebookLocalAppID is used if you need to differentiate between several iOS apps running against a single Facebook app. Useful, if you have full and lite versions of the same app,
// and wish sharing from both will appear on facebook as sharing from one main app. You have to add different suffix to each version. Do not forget to fill both suffixes on facebook developer ("URL Scheme Suffix"). Leave it blank unless you are sure of what you are doing. 
// The CFBundleURLSchemes in your App-Info.plist should be "fb" + the concatenation of these two IDs.
// Example: 
//    SHKFacebookAppID = 555
//    SHKFacebookLocalAppID = lite
// 
//    Your CFBundleURLSchemes entry: fb555lite
- (NSString*)facebookAppId {
	return [PWAccessKeys facebookAppId];
}

- (NSString*)readItLaterKey {
	return [PWAccessKeys readitLaterKey];
}


- (NSString*)twitterConsumerKey {
	return [PWAccessKeys twitterConsumerKey];
}

- (NSString*)twitterSecret {
	return [PWAccessKeys twitterSecret];
}
- (NSString*)twitterCallbackUrl {
	return [PWAccessKeys twitterCallbackUrl];
}

- (NSString*)bitLyLogin {
	return [PWAccessKeys bitlyLogin];
}

- (NSString*)bitLyKey {
    return [PWAccessKeys bitlyKey];
}


@end
