//
//  PWImageDescriptionLabel.h
//  FlickrExplore
//
//  Created by Patrik Weiskircher on 12/16/10.
//  Copyright 2010 INQNET. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PWImageDescriptionLabel : UIView {
	UILabel* imageNameLabel;
	UILabel* authorNameLabel;
}
@property(nonatomic, readwrite, retain) NSString* imageName;
@property(nonatomic, readwrite, retain) NSString* authorName;

@end
