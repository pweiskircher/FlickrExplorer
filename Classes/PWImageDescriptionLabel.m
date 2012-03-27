//
//  PWImageDescriptionLabel.m
//  FlickrExplore
//
//  Created by Patrik Weiskircher on 12/16/10.
//  Copyright 2010 INQNET. All rights reserved.
//

#import "PWImageDescriptionLabel.h"


@implementation PWImageDescriptionLabel

- (id)initWithFrame:(CGRect)frame {    
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
		imageNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		imageNameLabel.backgroundColor = [UIColor clearColor];
		imageNameLabel.textColor = [UIColor whiteColor];
		imageNameLabel.font = [UIFont boldSystemFontOfSize:22];
        imageNameLabel.adjustsFontSizeToFitWidth = YES;
		
		authorNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		authorNameLabel.backgroundColor = [UIColor clearColor];
		authorNameLabel.textColor = [UIColor whiteColor];
		authorNameLabel.font = [UIFont boldSystemFontOfSize:14];
        authorNameLabel.adjustsFontSizeToFitWidth = YES;
		
		[self addSubview:imageNameLabel];
		[self addSubview:authorNameLabel];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
	return CGSizeMake(imageNameLabel.bounds.size.width + 5 + authorNameLabel.bounds.size.width,
					  44);
}

- (void) layoutSubviews {
	[super layoutSubviews];
	
	[imageNameLabel sizeToFit];
	[authorNameLabel sizeToFit];
	
	CGFloat y = round(self.bounds.size.height / 2 - imageNameLabel.bounds.size.height/2);
    
    CGSize wantedSize = [self sizeThatFits:CGSizeZero];
    CGFloat imageWidth, authorWidth;
    if (wantedSize.width > self.frame.size.width) {
        CGFloat totalWidth = self.bounds.size.width - 50;
        imageWidth = round(totalWidth * 0.8);
        authorWidth = totalWidth - imageWidth;
    } else {
        imageWidth = imageNameLabel.bounds.size.width;
        authorWidth = authorNameLabel.bounds.size.width;
    }
	
	imageNameLabel.frame = CGRectMake(0, y, imageWidth, imageNameLabel.bounds.size.height);
	authorNameLabel.frame = CGRectMake(imageNameLabel.bounds.size.width+5, y+7, authorWidth, authorNameLabel.bounds.size.height);
}

- (NSString*) imageName {
	return imageNameLabel.text; // FIXME: returns Untitled if text is ""
}

- (NSString*) authorName {
	return authorNameLabel.text; // FIXME: only return the author name, not the prefix
}

- (void) setImageName:(NSString *)imageName {
	imageNameLabel.text = imageName;
	if ([imageNameLabel.text length] == 0 || imageNameLabel.text == nil)
		imageNameLabel.text = NSLocalizedString(@"Untitled", "untitled image name");
	[self layoutSubviews];
}

- (void) setAuthorName:(NSString *)authorName {
	authorNameLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"by", "$IMAGENAME by $AUTHORNAME"), authorName];
	[self layoutSubviews];
}

- (void)dealloc {
    [super dealloc];
}


@end
