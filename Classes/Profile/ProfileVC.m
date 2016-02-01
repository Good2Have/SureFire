//
//  ProfileVC.m
//  Tinder
//
//  Created by Elluminati - macbook on 12/06/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "ProfileVC.h"
#import "UIImageView+Download.h"
#import "EditProfileVC.h"
#import "UserSettings.h"

#define HeightScrollView 257.0

@interface ProfileVC ()
{
    IBOutlet UIScrollView *scrContainer;
    IBOutlet UIView *vwContainer;
    IBOutlet UIView *vwDetails;
}

@end

@implementation ProfileVC

@synthesize user;

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
    
    arrImages=[[NSMutableArray alloc]init];
    currentPage=0;
    
    
    self.navigationController.navigationBarHidden = NO;
    
    if (user==nil)
    {
        [self.navigationItem setTitle:@"My Profile"];
        [APPDELEGATE addBackButton:self.navigationItem];
        self.lblActive.hidden=YES;
        self.lblAway.hidden=YES;
        [APPDELEGATE addrightButton:self.navigationItem];
        //[self addEditInfoButtonOnNavigationBar];
        
        self.editprofileBtn.hidden=NO;
    }
    else{
     [self.navigationItem setTitle:user.first_name];
        self.lblActive.hidden=NO;
        self.lblAway.hidden=NO;
        [self addLeftButton:self.navigationItem];
        
        self.editprofileBtn.hidden=YES;
    }   
    
    [self.pcImage setNumberOfPages:[arrImages count]];
    [self.pcImage setCurrentPage:currentPage];
   
    //Setting up the scrollView
    _scrImage.bouncesZoom = YES;
    _scrImage.clipsToBounds = YES;
    
    _scrImage.delegate = self;
    scrContainer.delegate = self;
    [scrContainer setContentSize:CGSizeMake(ScreenSize.width, vwContainer.frame.size.height)];//+200 change by pranav
    
    [self initialSettingUpView];
    
}

-(void)initialSettingUpView
{
    UIImageView *imgProfilePic=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.scrImage.frame.size.width, self.scrImage.frame.size.height)];
    [imgProfilePic setBackgroundColor:[UIColor whiteColor]];
  //  [imgProfilePic downloadFromURL:[User currentUser].profile_pic withPlaceholder:nil];
    imgProfilePic.tag=1000;
    [self.scrImage addSubview:imgProfilePic];
    
    [self.scrImage setContentSize:CGSizeMake(self.scrImage.frame.size.width, self.scrImage.frame.size.height)];
    [self.pcImage setNumberOfPages:1];
    [self.pcImage setCurrentPage:0];
}

//-(void)addEditInfoButtonOnNavigationBar
//{
//    
//    UIButton *rightbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [rightbarbutton setFrame:CGRectMake(0, 0,25, 25)];
//    [rightbarbutton setImage:[UIImage imageNamed:@"edit_profile.png"] forState:UIControlStateNormal];
//    [rightbarbutton addTarget:self action:@selector(editProfile) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *EditBtn = [[UIBarButtonItem alloc] initWithCustomView:rightbarbutton];
//    
//    NSMutableArray *arrayItems = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems];
//    [arrayItems addObject:EditBtn];
//    
//    //Add a token button alongside the existing right bar button item
//    self.navigationItem.rightBarButtonItems = arrayItems;
//}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (user==nil) {
        [self getUserProfile:[User currentUser].fbid];
    }else{
        [self getUserProfile:user.fbid];
    }
}

#pragma mark -
#pragma mark - NavButton Methods

-(void)addBackToMessage:(UINavigationItem*)naviItem
{
    UIImage *imgButton = [UIImage imageNamed:@"chat_icon_on_line.png"];
	UIButton *rightbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightbarbutton setFrame:CGRectMake(0, 0, imgButton.size.width+20, imgButton.size.height)];
    [rightbarbutton setTitle:@"Done" forState:UIControlStateNormal];
    [rightbarbutton addTarget:self action:@selector(BackToMassageController:) forControlEvents:UIControlEventTouchUpInside];
    naviItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightbarbutton];
}
-(void)BackToMassageController:(UIButton*)sender
{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)addLeftButton:(UINavigationItem*)naviItem
{
	UIButton *rightbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightbarbutton setFrame:CGRectMake(0, 0, 60, 42)];
    [rightbarbutton setTitle:@"Done" forState:UIControlStateNormal];
    [rightbarbutton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    rightbarbutton.titleLabel.font = [UIFont fontWithName:HELVETICALTSTD_LIGHT size:15];
    
    [rightbarbutton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    naviItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightbarbutton];
}
-(void)done:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark -
#pragma mark - Methods

-(void)getUserProfile:(NSString *)fbid
{
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:fbid forKey:PARAM_ENT_USER_FBID];
    [dictParam setObject:[User currentUser].fbid forKey:@"ent_user_fbid_mine"];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_GETPROFILE withParamData:dictParam withBlock:^(id response, NSError *error)
    {
        if (response)
        {
            if ([[response objectForKey:@"errFlag"] intValue]==0)
            {
                NSMutableArray *arr=[[NSMutableArray alloc]initWithArray:[response objectForKey:@"images"]];
                if (arr)
                {
                    [arr removeObject:[response objectForKey:@"profilePic"]];
                    [arrImages removeAllObjects];
                    [arrImages addObject:[response objectForKey:@"profilePic"]];
                    [arrImages addObjectsFromArray:arr];
                    [self setScroll];
                }
                if ([response objectForKey:@"age"]!=nil)
                {
                    self.lblNameAndAge.text=[NSString stringWithFormat:@"%@ %@",[response objectForKey:@"firstName"],[response objectForKey:@"age"]];
                }
                else
                {
                    self.lblNameAndAge.text=[response objectForKey:@"firstName"];
                }
//                if ([response objectForKey:@"status"]==nil || [[response objectForKey:@"status"]isEqualToString:@""])
//                {
//                    if (user==nil) {
//                        Show_AlertView(@"Notice", @"Please Update Your Status");
//                    }
//                    self.txtAbout.text=[NSString stringWithFormat:@"About: n/a"];
//                }
//                else
//                {
//                    self.txtAbout.text=[NSString stringWithFormat:@"About: %@",[response objectForKey:@"status"]];
//                }
                
//                self.txtAbout.text=[NSString stringWithFormat:@"About %@: %@",[response objectForKey:@"firstName"],[response objectForKey:@"status"]];
                
                
                self.status =[response objectForKey:@"status"];
                [self.labelAboutTitle setText:[NSString stringWithFormat:@"About %@: %@",[response objectForKey:@"firstName"],[response objectForKey:@"status"]]];
                
                NSString *strActiveText = [Helper ConverGMTtoLocal:response[@"lastActive"]];
                self.lblActive.text=[NSString stringWithFormat:@"Active %@",strActiveText];
                
                //edit by rakesh
                
//                CLLocationDistance distance;
//                NSString *userLati=[response valueForKey:@"lati"];
//                NSString *userLongi=[response valueForKey:@"long"];
//                CLLocation *locB = [[CLLocation alloc] initWithLatitude:[[[UserDefaultHelper sharedObject] currentLatitude] floatValue] longitude:[[[UserDefaultHelper sharedObject] currentLongitude] floatValue]];
//                CLLocation *locA = [[CLLocation alloc] initWithLatitude:[userLati floatValue] longitude:[userLongi floatValue]];
//                distance=[locA distanceFromLocation:locB];
//                int Km = distance/1000;
//                self.lblAway.text=[NSString stringWithFormat:@"less than %dkm away",Km];
                if ([[UserSettings currentSetting].distance integerValue] == KM){
                    self.lblAway.text=[NSString stringWithFormat:@"less than %@ Km away",[response objectForKey:@"distance"]];
                }else{
                    self.lblAway.text=[NSString stringWithFormat:@"less than %@ mi. away",[response objectForKey:@"distance"]];
                }
                
            }
        }
    }];
}

-(void)setScroll
{
    [self.scrImage.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    int x=0;
    for (int i=0; i<[arrImages count]; i++)
    {
        UIImageView *img=[[UIImageView alloc]initWithFrame:CGRectMake(x, 0, self.scrImage.frame.size.width, self.scrImage.frame.size.height)];
        [img downloadFromURL:[arrImages objectAtIndex:i] withPlaceholder:nil];
        img.tag=1000+i;
        [img setContentMode:UIViewContentModeScaleAspectFit];
        [self.scrImage addSubview:img];
        x+=self.scrImage.frame.size.width;
    }
    [self.scrImage setContentSize:CGSizeMake(x, self.scrImage.frame.size.height)];
    [self.pcImage setNumberOfPages:[arrImages count]];
    [self.pcImage setCurrentPage:currentPage];
}

-(void)editProfile
{
    EditProfileVC *editPC=[[EditProfileVC alloc]initWithNibName:@"EditProfileVC" bundle:nil];
    editPC.strStatus=self.status;
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:editPC];
    [self presentViewController:navC animated:NO completion:nil];
}

#pragma mark -
#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = self.scrImage.frame.size.width;
    currentPage = floor((self.scrImage.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pcImage.currentPage = currentPage  ;
    
    if (sender == scrContainer)
    {
        UIImageView *imgVwCurrent = (UIImageView *)[self.scrImage viewWithTag:1000+currentPage];
        
        CGFloat yPos = -scrContainer.contentOffset.y;
        if (yPos > 0)
        {
            CGRect imgRect = imgVwCurrent.frame;
            imgRect.origin.x = ScreenSize.width * currentPage -yPos/2;
            imgRect.size.height = HeightScrollView+yPos;
            imgRect.size.width =  ScreenSize.width+yPos;
            imgVwCurrent.frame = imgRect;
            
            CGRect scrImgRect = _scrImage.frame;
            scrImgRect.origin.y =  _scrImage.frame.origin.y;
            scrImgRect.size.height = HeightScrollView+yPos;
            _scrImage.frame = scrImgRect;
            
            CGRect pgCntrlRect = _pcImage.frame;
            pgCntrlRect.origin.y =  scrImgRect.origin.y + scrImgRect.size.height - 50;
            _pcImage.frame = pgCntrlRect;

            
            CGRect vwDetailRect = vwDetails.frame;
            vwDetailRect.origin.y = scrImgRect.origin.y+scrImgRect.size.height;
            vwDetails.frame = vwDetailRect;
            
            CGRect vwContainerFrame = vwContainer.frame;
            vwContainerFrame.origin.y =scrContainer.contentOffset.y;
            vwContainerFrame.size.height = ScreenSize.height+yPos;
            vwContainer.frame = vwContainerFrame;
            
        }
    }
    
}

- (IBAction)changePage
{
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.scrImage.frame.size.width * self.pcImage.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrImage.frame.size;
    [self.scrImage scrollRectToVisible:frame animated:YES];
    //pageControlBeingUsed = YES;
}

#pragma mark -
#pragma mark - PPRevealSideViewController Delegate

- (BOOL) pprevealSideViewController:(PPRevealSideViewController *)controller shouldDeactivateGesture:(UIGestureRecognizer*)gesture forView:(UIView*)view
{
    if ([view isEqual:self.scrImage] || [view isKindOfClass:[UITableViewCell class]] || [NSStringFromClass([view class]) hasPrefix:@"UITableView"])
    {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)addEditInfoButtonOnNavigationBar:(id)sender {
    
    [self editProfile];
}
@end
