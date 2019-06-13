//
//  BootpayC.h
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 5..
//

#import <UIKit/UIKit.h>
#import "BootpayCUser.h"
#import "BootpayCDefault.h"

NS_ASSUME_NONNULL_BEGIN

@interface BootpayC : UIViewController {
    NSString *application_id;
    NSString *uuid;
    NSString *ver;
    NSString *sk;
    double sk_time;
    double last_time;
    double time;
    BootpayCUser *user;
    
    NSString *key;
    NSString *iv;
}

+ (id) sharedInstance;
+ (NSString*) dicToJsonString:(NSDictionary*) dic;

@end

NS_ASSUME_NONNULL_END
