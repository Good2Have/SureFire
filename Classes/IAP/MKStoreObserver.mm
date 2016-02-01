//
//  MKStoreObserver.m
//
//  Created by Mugunth Kumar on 17-Oct-09.
//  Copyright 2009 Mugunth Kumar. All rights reserved.
//

#import "MKStoreObserver.h"
#import "MKStoreManager.h"

@implementation MKStoreObserver
@synthesize restoredTransactionID;

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	for (SKPaymentTransaction *transaction in transactions)
	{
		switch (transaction.transactionState)
		{
			case SKPaymentTransactionStatePurchased:
				
                [self completeTransaction:transaction];
				
                break;
				
            case SKPaymentTransactionStateFailed:
				
                [self failedTransaction:transaction];
				
                break;
				
            case SKPaymentTransactionStateRestored:
				
                [self restoreTransaction:transaction];
				
                break;
                
            default:
				
                break;
		}			
	}
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{

    NSLog(@"%ld",(long)transaction.error.code);
    if (transaction.error.code != SKErrorPaymentCancelled){	
		
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The upgrade procedure failed" message:@"Please check your Internet connection and your App Store account information." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
        
        NSLog(@"transaction.error.code : %ld", (long)transaction.error.code);
        
        //NSString *messageToBeShown = [NSString stringWithFormat:@"Reason: %@, You can try: %@", [transaction.error localizedFailureReason], [transaction.error localizedRecoverySuggestion]];
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to complete your purchase" message:messageToBeShown
        //                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        //[alert show];
        //[alert release];
	}
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{		
    [[MKStoreManager sharedManager] provideContent: transaction.payment.productIdentifier];	
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{	
    [[MKStoreManager sharedManager] provideContent: transaction.originalTransaction.payment.productIdentifier];	
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];	
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    NSLog(@"%lu items restored", (unsigned long)queue.transactions.count);
}

@end
