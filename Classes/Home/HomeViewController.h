//
//  HomeViewController.h
//  Tinder
//
//  Created by Rahul Sharma on 24/11/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import "BaseVC.h"

#import "PPRevealSideViewController.h"
#import "TinderAppDelegate.h"
#import <FacebookSDK/FBSessionTokenCachingStrategy.h>
#import <FacebookSDK/FacebookSDK.h>
#import "TinderFBFQL.h"
#import "PlaceHolderTextView.h"
#import <MessageUI/MessageUI.h>
@interface HomeViewController : BaseVC<PPRevealSideViewControllerDelegate,FBLoginViewDelegate, TinderFBFQLDelegate,MFMessageComposeViewControllerDelegate>
{
    IBOutlet  UIImageView *imgProfile;
    NSString * strProfileUrl;
    int flag;
    IBOutlet UIView *viewGetMatched;
    IBOutlet UIButton *btnInvite;
    IBOutlet UIView *viewItsMatched;
    IBOutlet UILabel *lblItsMatched;
    IBOutlet UILabel *lblItsMatchedSubText;
    IBOutlet UILabel *lblNoFriendAround;
    
    IBOutlet UIView *vwSparkMessage;
    IBOutlet UIView *vwAlert;
    IBOutlet UIView *vwTypeMsgPopup;
    
    IBOutlet PlaceHolderTextView *txtSparkMSg;
    IBOutlet UILabel *lblSparkAlert;
    IBOutlet UIView *vwTokens;
    
    IBOutlet UILabel *lblSparkAlertsCounter;
    IBOutlet UIButton *btnSparkBalance;
    
    IBOutlet UIImageView *userOneImageView;
    IBOutlet UIImageView *userTwoImageView;
    
    NSMutableArray *arrayLastUnmatchesToUndo;
}
@property(strong ,nonatomic) NSDictionary *dictLoginUsrdetail;
@property(strong ,nonatomic) NSMutableArray *arrFBImageUrl;
@property(strong ,nonatomic)  NSString * strProfileUrl;
@property(assign ,nonatomic)  int flag;
@property(nonatomic,assign) BOOL animationFlag;

@property (strong, nonatomic) IBOutlet FBLoginView *loginView;

@property(nonatomic,strong)IBOutlet UIView *viewPercentMatch;
@property(nonatomic,strong)IBOutlet UILabel *lblPercentMatch;

-(IBAction)openMail :(id)sender;
-(IBAction)btnActionForItsMatchedView :(id)sender;

//surender
@property(nonatomic,assign) BOOL didUserLoggedIn;
@property(nonatomic,assign) BOOL chatVC;
@property(nonatomic,assign) BOOL _loadViewOnce;
- (IBAction)btnPurchaseTapped:(id)sender;
- (IBAction)btnSendSparkTapped:(UIButton *)sender;
- (IBAction)btnSendSparkWithMsgTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *imgVerified;
@property (weak, nonatomic) IBOutlet UIImageView *imgVerified2;

@end
