//
//  PWFavoriteController.h
//  FlickrExplorer
//
//  Created by Patrik Weiskircher on 24.9.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTMOAuthAuthentication.h"
#import "FMDatabase.h"

@interface PWFavoriteController : NSObject {
    NSMutableArray* connections;
    FMDatabase* database;
}
+ (id) defaultFavoriteController;

- (BOOL) isPhotoFavorited:(unsigned long long int)photoId;
- (void) favoritePhotoWithId:(unsigned long long int)photoId usingAuth:(GTMOAuthAuthentication*)auth block:(void (^)(bool success))block;
- (void) unfavoritePhotoWithId:(unsigned long long int)photoId usingAuth:(GTMOAuthAuthentication*)auth block:(void (^)(bool success))block;

@end
