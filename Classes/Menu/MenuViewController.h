//
//  MenuViewController.h
//  Tinder
//
//  Created by Rahul Sharma on 29/11/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import "BaseVC.h"

#import "SettingsViewController.h"
#import "PPRevealSideViewController.h"

@interface MenuViewController : BaseVC<PPRevealSideViewControllerDelegate,UIActionSheetDelegate>
{
    IBOutlet UIButton *btnProfile;
    __weak IBOutlet UIImageView *userImageView;
    __weak IBOutlet UILabel *userNameLabel;
}
-(IBAction)btnAction:(id)sender;

@end
