//
//  PurchaseTokenCell.h
//  Tinder
//
//  Created by Sanskar on 18/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TokenPackage.h"

@interface PurchaseTokenCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lblPackageName;
@property (strong, nonatomic) IBOutlet UILabel *lblPackageAmmount;
@property (strong, nonatomic) IBOutlet UILabel *lblPackageTokens;
@property (strong, nonatomic) IBOutlet UIButton *btnBuyPackage;

-(void)setCellData:(TokenPackage *)data;

@end
