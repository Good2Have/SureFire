//
//  AdminSettings.m
//  Tinder
//
//  Created by Sanskar on 23/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "AdminSettings.h"

@implementation AdminSettings
@synthesize registrationFreeCredit,requestReceiverCredit,requestSendingCredit,requestValidity,minWithdrawBalance;

#pragma mark -
#pragma mark - Init

-(id)init{
    
    if((self = [super init]))
    {
        
    }
    return self;
}

+(AdminSettings *)currentSetting
{
    static AdminSettings *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[AdminSettings alloc] init];
    });
    return obj;
}

-(void)setAdminSettingsWithDict:(NSDictionary *)dictData
{
    requestSendingCredit = [dictData objectForKey:@"request_sending_charge"];
    requestReceiverCredit=[dictData objectForKey:@"request_receiver_charge"];
    registrationFreeCredit=[dictData objectForKey:@"registration_free_credit"];
    requestValidity = [dictData objectForKey:@"request_validity"];
    minWithdrawBalance = [dictData objectForKey:@"min_withdraw_balance"];
    
    [User currentUser].freeCredits =[registrationFreeCredit intValue];
}


@end
