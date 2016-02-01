//
//  PurchaseTokenVC.m
//  Tinder
//
//  Created by Sanskar on 18/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "PurchaseTokenVC.h"
#import "PurchaseTokenCell.h"
#import "TokenPackage.h"
#import "PayPalUtility.h"
#import "MKStoreManager.h"

@interface PurchaseTokenVC ()

@end

@implementation PurchaseTokenVC

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    [self.navigationItem setTitle:@"Purchase Sparks"];
    [self addBackButton:self.navigationItem];
    self.navigationController.navigationBarHidden = NO;

    arrayTokenPackages = [[NSMutableArray alloc]init];
    [self callWebserviceToGetAllTokenPackages];
}

-(void)addBackButton:(UINavigationItem*)naviItem
{
    UIButton *leftbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftbarbutton setFrame:CGRectMake(0, 0, 35, 35)];
//    [leftbarbutton setTitle:@" ss" forState:UIControlStateNormal];
//    [leftbarbutton setBackgroundColor:[UIColor yellowColor]];
    [leftbarbutton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [leftbarbutton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [leftbarbutton setTitleColor:[UIColor colorWithRed:198.0f/255.0f green:50.0f/255.0f blue:51.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
    leftbarbutton.titleLabel.font = [UIFont fontWithName:HELVETICALTSTD_LIGHT size:15];
    
    [leftbarbutton addTarget:self action:@selector(btnBackTapped:) forControlEvents:UIControlEventTouchUpInside];
    naviItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftbarbutton];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

-(void)callWebserviceToGetAllTokenPackages
{
  
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    
    [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:nil];
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_GET_TOKEN_PLANS withParamData:dictParam withBlock:^(id response, NSError *error)
     {
         [[ProgressIndicator sharedInstance]hideProgressIndicator];
         if (response)
         {
             if ([[response objectForKey:@"errFlag"] intValue]==0)
             {
                 NSArray *arrayPlans = [response objectForKey:@"plans"];
                
                 for (NSDictionary *dictPlan in arrayPlans)
                 {
                     TokenPackage *package = [[TokenPackage alloc]initWithDict:dictPlan];
                     [arrayTokenPackages addObject:package];
                 }
                 
                 [_tblTokenPackages reloadData];
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
    return [arrayTokenPackages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"CellIdentifier";
    PurchaseTokenCell *cell = (PurchaseTokenCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
       cell = [[[NSBundle mainBundle] loadNibNamed:@"PurchaseTokenCell" owner:self options:nil] objectAtIndex:0];
   
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    TokenPackage *package=[arrayTokenPackages objectAtIndex:indexPath.row];
    [cell setCellData:package];
    
    [cell.btnBuyPackage setTag:indexPath.row];
    [cell.btnBuyPackage addTarget:self action:@selector(btnBuyPackageTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(IBAction)btnBuyPackageTapped:(UIButton *)sender
{
    TokenPackage *package = [arrayTokenPackages objectAtIndex:sender.tag];
    
    switch(sender.tag){
        case 0:
            [[MKStoreManager sharedManager] purchase_sparkpack4:self];
            break;
        case 1:
            [[MKStoreManager sharedManager] purchase_sparkpack12:self];
            break;
        case 2:
            [[MKStoreManager sharedManager] purchase_sparkpack20:self];
            break;
        case 3:
            [[MKStoreManager sharedManager] purchase_sparkpack100:self];
            break;
        case 4:
            [[MKStoreManager sharedManager] purchase_sparkpack200:self];
            break;
    }
    /*[[PayPalUtility sharedObject]setClientIDForProduction:nil andForSendboxID:nil];
    
    [[PayPalUtility sharedObject]pay:package.amount withVC:self withBlock:^(BOOL success,PayPalPayment *completedPayment)
     {
         if (success)
         {
             [[ProgressIndicator sharedInstance]showPIOnView:self.view  withMessage:nil];
             [self callForWebserviceToPlaceOrderWithPlanId:package.plan_id withCompletedPayment:completedPayment];
         }
     }];*/
    
}

-(void)callForWebserviceToPlaceOrderWithPlanId : (int) index
{
    TokenPackage *package = [arrayTokenPackages objectAtIndex:index];
    NSString *planId = package.plan_id;
    
    //NSDictionary *confirmDictFromPaypal = completedPayment.confirmation;
    //NSString *payId = [[confirmDictFromPaypal objectForKey:@"response"] objectForKey:@"id"];
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:planId forKey:PARAM_ENT_PLAN_ID];
    [dictParam setObject:[[User currentUser] fbid] forKey:PARAM_ENT_USER_FBID];
    //[dictParam setObject:payId forKey:<#(id<NSCopying>)#>];
    
    [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:nil];
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_PLACE_ORDER withParamData:dictParam withBlock:^(id response, NSError *error)
     {
         [[ProgressIndicator sharedInstance]hideProgressIndicator];
         if (response)
         {
             if ([[response objectForKey:@"errFlag"] intValue]==0)
             {
                 [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_CREDIT_UPDATE object:nil];
                 Show_AlertView(@"Success", @"Sparks Purchased Successfully");
                 [self btnBackTapped:nil];
             }
         }
        
     }];
}


- (IBAction)btnBackTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}


@end
