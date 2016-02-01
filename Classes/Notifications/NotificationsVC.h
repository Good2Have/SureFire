//
//  NotificationsVC.h
//  SureFire
//
//  Created by Sanskar on 24/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationsVC : UIViewController<UIGestureRecognizerDelegate,PPRevealSideViewControllerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *arrayNotifications;
}
@property (strong, nonatomic) IBOutlet UITableView *tblNotifications;
@property (weak, nonatomic) IBOutlet UILabel *labelNoRecordFound;


@end
