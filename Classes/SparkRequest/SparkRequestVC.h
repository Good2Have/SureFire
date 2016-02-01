//
//  SparkRequestVC.h
//  Tinder
//
//  Created by Sanskar on 24/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+AFNetworking.h"

@interface SparkRequestVC : UIViewController
{
    
    IBOutlet UILabel *lblSenderName;
    IBOutlet UIImageView *imgSenderImage;
    IBOutlet UILabel *lblSparkMsg;
    IBOutlet UILabel *lblCreditsReceived;
    IBOutlet UILabel *lblExpirehour;
}
@property(nonatomic,retain) NSDictionary *dictNotification;
- (IBAction)btnCrossTapped:(id)sender;
- (IBAction)btnAcceptTapped:(id)sender;


@end
