//
//  PWFlickrReachabilityChecker.h
//  FlickrExplorer
//
//  Created by Patrik Weiskircher on 10.7.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PWFlickrReachabilityChecker : NSObject <UIAlertViewDelegate> {
    UIAlertView* noNetworkAlertView;
}
- (BOOL) checkReachability;
@end
