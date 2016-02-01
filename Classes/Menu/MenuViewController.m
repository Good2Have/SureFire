//
//  MenuViewController.m
//  Tinder
//
//  Created by Rahul Sharma on 29/11/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import "MenuViewController.h"
#import "RoundedImageView.h"
#import "UploadImages.h"
#import "Helper.h"
#import "DataBase.h"
#import "ChatViewController.h"
#import "HomeViewController.h"
#import "UIImageView+Download.h"
#import "QuestionVC.h"
#import "ProfileVC.h"
#import "UserCreditsVC.h"
#import "NotificationsVC.h"
#import "WebViewController.h"
#import "ChattingViewController.h"
#import "VerifyViewController.h"

@interface MenuViewController ()
{
    UIActionSheet *actionSheet;
    RoundedImageView *profileImageView;
    
    IBOutlet UIView *vwContainer;
    IBOutlet UIScrollView *scrollVw;
}
@end

@implementation MenuViewController

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
    profileImageView = [[RoundedImageView alloc] initWithFrame:CGRectMake(0, 2, 50, 50)];
    //NSArray * profileImage= [self getProfileImages:[[[UserDefaultHelper sharedObject] facebookUserDetail] objectForKey:FACEBOOK_ID]];
    NSString *FBId=[[[UserDefaultHelper sharedObject] facebookUserDetail] objectForKey:FACEBOOK_ID];
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"(fbId== %@)",
                              FBId];
    NSMutableArray *profileImage=[[DBHelper sharedObject]getObjectsforEntity:ENTITY_UPLOADIMAGES ShortBy:@"imageUrlLocal" isAscending:YES predicate:predicate];
    if (profileImage.count > 0) {
        profileImageView.image =[UIImage imageWithContentsOfFile:[(UploadImages*)[profileImage objectAtIndex:0] imageUrlLocal]];
    }
    else {
        profileImageView.image = [UIImage imageNamed:@"pfImage.png"];
    }
    
    if ([User currentUser].profile_pic!=nil)
    {
        [profileImageView downloadFromURL:[User currentUser].profile_pic withPlaceholder:[UIImage imageNamed:@"pfImage.png"]];
    }
    
    NSString *dobString = [User currentUser].dob;
    
    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
    [dateformat setDateFormat:@"yyyy-MM-dd"];
    
    NSDate* birthday = [dateformat dateFromString:dobString];
    
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSYearCalendarUnit
                                       fromDate:birthday
                                       toDate:now
                                       options:0];
    NSInteger age = [ageComponents year];
    
    userNameLabel.text = [NSString stringWithFormat:@"%@, %i", [User currentUser].first_name, age];
    
    //Adding rounded image view to main view.
    [userImageView addSubview:profileImageView];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.view.backgroundColor = [Helper getColorFromHexString:@"#333333" :1.0];
    self.navigationController.navigationBarHidden = YES;
    
    [scrollVw setContentSize:CGSizeMake(vwContainer.frame.size.width, vwContainer.frame.size.height+50)];
   
}
-(void)viewWillAppear:(BOOL)animated
{
     [APPDELEGATE updatePendingSparkAlertCounter];
}
-(NSArray*)getProfileImages :(NSString*)FBId
{
    NSManagedObjectContext *context = [APPDELEGATE managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UploadImages" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSArray *result=nil;
    
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"(fbId== %@)",
                              FBId];
    [fetchRequest setPredicate:predicate];
    
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"imageUrlLocal" ascending:YES]];
    
    NSError *error = nil;
    result = [context executeFetchRequest:fetchRequest error:&error];
    return  result;
}

#pragma  mark -
#pragma  mark - Button Action Method

-(IBAction)btnAction:(id)sender
{
    UIButton * btn =(UIButton*)sender;
    switch (btn.tag)
    {
        case PROFILE:{
            
            ProfileVC *vc=[[ProfileVC alloc]initWithNibName:@"ProfileVC" bundle:nil];
            UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:vc];
            [self.revealSideViewController popViewControllerWithNewCenterController:n
                                                                           animated:YES];
            [self.revealSideViewController setDelegate:vc];
            PP_RELEASE(vc);
            PP_RELEASE(n);
            break;
        }
        case HOME:{
          
            HomeViewController *c= [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
           
            c.didUserLoggedIn = YES;
            c._loadViewOnce = NO;
            UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:c];
            [self.revealSideViewController popViewControllerWithNewCenterController:n
                                                                           animated:YES];
            
            PP_RELEASE(c);
            PP_RELEASE(n);
            break;
        }
        case MESSAGE:{
            ChatViewController *menu=[[ChatViewController alloc]initWithNibName:@"ChatViewController" bundle:nil];
            [self.revealSideViewController pushViewController:menu onDirection:PPRevealSideDirectionRight withOffset:62 animated:YES];
            PP_RELEASE(menu);
            break;
        }
        case SETTINGS:{
            
            SettingsViewController *c = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
           
            UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:c];
            [self.revealSideViewController popViewControllerWithNewCenterController:n
                                                                           animated:YES];
            [self.revealSideViewController setDelegate:c];
            
            PP_RELEASE(c);
            PP_RELEASE(n);
            break;
        }
        case INVITE:{
            [self showActionSheet];
            break;
        }
        case QUESTION:{
          
            /*
            QuestionVC *vcQue=[[QuestionVC alloc]initWithNibName:@"QuestionVC" bundle:nil];
            [self presentViewController:vcQue animated:YES completion:^{
            }];
             */
            
            QuestionVC *c = [[QuestionVC alloc] initWithNibName:@"QuestionVC" bundle:nil];
            
            UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:c];
            [self.revealSideViewController popViewControllerWithNewCenterController:n
                                                                           animated:YES];
            [self.revealSideViewController setDelegate:c];
            
            PP_RELEASE(c);
            PP_RELEASE(n);
            break;
        }
        case SPARKS:{
            UserCreditsVC *c;
          
            c = [[UserCreditsVC alloc] initWithNibName:@"UserCreditsVC" bundle:nil];
           
           
            UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:c];
            [self.revealSideViewController popViewControllerWithNewCenterController:n
                                                                           animated:YES];
            [self.revealSideViewController setDelegate:c];
            
            PP_RELEASE(c);
            PP_RELEASE(n);
            
            break;
            
        }
        case NOTIFICATION:{
            NotificationsVC *c;
            
            c = [[NotificationsVC alloc] initWithNibName:@"NotificationsVC" bundle:nil];
            
            UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:c];
            [self.revealSideViewController popViewControllerWithNewCenterController:n
                                                                           animated:YES];
            [self.revealSideViewController setDelegate:c];
            
            PP_RELEASE(c);
            PP_RELEASE(n);
            
            break;
            
        }
        case SUPPORT:{
            WebViewController *webController = [[WebViewController alloc] init];
            webController.typeString = @"Support";
            
            UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:webController];
            [self.revealSideViewController popViewControllerWithNewCenterController:n
                                                                           animated:YES];
            [self.revealSideViewController setDelegate:webController];
            
            break;
            
        }
        case HOW_WORKS:
        {
            WebViewController *webController = [[WebViewController alloc] init];
            webController.typeString = @"How it works";
            
            UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:webController];
            [self.revealSideViewController popViewControllerWithNewCenterController:n
                                                                           animated:YES];
            [self.revealSideViewController setDelegate:webController];
            
            break;
        }
        case  VERIFY:{
            VerifyViewController *c = [[VerifyViewController alloc] initWithNibName:@"VerifyViewController" bundle:nil];
            
            UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:c];
            [self.revealSideViewController popViewControllerWithNewCenterController:n
                                                                           animated:YES];
            [self.revealSideViewController setDelegate:c];
            
            PP_RELEASE(c);
            PP_RELEASE(n);
            break;
        }
        default:
            break;
    }
}

-(void)showActionSheet
{
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"Invite" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Mail ",@"Message",nil];
    actionSheet.tag = 200;
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

-(void) actionSheet:(UIActionSheet *)actSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *strMail = [NSString stringWithFormat:@"%@",@"I am using SureFire Match App! Did you know you can get PAID using this APP. Check it out @ https://play.google.com/store/apps/details?id=com.surefirematch&hl=en<br>Or visit<br>http://surefirematch.com"];
   
    NSString *strMsg = [NSString stringWithFormat:@"%@",@"I am using SureFire Match App! Did you know you can get PAID using this APP. Check it out @ https://play.google.com/store/apps/details?id=com.surefirematch&hl=en<br>Or visit<br>http://surefirematch.com"];
    
    if (actSheet.tag == 200) {
        if(buttonIndex == 0){
            [super sendMailSubject:@"SureFire Match App" toRecipents:[NSArray arrayWithObject:@""] withMessage:strMail];
        }
        else if(buttonIndex == 1){
            [super sendMessage:strMsg];
        }
    }
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end;
