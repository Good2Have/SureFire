//
//  AdminSettings.h
//  Tinder
//
//  Created by Sanskar on 23/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdminSettings : NSObject

@property(nonatomic,copy)NSString *registrationFreeCredit;
@property(nonatomic,copy)NSString *requestSendingCredit;
@property(nonatomic,copy)NSString *requestReceiverCredit;
@property(nonatomic,copy)NSString *requestValidity;
@property(nonatomic,copy)NSString *minWithdrawBalance;


+(AdminSettings *)currentSetting;
-(void)setAdminSettingsWithDict:(NSDictionary *)dictData;
@end
