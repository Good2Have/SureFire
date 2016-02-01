//
//  PayPalUtility.h
//  PayPal-iOS-SDK-Sample-App
//
//  Created by Elluminati - macbook on 12/07/14.
//  Copyright (c) 2014 PayPal. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PayPalMobile.h"

#define YOUR_CLIENT_ID_FOR_PRODUCTION   @"AXH_ixA0esQ4qwfmedeKpzv3PDj25jcOfp3eoNa6qOXG3BdM6xbh68RFxz_b"

//#define YOUR_CLIENT_ID_FOR_SANDBOX @"AabazBBQ0r60s1rEp1LTrDe0aSwUwrov18e2AVdb5qR-pRUoytrkh3jT9UJu"
//last working
//#define YOUR_CLIENT_ID_FOR_SANDBOX @"AU_AEf6WzUBrZYIt5GMSs3k4NxKZpCxNsgukhqyM1XOcSHAtRGdrOCnfkRgxZWMY-886dtrYZ6o542bD"

#define YOUR_CLIENT_ID_FOR_SANDBOX @"AXQI8hCmcmKNSg6iCEeso9ZyFXsHx6VMQE5RbeWlNUccloSazK8q8tciuZb3"

//#define YOUR_CLIENT_ID_FOR_SANDBOX @"APP-80W284485P519543T"


// Set the environment:
// - For live charges, use PayPalEnvironmentProduction (default).
// - To use the PayPal sandbox, use PayPalEnvironmentSandbox.
// - For testing, use PayPalEnvironmentNoNetwork.
#define kPayPalEnvironment PayPalEnvironmentProduction


typedef void (^PayPalPaymentCompletionBlock)(BOOL success,PayPalPayment *completedPayment);

@interface PayPalUtility : NSObject<PayPalPaymentDelegate,PayPalFuturePaymentDelegate>
{
    //blocks
    PayPalPaymentCompletionBlock dataBlock;
}
@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;

@property(nonatomic,strong)UIViewController *vcPresent;

@property(nonatomic, strong, readwrite) NSString *environment;
@property(nonatomic, assign, readwrite) BOOL acceptCreditCards;
@property(nonatomic, strong, readwrite) NSString *resultText;

+(PayPalUtility *)sharedObject;
-(void)setClientIDForProduction:(NSString *)productionID andForSendboxID:(NSString *)sendboxID;
- (void)payWithVC:(UIViewController *)vc;
-(void)pay:(NSString *)strPayment withVC:(UIViewController *)vc withBlock:(PayPalPaymentCompletionBlock)block;

@end
