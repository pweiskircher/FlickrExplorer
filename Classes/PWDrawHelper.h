//
//  PWDrawHelper.h
//  FlickrExplorer
//
//  Created by Patrik Weiskircher on 9.7.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PWDrawHelper : NSObject {
    
}
+ (void) drawRoundedRectangleUsing:(CGContextRef)context andBounds:(CGRect)bounds withRadius:(CGFloat)radius;
@end
