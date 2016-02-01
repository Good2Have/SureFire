//
//  LoginViewController.m
//  Tinder
//
//  Created by Rahul Sharma on 24/11/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import "LoginViewController.h"
#import "TinderAppDelegate.h"
#import "Helper.h"
#import "ProgressIndicator.h"
#import "Service.h"
#import "LocationHelper.h"
#import "LoginInfoVC.h"
#import "QuestionVC.h"

@interface LoginViewController ()

@property (nonatomic ,strong) NSMutableDictionary *paramDict;
@end

@implementation LoginViewController

@synthesize paramDict;


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

#pragma mark -
#pragma mark - ViewLife Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    [self getLocation];
    
    arrImages=[[NSMutableArray alloc]init];
    
    self.scrImages.delegate = self;
    [self.scrImages setPagingEnabled:YES];
    [self.scrImages setScrollEnabled:YES];
    
    /* Configure Help screens */
    [self setHelpScreens];
    
    /*Make custom Info and Facebook Buttons*/
    [Helper setButton:self.btnInfo Text:@"Privacy Policy" WithFont:SEGOUE_UI FSize:10 TitleColor:[UIColor darkGrayColor] ShadowColor:nil];
    
    if ([[UserDefaultHelper sharedObject] facebookToken]){
        [self onClickbtnFBLogin:nil];
    }
    
    if ([[UserDefaultHelper sharedObject]facebookUserDetail]){
        [self onClickbtnFBLogin:nil];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    PPRevealSideInteractions interContent = PPRevealSideInteractionNone;
    self.revealSideViewController.panInteractionsWhenClosed = interContent;
    self.revealSideViewController.panInteractionsWhenOpened = interContent;
}

#pragma mark -
#pragma mark - Methods

-(void)setHelpScreens
{
//    if (IS_iPhone5)
//    {
//        [arrImages addObject:[UIImage imageNamed:@"background_screen_three_vt_txt.png"]];
//        [arrImages addObject:[UIImage imageNamed:@"background_screen_one_vt_txt.png"]];
//        [arrImages addObject:[UIImage imageNamed:@"background_screen_two_vt_screen.png"]];
//    }
//    else
//    {
//        [arrImages addObject:[UIImage imageNamed:@"profile_signup_screen.png"]];
//        [arrImages addObject:[UIImage imageNamed:@"itamactch_signup_screen.png"]];
//        [arrImages addObject:[UIImage imageNamed:@"chat_signup_screen.png"]];
//    }
    [arrImages addObject:[UIImage imageNamed:@"surefire_1.jpg"]];
    [arrImages addObject:[UIImage imageNamed:@"surefire_2.jpg"]];
    [arrImages addObject:[UIImage imageNamed:@"surefire_3.jpg"]];
    [arrImages addObject:[UIImage imageNamed:@"surefire_4.jpg"]];
    [arrImages addObject:[UIImage imageNamed:@"surefire_5.jpg"]];
    
    self.scrImages.contentSize = CGSizeMake(self.scrImages.frame.size.width * arrImages.count, self.scrImages.frame.size.height);
    
    [self performSelector:@selector(setScrollViewForImage) withObject:nil afterDelay:0.3];
    
    self.pageControl.pageIndicatorTintColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"slider_indicator_off.png"]];
    self.pageControl.currentPageIndicatorTintColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"slider_indicator_on.png"]];
}

-(void)setScrollViewForImage
{
    for (int i = 0; i < arrImages.count; i++)
    {
        CGRect frame;
        frame.origin.x = self.scrImages.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = self.scrImages.frame.size;
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:frame];
        imgView.image = [arrImages objectAtIndex:i];
        [imgView setContentMode:UIViewContentModeScaleAspectFit];
        [self.scrImages addSubview:imgView];
    }
}

#pragma mark -
#pragma mark - Actions

-(IBAction)changePage:(id)sender
{
    int page = self.pageControl.currentPage;
    CGRect frame = self.scrImages.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrImages scrollRectToVisible:frame animated:YES];
}

-(IBAction)onClickbtnInfo:(id)sender
{
    LoginInfoVC *vc=[[LoginInfoVC alloc]initWithNibName:@"LoginInfoVC" bundle:nil];
    vc.parent=self;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

-(IBAction)onClickbtnFBLogin:(id)sender
{
    if ([[UserDefaultHelper sharedObject]facebookUserDetail])
    {
        [super updateLocation];
        [self showHomeScreen];
    }
    else
    {
        if ([FacebookUtility sharedObject].session.state!=FBSessionStateOpen)
        {
            [[FacebookUtility sharedObject]getFBToken];
        }
        
        if ([[FacebookUtility sharedObject]isLogin])
        {
            [self getFacebookUserDetails];
        }
        else
        {
            [[FacebookUtility sharedObject]loginInFacebook:^(BOOL success, NSError *error)
             {
                 if (success)
                 {
                     if ([FacebookUtility sharedObject].session.state==FBSessionStateOpen)
                     {
                         [self getFacebookUserDetails];
                     }
                 }
                 else
                 {
                     UIAlertView *alertView = [[UIAlertView alloc]
                                               initWithTitle:@"Error"
                                               message:error.localizedDescription
                                               delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
                     [alertView show];
                 }
             }];
        }
        /*NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
        NSDate * currentDate = [NSDate date];
        NSDateComponents * comps = [[NSDateComponents alloc] init];
        [comps setYear: -18];
        NSDate * minDate = [gregorian dateByAddingComponents: comps toDate: currentDate options: 0];
       
        [comps setYear: -100];
         NSDate * maxDate = [gregorian dateByAddingComponents: comps toDate: currentDate options: 0];
        
        self.picDate.minimumDate = minDate;
        self.picDate.maximumDate = maxDate;
        self.picDate.date = minDate;
        
        self.viewDatePic.hidden=NO;*/
        
      // [self loginWithFb];
    }
}

-(void)loginWithFb
{
    if ([FacebookUtility sharedObject].session.state!=FBSessionStateOpen)
    {
        [[FacebookUtility sharedObject]getFBToken];
    }
    
    if ([[FacebookUtility sharedObject]isLogin])
    {
        [self getFacebookUserDetails];
    }
    else
    {
        [[FacebookUtility sharedObject]loginInFacebook:^(BOOL success, NSError *error)
         {
             if (success)
             {
                 if ([FacebookUtility sharedObject].session.state==FBSessionStateOpen)
                 {
                     [self getFacebookUserDetails];
                 }
             }
             else
             {
                 UIAlertView *alertView = [[UIAlertView alloc]
                                           initWithTitle:@"Error"
                                           message:error.localizedDescription
                                           delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
                 [alertView show];
             }
         }];
    }
}

-(IBAction)onClickDone:(id)sender
{
    self.viewDatePic.hidden=YES;
    
    NSDate *birthDate = self.picDate.date;
    NSDate *currentDate = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit; //|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:birthDate toDate:currentDate options:0];
    
    NSInteger days = [dateComponents day];
    NSInteger months = [dateComponents month];
    NSInteger years = [dateComponents year];
    
    NSLog(@"%d Years , %d Months , %d Days", years, months, days);
    
    if(years < 18)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error !!!"
                                                        message:@"You should be a minimum of 18 yrs old to Sign Up !"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [alert dismissWithClickedButtonIndex:0 animated:YES];
        });
    }
    else
    {
        strBdate=[[UtilityClass sharedObject]DateToString:birthDate withFormate:@"yyyy-MM-dd"]; //0000-00-00
      
        if ([FacebookUtility sharedObject].session.state!=FBSessionStateOpen)
        {
            [[FacebookUtility sharedObject]getFBToken];
        }
        
        if ([[FacebookUtility sharedObject]isLogin])
        {
            [self getFacebookUserDetails];
        }
        else
        {
            [[FacebookUtility sharedObject]loginInFacebook:^(BOOL success, NSError *error)
             {
                 if (success)
                 {
                     if ([FacebookUtility sharedObject].session.state==FBSessionStateOpen)
                     {
                         [self getFacebookUserDetails];
                     }
                 }
                 else
                 {
                     UIAlertView *alertView = [[UIAlertView alloc]
                                               initWithTitle:@"Error"
                                               message:error.localizedDescription
                                               delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
                     [alertView show];
                 }
             }];
        }
    
        /*
        if ([[TwitterUtility sharedObject]isLogin])
        {
            //[self getFacebookUserDetails];
        }
        else
        {
            [[TwitterUtility sharedObject]LoginInTwitter:self withLoginBlock:^(BOOL success, NSError *error)
            {
            }];
        }
*/
    }
}

-(void)getFacebookUserDetails
{
    //me?fields=id,birthday,gender,first_name,age_range,last_name,name,picture.type(normal)
    
    ProgressIndicator *pi = [ProgressIndicator sharedInstance];
    [pi showPIOnView:self.view withMessage:@"Logging In.."];
    
    if ([[FacebookUtility sharedObject]isLogin])
    {
        [[FacebookUtility sharedObject]fetchMeWithFields:@"id,birthday,gender,first_name,age_range,last_name,name,email,picture.type(large)" FBCompletionBlock:^(id response, NSError *error)
         {
             if (!error)
             {
                 [[UserDefaultHelper sharedObject] setFacebookUserDetail:[NSMutableDictionary dictionaryWithDictionary:response]];
               
                 [self parseLogin:response];
             }
             else
             {
                 [pi hideProgressIndicator];
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Please try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                 alert.tag = 202;
                 [alert show];
             }
         }];
    }
    else
    {
        [pi hideProgressIndicator];
    }
}

#pragma mark -
#pragma mark -  login Parse methods

-(void)parseLogin :(NSDictionary*)FBUserDetailDict
{
    EntSex sex;
    if ([[FBUserDetailDict objectForKey:@"gender"] isEqualToString:@"female"])
    {
        sex= EntSexFemale;
    }
    else
    {
        sex=EntSexMale;
    }
    
    NSString *strPushToken =[[UserDefaultHelper sharedObject] deviceToken];
    if (!([strPushToken length] > 0))
    {
        strPushToken = @"SIMULATOR_TEST";
    }
    NSString *lat=@"0.0";
    if ([[UserDefaultHelper sharedObject] currentLatitude]!=nil)
    {
        lat=[[UserDefaultHelper sharedObject] currentLatitude];
    }
    NSString *log=@"0.0";
    if ([[UserDefaultHelper sharedObject] currentLongitude]!=nil)
    {
        log=[[UserDefaultHelper sharedObject] currentLongitude];
    }

    //NSString *BDAy =strBdate;
   
    NSString  *BDAy = [Helper getBirthDate:[FBUserDetailDict objectForKey:FACEBOOK_BIRTHDAY]];
    if (BDAy.length == 0 || [BDAy isEqualToString:@""] || BDAy == nil) {
        BDAy  =@"0000-00-00";
    }
    else{
        BDAy = [Helper getBirthDate:[FBUserDetailDict objectForKey:FACEBOOK_BIRTHDAY]];
    }
    
    
    NSString *proPic=@"https://fbcdn-profile-a.akamaihd.net/static-ak/rsrc.php/v2/yL/r/HsTZSDw4avx.gif";
    if ([[[FBUserDetailDict objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"]!=nil)
    {
        proPic=[[[FBUserDetailDict objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
    }

    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    
    [dictParam setObject:[FBUserDetailDict objectForKey:@"id"] forKey:PARAM_ENT_FBID];
    [dictParam setObject:[FBUserDetailDict objectForKey:@"first_name"] forKey:PARAM_ENT_FIRST_NAME];
    [dictParam setObject:[FBUserDetailDict objectForKey:@"last_name"] forKey:PARAM_ENT_LAST_NAME];
    [dictParam setObject:[NSString stringWithFormat:@"%d",sex] forKey:PARAM_ENT_SEX];
    [dictParam setObject:strPushToken forKey:PARAM_ENT_PUSH_TOKEN];
    
    [dictParam setObject:lat forKey:PARAM_ENT_CURR_LAT];
    [dictParam setObject:log forKey:PARAM_ENT_CURR_LONG];
    [dictParam setObject:BDAy forKey:PARAM_ENT_DOB];
    [dictParam setObject:proPic forKey:PARAM_ENT_PROFILE_PIC];
    [dictParam setObject:@"1" forKey:PARAM_ENT_DEVICE_TYPE];
    
    NSString *emailString = [FBUserDetailDict objectForKey:@"email"];
    
    if (emailString.length == 0) {
        
        [dictParam setObject:@"" forKey:PARAM_ENT_EMAIL];
    }
    else {
        [dictParam setObject:emailString forKey:PARAM_ENT_EMAIL];
    }
    
    [[UserDefaultHelper sharedObject]setFacebookLoginRequest:dictParam];
    [[User currentUser] setUser];
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_LOGIN withParamData:dictParam withBlock:^(id response, NSError *error)
    {
        [[ProgressIndicator sharedInstance]hideProgressIndicator];
        if (response)
        {
            if ([[response objectForKey:@"errFlag"] intValue]==0)
            {
                //[self showHomeScreen];
                NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
                [dictParam setObject:[[User currentUser] fbid] forKey:PARAM_ENT_USER_FBID];
                
                AFNHelper *afn=[[AFNHelper alloc]init];
                [afn getDataFromPath:METHOD_GET_CREDITS withParamData:dictParam withBlock:^(id response, NSError *error)
                 {
//                     [[ProgressIndicator sharedInstance]hideProgressIndicator];
                     if (response)
                     {
                         if ([[response objectForKey:@"errFlag"] intValue]==0)
                         {
                             [[UserDefaultHelper sharedObject] setAvailableCredits:[response objectForKey:@"credits"]];
                             [[User currentUser]setAvalableCredits];
                         }
                     }
                 }];

                [self showQuestionsScreen];
            }
        }
    }];
}

-(void)showHomeScreen
{
    [[User currentUser]setUser];
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[[User currentUser] fbid] forKey:PARAM_ENT_USER_FBID];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_GET_CREDITS withParamData:dictParam withBlock:^(id response, NSError *error)
     {
//         [[ProgressIndicator sharedInstance]hideProgressIndicator];
         if (response)
         {
             if ([[response objectForKey:@"errFlag"] intValue]==0)
             {
                 [[UserDefaultHelper sharedObject] setAvailableCredits:[response objectForKey:@"credits"]];
                 [[User currentUser]setAvalableCredits];
                 
                 
             }
         }
     }];

    
    HomeViewController *home = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    home._loadViewOnce = NO;
    home.didUserLoggedIn = YES;
    home._loadViewOnce = NO;
    NSMutableArray *navigationarray = [[NSMutableArray alloc]initWithArray:self.navigationController.viewControllers];
    [navigationarray removeAllObjects];
    [navigationarray addObject:home];
    [self.navigationController setViewControllers:navigationarray animated:YES];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_CREDIT_UPDATE object:nil];
}

-(void)showDiscoverySettingsScreen
{
    [[User currentUser]setUser];
    SettingsViewController *setting = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    NSMutableArray *navigationarray = [[NSMutableArray alloc]initWithArray:self.navigationController.viewControllers];
    [navigationarray removeAllObjects];
    [navigationarray addObject:setting];
    [self.navigationController setViewControllers:navigationarray animated:YES];
}

-(void)showQuestionsScreen
{
    [[User currentUser]setUser];
    QuestionVC *quVC = [[QuestionVC alloc] initWithNibName:@"QuestionVC" bundle:nil];
    NSMutableArray *navigationarray = [[NSMutableArray alloc]initWithArray:self.navigationController.viewControllers];
    [navigationarray removeAllObjects];
    [navigationarray addObject:quVC];
    [self.navigationController setViewControllers:navigationarray animated:YES];
}

-(void)getLocation
{
    [[LocationHelper sharedObject]startLocationUpdatingWithBlock:^(CLLocation *newLocation, CLLocation *oldLocation, NSError *error)
    {
        if (!error)
        {
            [[LocationHelper sharedObject]stopLocationUpdating];
        }
    }];
}

#pragma mark -
#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 202)
    {
        [self getFacebookUserDetails];
    }
}

#pragma mark -
#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = self.scrImages.frame.size.width;
    float fractionalPage = self.scrImages.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.pageControl.currentPage = page;
}

#pragma mark -
#pragma mark - Memory mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end