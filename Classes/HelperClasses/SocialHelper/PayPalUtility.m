//
//  PayPalUtility.m
//  PayPal-iOS-SDK-Sample-App
//
//  Created by Elluminati - macbook on 12/07/14.
//  Copyright (c) 2014 PayPal. All rights reserved.
//

#import "PayPalUtility.h"

@implementation PayPalUtility

#pragma mark -
#pragma mark - Init

-(id)init
{
    self=[super init];
    if (self)
    {
//        [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : YOUR_CLIENT_ID_FOR_PRODUCTION}];
       
        [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : YOUR_CLIENT_ID_FOR_PRODUCTION,
                                                               PayPalEnvironmentSandbox : YOUR_CLIENT_ID_FOR_SANDBOX}];
        
        // Set up payPalConfig
        _payPalConfig = [[PayPalConfiguration alloc] init];
        _payPalConfig.acceptCreditCards = YES;
        _payPalConfig.languageOrLocale = @"en";
        _payPalConfig.merchantName = @"Flamer , Inc.";
        _payPalConfig.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/privacy-full"];
        _payPalConfig.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/useragreement-full"];
        
        _payPalConfig.languageOrLocale = [NSLocale preferredLanguages][0];
        
        // use default environment, should be Production in real life
        self.environment = kPayPalEnvironment;
        
        [PayPalMobile preconnectWithEnvironment:kPayPalEnvironment];
    }
    return self;
}

+(PayPalUtility *)sharedObject
{
    static PayPalUtility *obj=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        obj = [[PayPalUtility alloc] init];
    });
    return obj;
}

#pragma mark -
#pragma mark - Methods

-(void)setClientIDForProduction:(NSString *)productionID andForSendboxID:(NSString *)sendboxID
{
    if (productionID==nil)
    {
        productionID=YOUR_CLIENT_ID_FOR_PRODUCTION;
    }
    if (sendboxID==nil)
    {
        sendboxID=YOUR_CLIENT_ID_FOR_SANDBOX;
    }
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : productionID,  PayPalEnvironmentSandbox : sendboxID}];
}

#pragma mark - Receive Single Payment

-(void)pay:(NSString *)strPayment withVC:(UIViewController *)vc withBlock:(PayPalPaymentCompletionBlock)block
{
    if (block) {
        dataBlock=[block copy];
    }
    if (vc) {
        self.vcPresent=vc;
    }
    self.resultText = nil;
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = [NSDecimalNumber decimalNumberWithString:strPayment];
    payment.currencyCode = @"AUD";
    payment.shortDescription = @"Token Package";
    payment.items = nil;
    payment.paymentDetails = nil;
    
    if (!payment.processable) {
        // This particular payment will always be processable. If, for
        // example, the amount was negative or the shortDescription was
        // empty, this payment wouldn't be processable, and you'd want
        // to handle that here.
    }
    
    // Update payPalConfig re accepting credit cards.
    self.payPalConfig.acceptCreditCards = self.acceptCreditCards;
    
    PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
                                                                                                configuration:self.payPalConfig
                                                                                                     delegate:self];
    
    if (self.vcPresent) {
        [self.vcPresent presentViewController:paymentViewController animated:YES completion:nil];
    }
}

- (void)payWithVC:(UIViewController *)vc
{
    if (vc) {
        self.vcPresent=vc;
    }
    
    // Remove our last completed payment, just for demo purposes.
    self.resultText = nil;
    
    // Note: For purposes of illustration, this example shows a payment that includes
    //       both payment details (subtotal, shipping, tax) and multiple items.
    //       You would only specify these if appropriate to your situation.
    //       Otherwise, you can leave payment.items and/or payment.paymentDetails nil,
    //       and simply set payment.amount to your total charge.
    
    // Optional: include multiple items
    /*
    PayPalItem *item1 = [PayPalItem itemWithName:@"Old jeans with holes"
                                    withQuantity:2
                                       withPrice:[NSDecimalNumber decimalNumberWithString:@"84.99"]
                                    withCurrency:@"USD"
                                         withSku:@"Hip-00037"];
    PayPalItem *item2 = [PayPalItem itemWithName:@"Free rainbow patch"
                                    withQuantity:1
                                       withPrice:[NSDecimalNumber decimalNumberWithString:@"0.00"]
                                    withCurrency:@"USD"
                                         withSku:@"Hip-00066"];
    PayPalItem *item3 = [PayPalItem itemWithName:@"Long-sleeve plaid shirt (mustache not included)"
                                    withQuantity:1
                                       withPrice:[NSDecimalNumber decimalNumberWithString:@"37.99"]
                                    withCurrency:@"USD"
                                         withSku:@"Hip-00291"];
    NSArray *items = @[item1, item2, item3];
    NSDecimalNumber *subtotal = [PayPalItem totalPriceForItems:items];
    
    // Optional: include payment details
    NSDecimalNumber *shipping = [[NSDecimalNumber alloc] initWithString:@"5.99"];
    NSDecimalNumber *tax = [[NSDecimalNumber alloc] initWithString:@"2.50"];
    PayPalPaymentDetails *paymentDetails = [PayPalPaymentDetails paymentDetailsWithSubtotal:subtotal
                                                                               withShipping:shipping
                                                                                    withTax:tax];
    
    NSDecimalNumber *total = [[subtotal decimalNumberByAdding:shipping] decimalNumberByAdding:tax];
    
    
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = total;
    payment.currencyCode = @"USD";
    payment.shortDescription = @"Hipster clothing";
    payment.items = items;  // if not including multiple items, then leave payment.items as nil
    payment.paymentDetails = paymentDetails; // if not including payment details, then leave payment.paymentDetails as nil
     */
    
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = [NSDecimalNumber decimalNumberWithString:@"1.0"];
    payment.currencyCode = @"USD";
    payment.shortDescription = @"Testing...";
    payment.items = nil;
    payment.paymentDetails = nil;
    
    if (!payment.processable) {
        // This particular payment will always be processable. If, for
        // example, the amount was negative or the shortDescription was
        // empty, this payment wouldn't be processable, and you'd want
        // to handle that here.
    }
    
    // Update payPalConfig re accepting credit cards.
    //self.payPalConfig.acceptCreditCards = self.acceptCreditCards;
    
    PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
                                                                                                configuration:self.payPalConfig
                                                                                                     delegate:self];
    
    if (self.vcPresent) {
        [self.vcPresent presentViewController:paymentViewController animated:YES completion:nil];
    }
}

#pragma mark -
#pragma mark - PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment
{
    NSLog(@"PayPal Payment Success!");
    self.resultText = [completedPayment description];
    //[self showSuccess];
    
    [self sendCompletedPaymentToServer:completedPayment]; // Payment was processed successfully; send to server for verification and fulfillment
    
    if (dataBlock) {
        dataBlock(YES,completedPayment);
    }
    
    if (self.vcPresent)
    {
        [self.vcPresent dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController
{
    NSLog(@"PayPal Payment Canceled");
    self.resultText = nil;
    //self.successView.hidden = YES;
    if (dataBlock) {
        dataBlock(NO,nil);
    }
    if (self.vcPresent) {
        [self.vcPresent dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -
#pragma mark - Proof of payment validation

- (void)sendCompletedPaymentToServer:(PayPalPayment *)completedPayment
{
    // TODO: Send completedPayment.confirmation to server
    NSLog(@"Here is your proof of payment:\n\n%@\n\nSend this to your server for confirmation and fulfillment.", completedPayment.confirmation);
}


#pragma mark - Authorize Future Payments

- (IBAction)getUserAuthorization:(id)sender
{
    //PayPalFuturePaymentViewController *futurePaymentViewController = [[PayPalFuturePaymentViewController alloc] initWithConfiguration:self.payPalConfig delegate:self];
    //[self presentViewController:futurePaymentViewController animated:YES completion:nil];
}


#pragma mark - PayPalFuturePaymentDelegate methods

- (void)payPalFuturePaymentViewController:(PayPalFuturePaymentViewController *)futurePaymentViewController didAuthorizeFuturePayment:(NSDictionary *)futurePaymentAuthorization
{
    NSLog(@"PayPal Future Payment Authorization Success!");
    self.resultText = futurePaymentAuthorization[@"code"];
    //[self showSuccess];
    
    [self sendAuthorizationToServer:futurePaymentAuthorization];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalFuturePaymentDidCancel:(PayPalFuturePaymentViewController *)futurePaymentViewController
{
    NSLog(@"PayPal Future Payment Authorization Canceled");
    //self.successView.hidden = YES;
    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendAuthorizationToServer:(NSDictionary *)authorization
{
    // TODO: Send authorization to server
    NSLog(@"Here is your authorization:\n\n%@\n\nSend this to your server to complete future payment setup.", authorization);
}

@end
