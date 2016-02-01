//
//  UserCreditsVC.m
//  Tinder
//
//  Created by Sanskar on 23/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "UserCreditsVC.h"
#import "PurchaseTokenVC.h"
#import "AdminSettings.h"


@interface UserCreditsVC ()
{
    CGRect selectedBtnRect;
}

@end

@implementation UserCreditsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Sparks(Credits)"];
    self.navigationController.navigationBarHidden = NO;
    [APPDELEGATE addBackButton:self.navigationItem];
    [APPDELEGATE addrightButton:self.navigationItem];
    [vwSubPopup.layer setCornerRadius:7.0];
    [vwSubPopup.layer setMasksToBounds:YES];
    [vwSubPopup.layer setBorderColor:[UIColor redColor].CGColor];
    [vwSubPopup.layer setBorderWidth:1.0];
    
   /* if ([lblTotalCredits.text integerValue]<[[AdminSettings currentSetting] minimumWithDrawCredits]) {
    
    }
    */
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTokensStatus) name:NOTIFICATION_CREDIT_CHANGED object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"Loading..."];
    
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

                 [self updateTokensStatus];

             }
         }
     }];
    
  
}

-(void)updateTokensStatus
{
     NSLog( @"Free %d Purchased %d",[User currentUser].freeCredits,[User currentUser].purchasedCredits);
    
    lblFreeCredits.text = [NSString stringWithFormat:@"%d",[[User currentUser]freeCredits]];
    lblPurchasedCredits.text = [NSString stringWithFormat:@"%d",[[User currentUser]purchasedCredits]];
    lblTotalCredits.text = [NSString stringWithFormat:@"%d",[User currentUser].freeCredits+[User currentUser].purchasedCredits];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnPurchaseTokensTapped:(id)sender
{
    PurchaseTokenVC *purchaseVC = [[PurchaseTokenVC alloc]init];
    [self.navigationController pushViewController:purchaseVC animated:YES];
}

- (IBAction)btnWithdrawTapped:(UIButton *)sender
{
    [self.labelInstruction setText:[NSString stringWithFormat:@"*Minimum spark withdrwal is %@",[[AdminSettings currentSetting]minWithdrawBalance]]];
    if ([[AdminSettings currentSetting]minWithdrawBalance].integerValue > ([User currentUser].purchasedCredits+[User currentUser].freeCredits))
    {
         Show_AlertView(@"Notice", @"You don't have enough credits to withdraw");
    }
    else
    {
        [self showWithdrawViewFromRect:sender.frame];
    }
}

-(void)showWithdrawViewFromRect:(CGRect)fromRect
{
    txtAmmountWithdraw.text = [NSString stringWithFormat:@"%d",[User currentUser].purchasedCredits];
    txtEmail.text = [[User currentUser] emailForPaypal];
    
    [vwWithdrawPopup setFrame:self.view.frame];
    [self.view addSubview:vwWithdrawPopup];
   // [self zoomOutView:vwWithdrawPopup fromRect:fromRect];
}


- (IBAction)btnClosePopupTapped:(id)sender
{
     //[self zoomInView:vwWithdrawPopup toRect:selectedBtnRect];
    [vwWithdrawPopup removeFromSuperview];
}

- (IBAction)btnWithdrawActionTapped:(id)sender
{
    NSString *msg = nil;
    
    if (![[UtilityClass sharedObject]isValidEmailAddress:txtEmail.text]) {
         msg = @"Please enter valid Email";
    }
    else if ([txtAmmountWithdraw.text integerValue] > [User currentUser].purchasedCredits) {
        msg = @"Please enter Withdraw Amount less than or equal available purchased credits";
    }
    else if ([[AdminSettings currentSetting]minWithdrawBalance].integerValue > txtAmmountWithdraw.text.integerValue)
    {
        msg = [NSString stringWithFormat:@"Please enter Withdraw Amount more than or equal to %d",[[AdminSettings currentSetting]minWithdrawBalance].integerValue];
    }
    
    if (msg.length > 0) {
        Show_AlertView(@"Notice",msg);
    }
    else
    {
        [[UserDefaultHelper sharedObject]setEmailForPaypal:txtEmail.text];
        [[User currentUser] setEmailForPaypal:txtEmail.text];
        [self callForWebserviceToWithdrawCredits];
    }
}

-(void)callForWebserviceToWithdrawCredits
{
    [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:nil];
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[[User currentUser] fbid] forKey:PARAM_ENT_USER_FBID];
    [dictParam setObject:txtEmail.text forKey:PARAM_ENT_USER_EMAIL];
    [dictParam setObject:[NSNumber numberWithInteger:[txtAmmountWithdraw.text integerValue]] forKey:PARAM_ENT_WITHDRAW_CREDITS];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_WITHDRAW_CREDITS withApiUrl:API_URL_Pay  withParamData:dictParam withBlock:^(id response, NSError *error)
     {
         [[ProgressIndicator sharedInstance]hideProgressIndicator];
         if (response)
         {
             if ([[response objectForKey:@"errFlag"] intValue]==0)
             {
                 [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_CREDIT_UPDATE object:nil];
                 //[self zoomInView:vwWithdrawPopup toRect:selectedBtnRect];
                 [vwWithdrawPopup removeFromSuperview];
                 
                 Show_AlertView(@"Success", [response objectForKey:@"errMsg"]);
                
             }
             else
             {
                 Show_AlertView(@"Notice", [response objectForKey:@"errMsg"]);
             }
         }
     }];
}

#pragma mark - Animation Methods

-(void)zoomOutView:(UIView *)view fromRect:(CGRect)fromRect
{
    selectedBtnRect = fromRect;
    [view setFrame:fromRect];
    view.userInteractionEnabled = NO;
    view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    
    [UIView animateWithDuration:0.6 animations:^{
        
        view.transform = CGAffineTransformIdentity;
        [view setFrame:[APPDELEGATE window].frame];
        
    } completion:^(BOOL finished) {
        view.transform = CGAffineTransformIdentity;
        [view setCenter:[APPDELEGATE window].center];
        [view setFrame:[APPDELEGATE window].frame];
        view.userInteractionEnabled = YES;
        [view setAlpha:1.0];
    }];
    
}

-(void)zoomInView:(UIView *)view toRect:(CGRect)toRect
{
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.5 animations:^{
        view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 0.1);
        [view setAlpha:0.0];
        [view setFrame:toRect];
    }completion:^(BOOL finished) {
        view.transform = CGAffineTransformIdentity;
        [view setFrame:[APPDELEGATE window].frame];
        [view setCenter:[APPDELEGATE window].center];
        [view setAlpha:1.0];
        self.view.userInteractionEnabled = YES;
        [view removeFromSuperview];
        
    }];
}

#pragma mark - Tap On Popup Background
- (IBAction)tapDetected:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
}

#pragma mark - textFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end
