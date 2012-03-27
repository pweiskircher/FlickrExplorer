//
//  PWFavoriteController.m
//  FlickrExplorer
//
//  Created by Patrik Weiskircher on 24.9.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PWFavoriteController.h"
#import "PWPreferences.h"
#import "OFXMLMapper.h"

static PWFavoriteController* favoriteController = nil;

@implementation PWFavoriteController

- (id)init
{
    self = [super init];
    if (self) {
        connections = [[NSMutableArray array] retain];
        database = [[FMDatabase databaseWithPath:[PWPreferences databasePath]] retain];
        if (![database open]) {
            NSLog(@"database unavailable, continuing without it.");
            [database release], database = nil;
        } else {
            [database executeUpdate:@"CREATE TABLE IF NOT EXISTS favorites (id INTEGER PRIMARY KEY AUTOINCREMENT, photo_id INTEGER)"];
        }
    }
    
    return self;
}

- (void)dealloc {
    [database close], [database release], database = nil;
    [connections release];
    [super dealloc];
}

+ (id) defaultFavoriteController {
    if (!favoriteController) {
        favoriteController = [[PWFavoriteController alloc] init];
    }
    return [[favoriteController retain] autorelease];
}

- (BOOL) isPhotoFavorited:(unsigned long long int)photoId {
    FMResultSet *s = [database executeQueryWithFormat:@"SELECT count(*) FROM favorites WHERE photo_id = %d", photoId];
    [s next];

    return [s intForColumnIndex:0] == 1;
}

- (void) executeRequest:(NSString*)method withPhotoId:(unsigned long long int)photoId usingAuth:(GTMOAuthAuthentication*)auth block:(void (^)(bool success))block {
    NSURL* url = [PWPreferences flickrRequestUrlWithMethod:method
                                              andArguments:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%llu", photoId]
                                                                                       forKey:@"photo_id"]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [auth authorizeRequest:request];
    
    NSMutableDictionary* data = [NSMutableDictionary dictionary];
    [data setObject:[[block copy] autorelease] forKey:@"block"];
    [data setObject:[NSMutableData data] forKey:@"data"];
    [data setObject:[NSURLConnection connectionWithRequest:request delegate:self] forKey:@"connection"];
    [data setObject:[NSNumber numberWithUnsignedLongLong:photoId] forKey:@"photo_id"];
    [data setObject:method forKey:@"method"];
    
    [connections addObject:data];
}

- (NSDictionary*) dataForConnection:(NSURLConnection*) connection {
    for (NSDictionary* dict in connections) {
        if ([dict objectForKey:@"connection"] == connection)
            return dict;
    }
    return nil;
}

- (void) favoritePhotoWithId:(unsigned long long int)photoId usingAuth:(GTMOAuthAuthentication*)auth block:(void (^)(bool success))block {
    [self executeRequest:@"flickr.favorites.add" withPhotoId:photoId usingAuth:auth block:block];
}

- (void) unfavoritePhotoWithId:(unsigned long long int)photoId usingAuth:(GTMOAuthAuthentication*)auth block:(void (^)(bool success))block {
    [self executeRequest:@"flickr.favorites.remove" withPhotoId:photoId usingAuth:auth block:block];    
}


- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"error on flickr request: %@", error);
    
    NSDictionary* data = [self dataForConnection:connection];
    void (^block)(bool success) = [data objectForKey:@"block"];
    block(NO);
    
    [connections removeObjectIdenticalTo:data];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSDictionary* d = [self dataForConnection:connection];
    [[d objectForKey:@"data"] appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    NSDictionary* data = [self dataForConnection:connection];
    NSDictionary* result = [OFXMLMapper dictionaryMappedFromXMLData:[data objectForKey:@"data"]];
    
    bool successful = [[[result objectForKey:@"rsp"] objectForKey:@"stat"] isEqualToString:@"ok"];
    
    if (successful) {
        unsigned long long photoId = [[data objectForKey:@"photo_id"] unsignedLongLongValue];
        
        if ([[data objectForKey:@"method"] isEqualToString:@"flickr.favorites.add"]) {
            [database executeUpdateWithFormat:@"INSERT INTO favorites (photo_id) values(%d)", photoId];
        } else if ([[data objectForKey:@"method"] isEqualToString:@"flickr.favorites.remove"]) {
            [database executeUpdateWithFormat:@"DELETE FROM favorites WHERE photo_id = %d", photoId];
        }
    }
    
    void (^block)(bool success) = [data objectForKey:@"block"];
    block(successful);
    
    [connections removeObjectIdenticalTo:data];
}


@end
