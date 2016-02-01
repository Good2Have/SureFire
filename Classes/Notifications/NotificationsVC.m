//
//  NotificationsVC.m
//  SureFire
//
//  Created by Sanskar on 24/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "NotificationsVC.h"
#import "SparkRequestVC.h"
#import "ProfileMatchedCell.h"
#import "UIImageView+Download.h"

@interface NotificationsVC ()
{
     UISwipeGestureRecognizer *deleteSwipe;
}

@end

@implementation NotificationsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Spark Notifications"];
    [APPDELEGATE addBackButton:self.navigationItem];
    [APPDELEGATE addrightButton:self.navigationItem];
   
    self.view.backgroundColor = [Helper getColorFromHexString:@"#333333" :1.0];
    
    deleteSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(removeNotifications:)];
    [deleteSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    [deleteSwipe setDelegate:self];
    [self.tblNotifications addGestureRecognizer:deleteSwipe];

}

#pragma mark -
#pragma mark - PPRevealSlider Delegte method

- (BOOL) pprevealSideViewController:(PPRevealSideViewController *)controller shouldDeactivateGesture:(UIGestureRecognizer*)gesture forView:(UIView*)view
{
    return YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = NO;
    [self callWebserviceToGetAllNotifications];
}

-(void)callWebserviceToGetAllNotifications
{
    
    arrayNotifications = [[NSMutableArray alloc]init];
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    
    [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:nil];
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_GETNOTIFICATIONS withParamData:dictParam withBlock:^(id response, NSError *error)
     {
         [[ProgressIndicator sharedInstance]hideProgressIndicator];
         if (response)
         {
             if ([[response objectForKey:@"errFlag"] intValue]==0)
             {
                 
                 [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"request_validity"] forKey:@"time_request_validity"];
                 NSArray *arrayNots = [response objectForKey:@"requests"];
                 
                 for (NSDictionary *dictPlan in arrayNots)
                 {
                     [arrayNotifications addObject:dictPlan];
                 }
               
                        [self.labelNoRecordFound setHidden:YES];
               
                        
                 [self.tblNotifications reloadData];
             }else{
                 [self.labelNoRecordFound setHidden:NO];
             }
         }
     }];
    
}

#pragma mark -
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayNotifications count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"CellIdentifier";
    ProfileMatchedCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[ProfileMatchedCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
   
    NSDictionary *dictNotif = [arrayNotifications objectAtIndex:indexPath.row];
    
    cell.labelFirstName.text = [dictNotif objectForKey:@"First_Name"];
    
    NSString *messageTxt=[dictNotif objectForKey:@"message"];
    
    if(messageTxt.length!=0)
    {
        
        cell.labelLastMessage.text = [dictNotif objectForKey:@"message"];//@"You have a new Spark Match Alert";
        
    }
    
    else
    {
         cell.labelLastMessage.text = @"You have a new Spark Match Alert";
    
    }
    
    
    
    [cell.thumbNailImage downloadFromURL:[dictNotif objectForKey:@"Profile_Pic_Url"] withPlaceholder:[UIImage imageNamed:@"placeholder.png"]];
    [cell.imageViewLine setFrame:CGRectMake(0,64,cell.contentView.frame.size.width, 1)];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SparkRequestVC *sparkReqVC = [[SparkRequestVC alloc]init];
    [sparkReqVC setDictNotification:arrayNotifications[indexPath.row]];
   // [self presentViewController:sparkReqVC animated:YES completion:nil];
    
    UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:sparkReqVC];
    [self.revealSideViewController setDelegate:sparkReqVC];
    [self.revealSideViewController popViewControllerWithNewCenterController:n
                                                                   animated:YES];
    PP_RELEASE(sparkReqVC);
    PP_RELEASE(n);

}

- (void)removeNotifications:(UISwipeGestureRecognizer *)recognizer {
    
    CGPoint location = [recognizer locationInView:self.tblNotifications];
    NSIndexPath *swipedIndexPath = [self.tblNotifications indexPathForRowAtPoint:location];
    UITableViewCell *swipedCell  = [self.tblNotifications cellForRowAtIndexPath:swipedIndexPath];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
