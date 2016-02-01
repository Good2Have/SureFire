//
//  WebViewController.m
//  snapchatclone
//
//  Created by soumya ranjan sahu on 25/11/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    
    [APPDELEGATE addBackButton:self.navigationItem];
    [APPDELEGATE addrightButton:self.navigationItem];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 25)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:20];
    headerLabel.text = self.typeString;
    headerLabel.textColor = [UIColor colorWithRed:255.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = headerLabel;
    
    NSURL *webUrl;
    
    if ([self.typeString isEqualToString:@"How it works"]) {
        
        webUrl = [NSURL URLWithString:@"http://www.surefirematch.com/howitworks/"];
    }
    else if ([self.typeString isEqualToString:@"Support"]) {
        
        webUrl = [NSURL URLWithString:@"https://surefirematch.freshdesk.com/support/home"];
    }
    
    ProgressIndicator *pi = [ProgressIndicator sharedInstance];
    [pi showPIOnView:self.view withMessage:@"Loading"];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:webUrl]];
    // Do any additional setup after loading the view from its nib.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    ProgressIndicator *pi = [ProgressIndicator sharedInstance];
    [pi hideProgressIndicator];
}

- (void)didTapBackButton:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - PPRevealSlider Delegte method

- (BOOL) pprevealSideViewController:(PPRevealSideViewController *)controller shouldDeactivateGesture:(UIGestureRecognizer*)gesture forView:(UIView*)view
{
    return YES;
}

@end
