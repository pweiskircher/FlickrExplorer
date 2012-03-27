//
//  PWHelper.m
//  FlickrExplorer
//
//  Created by Patrik Weiskircher on 14.7.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PWHelper.h"
#import <MessageUI/MessageUI.h>

@implementation PWHelper
+ (BOOL) checkCanSendMailAndShowError {
    if ([MFMailComposeViewController canSendMail] == NO) {
        UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Can't send email", "can't send email title")
                                                         message:NSLocalizedString(@"Please configure an email account on your device.", "can't send email message")
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"Ok", "ok") otherButtonTitles:nil] autorelease];
        [alert show];
        return NO;
    }
    return YES;
}
@end
