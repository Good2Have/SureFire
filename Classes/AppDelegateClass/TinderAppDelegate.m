//
//  TinderAppDelegate.m
//  Tinder
//
//  Created by Rahul Sharma on 24/11/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import "TinderAppDelegate.h"

#import "SplashVC.h"

#import "ChatViewController.h"
#import "JSDemoViewController.h"
#import "SparkRequestVC.h"
#import "NotificationsVC.h"
#import "MenuViewController.h"
#import "ChattingViewController.h"
#define _offsetValue 62
#define _animated  YES
NSString *const FBSessionStateChangedNotification =
@"com.facebook.samples.Tinder:FBSessionStateChangedNotification";

@implementation TinderAppDelegate

@synthesize navigationController;
@synthesize loggedInSession;
@synthesize managedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //For Push Noti Reg.
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];

        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }

 
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.vcSplash = [[SplashVC alloc]initWithNibName:@"SplashVC" bundle:nil];
    self.window.rootViewController = self.vcSplash;
    [self.window makeKeyAndVisible];
    
    [self customizeNavigationBar];
    
    [[FacebookUtility sharedObject]getFBToken];
    MenuViewController *vc = [[MenuViewController alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotUpdatesInUserCredits:) name:NOTIFICATION_CREDIT_UPDATE object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatVC:) name:@"notificationName" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatVCforSpark:) name:@"chatVCforSpark" object:nil];
    
    
    [self updatePendingSparkAlertCounter];
    return YES;
}

//Notification Event Whenever user credits updating
- (void)gotUpdatesInUserCredits:(NSNotification *)notification
{
    [[ProgressIndicator sharedInstance]showPIOnWindow:self.window withMessge:nil];
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[[User currentUser] fbid] forKey:PARAM_ENT_USER_FBID];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_GET_CREDITS withParamData:dictParam withBlock:^(id response, NSError *error)
     {
         [[ProgressIndicator sharedInstance]hideProgressIndicator];
         if (response)
         {
             if ([[response objectForKey:@"errFlag"] intValue]==0)
             {
                 [[UserDefaultHelper sharedObject] setAvailableCredits:[response objectForKey:@"credits"]];
                 [[User currentUser]setAvalableCredits];
                 [[User currentUser]setNumberOfSparkAlertPending:[[response objectForKey:@"request_count"] integerValue]];
                 [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_CREDIT_CHANGED object:nil];
                 [self updatePendingSparkAlertCounter];
             }
         }
     }];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	
    NSString *dt = [[deviceToken description] stringByTrimmingCharactersInSet:
                    [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    dt = [dt stringByReplacingOccurrencesOfString:@" " withString:@""];
//    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Hello World!"
//                                                      message:dt
//                                                     delegate:nil
//                                            cancelButtonTitle:@"OK"
//                                            otherButtonTitles:nil];
//    [message show];
    DLog(@"My token is: %@", dt);
    [[UserDefaultHelper sharedObject]setDeviceToken:dt];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	DLog(@"Failed to get token, error: %@", error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"Here :%@",userInfo);
//     handler(UIBackgroundFetchResultNewData);
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"newMessage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [APPDELEGATE addrightButton:self.navigationController.navigationItem];
    if (application.applicationState == UIApplicationStateActive)
    {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.userInfo = userInfo;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.alertBody = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
        localNotification.fireDate = [NSDate date];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
    }
//    [self updatePendingSparkAlertCounter];
           [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_CREDIT_UPDATE object:nil];
//    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_CREDIT_CHANGED object:nil];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    NSLog(@"didReceiveRemoteNotification userInfo=%@", userInfo);

    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"newMessage"];
    [[NSUserDefaults standardUserDefaults] synchronize];

   // [UIApplication sharedApplication].applicationIconBadgeNumber = [[[userInfo objectForKey:@"aps"] objectForKey: @"badge"] intValue];
    NSDictionary  *aps = [userInfo objectForKey:@"aps"];
    NSLog(@"the aps is %@",aps);
    
    if (application.applicationState == UIApplicationStateBackground  | application.applicationState ==UIApplicationStateInactive )
    {
        SparkRequestVC *sparkReqVC = [[SparkRequestVC alloc]init];
        [sparkReqVC setDictNotification:aps];
      //  [self.navigationController presentViewController:sparkReqVC animated:YES completion:nil];
        
        UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:sparkReqVC];
        [self.revealSideViewController setDelegate:sparkReqVC];
        [self.revealSideViewController popViewControllerWithNewCenterController:n
                                                                       animated:YES];
        PP_RELEASE(sparkReqVC);
        PP_RELEASE(n);
    }
    else if (application.applicationState == UIApplicationStateActive)
    {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.userInfo = userInfo;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.alertBody = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
        localNotification.fireDate = [NSDate date];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
        SparkRequestVC *sparkReqVC = [[SparkRequestVC alloc]init];
        [sparkReqVC setDictNotification:aps];
     
       // [self.navigationController presentViewController:sparkReqVC animated:YES completion:nil];
        
        UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:sparkReqVC];
        [self.revealSideViewController setDelegate:sparkReqVC];
        [self.revealSideViewController popViewControllerWithNewCenterController:n
                                                                       animated:YES];
        PP_RELEASE(sparkReqVC);
        PP_RELEASE(n);
    }
    
     [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_CREDIT_CHANGED object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
#pragma mark -
#pragma mark - FBSetion Methods

- (void) closeSession
{
    [[FBSession activeSession] closeAndClearTokenInformation];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

#pragma mark -
#pragma mark - Facebook Methods

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[FacebookUtility sharedObject].session];
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext_ != nil)
    {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"Tinder" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    NSURL *storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Tinder.sqlite"]];
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    
    NSDictionary *options = @{ NSSQLitePragmasOption : @{@"journal_mode" : @"DELETE"} };
    
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return persistentStoreCoordinator_;
}

#pragma mark -
#pragma mark - Utility Methods

-(void)addBackButton:(UINavigationItem*)naviItem
{
    /*
    UIImage *imgButton = [UIImage imageNamed:@"menu_icon_off.png"];
	UIButton *leftbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
	[leftbarbutton setBackgroundImage:imgButton forState:UIControlStateNormal];
    [leftbarbutton setBackgroundImage:[UIImage imageNamed:@"menu_icon_on.png"] forState:UIControlStateHighlighted];
	[leftbarbutton setFrame:CGRectMake(0, 0, imgButton.size.width, imgButton.size.height)];
    [leftbarbutton addTarget:self action:@selector(menuClicked) forControlEvents:UIControlEventTouchUpInside];
    naviItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftbarbutton];
    */
    
    UIImage *imgButton = [UIImage imageNamed:@"btn_menu.png"];
    UIButton *leftbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftbarbutton setBackgroundImage:imgButton forState:UIControlStateNormal];
//    [leftbarbutton setBackgroundImage:[UIImage imageNamed:@"menu_icon_off.png"] forState:UIControlStateHighlighted];
//      [leftbarbutton setBackgroundColor:[UIColor yellowColor]];
    [leftbarbutton setFrame:CGRectMake(0, 0, imgButton.size.width, imgButton.size.height)];
    [leftbarbutton addTarget:self action:@selector(menuClicked) forControlEvents:UIControlEventTouchUpInside];
    naviItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftbarbutton];
     

}
-(void)menuClicked
{
    MenuViewController *menu=[[MenuViewController alloc]initWithNibName:@"MenuViewController" bundle:nil];
    _revealSideViewController.delegate = self;
    [_revealSideViewController pushViewController:menu onDirection:PPRevealSideDirectionLeft withOffset:_offsetValue animated:_animated];
    PP_RELEASE(menu);
}

-(void)addrightButton:(UINavigationItem*)naviItem
{

    UIImage *imgButtonEnabled = [UIImage imageNamed:@"ic_chat_on.png"];
    UIImage *imgButtonDisabled = [UIImage imageNamed:@"ic_chat_off.png"];
    
    UIButton *rightbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightbarbutton setFrame:CGRectMake(0, 0, imgButtonEnabled.size.width, imgButtonEnabled.size.height)];
    [rightbarbutton addTarget:self action:@selector(chatbuttonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    naviItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightbarbutton];
    NSString *newMessage = [[NSUserDefaults standardUserDefaults] objectForKey:@"newMessage"];
  
    if ([newMessage isEqualToString:@"1"])
    {
        [rightbarbutton setBackgroundImage:imgButtonEnabled forState:UIControlStateNormal];
    }else{
        [rightbarbutton setBackgroundImage:imgButtonDisabled forState:UIControlStateNormal];
    }

    UIBarButtonItem *chatBtn = [[UIBarButtonItem alloc]initWithCustomView:rightbarbutton];
  
    vwTokens = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 35, 30)];
    UIImageView *imgSpark = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 19, 24)];
    [imgSpark setImage:[UIImage imageNamed:@"ic_fire.png"]];
    lblSparkAlertsCounter = [[UILabel alloc]initWithFrame:CGRectMake(11, 2, 15, 16)];
    UIButton *btnSparkCounter = [[UIButton alloc]initWithFrame:vwTokens.frame];
    
    lblSparkAlertsCounter.layer.cornerRadius = 7.0;
    lblSparkAlertsCounter.layer.masksToBounds = YES;
    [lblSparkAlertsCounter.layer setBorderColor:[UIColor redColor].CGColor];
    [lblSparkAlertsCounter.layer setBorderWidth:1.0];

    [lblSparkAlertsCounter setTextColor:[UIColor redColor]];
    [lblSparkAlertsCounter setFont:[UIFont systemFontOfSize:12.0]];
    [lblSparkAlertsCounter setTextAlignment:NSTextAlignmentCenter];
    [btnSparkCounter addTarget:self action:@selector(btnPendingSparkRequestTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [vwTokens addSubview:imgSpark];
    [vwTokens addSubview:lblSparkAlertsCounter];
    [vwTokens addSubview:btnSparkCounter];
    
    UIBarButtonItem *tokenBtn = [[UIBarButtonItem alloc] initWithCustomView:vwTokens];
    //Add a token button alongside the existing right bar button item
    naviItem.rightBarButtonItems = [NSArray arrayWithObjects:tokenBtn,chatBtn, nil];
    
//    [lblSparkAlertsCounter setText:[User cur]];
    [self updatePendingSparkAlertCounter];
    
}

-(void)chatbuttonClicked:(id)sender
{
    NSString *newMessage = [[NSUserDefaults standardUserDefaults] objectForKey:@"newMessage"];
    UIImage *imgButtonDisabled = [UIImage imageNamed:@"ic_chat_off.png"];
    if ([newMessage isEqualToString:@"1"]){
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"newMessage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [sender setBackgroundImage:imgButtonDisabled forState:UIControlStateNormal];
    }
    ChatViewController *menu=[[ChatViewController alloc]initWithNibName:@"ChatViewController" bundle:nil];
    _revealSideViewController.delegate = self;
    [_revealSideViewController pushViewController:menu onDirection:PPRevealSideDirectionRight withOffset:_offsetValue animated:_animated];
    PP_RELEASE(menu);
}

-(void)customizeNavigationBar
{
    [[UINavigationBar appearance]setBackgroundColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor redColor], UITextAttributeTextColor,
      [UIColor clearColor], UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
      [UIFont fontWithName:HELVETICALTSTD_LIGHT size:15.0], UITextAttributeFont, nil]];
    
}

- (IBAction)btnPendingSparkRequestTapped:(id)sender
{
    NotificationsVC *c = [[NotificationsVC alloc] initWithNibName:@"NotificationsVC" bundle:nil];
    [_revealSideViewController setDelegate:c];
    UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:c];
    [_revealSideViewController popViewControllerWithNewCenterController:n
                                                                            animated:YES];
    
    PP_RELEASE(c);
    PP_RELEASE(n);
}

-(void)updatePendingSparkAlertCounter
{
    int pendingSparksCount = [User currentUser].numberOfSparkAlertPending;
    
    if (pendingSparksCount)
    {
        [lblSparkAlertsCounter setText:[NSString stringWithFormat:@"%d",pendingSparksCount]];
        
        CGRect rect = lblSparkAlertsCounter.frame;
        CGFloat width = [self getWidthOfString:[NSString stringWithFormat:@"%d",pendingSparksCount] forSize:CGSizeMake(233, 1000.0f)];
        if (width<28)
        {
            rect.size.width = width+7;
        }
        else
        {
            rect.size.width = 35;
            int noOfChar = [[NSString stringWithFormat:@"%d",pendingSparksCount] length];
            [lblSparkAlertsCounter setFont:[UIFont systemFontOfSize:(int)(width+7)/(noOfChar-1)]];
        }
        [lblSparkAlertsCounter setFrame:rect];
        
        [lblSparkAlertsCounter setHidden:NO];
    }
    else
    {
        [lblSparkAlertsCounter setHidden:NO];
        [lblSparkAlertsCounter setText:@"0"];
    }
}


- (CGFloat) getWidthOfString: (NSString *) string forSize: (CGSize) size{
    
    CGSize stringSize = [string sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    // NSLog(@"stringSize = %@", NSStringFromCGSize(stringSize));
    return stringSize.width;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
*/

- (NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark -
#pragma mark - sharedAppDelegate

+(TinderAppDelegate *)sharedAppDelegate
{
    return (TinderAppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(void)showToastMessage:(NSString *)message
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    
	// Configure for text only and offset down
	hud.mode = MBProgressHUDModeText;
	hud.detailsLabelText = message;
	hud.margin = 10.f;
	hud.yOffset = 150.f;
	hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:2.0];
}
-(void)chatVC:(NSNotification*)notification
{
    NSDictionary *dict = notification.object;
    NSMutableDictionary * dictChat = [[NSMutableDictionary alloc]init];
    ChattingViewController *vc = [[ChattingViewController alloc] init];
    NSString * strPath =dict[@"pPic"];
    //    User *user = [[User alloc] init];
    //    vc.userFriend = user;
    vc.friendFbId = dict[@"uFbId"];
    vc.status = @"5";
    vc.ChatPersonNane =dict[@"uName"];
    vc.matchedUserProfileImagePath = strPath;
    [dictChat setValue:dict[@"uFbId"] forKey:@"fbId"];
    [dictChat setValue:@"5" forKey:@"status"];
    [dictChat setValue:dict[@"uName"] forKey:@"fName"];
    [dictChat setValue:strPath forKey:@"proficePic"];
    vc.dictUser = dictChat;
    UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.revealSideViewController popViewControllerWithNewCenterController:n
                                                                   animated:YES];
}
-(void)chatVCforSpark:(NSNotification*)notification
{
    NSDictionary *dict = notification.object;
    NSMutableDictionary * dictChat = [[NSMutableDictionary alloc]init];
    ChattingViewController *vc = [[ChattingViewController alloc] init];
    NSString * strPath =dict[@"proficePic"];
    //    User *user = [[User alloc] init];
    //    vc.userFriend = user;
    vc.friendFbId = dict[@"fbId"];
    vc.status = @"";
    vc.ChatPersonNane =dict[@"fName"];
    vc.matchedUserProfileImagePath = strPath;
    [dictChat setValue:dict[@"fbId"] forKey:@"fbId"];
    [dictChat setValue:@"" forKey:@"status"];
    [dictChat setValue:dict[@"fName"] forKey:@"fName"];
    [dictChat setValue:strPath forKey:@"proficePic"];
    vc.dictUser = dictChat;
    
    UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.revealSideViewController popViewControllerWithNewCenterController:n
                                                                   animated:YES];
}
@end