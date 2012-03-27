//
//  PWDrawHelper.m
//  FlickrExplorer
//
//  Created by Patrik Weiskircher on 9.7.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PWDrawHelper.h"


@implementation PWDrawHelper
+ (void) drawRoundedRectangleUsing:(CGContextRef)context andBounds:(CGRect)bounds withRadius:(CGFloat)radius {
	CGContextBeginPath(context);
	
	CGContextMoveToPoint(context, radius, 0);
	CGContextAddArc(context,
					bounds.size.width - radius, radius, radius, 
					-M_PI/2, 0, 0);
	CGContextAddArc(context,
					bounds.size.width - radius, bounds.size.height - radius, radius,
					0, M_PI/2, 0);
	CGContextAddArc(context,
					radius, bounds.size.height - radius, radius,
					M_PI/2, M_PI, 0);
	CGContextAddArc(context,
					radius, radius, radius,
					M_PI, -M_PI/2, 0);
    
	CGContextFillPath(context);
}
@end
