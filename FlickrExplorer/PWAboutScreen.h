//
//  PWAboutScreen.h
//  FlickrExplorer
//
//  Created by Patrik Weiskircher on 10.7.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface PWAboutScreen : NSObject <MFMailComposeViewControllerDelegate> {
    UIView *view;
    UILabel *versionLabel;
    UIButton *logoutTwitterButton;
    UIButton *feedbackButton;
    UIViewController* viewController;
    
    CGRect _originalFeedbackButtonRect;
}
@property (nonatomic, retain) IBOutlet UIView *view;
@property (nonatomic, retain) IBOutlet UILabel *versionLabel;
@property (nonatomic, retain) IBOutlet UIButton *logoutTwitterButton;
@property (nonatomic, retain) IBOutlet UIButton *feedbackButton;

- (id) initWithViewController:(UIViewController*)controller;
- (IBAction)feedbackClicked:(id)sender;
- (IBAction)logoutOfTwitter:(id)sender;
@end
