

#import "MKStoreManager.h"
#import "PurchaseTokenVC.h"
#import "VerifyViewController.h"

@implementation MKStoreManager

@synthesize purchasableObjects;
@synthesize storeObserver;

// all your features should be managed one and only by StoreManager


static NSString *iap_pack_4 = @"com.surefire.sparkpack4";
static NSString *iap_pack_12 = @"com.surefire.sparkpack12";
static NSString *iap_pack_20 = @"com.surefire.sparkpack20a";
static NSString *iap_pack_100 = @"com.surefire.sparkpack100";
static NSString *iap_pack_200 = @"com.surefire.sparkpack200";
static NSString *iap_verify = @"com.surefirematch.verify";

static MKStoreManager* _sharedStoreManager; // self 


+ (MKStoreManager*)sharedManager
{
	@synchronized(self) {
		
        if (_sharedStoreManager == nil) {
			
            [[self alloc] init]; // assignment not done here
			_sharedStoreManager.purchasableObjects = [[NSMutableArray alloc] init];			
			[_sharedStoreManager requestProductData];
            
			_sharedStoreManager.storeObserver = [[MKStoreObserver alloc] init];
			[[SKPaymentQueue defaultQueue] addTransactionObserver:_sharedStoreManager.storeObserver];
        }
    }
    return _sharedStoreManager;
}


#pragma mark Singleton Methods

+ (id)allocWithZone:(NSZone *)zone

{	
    @synchronized(self) {
		
        if (_sharedStoreManager == nil) {
			
            _sharedStoreManager = [super allocWithZone:zone];			
            return _sharedStoreManager;  // assignment and return on first allocation
        }
    }
	
    return nil; //on subsequent allocation attempts return nil	
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;	
}

- (void) requestProductData
{
    NSLog(@"requestProductData");
          
	SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: 
								 [NSSet setWithObjects:
                                  iap_pack_4, iap_pack_12, iap_pack_20, iap_pack_100, iap_pack_200, iap_verify,
                                  nil]]; // add any other product here
	request.delegate = self;
	[request start];
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"productsRequest didReceiveResponse");
    
	[purchasableObjects addObjectsFromArray:response.products];
	// populate your UI Controls here
	for(int i=0;i<[purchasableObjects count];i++)
	{
		SKProduct *product = [purchasableObjects objectAtIndex:i];
        
		NSLog(@"Feature: %@, Cost: %f, ID: %@",[product localizedTitle],
			  [[product price] doubleValue], [product productIdentifier]);
	}
}

- (void) purchase_sparkpack4:(UIViewController *)vc
{
    tempVC = vc;
    [self buyFeature: iap_pack_4];
}

- (void) purchase_sparkpack12:(UIViewController *)vc
{
    tempVC = vc;
    [self buyFeature: iap_pack_12];
}

- (void) purchase_sparkpack20:(UIViewController *)vc
{
    tempVC = vc;
    [self buyFeature: iap_pack_20];
}

- (void) purchase_sparkpack100:(UIViewController *)vc
{
    tempVC = vc;
    [self buyFeature: iap_pack_100];
}

- (void) purchase_sparkpack200:(UIViewController *)vc
{
    tempVC = vc;
    [self buyFeature: iap_pack_200];
}

- (void) purchase_verify:(UIViewController*) vc
{
    tempVC = vc;
    [self buyFeature:iap_verify];
}

- (void) buyFeature:(NSString*) featureId
{
//    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions]; 

	if ([SKPaymentQueue canMakePayments])
	{
		SKPayment *payment = [SKPayment paymentWithProductIdentifier:featureId];
//        [payment.quantity ];
//        NSLog(@"******* %d", [payment quantity]);
		[[SKPaymentQueue defaultQueue] addPayment:payment];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"A Robber Escape" message:@"You are not authorized to purchase from AppStore" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
	}
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
	NSString *messageToBeShown = [NSString stringWithFormat:@"Reason: %@, You can try: %@", [transaction.error localizedFailureReason], [transaction.error localizedRecoverySuggestion]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to complete your purchase" message:messageToBeShown
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];
    if([tempVC class] == [VerifyViewController class]){
        [(VerifyViewController*)tempVC purchaseFailed];
    }
}

-(void) provideContent: (NSString*) productIdentifier
{ 
    PurchaseTokenVC *vc = (PurchaseTokenVC*)tempVC;
	if([productIdentifier isEqualToString: iap_pack_4])
    {
        [vc callForWebserviceToPlaceOrderWithPlanId:0];
    }else if([productIdentifier isEqualToString: iap_pack_12]){
        [vc callForWebserviceToPlaceOrderWithPlanId:1];
    }else if([productIdentifier isEqualToString: iap_pack_20]){
        [vc callForWebserviceToPlaceOrderWithPlanId:2];
    }else if([productIdentifier isEqualToString: iap_pack_100]){
        [vc callForWebserviceToPlaceOrderWithPlanId:3];
    }else if([productIdentifier isEqualToString: iap_pack_200]){
        [vc callForWebserviceToPlaceOrderWithPlanId:4];
    }else if([productIdentifier isEqualToString: iap_verify]){
        [(VerifyViewController*)tempVC purchaseFinished];
    }
}

-(void) restoreTransactionRequest
{
    
}

-(void) restoreTransactionFinished
{
}

@end

