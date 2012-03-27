//
//  PWFlickrContext.m
//  FlickrExplore
//
//  Created by Patrik Weiskircher on 11.12.2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PWFlickrContext.h"
#import "PWAccessKeys.h"


static OFFlickrAPIContext* _sharedContext;

@implementation PWFlickrContext
+ (OFFlickrAPIContext*) sharedContext {
	if (!_sharedContext) {
		_sharedContext = [[OFFlickrAPIContext alloc] initWithAPIKey:[PWAccessKeys flickrConsumerKey]
													   sharedSecret:[PWAccessKeys flickrSecret]];
	}
	return _sharedContext;
}
@end
