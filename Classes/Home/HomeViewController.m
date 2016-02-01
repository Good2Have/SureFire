
//
//  HomeViewController.m
//  Tinder
//
//  Created by Rahul Sharma on 24/11/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import "HomeViewController.h"
#import <FacebookSDK/FBSessionTokenCachingStrategy.h>
#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/QuartzCore.h>
#import "RoundedImageView.h"
#import "UploadImages.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageDownloader.h"
#import "Login.h"
#import "TinderGenericUtility.h"
#import "ChatViewController.h"
#import "MenuViewController.h"
#import "ChattingViewController.h"
#import "UIImageView+Download.h"
#import "User.h"
#import "QuestionVC.h"
#import "ProfileVC.h"
#import "PurchaseTokenVC.h"
#import "NotificationsVC.h"
#import "UserCreditsVC.h"
#import "MessageTable.h"
#import "NSUserDefaults+RMSaveCustomObject.h"
@interface HomeViewController ()<UIAlertViewDelegate>
{
    BOOL inAnimation;
    CALayer *waveLayer;
    NSTimer *animateTimer;
    RoundedImageView *profileImageView;
    NSMutableArray * arr ;
    NSArray *  profileImg;
    CGPoint original;
    NSMutableArray *myProfileMatches;
    
    IBOutlet UIView *matchesView;
    IBOutlet UIView *visibleView1;
    IBOutlet UIView *visibleView2;
    
    IBOutlet UIImageView *mainImageView;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *nameLabel2;
    IBOutlet UILabel *commonFriends;
    IBOutlet UILabel *picsCount;
    IBOutlet UILabel *commonInterest;
    
    IBOutlet UILabel *lblMutualFriend;
    IBOutlet UILabel *lblMutualLikes;
    IBOutlet UILabel *lblMutualFriend2;
    IBOutlet UILabel *lblMutualLikes2;
    
    NSTimer *locationUpdateTimer;
    BOOL isCheckedForDontShowAlert;
}
@property (strong, nonatomic) PPRevealSideViewController *revealSideViewController;
@property (nonatomic, strong, readonly) IBOutlet UIImageView *imgvw;
@property (nonatomic, strong) IBOutlet UILabel *decision;
@property (nonatomic, strong) IBOutlet UILabel *liked;
@property (nonatomic, strong) IBOutlet UILabel *nope;
@property (nonatomic, strong) IBOutlet UIButton *likedBtn;
@property (nonatomic, strong) IBOutlet UIButton *nopeBtn;
@property (nonatomic, strong) IBOutlet UILabel *lblNoOfImage;

@end

@implementation HomeViewController
@synthesize dictLoginUsrdetail;
@synthesize arrFBImageUrl;
@synthesize strProfileUrl;
@synthesize flag;
@synthesize loginView;
@synthesize imgvw;
@synthesize liked;
@synthesize nope;
@synthesize lblNoOfImage;
@synthesize didUserLoggedIn;
@synthesize _loadViewOnce;

#pragma mark -
#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)showMessageIcon
{
    [APPDELEGATE addrightButton:self.navigationItem]; 
}

#pragma mark -
#pragma mark - View cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self updateLocation];
    
    [userOneImageView.layer setCornerRadius:50];
    [userTwoImageView.layer setCornerRadius:50];
    
    [userOneImageView.layer setBorderColor:[[UIColor colorWithRed:198.0f/255.0f green:50.0f/255.0f blue:51.0f/255.0f alpha:1.0] CGColor]];
    [userTwoImageView.layer setBorderColor:[[UIColor colorWithRed:198.0f/255.0f green:50.0f/255.0f blue:51.0f/255.0f alpha:1.0] CGColor]];
    
    [userOneImageView.layer setBorderWidth:5];
    [userTwoImageView.layer setBorderWidth:5];
    
    self.loginView.readPermissions = @[@"user_photos"];
    arr = [[NSMutableArray alloc]init];
    self.navigationController.navigationBar.translucent = NO;

    self.navigationController.navigationBarHidden = YES;
    [APPDELEGATE addBackButton:self.navigationItem];
   
    UIImageView *logoImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 123, 30)];
    logoImg.image = [UIImage imageNamed:@"image_logo.png"];
    self.navigationItem.titleView = logoImg;
    
   [APPDELEGATE addrightButton:self.navigationItem];
    
    [self.revealSideViewController setDirectionsToShowBounce: PPRevealSideDirectionLeft | PPRevealSideDirectionRight];
    self.revealSideViewController.delegate = self;
    
    lblNoFriendAround.hidden = NO;
    btnInvite.hidden = YES;
    [Helper setButton:btnInvite Text:@"Invite your friends!" WithFont:SEGOUE_UI FSize:14 TitleColor:[UIColor grayColor] ShadowColor:nil];
    [btnInvite.titleLabel setTextAlignment:NSTextAlignmentCenter];
    btnInvite.titleEdgeInsets = UIEdgeInsetsMake(-6, 15.0, 0.0, 0.0);
    [Helper setToLabel:lblNoFriendAround Text:@"Finding People around you." WithFont:SEGOUE_UI FSize:17 Color:[UIColor blackColor]];
    lblNoFriendAround.textAlignment = NSTextAlignmentCenter;
    
    [imgvw.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [imgvw.layer setBorderWidth: 0.7];
    [mainImageView.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [mainImageView.layer setBorderWidth: 0.7];
    
    if (IS_IPHONE_5) {
        profileImageView = [[RoundedImageView alloc] initWithFrame:CGRectMake(105, 170, 110, 110)];
    }else{
        profileImageView = [[RoundedImageView alloc] initWithFrame:CGRectMake(105, 130, 110, 110)];
    }
    
    profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    profileImageView.clipsToBounds = YES;
    [self.view addSubview:profileImageView];
    
    [profileImageView downloadFromURL:[User currentUser].profile_pic withPlaceholder:[UIImage imageNamed:@"pfImage.png"]];
    
    inAnimation = NO;
    waveLayer=[CALayer layer];
    if (IS_IPHONE_5) {
        waveLayer.frame = CGRectMake(155, 220, 10, 10);
    }else{
        waveLayer.frame = CGRectMake(155, 180, 10, 10);
    }
    waveLayer.borderWidth =0.2;
    waveLayer.cornerRadius =5.0;
    [self.view.layer addSublayer:waveLayer];
    profileImageView.hidden = NO;
    [waveLayer setHidden:NO];
    [self.view bringSubviewToFront:profileImageView];
    
    //self.viewPercentMatch.layer.cornerRadius=40.0f;
    //self.viewPercentMatch.backgroundColor=[UIColor clearColor];
  
    /*
    BOOL isQuestionShow=[[NSUserDefaults standardUserDefaults]boolForKey:@"isQuestionShow"];
    if (!isQuestionShow)
    {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"isQuestionShow"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        QuestionVC *c = [[QuestionVC alloc] initWithNibName:@"QuestionVC" bundle:nil];
        
        UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:c];
        [self.revealSideViewController popViewControllerWithNewCenterController:n
                                                                       animated:YES];
        [self.revealSideViewController setDelegate:c];
        
        PP_RELEASE(c);
        PP_RELEASE(n);
        
        /*
        QuestionVC *vcQue=[[QuestionVC alloc]initWithNibName:@"QuestionVC" bundle:nil];
        [self presentViewController:vcQue animated:YES completion:^{
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"isQuestionShow"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
         */
    //}

    UITapGestureRecognizer *dismissKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeKeyboardFromView)];
    [vwSparkMessage addGestureRecognizer:dismissKeyboard];
    
    [vwAlert.layer setBorderWidth:5.0];
    [vwAlert.layer setBorderColor:[UIColor blackColor].CGColor];
    [vwAlert.layer setCornerRadius:5.0];
    [vwAlert.layer setMasksToBounds:YES];
    
    lblSparkAlertsCounter.layer.cornerRadius = 7.0;
    lblSparkAlertsCounter.layer.masksToBounds = YES;
    [lblSparkAlertsCounter.layer setBorderColor:[UIColor redColor].CGColor];
    [lblSparkAlertsCounter.layer setBorderWidth:1.0];
   
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTokensStatus) name:NOTIFICATION_CREDIT_CHANGED object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendRequestForGetMatches) name:NOTIFICATION_MATCHES_UPDATE object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMessageIcon) name:@"MessageCount" object:nil];
}

-(void) removeKeyboardFromView
{
    [vwSparkMessage endEditing:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [APPDELEGATE addrightButton:self.navigationItem];
    [self callForWebserviceToGetAdminSettings];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTokensStatus) name:NOTIFICATION_CREDIT_CHANGED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendRequestForGetMatches) name:NOTIFICATION_MATCHES_UPDATE object:nil];
    
//       [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_CREDIT_UPDATE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMessageIcon) name:@"MessageCount" object:nil];
    
    
 [APPDELEGATE updatePendingSparkAlertCounter];
    
}

//Method to get Admin Settings
-(void)callForWebserviceToGetAdminSettings
{
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_GET_ADMIN_SETTINGS withParamData:dictParam withBlock:^(id response, NSError *error)
     {
         if (response)
         {
             if ([[response objectForKey:@"errFlag"] intValue]==0)
             {
                 [[AdminSettings currentSetting] setAdminSettingsWithDict:response];
                 [self updateTokensStatus];
             }
         }
     }];
}

-(void)updateTokensStatus
{
    NSLog( @"Free %d Purchased %d",[User currentUser].freeCredits,[User currentUser].purchasedCredits);

    [self updateTokenCounter];
}

-(void)updateTokenCounter
{
    int tokensAvailable = [User currentUser].freeCredits+[User currentUser].purchasedCredits;
    
    NSString *strTotalBal = [NSString stringWithFormat:@"Balance : %d",tokensAvailable];
    
    NSMutableAttributedString *undrlineString = [[NSMutableAttributedString alloc] initWithString:strTotalBal];
    [undrlineString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [undrlineString length])];
    
    [btnSparkBalance setAttributedTitle:undrlineString forState:UIControlStateNormal];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
     [self getLocation];
    PPRevealSideInteractions interContent = PPRevealSideInteractionContentView;
    self.revealSideViewController.panInteractionsWhenClosed = interContent;
    self.revealSideViewController.panInteractionsWhenOpened = interContent;
    
    [self performSelector:@selector(sendRequestForGetMatches) withObject:nil afterDelay:.2];
    
    [self performSelector:@selector(startAnimation) withObject:nil];
    [self performSelector:@selector(preloadLeft) withObject:nil afterDelay:0.1];
    [self performSelector:@selector(preLoadRight) withObject:nil afterDelay:0.3];
}

#pragma mark -
#pragma mark - Nav button methods

-(void)preloadLeft
{
    MenuViewController *menu=[[MenuViewController alloc]initWithNibName:@"MenuViewController" bundle:nil];
    [self.revealSideViewController preloadViewController:menu forSide:PPRevealSideDirectionLeft];
    PP_RELEASE(menu);
}

-(void)preLoadRight
{
    [ChatViewController checkMetches];
    ChatViewController *menu = [[ChatViewController alloc]initWithNibName:@"ChatViewController" bundle:nil];
    [self.revealSideViewController preloadViewController:menu forSide:PPRevealSideDirectionRight];
    PP_RELEASE(menu);
    
    if ([self chatVC]==YES) {
        [[NSUserDefaults standardUserDefaults] rm_setCustomObject:@"1" forKey:@"ChatRedirect"];
        [self setChatVC:NO];
        [APPDELEGATE chatbuttonClicked:[[UIButton alloc] init]];
    }
    
}

#pragma mark -
#pragma mark - requestForGetMatches

-(void)sendRequestForGetMatches
{
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_FINDMATCHES withParamData:paramDict withBlock:^(id response, NSError *error)
    {
        if (response)
        {
            if ([[response objectForKey:@"errFlag"] intValue]==0)
            {
                NSArray *matches = response[@"matches"];
                if ([matches count] > 0)
                {
                    [self performSelectorOnMainThread:@selector(fetchMatchesData:) withObject:matches waitUntilDone:NO];
                }
                else{
                    [Helper setToLabel:lblNoFriendAround Text:@"There's no one new around you." WithFont:SEGOUE_UI FSize:17 Color:[UIColor blackColor]];
                    btnInvite.hidden = NO;
                    lblNoFriendAround = NO;
                    [waveLayer setHidden:YES];
                }
            }
            else{
                [Helper setToLabel:lblNoFriendAround Text:@"There's no one new around you." WithFont:SEGOUE_UI FSize:17 Color:[UIColor blackColor]];
                btnInvite.hidden = NO;
                lblNoFriendAround = NO;
                [waveLayer setHidden:YES];
            }
        }else{
            [Helper setToLabel:lblNoFriendAround Text:@"There's no one new around you." WithFont:SEGOUE_UI FSize:17 Color:[UIColor blackColor]];
            btnInvite.hidden = NO;
            lblNoFriendAround = NO;
            [waveLayer setHidden:YES];
        }
    }];
}

-(void)fetchMatchesData:(NSArray*)matches
{
    myProfileMatches  = [[NSMutableArray alloc] initWithArray:matches];

    if(myProfileMatches.count>0)
    {
        NSMutableDictionary *dictForMutal=[myProfileMatches objectAtIndex:0];
        [TinderFBFQL executeFQlForMutualFriendForId:nil andFriendId:[dictForMutal valueForKey:@"fbId"] andDelegate:self];
        [TinderFBFQL executeFQlForMutualLikesForId:nil andFriendId:[dictForMutal valueForKey:@"fbId"] andDelegate:self];
        
        [self setupMatchesView];
        
        /*
        for (NSDictionary *match in myProfileMatches)
        {
            if ([flStrForObj([match objectForKey:@"pPic"]) length] > 0) {
                [self imageDownloader:match[@"pPic"] forId:match[@"fbId"]];
            }
            else{
                [self imageDownloader:match[@"https://fbcdn-profile-a.akamaihd.net/static-ak/rsrc.php/v2/yL/r/HsTZSDw4avx.gif"] forId:match[@"fbId"]];
            }
        }
         */
        
        
    }
}


-(void)setupMatchesView
{
    self.decision.hidden = YES;
    
    if ([myProfileMatches count] > 0)
    {
        lblNoFriendAround.hidden = YES;
        NSDictionary *match = [myProfileMatches objectAtIndex:0];
        mainImageView.contentMode = UIViewContentModeScaleAspectFill;
        mainImageView.clipsToBounds = YES;
        
        //[mainImageView setShowActivity:YES];
        [mainImageView downloadFromURL:[match valueForKey:@"pPic"] withPlaceholder:[UIImage imageNamed:@"pfImage.png"]];
        [mainImageView setBackgroundColor:[UIColor whiteColor]];
        //[mainImageView setPlaceholderImage:[UIImage imageNamed:@"pfImage.png"]];
        
        
        [Helper setToLabel:nameLabel Text:[NSString stringWithFormat:@"%@, %@", match[@"firstName"], match[@"age"]] WithFont:HELVETICALTSTD_ROMAN FSize:16 Color: WHITE_COLOR] ;
        
        NSString *strMFC=[NSString stringWithFormat:@"%@",match[@"mutualFriendcout"]];
        NSString *strMLC=[NSString stringWithFormat:@"%@",match[@"mutualLikecount"]];
        
        [Helper setToLabel:commonFriends Text:strMFC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color:[UIColor lightGrayColor]];
        [Helper setToLabel:commonInterest Text:strMLC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: [UIColor lightGrayColor]];
        
        [Helper setToLabel:picsCount Text:[NSString stringWithFormat:@"%@", match[@"imgCnt"]] WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: WHITE_COLOR] ;
        picsCount.text=match[@"images"];
        
        self.lblPercentMatch.text=[NSString stringWithFormat:@"%@%%",[match objectForKey:@"matchPercentage"]];
        
        [waveLayer setHidden:YES];
        [profileImageView setHidden:YES];
        [btnInvite setHidden:YES];
        [lblNoFriendAround setHidden:YES];
        
        
        [matchesView setHidden:NO];
        [btnInvite setHidden:YES];
        visibleView1.hidden = NO;
        visibleView1.center = original;
        [visibleView1 setFrame:visibleView2.frame];
        
        if ([myProfileMatches count] > 1)
        {
            visibleView2.hidden = NO;
            imgvw.contentMode = UIViewContentModeScaleAspectFill;
            imgvw.clipsToBounds = YES;
            NSDictionary *match1 = [myProfileMatches objectAtIndex:1];
            
           // [imgvw setShowActivity:YES];
           // [imgvw setImageURL:[NSURL URLWithString:[match1 valueForKey:@"pPic"]]];
            
            if([match1[@"verify"] intValue] == 1)
                self.imgVerified2.image = [UIImage imageNamed:@"bg_image_overlay_green"];
            else
                self.imgVerified2.image = [UIImage imageNamed:@"bg_image_overlay_gray"];
            
            [imgvw downloadFromURL:[match1 valueForKey:@"pPic"] withPlaceholder:[UIImage imageNamed:@"pfImage.png"]];
            [imgvw setBackgroundColor:[UIColor whiteColor]];
           // [imgvw setPlaceholderImage:[UIImage imageNamed:@"pfImage.png"]];
            
            [Helper setToLabel:nameLabel2 Text:[NSString stringWithFormat:@"%@, %@", match1[@"firstName"], match1[@"age"]] WithFont:HELVETICALTSTD_ROMAN FSize:16 Color: BLACK_COLOR] ;
            
            
            NSString *strMFC=[NSString stringWithFormat:@"%@",match1[@"mutualFriendcout"]];
            NSString *strMLC=[NSString stringWithFormat:@"%@",match1[@"mutualLikecount"]];
            
            [Helper setToLabel:lblMutualFriend2 Text:strMFC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: [UIColor lightGrayColor]];
            [Helper setToLabel:lblMutualLikes2 Text:strMLC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: [UIColor lightGrayColor]];
            
            [Helper setToLabel:lblNoOfImage Text:[NSString stringWithFormat:@"%@", match1[@"imgCnt"]] WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: WHITE_COLOR] ;
            lblNoOfImage.text=match1[@"images"];
            
           
        }
        else
        {
            visibleView2.hidden = YES;
        }
    }
    else
    {
        [matchesView setHidden:YES];
        [btnInvite setHidden:NO];
        [waveLayer setHidden:NO];
        [profileImageView setHidden:NO];
       
    }
}


-(void)imageDownloader:(NSString*)url forId:(NSString*)fbid
{
    
    NSString *tmpDir = NSTemporaryDirectory();
    
    [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:url]
                                                        options:0
                                                       progress:^(NSUInteger receivedSize, long long expectedSize)
     {
         // progression tracking code
     }
                                                      completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
     {
         if (image && finished)
         {
             NSData *data = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0)];
             NSString *savePath = [tmpDir stringByAppendingPathComponent:fbid];
             [data writeToFile:[savePath stringByAppendingPathExtension:@"jpg"] atomically:YES];
             [self performSelectorOnMainThread:@selector(doneDownloadingImageFor:) withObject:fbid waitUntilDone:NO];
         }
     }];
}

-(void)doneDownloadingImageFor:(NSString*)fbid
{
    static NSInteger count = 0;
    count++;
    if (count <= [myProfileMatches count])
    {
        lblNoFriendAround.hidden = YES;
        NSDictionary *match = [myProfileMatches objectAtIndex:0];
        mainImageView.contentMode = UIViewContentModeScaleAspectFill;
        mainImageView.clipsToBounds = YES;
        
        NSString *savePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:match[@"fbId"]] stringByAppendingPathExtension:@"jpg"];
        
        mainImageView.image = [UIImage imageWithContentsOfFile:savePath];
        [Helper setToLabel:nameLabel Text:[NSString stringWithFormat:@"%@, %@", match[@"firstName"], match[@"age"]] WithFont:HELVETICALTSTD_ROMAN FSize:13 Color: WHITE_COLOR] ;
        
        NSString *strMFC=[NSString stringWithFormat:@"%@",match[@"mutualFriendcout"]];
        NSString *strMLC=[NSString stringWithFormat:@"%@",match[@"mutualLikecount"]];
        
        [Helper setToLabel:commonFriends Text:strMFC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: WHITE_COLOR];
        [Helper setToLabel:commonInterest Text:strMLC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: WHITE_COLOR];
        
        [Helper setToLabel:picsCount Text:[NSString stringWithFormat:@"%@", match[@"imgCnt"]] WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: WHITE_COLOR] ;
        picsCount.text=match[@"images"];
        
        self.lblPercentMatch.text=[NSString stringWithFormat:@"%@%%",[match objectForKey:@"matchPercentage"]];
        
        [waveLayer setHidden:YES];
        [profileImageView setHidden:YES];
        [btnInvite setHidden:YES];
        [lblNoFriendAround setHidden:YES];
        
        
        [matchesView setHidden:NO];
        [btnInvite setHidden:YES];
        
        
        original = visibleView1.center;
        visibleView1.hidden = NO;
        
        if (count >= 1 && [myProfileMatches count]>1)
        {
            visibleView2.hidden = NO;
            imgvw.contentMode = UIViewContentModeScaleAspectFill;
            imgvw.clipsToBounds = YES;
            NSDictionary *match1 = [myProfileMatches objectAtIndex:1];
            NSString *savePath1 = [[NSTemporaryDirectory() stringByAppendingPathComponent:match1[@"fbId"]] stringByAppendingPathExtension:@"jpg"];
            
            imgvw.image = [UIImage imageWithContentsOfFile:savePath1];
            
            [Helper setToLabel:nameLabel2 Text:[NSString stringWithFormat:@"%@, %@", match1[@"firstName"], match1[@"age"]] WithFont:HELVETICALTSTD_ROMAN FSize:13 Color: WHITE_COLOR] ;
          
            NSString *strMFC=[NSString stringWithFormat:@"%@",match1[@"mutualFriendcout"]];
            NSString *strMLC=[NSString stringWithFormat:@"%@",match1[@"mutualLikecount"]];
            
            [Helper setToLabel:lblMutualFriend2 Text:strMFC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: WHITE_COLOR];
            [Helper setToLabel:lblMutualLikes2 Text:strMLC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: WHITE_COLOR];
            
            [Helper setToLabel:lblNoOfImage Text:[NSString stringWithFormat:@"%@", match1[@"imgCnt"]] WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: WHITE_COLOR] ;
            lblNoOfImage.text=match1[@"images"];

        }
        else {
            visibleView2.hidden = YES;
        }
        count = 0;
    }
}

#pragma mark -
#pragma mark - actionForNopeAndLike

-(IBAction)pan:(UIPanGestureRecognizer*)gs
{
    CGPoint curLoc = visibleView1.center;
    CGPoint translation = [gs translationInView:gs.view.superview];
    float diff = 0;
    
    if (gs.state == UIGestureRecognizerStateBegan) {
    } else if (gs.state == UIGestureRecognizerStateChanged) {
        if (curLoc.x < original.x) {
            diff = original.x - curLoc.x;
            if (diff > 50)
                [nope setAlpha:1];
            else {
                [nope setAlpha:diff/50];
            }
            [liked setHidden:YES];
            [nope setHidden:NO];
            
        }
        else if (curLoc.x > original.x) {
            diff = curLoc.x - original.x;
            if (diff > 50)
                [liked setAlpha:1];
            else {
                [liked setAlpha:diff/50];
            }
            
            [liked setHidden:NO];
            [nope setHidden:YES];
        }
        
        gs.view.center = CGPointMake(gs.view.center.x + translation.x,
                                     gs.view.center.y + translation.y);
        [gs setTranslation:CGPointMake(0, 0) inView:self.view];
    }
    else if (gs.state == UIGestureRecognizerStateEnded)
    {
        if (![nope isHidden] || ![liked isHidden])
        {
            [nope setHidden:YES];
            [liked setHidden:YES];
            [visibleView1 setHidden:YES];
            visibleView1.center = original;
            visibleView1.frame = visibleView2.frame;
            [visibleView1 setHidden:NO];
            diff = curLoc.x - original.x;
            
            if (abs(diff) > 50)
            {
                mainImageView.image = nil;
                mainImageView.image = imgvw.image;
                
                UIButton *btn = nil;
                if (diff > 0) {
                    btn = self.nopeBtn;
                }
                else {
                    btn = self.likedBtn;
                }
//                [btn setTag:1000];
                self.decision.text = @"";
                [self setAnimationFlag:YES];
                [self performSelector:@selector(likeDislikeButtonAction:) withObject:btn];
            }
        }
    }
}

-(void)updateNextProfileView
{
    self.decision.hidden = YES;
    [myProfileMatches removeObjectAtIndex:0];
    if(myProfileMatches.count>0)
    {
        NSMutableDictionary *dictForMutal=[myProfileMatches objectAtIndex:0];
        [TinderFBFQL executeFQlForMutualFriendForId:nil andFriendId:[dictForMutal valueForKey:@"fbId"] andDelegate:self];
        [TinderFBFQL executeFQlForMutualLikesForId:nil andFriendId:[dictForMutal valueForKey:@"fbId"] andDelegate:self];
        
    }
    [self setupMatchesView];
  /*
    self.decision.hidden = YES;
    [myProfileMatches removeObjectAtIndex:0];
    
    if(myProfileMatches.count>0)
    {
        NSMutableDictionary *dictForMutal=[myProfileMatches objectAtIndex:0];
        [TinderFBFQL executeFQlForMutualFriendForId:nil andFriendId:[dictForMutal valueForKey:@"fbId"] andDelegate:self];
        [TinderFBFQL executeFQlForMutualLikesForId:nil andFriendId:[dictForMutal valueForKey:@"fbId"] andDelegate:self];
    }
    if ([myProfileMatches count] > 0)
    {
        NSDictionary *match = [myProfileMatches objectAtIndex:0];
        
        NSString *savePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:match[@"fbId"]] stringByAppendingPathExtension:@"jpg"];
        
        mainImageView.image = [UIImage imageWithContentsOfFile:savePath];
        
        [nameLabel setText:[NSString stringWithFormat:@"%@, %@", match[@"firstName"], match[@"age"]]];
        
        [waveLayer setHidden:YES];
        [profileImageView setHidden:YES];
        
        [matchesView setHidden:NO];
        
        original = visibleView1.center;
        
        if ([myProfileMatches count] > 1)
        {
            visibleView2.hidden = NO;
            
            NSDictionary *match1 = [myProfileMatches objectAtIndex:1];
            NSString *savePath1 = [[NSTemporaryDirectory() stringByAppendingPathComponent:match1[@"fbId"]] stringByAppendingPathExtension:@"jpg"];
            
            [nameLabel2 setText:[NSString stringWithFormat:@"%@, %@", match1[@"firstName"], match1[@"age"]]];
            
            imgvw.image = [UIImage imageWithContentsOfFile:savePath1];
        }
        else
        {
            visibleView2.hidden = YES;
        }
    }
    else
    {
        [matchesView setHidden:YES];
        [btnInvite setHidden:NO];
        [waveLayer setHidden:NO];
        [profileImageView setHidden:NO];
        [self performSelector:@selector(startAnimation) withObject:nil];
    }
     */
}

-(IBAction)likeDislikeButtonAction:(UIButton*)sender
{
    NSDictionary *profile = [myProfileMatches objectAtIndex:0];
    
    if (sender.tag == 300) { // Like
        [self performSelector:@selector(sendInviteAction:) withObject:@{@"fbid": profile[@"fbId"], @"action": [NSNumber numberWithInt:1]}];
    }
    else if (sender.tag == 200) { // Dislike
        [self performSelector:@selector(sendInviteAction:) withObject:@{@"fbid": profile[@"fbId"], @"action": [NSNumber numberWithInt:2]}];
    }
    
    if (self.decision.text.length > 0) {
        self.decision.hidden = NO;
        [self.view bringSubviewToFront:self.decision];
        if (sender.tag == 300) {
            self.decision.text = @"Liked";
            self.decision.textColor = [UIColor colorWithRed:0.001 green:0.548 blue:0.002 alpha:1.000];
        }
        else {
            self.decision.text = @"No";
            self.decision.textColor = [UIColor redColor];
        }
        
        //        [self performSelector:@selector(updateNextProfileView) withObject:nil afterDelay:0.5];
    }
    else {
        self.decision.text = @"Liked";
        //        [self performSelector:@selector(updateNextProfileView) withObject:nil afterDelay:0];
    }
    if (self.animationFlag == YES) {
        [self setAnimationFlag:NO];
        [self performSelector:@selector(updateNextProfileView) withObject:nil afterDelay:0];
    }else{
        [UIView animateWithDuration:1.2 animations:^{
            CGRect frame = [visibleView1 frame];
            if ( [self.decision.text isEqualToString:@"No"]) {
                frame.origin.x = -(frame.size.width + 10);
                frame.origin.y = frame.origin.y + 80;
            }else{
                frame.origin.x = self.view.frame.size.width + 50;
                frame.origin.y = frame.origin.y + 80;
            }
            [visibleView1 setFrame:frame];
        } completion:^(BOOL finished) {
            [self performSelector:@selector(updateNextProfileView) withObject:nil afterDelay:0];
        }];
    }
}

-(void)loadImageForSharedFrnd :(NSArray*)arrayFrnd
{
    commonFriends.text=[NSString stringWithFormat:@"%d",arrayFrnd.count];
}

-(void)loadImageForSharedIntrest:(NSArray*)arrayIntrst
{
    commonInterest.text=[NSString stringWithFormat:@"%d",arrayIntrst.count];
}

-(IBAction)showUserProfile:(id)sender
{
    if ([myProfileMatches count]==0)
    {
        return;
    }
    ProfileVC *vc=[[ProfileVC alloc]initWithNibName:@"ProfileVC" bundle:nil];
    
    NSDictionary *dict=[myProfileMatches objectAtIndex:0];
    User *user=[[User alloc]init];
    user.fbid=[dict objectForKey:@"fbId"];
    user.first_name=[dict objectForKey:@"firstName"];
    user.profile_pic=[dict objectForKey:@"pPic"];
    vc.user=user;
    [self.navigationController pushViewController:vc animated:NO];

}

-(void)donePreviewing:(NSNumber*)val
{
    if ([val integerValue] == 0) {
        return;
    }
    NSDictionary *profile = [myProfileMatches objectAtIndex:0];
    [self performSelector:@selector(sendInviteAction:) withObject:@{@"fbid": profile[@"fbId"], @"action": val}];
    [self performSelector:@selector(updateNextProfileView) withObject:nil afterDelay:0];
}

-(void)sendInviteAction:(NSDictionary*)params
{
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setObject:params[@"fbid"]  forKey:PARAM_ENT_INVITEE_FBID];
    [paramDict setObject:flStrForObj(params[@"action"])  forKey:PARAM_ENT_USER_ACTION];
    [paramDict setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    
    WebServiceHandler *handler = [[WebServiceHandler alloc] init];
    handler.requestType = eParseKey;
    NSMutableURLRequest * request = [Service parseInviteAction:paramDict];
    [handler placeWebserviceRequestWithString:request Target:self Selector:@selector(inviteActionResponse:)];
}

-(void)inviteActionResponse:(NSDictionary*)response
{
    NSDictionary * dict = [response objectForKey:@"ItemsList"];
    
    if ([[dict objectForKey:@"errFlag"]integerValue] ==0 &&[[dict objectForKey:@"errNum"]integerValue] ==55)
    {
        viewItsMatched.hidden = NO;
        [[UserDefaultHelper sharedObject]setItsMatch:[NSMutableDictionary dictionaryWithDictionary:dict]];
        
        [self.view bringSubviewToFront:viewItsMatched];
        
        [Helper setToLabel:lblItsMatchedSubText Text:[NSString stringWithFormat:@"You and %@ have liked each other.",dict[@"uName"]] WithFont:HELVETICALTSTD_LIGHT FSize:14 Color:[UIColor darkGrayColor]];
        
        lblItsMatchedSubText.textAlignment= NSTextAlignmentCenter;
        
        RoundedImageView *userImg  = [[RoundedImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [userImg downloadFromURL:[User currentUser].profile_pic withPlaceholder:nil];
        
        RoundedImageView *FriendImg  = [[RoundedImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
      
        UIActivityIndicatorView *activityIndicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(50/2-20/2, 46/2-20/2, 20, 20)];
        [FriendImg addSubview:activityIndicator];
        
        activityIndicator.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
        [activityIndicator startAnimating];
        
        FriendImg.image =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[Helper removeWhiteSpaceFromURL:dict[@"pPic"]]]]];
        [activityIndicator stopAnimating];
        
        [userOneImageView addSubview:userImg];
        [userTwoImageView addSubview:FriendImg];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    else{
        viewItsMatched.hidden = YES;
        lblNoFriendAround.hidden = NO;
        [Helper setToLabel:lblNoFriendAround Text:@"There's no one new around you." WithFont:SEGOUE_UI FSize:17 Color:[UIColor blackColor]];
        btnInvite.hidden = NO;
    }
    if (visibleView1.hidden == YES) {
        [Helper setToLabel:lblNoFriendAround Text:@"There's no one new around you." WithFont:SEGOUE_UI FSize:17 Color:[UIColor blackColor]];
        btnInvite.hidden = NO;
        lblNoFriendAround .hidden= NO;
        visibleView2.hidden = NO;
    }
}

-(void)getLocation
{
    [[LocationHelper sharedObject]startLocationUpdatingWithBlock:^(CLLocation *newLocation, CLLocation *oldLocation, NSError *error) {
        if (!error) {
            [[LocationHelper sharedObject]stopLocationUpdating];
            [super updateLocation];
        }
    }];
}

-(IBAction)btnActionForItsMatchedView :(id)sender
{
 
    UIButton * btn =(UIButton*)sender;
    if (btn.tag ==100) {
        viewItsMatched.hidden = YES;
    }
    else
    {
        /*
        ProgressIndicator * pi = [ProgressIndicator sharedInstance];
        [pi showPIOnView:viewItsMatched withMessage:@"Loading.."];
        
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSMutableDictionary * dict=[[UserDefaultHelper sharedObject] itsMatch];
        
        NSString *imgpath = [NSString stringWithFormat:@"%@/image1.jpg",docDir];
        NSURL *url = [NSURL URLWithString:[Helper removeWhiteSpaceFromURL:dict[@"pPic"]]];
        
        [self performSelectorOnMainThread:@selector(pushToChatViewController:) withObject:dict waitUntilDone:YES];
        
        
        [SDWebImageDownloader.sharedDownloader downloadImageWithURL:url
                                                            options:0
                                                           progress:^(NSUInteger receivedSize, long long expectedSize)
         {
             // progression tracking code
         }
                                                          completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
         {
             if (image && finished)
             {
                 NSData* theData  = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0)];
                 BOOL isWrite =[theData writeToFile:imgpath atomically:YES];
                 if (isWrite ==YES)
                 {
                     [[UserDefaultHelper sharedObject]setPath:imgpath];
                     [self performSelectorOnMainThread:@selector(pushToChatViewController:) withObject:dict waitUntilDone:YES];
                 }
             }
         }];
         
         */
        viewItsMatched.hidden = YES;
        NSMutableDictionary * dict=[[UserDefaultHelper sharedObject] itsMatch];
//        [self performSelectorOnMainThread:@selector(pushToChatViewController:) withObject:dict waitUntilDone:YES];
//        [self pushToChatViewController:dict];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationName" object:dict];
        
    }
}

-(void)pushToChatViewController :(NSDictionary *)dict
{
    
    NSMutableDictionary * dictChat = [[NSMutableDictionary alloc]init];
    ChattingViewController *vc = [[ChattingViewController alloc] init];
    NSString * strPath =[[UserDefaultHelper sharedObject] path];
//    User *user = [[User alloc] init];
//    vc.userFriend = user;
    vc.friendFbId = dict[@"uFbId"];
    vc.status = @"5";
    vc.ChatPersonNane =dict[@"uName"];
    //vc.matchedUserProfileImagePath = strPath;
    [dictChat setValue:dict[@"uFbId"] forKey:@"fbId"];
    [dictChat setValue:@"5" forKey:@"status"];
    [dictChat setValue:dict[@"uName"] forKey:@"fName"];
    [dictChat setValue:strPath forKey:@"proficePic"];
    vc.dictUser = dictChat;
    
//    UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:vc];
//    [self.revealSideViewController popViewControllerWithNewCenterController:n animated:YES];
    
//    ChattingViewController *vc = [[ChattingViewController alloc] init];
//    vc.userFriend=user;
//    vc.friendFbId = user.fbid;
//    vc.status = @"";
//    vc.ChatPersonNane =user.first_name;
//    vc.matchedUserProfileImagePath = user.profile_pic;
//    [dict setValue:user.fbid forKey:@"fbId"];
//    [dict setValue:@"" forKey:@"status"];
//    [dict setValue:user.first_name forKey:@"fName"];
//    [dict setValue:user.profile_pic forKey:@"proficePic"];
//    vc.dictUser = dict;
//    UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:vc];
//    [self.revealSideViewController popViewControllerWithNewCenterController:n
//                                                                   animated:YES];
    [self.revealSideViewController.navigationController pushViewController:vc animated:YES];
}

#pragma mark -
#pragma mark - PPRevealSideViewControllerDelegate

- (BOOL) pprevealSideViewController:(PPRevealSideViewController *)controller shouldDeactivateGesture:(UIGestureRecognizer*)gesture forView:(UIView*)view
{
    if ([view isEqual:matchesView] ||
        [view isEqual:mainImageView] ||
        [view.superview isEqual:visibleView2] ||
        [view.superview isEqual:visibleView1] ||
        [view isEqual:visibleView1] ||
        [view isEqual:visibleView2] ||
        [view.superview isEqual:matchesView])
    {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark - Animation Methods

-(void)startAnimation
{
    if ([waveLayer isHidden] || ![self.view window] || inAnimation == YES)
    {
        return;
    }
    inAnimation = YES;
    [self waveAnimation:waveLayer];
}

-(void)waveAnimation:(CALayer*)aLayer
{
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.duration = 3;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transformAnimation.removedOnCompletion = YES;
    transformAnimation.fillMode = kCAFillModeRemoved;
    [aLayer setTransform:CATransform3DMakeScale( 10, 10, 1.0)];
    [transformAnimation setDelegate:self];
    
    CATransform3D xform = CATransform3DIdentity;
    xform = CATransform3DScale(xform, 40, 40, 1.0);
    //xform = CATransform3DTranslate(xform, 60, -60, 0);
    transformAnimation.toValue = [NSValue valueWithCATransform3D:xform];
    [aLayer addAnimation:transformAnimation forKey:@"transformAnimation"];
    
    
    UIColor *fromColor = [UIColor colorWithRed:255 green:120 blue:0 alpha:1];
    UIColor *toColor = [UIColor colorWithRed:255 green:120 blue:0 alpha:0.1];
    CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    colorAnimation.duration = 3;
    colorAnimation.fromValue = (id)fromColor.CGColor;
    colorAnimation.toValue = (id)toColor.CGColor;
    
    [aLayer addAnimation:colorAnimation forKey:@"colorAnimationBG"];
    
    
    UIColor *fromColor1 = [UIColor colorWithRed:0 green:255 blue:0 alpha:1];
    UIColor *toColor1 = [UIColor colorWithRed:0 green:255 blue:0 alpha:0.1];
    CABasicAnimation *colorAnimation1 = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    colorAnimation1.duration = 3;
    colorAnimation1.fromValue = (id)fromColor1.CGColor;
    colorAnimation1.toValue = (id)toColor1.CGColor;
    
    [aLayer addAnimation:colorAnimation1 forKey:@"colorAnimation"];
}

- (void)animationDidStart:(CAAnimation *)anim
{
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    inAnimation = NO;
    [self performSelectorInBackground:@selector(startAnimation) withObject:nil];
}

#pragma mark -
#pragma mark - Mail Methods

-(IBAction)openMail :(id)sender
{
    
     NSString *strMsg = [NSString stringWithFormat:@"%@",@"I am using SureFire Match App! Did you know you can get PAID using this APP. Check it out @ https://play.google.com/store/apps/details?id=com.surefirematch&hl=en<br>Or visit<br>http://surefirematch.com"];
//    [super sendMailSubject:@"SureFire App!" toRecipents:[NSArray arrayWithObject:@""] withMessage:strMsg];
    
    
    if([MFMessageComposeViewController canSendText]) {

        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        messageController.messageComposeDelegate = self;
//        [messageController setRecipients:recipents];
        [messageController setBody:strMsg];
        
        // Present message view controller on screen
        [self presentViewController:messageController animated:YES completion:nil];
    }
    
   
    
    
 
}

#pragma mark -
#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        PurchaseTokenVC *purchaseVC = [[PurchaseTokenVC alloc]init];
        [self.navigationController pushViewController:purchaseVC animated:YES];
    }
}

- (IBAction)btnBalanceTapped:(id)sender
{
    UserCreditsVC *c = [[UserCreditsVC alloc] initWithNibName:@"UserCreditsVC" bundle:nil];
    
    UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:c];
    [[APPDELEGATE revealSideViewController] setDelegate:c];
    [[APPDELEGATE revealSideViewController] popViewControllerWithNewCenterController:n
                                                                   animated:YES];
    
    
    PP_RELEASE(c);
    PP_RELEASE(n);
}

- (IBAction)btnPendingSparkRequestTapped:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"newMessage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NotificationsVC *c = [[NotificationsVC alloc] initWithNibName:@"NotificationsVC" bundle:nil];
    [[APPDELEGATE revealSideViewController] setDelegate:c];
    UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:c];
    [[APPDELEGATE revealSideViewController] popViewControllerWithNewCenterController:n
                                                                   animated:YES];
    
    
    PP_RELEASE(c);
    PP_RELEASE(n);
}

- (IBAction)btnOkOnAlertSubviewTapped:(id)sender
{
    if (isCheckedForDontShowAlert)
    {
        [USERDEFAULT setBool:YES forKey:@"DontShowAlertForSpark"];
        [USERDEFAULT synchronize];
    }
    
    [UIView animateWithDuration:0.33 animations:^{
        [vwAlert setHidden:YES];
        [vwTypeMsgPopup setHidden:NO];
    }];

}

- (IBAction)btnCheckMarkDontShowTapped:(UIButton *)sender
{

    if (![sender isSelected])
    {
        [sender setSelected:YES];
        isCheckedForDontShowAlert = YES;
    }
    else
    {
        [sender setSelected:NO];
        isCheckedForDontShowAlert = NO;
    }
}

- (IBAction)btnSendSparkTapped:(UIButton *)sender
{
    lblSparkAlert.text = [NSString stringWithFormat:@"You will be charged %@ sparks to send your profile.",[[AdminSettings currentSetting]requestSendingCredit]];
    
    [txtSparkMSg setPlaceholder:@"Message..."];
    [txtSparkMSg setText:nil];
    
    
    [self.navigationController setNavigationBarHidden:YES];
  
    
    [UIView animateWithDuration:0.33 animations:^{
       
        [vwSparkMessage setFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height+44)];
        [self.view addSubview:vwSparkMessage];
    }];
    
    BOOL dontShowAlert = [USERDEFAULT boolForKey:@"DontShowAlertForSpark"];
    if (!dontShowAlert)
    {
        [vwAlert setHidden:NO];
        [vwTypeMsgPopup setHidden:YES];
        
    }
    else
    {
        [vwAlert setHidden:YES];
        [vwTypeMsgPopup setHidden:NO];
    }
}

- (IBAction)btnSendSparkWithMsgTapped:(id)sender
{
    [UIView animateWithDuration:0.33 animations:^{
        [vwSparkMessage removeFromSuperview];
    }];
    [self callForWebserviceToSendSpark];
    
    [self.navigationController setNavigationBarHidden:NO];
   
}

- (IBAction)btnCancelTapped:(id)sender
{
    [UIView animateWithDuration:0.33 animations:^{
        [vwSparkMessage removeFromSuperview];
    }];
    [self.navigationController setNavigationBarHidden:NO];
}

//Method to Send Push Alert
-(void)callForWebserviceToSendSpark
{
    int totalUserCredits = [User currentUser].freeCredits+[User currentUser].purchasedCredits;
    int creditRequiredToSendAlert = [[AdminSettings currentSetting].requestSendingCredit integerValue];
    
    if (totalUserCredits >= creditRequiredToSendAlert)
    {
        NSDictionary *profile = [myProfileMatches objectAtIndex:0];
        
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
        [dictParam setObject:[[User currentUser] fbid] forKey:PARAM_ENT_SENDER_USER_ID];
        [dictParam setObject:profile[@"fbId"] forKey:PARAM_ENT_RECEIVER_USER_ID];
        [dictParam setObject:txtSparkMSg.text forKey:@"message"];
        
        //[[ProgressIndicator sharedInstance]showPIOnView:vwTokens withMessage:nil];
        
        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
        NSDictionary * dictUser1 =[ud objectForKey:UD_FB_USER_DETAIL];
        
        MessageTable *msgTbl=(MessageTable *)[[DBHelper sharedObject]createObjectForEntity:ENTITY_MESSAGETABLE];
        msgTbl.message=txtSparkMSg.text;
        msgTbl.fId=[[User currentUser] fbid];
        msgTbl.name=[dictUser1 objectForKey:FACEBOOK_FIRSTNAME];
        msgTbl.uniqueId=[NSString stringWithFormat:@"%@%@",[[User currentUser] fbid],profile[@"fbId"]];
        msgTbl.messageDate=[Helper getCurrentTime];
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
        msgTbl.date=[NSNumber numberWithDouble:interval];
        
        msgTbl.senderId=[NSNumber numberWithLongLong:[[[User currentUser] fbid] longLongValue]];
        msgTbl.receiverId=[NSNumber numberWithLongLong:[profile[@"fbId"] longLongValue]];
        [[DBHelper sharedObject]saveContext];
        
        
        AFNHelper *afn=[[AFNHelper alloc]init];
        [afn getDataFromPath:METHOD_SEND_SPARK withParamData:dictParam withBlock:^(id response, NSError *error)
         {
             //[[ProgressIndicator sharedInstance]hideProgressIndicator];
             if (response)
             {
                 if ([[response objectForKey:@"errFlag"] intValue]==0)
                 {
                     [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_CREDIT_UPDATE object:nil];
                     Show_AlertView(@"Success", @"Spark sent Succesfully");
                    [self performSelector:@selector(updateNextProfileView) withObject:nil afterDelay:0];
                 }
                 else
                 {
                     Show_AlertView(@"Failure", [response objectForKey:@"error"]);
                 }
             }
         }];
    }
    else
    {
        Show_AlertView_NO_YES(@"Notice",@"You Don't have enough credits to send spark ,Will you like to purchase Credits?",self);
    }
}


- (CGFloat) getWidthOfString: (NSString *) string forSize: (CGSize) size{
    
    CGSize stringSize = [string sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    // NSLog(@"stringSize = %@", NSStringFromCGSize(stringSize));
    return stringSize.width;
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
