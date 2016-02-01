//
//  UserCreditsVC.h
//  Tinder
//
//  Created by Sanskar on 23/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCreditsVC : UIViewController<PPRevealSideViewControllerDelegate,UITextFieldDelegate>
{
    
    IBOutlet UILabel *lblFreeCredits;
    IBOutlet UILabel *lblPurchasedCredits;
    IBOutlet UILabel *lblTotalCredits;
    IBOutlet UIButton *btnWithdraw;
    
    IBOutlet UIView *vwWithdrawPopup;
    IBOutlet UIView *vwSubPopup;
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtAmmountWithdraw;
    
}
@property (weak, nonatomic) IBOutlet UILabel *labelInstruction;

@end
