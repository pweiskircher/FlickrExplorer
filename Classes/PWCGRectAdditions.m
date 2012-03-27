//
//  PWCGRectAdditions.m
//  FlickrExplore
//
//  Created by Patrik Weiskircher on 12/14/10.
//  Copyright 2010 INQNET. All rights reserved.
//

#import "PWCGRectAdditions.h"

CGRect CGRectWithCenter(CGRect rect, CGSize size) {
	return CGRectMake(round(rect.size.width/2 - size.width/2), round(rect.size.height/2 - size.height/2),
					  size.width, size.height);
}