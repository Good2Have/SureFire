//
//  ChattingViewController.m
//  SureFire
//
//  Created by soumya ranjan sahu on 29/01/15.
//  Copyright (c) 2015 AppDupe. All rights reserved.
//

#import "ChattingViewController.h"
#import "MessageTable.h"
#import "SenderChatCell.h"
#import "RecieverChatCell.h"
#import "ProfileVC.h"

@interface ChattingViewController ()
{
    BOOL isReloding;
    
    UIButton *buttonBlockUser;
    int _currentKeyboardHeight;
}

@end

@implementation ChattingViewController

#pragma mark - View Delegate Methods -

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setIsFirstTime:YES];
    self.messageArray = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSDictionary * dictP = [ud objectForKey:UD_FB_USER_DETAIL];
    self.userFbId = [dictP objectForKey:FACEBOOK_ID];
    
    [self.navigationItem setTitle:self.ChatPersonNane];
    
    
    UIButton *titleLabelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleLabelButton setTitle:self.ChatPersonNane forState:UIControlStateNormal];
    [titleLabelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    titleLabelButton.frame = CGRectMake(0, 0, 70, 44);
    
//    titleLabelButton.font = [UIFont boldSystemFontOfSize:16];
    [titleLabelButton addTarget:self action:@selector(didTapTitleView:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = titleLabelButton;
    
    
    
//    [self setMoreView];
    [self addrightButton:self.navigationItem];
    [self addBack:self.navigationItem];
    [self messageTableReload];

//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)didTapTitleView:(id) sender
{
//    NSLog(@"Title tap");
    ProfileVC *vc=[[ProfileVC alloc]initWithNibName:@"ProfileVC" bundle:nil];
    

//    User *user=self.userFriend
//    user.fbid=[dict objectForKey:@"fbId"];
//    user.first_name=[dict objectForKey:@"firstName"];
//    user.profile_pic=[dict objectForKey:@"pPic"];
    vc.user=self.userFriend;
    [self.navigationController pushViewController:vc animated:NO];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Get Messages -

-(void)messageTableReload
{
    if (!isReloding)
    {
        isReloding = YES;
        NSMutableDictionary *dictParam = [[NSMutableDictionary alloc]init];
        
        NSString *userFBID = [[[UserDefaultHelper sharedObject] facebookUserDetail] objectForKey:FACEBOOK_ID];
        
        NSNumber *numfriendFbId = [NSNumber numberWithLongLong:[self.friendFbId longLongValue]];
        NSNumber *numUserFbId = [NSNumber numberWithLongLong:[userFBID longLongValue]];
        
        NSNumber *mid = [[DBHelper sharedObject]getLastMsgID:numfriendFbId andRecever:numUserFbId];
        
        [dictParam setObject:[NSString stringWithFormat:@"%@",mid] forKey:PARAM_ENT_LAST_MESS_ID];
        [dictParam setObject:self.friendFbId forKey:PARAM_ENT_RECEVER_USER_FBID];
        [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
        
        AFNHelper *afn = [[AFNHelper alloc]init];
        [afn getDataFromPath:METHOD_GETCHATSYNC withParamData:dictParam withBlock:^(id response, NSError *error)
         {
             if (response)
             {
                 NSMutableArray *arrChat=[[NSMutableArray alloc]initWithArray:[response objectForKey:@"chat"]];
                 if ([arrChat count] > 0) {
                     self.scrollToBottom = YES;
                 }else{
                     self.scrollToBottom = NO;
                 }
                 NSString *uniqueId =[NSString stringWithFormat:@"%@%@",self.userFbId,self.friendFbId];
                 [[DBHelper sharedObject]insertMsgToDB:arrChat uniqueId:uniqueId];
[self performSelector:@selector(messageTableReload) withObject:nil afterDelay:7];
                 [self getMessages];
                 
             }
             isReloding = NO;
         }];
        
//        [self performSelector:@selector(messageTableReload) withObject:nil afterDelay:7];
        
    }
}

- (void)getMessages
{
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"senderId = %@ OR receiverId = %@",[NSNumber numberWithLongLong:self.friendFbId.longLongValue],[NSNumber numberWithLongLong:self.friendFbId.longLongValue]];
    NSArray *storedMessages=[[DBHelper sharedObject] getObjectsforEntity:ENTITY_MESSAGETABLE ShortBy:@"messageDate" isAscending:YES predicate:predicate];
    
    if (storedMessages.count > 0)
    {
        [self.messageArray removeAllObjects];
        [self.messageArray addObjectsFromArray:storedMessages];
    }
    else
    {
        [self.messageArray removeAllObjects];
    }
    [self.tableView reloadData];
    
    if (self.scrollToBottom)
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    if (self.isFirstTime && [self.messageArray count] > 0)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        [self setIsFirstTime:NO];
    }

}

#pragma mark - TableView Delegate Methods -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messageArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageTable *messageObj = [self.messageArray objectAtIndex:indexPath.row];
    
    CGSize constrainedSize = CGSizeMake(230  , 9999);
    
    NSDictionary *attributesDictionary = @{NSFontAttributeName:[UIFont systemFontOfSize:14]};
    
    if (messageObj.message == nil) {
        messageObj.message = @"";
    }
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:messageObj.message attributes:attributesDictionary];
    
    CGRect requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    return MAX(64, requiredHeight.size.height + 45);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageTable *messageObj = [self.messageArray objectAtIndex:indexPath.row];
    NSString *senderId = messageObj.fId;
    
    CGSize constrainedSize = CGSizeMake(230  , 9999);
    
    NSDictionary *attributesDictionary = @{NSFontAttributeName:[UIFont systemFontOfSize:14]};
    if (messageObj.message == nil) {
        messageObj.message = @"";
    }
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:messageObj.message attributes:attributesDictionary];
    
    CGRect requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    if ([senderId isEqualToString:self.userFbId]) {
        
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SenderChatCell" owner:self options:0];
        SenderChatCell *cell = [array objectAtIndex:0];
        
        UIImage *senderImage = [UIImage imageNamed:@"bg_chat_sender.png"];
        UIEdgeInsets capInsets = UIEdgeInsetsMake(30, 20, 20, 15);
        
        UIImage *newImage = [senderImage resizableImageWithCapInsets:capInsets];
        [cell.chatBubbleImageView setImage:newImage];
        
        cell.userNameLabel.text = messageObj.name;
        
        
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [dateFormatter setTimeZone :[NSTimeZone timeZoneForSecondsFromGMT: 0]];
        
        
        NSDate *d = [dateFormatter dateFromString:messageObj.messageDate];
        d = [d dateByAddingTimeInterval:60];
        //NSLog(@"message date:%@",messageObj.messageDate);
        NSInteger seconds = [[NSTimeZone systemTimeZone] secondsFromGMT];
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"dd MMM hh:mm a"];
        [format setTimeZone :[NSTimeZone timeZoneForSecondsFromGMT: seconds]];
        NSString *dateString = [format stringFromDate:d];
        
        [cell.timeLabel setText:dateString];

        
        //        [cell.timeLabel setText:[self relativeDateStringForDate:[dateFormatter dateFromString:messageObj.messageDate]]];
        
        [cell.timeLabel setFont:[UIFont systemFontOfSize:7]];
        
        [cell.messageLabel setText:messageObj.message];
        
//        NSString *imageUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",messageObj.fId];
        [cell.userImageView loadImageFromURL:[NSURL URLWithString:[User currentUser].profile_pic]];
        
        
        CGRect textframe = cell.messageLabel.frame;
        CGRect frame = cell.chatBubbleImageView.frame;
        textframe.size.height = requiredHeight.size.height;
        cell.messageLabel.frame = textframe;
        [cell.messageLabel sizeToFit];
        
        textframe = cell.messageLabel.frame;
        frame.size.height = textframe.size.height + 27;
        cell.chatBubbleImageView.frame = frame;
        
        return cell;
    }
    else {
        
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RecieverChatCell" owner:self options:0];
        RecieverChatCell *cell = [array objectAtIndex:0];
        
        UIImage *senderImage = [UIImage imageNamed:@"bg_chat_reciever.png"];
        UIEdgeInsets capInsets = UIEdgeInsetsMake(30, 20, 20, 15);
        
        UIImage *newImage = [senderImage resizableImageWithCapInsets:capInsets];
        [cell.chatBubbleImageView setImage:newImage];
        
        cell.userNameLabel.text = messageObj.name;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [dateFormatter setTimeZone :[NSTimeZone timeZoneForSecondsFromGMT: 0]];
        NSDate *d = [dateFormatter dateFromString:messageObj.messageDate];
        
        NSInteger seconds = [[NSTimeZone systemTimeZone] secondsFromGMT];
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"dd MMM hh:mm a"];
        [format setTimeZone :[NSTimeZone timeZoneForSecondsFromGMT: seconds]];
        NSString *dateString = [format stringFromDate:d];
        
        [cell.timeLabel setText:dateString];
        
        
        
//        [cell.timeLabel setText:[self relativeDateStringForDate:[dateFormatter dateFromString:messageObj.messageDate]]];
        
          [cell.timeLabel setFont:[UIFont systemFontOfSize:7]];
        
        [cell.messageLabel setText:messageObj.message];
        
//        NSString *imageUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",messageObj.fId];
//        [cell.userImageView loadImageFromURL:[NSURL URLWithString:imageUrl]];


//        NSString *imageUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",messageObj.fId];
        [cell.userImageView loadImageFromURL:[NSURL URLWithString:[self.dictUser valueForKey:@"proficePic"]]];

        
        
        CGRect textframe = cell.messageLabel.frame;
        CGRect frame = cell.chatBubbleImageView.frame;
        textframe.size.height = requiredHeight.size.height;
        cell.messageLabel.frame = textframe;
        [cell.messageLabel sizeToFit];
        
        textframe = cell.messageLabel.frame;
        frame.size.height = textframe.size.height + 27;
        cell.chatBubbleImageView.frame = frame;
        return cell;
    }
}

#pragma mark - - -

- (NSString *)relativeDateStringForDate:(NSDate*)bDate

{
    const int SECOND = 1;
    const int MINUTE = 60 * SECOND;
    const int HOUR = 60 * MINUTE;
    //    const int DAY = 24 * HOUR;
    //    const int MONTH = 30 * DAY;
    
 
    
    
    
    NSDate *now = [NSDate date];
    NSTimeInterval delta = [bDate timeIntervalSinceDate:now] * -1.0;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSUInteger units = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit);
    
    NSDateComponents *components = [calendar components:units fromDate:bDate toDate:now options:0];
    
    NSString *relativeString;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    if (delta < 0) {
        
        relativeString = @"1 sec ago";
    }
    else if (delta < 1 * MINUTE) {
        
        relativeString = (components.second == 1) ? @"1 sec ago" : [NSString stringWithFormat:@"%d secs ago",(int)components.second];
    }
    else if (delta < 2 * MINUTE) {
        
        relativeString =  @"1 min ago";
    }
    else if (delta < 45 * MINUTE) {
        
        relativeString = [NSString stringWithFormat:@"%d mins ago",(int)components.minute];
    }
    else if (delta < 90 * MINUTE) {
        
        relativeString = @"1 hr ago";
    }
    else if (delta < 24 * HOUR) {
        
        relativeString = [NSString stringWithFormat:@"%d hrs ago",(int)components.hour];
    }
    else {
        
        [dateFormat setDateFormat:@"MMMM dd 'at' hh:mm a"];
        
        relativeString = [dateFormat stringFromDate:bDate];
    }
    
    return relativeString;
}

#pragma mark -
#pragma mark - NavigationButton Methods

-(void)addrightButton:(UINavigationItem*)naviItem
{
     UIImage *imgButton = [UIImage imageNamed:@"more"];
    UIButton *rightbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightbarbutton setFrame:CGRectMake(0, 0, imgButton.size.width+20, imgButton.size.height)];
    [rightbarbutton setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    rightbarbutton.tag=100;
    [rightbarbutton addTarget:self action:@selector(buttonSliderPressed:) forControlEvents:UIControlEventTouchUpInside];
    naviItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightbarbutton];
}

-(void)addBack:(UINavigationItem*)naviItem
{
    UIImage *imgButton = [UIImage imageNamed:@"btn_menu"];
    UIButton *rightbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightbarbutton setFrame:CGRectMake(0, 0, imgButton.size.width+20, imgButton.size.height)];
//    [rightbarbutton setTitle:@"Back" forState:UIControlStateNormal];
    [rightbarbutton setImage:[UIImage imageNamed:@"btn_menu"] forState:UIControlStateNormal];
    
    [rightbarbutton setTitleColor:[UIColor colorWithRed:198.0f/255.0f green:50.0f/255.0f blue:51.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
    [rightbarbutton addTarget:self action:@selector(buttonBackPressed:) forControlEvents:UIControlEventTouchUpInside];
    naviItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightbarbutton];
}

- (void)buttonSliderPressed:(UIBarButtonItem *)sender
{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Unmatch", nil];
    
    [actionSheet showInView:self.view];
//    if (sender.tag == 100)
//    {  //sliding is not done
//        sender.tag = 200;       //done button
//        float y;
//        if (IS_IOS7)
//        {
//            y=46;
//        }
//        else
//        {
//            y=0;
//        }
//        CGRect rect = CGRectMake(0, 0, self.customSlidingView.frame.size.width, self.customSlidingView.frame.size.height);
//        rect.origin.y = y;
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:0.2];
//        [self.customSlidingView setFrame:rect];
//        [UIView commitAnimations];
//    }
//    else
//    {
//        sender.tag = 100; //More button
//        float y;
//        if (IS_IOS7)
//        {
//            y=0;
//        }
//        else
//        {
//            y=-46;
//        }
//        CGRect rect = CGRectMake(0, 0, self.customSlidingView.frame.size.width, self.customSlidingView.frame.size.height);
//        rect.origin.y = y;
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:0.2];
//        [self.customSlidingView setFrame:rect];
//        [UIView commitAnimations];
//    }
}

- (void)buttonBackPressed:(UIBarButtonItem *)sender
{
    //done button
    self.navigationItem.rightBarButtonItem.title = @"Back";
    self.navigationItem.rightBarButtonItem.tintColor =[UIColor whiteColor];
    HomeViewController *c;
    // if (IS_IPHONE_5)
    {
        c = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    }
    /*
     else
     {
     c = [[HomeViewController alloc] initWithNibName:@"HomeViewController_ip4" bundle:nil];
     }
     */
    c.didUserLoggedIn = YES;
    UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:c];
    [self.revealSideViewController popViewControllerWithNewCenterController:n
                                                                   animated:YES];
    PP_RELEASE(c);
    PP_RELEASE(n);
}

#pragma mark -
#pragma mark - MoreView Methods

-(void)setMoreView
{
    
    
    /* add sliding view to self.view */
    float y=-46;
    if (IS_IOS7)
    {
        y=-46;
    }
    self.customSlidingView = [[UIView alloc]initWithFrame:CGRectMake(0, y, 320, 46)];
    self.customSlidingView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_tab.png"]];
    [self.view addSubview:self.customSlidingView];
    
    [self addrightButton:self.navigationItem];
    [self addBack:self.navigationItem];
    
    /* add button to customSlidingview */
    UIImage * imgShowProfile = [UIImage imageNamed:@"show_profile.png"];
    UIButton *buttonShowProfile = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonShowProfile.frame = CGRectMake(25, 5, imgShowProfile.size.width, imgShowProfile.size.height);
    [buttonShowProfile setBackgroundImage:imgShowProfile forState:UIControlStateNormal];
    [buttonShowProfile addTarget:self action:@selector(showProfile) forControlEvents:UIControlEventTouchUpInside];
    [Helper setButton:buttonShowProfile Text:nil WithFont:nil FSize:12.0 TitleColor:nil ShadowColor:nil];
    [self.customSlidingView addSubview:buttonShowProfile];
    
    
    UIImage * imgFlag = [UIImage imageNamed:@"flag_icon.png"];
    UIButton *buttonFlagReport = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonFlagReport.frame = CGRectMake(100, 5, imgFlag.size.width, imgFlag.size.height);
    [buttonFlagReport setBackgroundImage:imgFlag forState:UIControlStateNormal];
    [Helper setButton:buttonFlagReport Text:nil WithFont:nil FSize:12.0 TitleColor:nil ShadowColor:nil];
    [buttonFlagReport addTarget:self action:@selector(buttonReportTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.customSlidingView addSubview:buttonFlagReport];
    
    
    UIImage * imgblock = [UIImage imageNamed:@"block_icon.png"];
    UIImage * imgunblock = [UIImage imageNamed:@"unblock_icon.png"];
    buttonBlockUser = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonBlockUser.frame = CGRectMake(175, 5, imgblock.size.width, imgblock.size.height);
    [buttonBlockUser setImage:imgblock forState:UIControlStateNormal];
    [buttonBlockUser setImage:imgunblock forState:UIControlStateSelected];
    [buttonBlockUser addTarget:self action:@selector(buttonBlockTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.customSlidingView addSubview:buttonBlockUser];
    
    if (self.userFriend.flag==EntFlagBlock){
        buttonBlockUser.selected=YES;
    }else{
        buttonBlockUser.selected=NO;
    }
}

-(void)showProfile
{
    ProfileVC *vc = [[ProfileVC alloc]initWithNibName:@"ProfileVC" bundle:nil];
    User *user = [[User alloc]init];
    user.fbid = [self.dictUser objectForKey:@"fbId"];
    user.first_name = [self.dictUser objectForKey:@"fName"];
    user.profile_pic = [self.dictUser objectForKey:@"proficePic"];
    vc.user = user;
    [self.navigationController pushViewController:vc animated:NO];
    /*
     TinderPreviewUserProfileViewController *pc ;
     if (IS_IPHONE_5) {
     pc = [[TinderPreviewUserProfileViewController alloc] initWithNibName:@"TinderPreviewUserProfileViewController" bundle:nil];
     }
     else{
     pc = [[TinderPreviewUserProfileViewController alloc] initWithNibName:@"TinderPreviewUserProfileViewController_ip4" bundle:nil];
     
     }
     pc.userProfile = dictUser;
     pc.userFriend=userFriend;
     buttonUserTitle.hidden = YES;
     buttonUserPic.hidden = YES;
     [self.navigationController pushViewController:pc animated:NO];
     */
}

- (void) buttonReportTapped:(UIButton *)sender
{
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Surefire App!"];
    [controller setMessageBody:@"" isHTML:NO];
    NSMutableArray *emails = [[NSMutableArray alloc] initWithObjects:@"support@surefirematch.com", nil];
    [controller setToRecipients:[NSArray arrayWithArray:(NSArray *)emails]];
    if (controller) [self presentViewController:controller animated:YES completion:nil];
}

- (void) buttonBlockTapped:(UIButton *)sender
{
    if (self.userFriend.flag==EntFlagBlock)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Alert!" message:@"Are you sure you want to Unblock this user?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alertView.tag =100;
        [alertView show];
    }
    else if(self.userFriend.flag==EntFlagUnblock)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Alert!" message:@"Are you sure you want to block this user?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alertView.tag =200;
        [alertView show];
    }
}

#pragma mark -
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    WebServiceHandler *webserviceHandler = [[WebServiceHandler alloc]init];
    webserviceHandler.delegate = self;
    NSUserDefaults *userDeafults = [NSUserDefaults standardUserDefaults];
    if(buttonIndex == 1)
    {
        if (alertView.tag == 100)
        {
            // unblock user
            buttonBlockUser.selected=NO;
            self.userFriend.flag=EntFlagUnblock;
            
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            
            [dictParam setObject:[NSString stringWithFormat:@"%d",EntFlagUnblock] forKey:PARAM_ENT_FLAG];
            [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
            [dictParam setObject:self.userFriend.fbid forKey:PARAM_ENT_USER_BLOCK_FBID];
            
            AFNHelper *afn=[[AFNHelper alloc]init];
            [afn getDataFromPath:METHOD_BLOCKUSER withParamData:dictParam withBlock:^(id response, NSError *error)
             {
                 if (response)
                 {
                     if ([[response objectForKey:@"errFlag"] intValue]==0)
                     {
                         [[TinderAppDelegate sharedAppDelegate]showToastMessage:[response objectForKey:@"errMsg"]];
                     }
                 }
             }];
            
        }
        else
        {
            /*block user service call */
            
            buttonBlockUser.selected=YES;
            self.userFriend.flag=EntFlagBlock;
            UIBarButtonItem * btn = self.navigationItem.rightBarButtonItem;
            if (btn.tag == 200)
            {
                [self buttonSliderPressed:btn];
            }
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            
            [dictParam setObject:[NSString stringWithFormat:@"%d",EntFlagBlock] forKey:PARAM_ENT_FLAG];
            [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
            [dictParam setObject:self.userFriend.fbid forKey:PARAM_ENT_USER_BLOCK_FBID];
            
            
            AFNHelper *afn=[[AFNHelper alloc]init];
            [afn getDataFromPath:METHOD_BLOCKUSER withParamData:dictParam withBlock:^(id response, NSError *error)
             {
                 if (response)
                 {
                     if ([[response objectForKey:@"errFlag"] intValue]==0)
                     {
                         [[TinderAppDelegate sharedAppDelegate]showToastMessage:[response objectForKey:@"errMsg"]];
                     }
                 }
             }];
            
        }
        [userDeafults synchronize];
    }
}

#pragma mark-
#pragma mark- MailDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent)
    {
        NSLog(@"It's away!");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - Webservice response Delegate

- (void)getServiceResponseDelegate:(NSDictionary *)responseDict serviceType:(int)type error:(NSError *)error
{
    ProgressIndicator *pi =[ProgressIndicator sharedInstance];
    [pi hideProgressIndicator];
    
    if (error == nil)
    {
        if ([[responseDict objectForKey:@"errFlag"]intValue] == 0)
        {
            //[self deleteAllDbObject];
            NSLog(@"success");
            if (type == 4 || type == 5)
            {  //blockUser or UnblockUser Response
                /* update MatchedUserList Table in database  */
                
                TinderAppDelegate *appDelegate = (TinderAppDelegate *)[[UIApplication sharedApplication] delegate];
                NSManagedObjectContext *context = [appDelegate managedObjectContext];
                
                NSPredicate *predicate=[NSPredicate predicateWithFormat:@"fId == %@",self.friendFbId];
                NSArray *blockedUserProfile=[[DBHelper sharedObject]getObjectsforEntity:ENTITY_MATCHEDUSERLIST ShortBy:nil isAscending:YES predicate:predicate];
                
                if (blockedUserProfile.count > 0)
                {
                    MatchedUserList *matchedUser = [blockedUserProfile objectAtIndex:0];
                    if (type == 4)
                    {
                        matchedUser.status = @"4"; //blocking user
                        self.status = @"4";
                    }
                    else
                    {
                        matchedUser.status = @"3"; // unblocking user
                        self.status = @"3";
                    }
                    NSError *error;
                    if ( [context save:&error])
                    {
                        
                    }
                }
            }
        }
    }else{
        NSLog(@"error");
    }
}

#pragma mark -
#pragma mark - UIButton Action

- (void) buttonUserProfileTapped :(UIButton *)sender
{
    [self showProfile];
    /*
     TinderPreviewUserProfileViewController *pc ;
     
     if (IS_IPHONE_5) {
     pc = [[TinderPreviewUserProfileViewController alloc] initWithNibName:@"TinderPreviewUserProfileViewController" bundle:nil];
     }
     else{
     pc = [[TinderPreviewUserProfileViewController alloc] initWithNibName:@"TinderPreviewUserProfileViewController_ip4" bundle:nil];
     }
     pc.userFriend=userFriend;
     pc.userProfile = dictUser;
     buttonUserTitle.hidden = YES;
     buttonUserPic.hidden = YES;
     [self.navigationController pushViewController:pc animated:NO];
     */
}

-(void)deleteAllDbObject
{
    TinderAppDelegate *appDelegate =(TinderAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MessageTable" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray*fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    NSMutableArray *fetchedCategorList=[[NSMutableArray alloc]initWithArray:fetchedObjects];
    
    for (NSManagedObject *managedObject in fetchedCategorList)
    {
        [context deleteObject:managedObject];
    }
}

#pragma mark -
#pragma mark - Messages view delegate: OPTIONAL

-(void) moveSlidingViewToDefaultFrame
{
    UIBarButtonItem * btn = self.navigationItem.rightBarButtonItem;
    if (btn.tag == 200)
    {
        [self buttonSliderPressed:btn];
    }
}

#pragma mark -
#pragma mark - Messages view delegate: REQUIRED

- (void)didSendText:(NSString *)text
{
    if (text.length==0)
    {
        return;
    }
    self.currentMessage = text;
    
    if (self.userFriend.flag==EntFlagBlock) { // Blocked
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Do you want to unblock user?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.tag = 100;
        [alert show];
    }else{
        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
        NSDictionary * dictUser1 =[ud objectForKey:UD_FB_USER_DETAIL];
        
        MessageTable *msgTbl=(MessageTable *)[[DBHelper sharedObject]createObjectForEntity:ENTITY_MESSAGETABLE];
        msgTbl.message=text;
        msgTbl.fId=self.userFbId;
        msgTbl.name=[dictUser1 objectForKey:FACEBOOK_FIRSTNAME];
        msgTbl.uniqueId=[NSString stringWithFormat:@"%@%@",self.userFbId,self.friendFbId];
        msgTbl.messageDate=[Helper getCurrentTime];
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
        msgTbl.date=[NSNumber numberWithDouble:interval];
        
        msgTbl.senderId=[NSNumber numberWithLongLong:[self.userFbId longLongValue]];
        msgTbl.receiverId=[NSNumber numberWithLongLong:[self.friendFbId longLongValue]];
        [[DBHelper sharedObject]saveContext];
        
        [self.messageArray insertObject:msgTbl atIndex:self.messageArray.count];
        
        
        [self.tableView beginUpdates];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0];
        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
        
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
        [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
        [dictParam setObject:text forKey:PARAM_ENT_MESSAGE];
        [dictParam setObject:self.friendFbId forKey:PARAM_ENT_USER_RECEVER_FBID];
        
        
        AFNHelper *afn=[[AFNHelper alloc]init];
        [afn getDataFromPath:METHOD_SENDMESSAGE withParamData:dictParam withBlock:^(id response, NSError *error)
         {
             if (response)
             {
                 
             }
         }];
        self.chatTextField.text = @"";
        [self scrollToBottomAnimated:YES];
    }
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    NSInteger rows = [self.tableView numberOfRowsInSection:0];
    
    if(rows > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animated];
    }
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    //    CGFloat deltaHeight = kbSize.height - _currentKeyboardHeight;
    // Write code to adjust views accordingly using deltaHeight
    _currentKeyboardHeight = kbSize.height;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        CGRect chatFrame = self.chatBackView.frame;
        chatFrame.origin.y = self.view.frame.size.height-_currentKeyboardHeight-44;
        self.chatBackView.frame = chatFrame;
        
        CGRect tableFrame = self.tableView.frame;
        tableFrame.size.height = self.view.frame.size.height-_currentKeyboardHeight-88;
        self.tableView.frame = tableFrame;
    }];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    //    NSDictionary *info = [notification userInfo];
    //    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    // Write code to adjust views accordingly using kbSize.height
    _currentKeyboardHeight = 0.0f;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        CGRect chatFrame = self.chatBackView.frame;
        chatFrame.origin.y = self.view.frame.size.height-44;
        self.chatBackView.frame = chatFrame;
        
        CGRect tableFrame = self.tableView.frame;
        tableFrame.size.height = self.view.frame.size.height-88;
        self.tableView.frame = tableFrame;
    }];
}


- (IBAction)buttonSendTapped:(id)sender
{
    [self didSendText:self.chatTextField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Actionsheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
 
    
   
    if (buttonIndex == 0) {
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
        
        [dictParam setObject:@"Submit" forKey:@"ent_submit"];
        [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
        [dictParam setObject:self.friendFbId forKey:PARAM_ENT_UNMATCH_USER_ID];
        
        
        AFNHelper *afn=[[AFNHelper alloc]init];
        [afn getDataFromPath:METHOD_UNMATCH_USER withParamData:dictParam withBlock:^(id response, NSError *error)
         {
             if (response)
             {
                 if ([[response objectForKey:@"errFlag"] intValue]==0)
                 {
                     [[TinderAppDelegate sharedAppDelegate]showToastMessage:[response objectForKey:@"errMsg"]];
//                     -(void)deleteMsgFromDB:(NSString *)uniqueId
                     [[DBHelper sharedObject] deleteMsgFromDB:self.friendFbId];
                     
                     HomeViewController *c= [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
                     
                     c.didUserLoggedIn = YES;
                     c._loadViewOnce = NO;
                     UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:c];
                     [self.revealSideViewController popViewControllerWithNewCenterController:n
                                                                                    animated:YES];
                     
                     PP_RELEASE(c);
                     PP_RELEASE(n);

                 }
             }
         }];
    }
//    else if (buttonIndex == 1){
//        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
//        controller.mailComposeDelegate = self;
//        [controller setSubject:@"Surefire App!"];
//        [controller setMessageBody:@"" isHTML:NO];
//        NSMutableArray *emails = [[NSMutableArray alloc] initWithObjects:@"support@surefirematch.com", nil];
//        [controller setToRecipients:[NSArray arrayWithArray:(NSArray *)emails]];
//        if (controller) [self presentViewController:controller animated:YES completion:nil];
//    }
}

@end
