//
//  BootpayCCController.h
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 4..
//

#import <UIKit/UIKit.h>
#import "BootpayCRequest.h"
#import "BootpayCUser.h"
#import "BootpayCExtra.h"
#import "BootpayCItem.h"
#import "BootpayCWebView.h"
//#import "Bootpay"
//#import "SwiftyBootpay-Swift.h"
 

NS_ASSUME_NONNULL_BEGIN

@interface BootpayCController : UIViewController <BootpayCControllerProtocol>{
    BootpayCRequest *request;
    BootpayCUser *user;
    BootpayCExtra *extra;
    NSMutableArray *items;
    BOOL isPaying;
//    Bootpay
    id<BootpayCRequestProtocol> sendable;
//    bool firstLoad;
//    NSString *bootpayScript;
    BootpayCWebView *wv;
}

- (void) setRequest: (BootpayCRequest*)value;
- (void) setUser: (BootpayCUser*)value;
- (void) setExtra: (BootpayCExtra*)value;
- (void) setSendable: (id<BootpayCRequestProtocol>)value;
- (void) setItems: (NSMutableArray*)value;
- (void) dismissController;



@end

NS_ASSUME_NONNULL_END
