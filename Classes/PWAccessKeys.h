//
//  PWAccessKeys.h
//  FlickrExplorer
//
//  Created by Patrik Weiskircher on 27.3.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PWAccessKeys : NSObject
+ (NSString*) flickrConsumerKey;
+ (NSString*) flickrSecret;

+ (NSString*) readitLaterKey;

+ (NSString*) twitterConsumerKey;
+ (NSString*) twitterSecret;
+ (NSString*) twitterCallbackUrl;

+ (NSString*) bitlyLogin;
+ (NSString*) bitlyKey;

+ (NSString*) facebookAppId;
@end
