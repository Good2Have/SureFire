//
//  PurchaseTokenVC.h
//  Tinder
//
//  Created by Sanskar on 18/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PurchaseTokenVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *arrayTokenPackages;
}

@property (strong, nonatomic) IBOutlet UITableView *tblTokenPackages;
-(void)callForWebserviceToPlaceOrderWithPlanId : (int) index;

@end
