//
//  SparkRequestVC.m
//  Tinder
//
//  Created by Sanskar on 24/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "SparkRequestVC.h"
#import "ChattingViewController.h"
#import "NSUserDefaults+RMSaveCustomObject.h"

@interface SparkRequestVC ()

@end

@implementation SparkRequestVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Spark Match"];
    [APPDELEGATE addBackButton:self.navigationItem];
    [APPDELEGATE addrightButton:self.navigationItem];
    
    int totalCreditReceived = [[_dictNotification objectForKey:@"receiver_gain_free_credit"] integerValue]+[[_dictNotification objectForKey:@"receiver_gain_purchased_credit"] integerValue];
    
    lblSenderName.text = [_dictNotification objectForKey:@"First_Name"];
    
    if (![_dictNotification objectForKey:@"message"] || [[_dictNotification objectForKey:@"message"] isEqual:[NSNull null]])
    {
        lblSparkMsg.text = nil;
    }
    else
    {
        lblSparkMsg.text = [_dictNotification objectForKey:@"message"];
    }
    
    lblCreditsReceived.text = [NSString stringWithFormat:@"%d",totalCreditReceived];
    
    lblExpirehour.text=[NSString stringWithFormat:@"Spark Notifications expire after %@ hours",  [[NSUserDefaults standardUserDefaults]objectForKey:@"time_request_validity"]];
    [imgSenderImage setImageWithURL:[NSURL URLWithString:[_dictNotification objectForKey:@"Profile_Pic_Url"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    [imgSenderImage.layer setCornerRadius:imgSenderImage.frame.size.width/2];
    [imgSenderImage .layer setMasksToBounds:YES];
    
  //  [self.navigationController setNavigationBarHidden:YES];
}

- (IBAction)btnCrossTapped:(id)sender
{
    [self callWebserviceToAcceptSparkWithTransferID:[_dictNotification objectForKey:@"transfer_id"] acceptanceFlag:@"0"];
}

- (IBAction)btnAcceptTapped:(id)sender
{
    [self callWebserviceToAcceptSparkWithTransferID:[_dictNotification objectForKey:@"transfer_id"] acceptanceFlag:@"1"];
}

//Method to Accept Spark Request
- (void)callWebserviceToAcceptSparkWithTransferID : (NSString *)transferId acceptanceFlag : (NSString *)acceptanceFlag
{
    
    [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:nil];
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:transferId forKey:PARAM_ENT_TRANSFER_ID];
    [dictParam setObject:acceptanceFlag forKey:@"accepted"];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_COMPLETE_TRANSFER withParamData:dictParam withBlock:^(id response, NSError *error)
     {
         
         [[ProgressIndicator sharedInstance]hideProgressIndicator];
         if (response)
         {
             if ([[response objectForKey:@"errFlag"] intValue]==0)
             {
                 NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
                 [dict setValue:[_dictNotification objectForKey:@"Fb_Id"] forKey:@"fbId"];
                 [dict setValue:@"" forKey:@"status"];
                 [dict setValue:[_dictNotification objectForKey:@"First_Name"] forKey:@"fName"];
                 [dict setValue:[_dictNotification objectForKey:@"Profile_Pic_Url"] forKey:@"proficePic"];

                 [[NSUserDefaults standardUserDefaults] rm_setCustomObject:dict forKey:@"chatVC"];
                 
                 
                 HomeViewController *homeVC = [[HomeViewController alloc]init];
                 [homeVC setChatVC:YES];
                 UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:homeVC];
                 [self.revealSideViewController setDelegate:homeVC];
                 [self.revealSideViewController popViewControllerWithNewCenterController:n
                                                                                animated:YES];
                 
                 //[[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_CREDIT_UPDATE object:nil];
                 PP_RELEASE(homeVC);
                 PP_RELEASE(n);
                 [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_CREDIT_UPDATE object:nil];
                 [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_MATCHES_UPDATE object:nil];
                 
             }
            
            // [self dismissViewControllerAnimated:YES completion:nil];
             
             
         }
     }];
    
    
     //[_dictNotification objectForKey:@"Fb_Id"]
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
