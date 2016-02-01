

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "MKStoreObserver.h"

@interface MKStoreManager : NSObject<SKProductsRequestDelegate> {

	NSMutableArray *purchasableObjects;
	MKStoreObserver *storeObserver;
    
    UIViewController *tempVC;
}

@property (nonatomic, retain) NSMutableArray *purchasableObjects;
@property (nonatomic, retain) MKStoreObserver *storeObserver;

- (void) requestProductData;


- (void) purchase_sparkpack4:(UIViewController *)vc;
- (void) purchase_sparkpack12:(UIViewController *)vc;
- (void) purchase_sparkpack20:(UIViewController *)vc;
- (void) purchase_sparkpack100:(UIViewController *)vc;
- (void) purchase_sparkpack200:(UIViewController *)vc;
- (void) purchase_verify:(UIViewController*) vc;
// do not call this directly. This is like a private method
- (void) buyFeature:(NSString*) featureId;

- (void) failedTransaction: (SKPaymentTransaction *)transaction;
-(void) provideContent: (NSString*) productIdentifier;

+ (MKStoreManager*)sharedManager;

-(void) restoreTransactionRequest;
-(void) restoreTransactionFinished;

@end
