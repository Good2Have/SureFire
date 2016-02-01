//
//  WebViewController.h
//  snapchatclone
//
//  Created by soumya ranjan sahu on 25/11/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <PPRevealSideViewControllerDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (retain, nonatomic) NSString *typeString;

@end
