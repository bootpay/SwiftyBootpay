//
//  BootpayCRequest.h
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 4..
//

#import <Foundation/Foundation.h>
#import "BootpayCItem.h"
#import "BootpayCUser.h"
#import "BootpayCExtra.h" 

NS_ASSUME_NONNULL_BEGIN

@interface BootpayCRequest : NSObject {
//    NSString *application_id;
    NSString *pg;
    NSString *method;
    NSMutableArray *methods;
    
    NSString *name;
    double price;
    double tax_free;
    
    NSString *order_id;
    BOOL use_order_id;
    NSMutableDictionary *params;
    NSString *account_expire_at;
    BOOL show_agree_window;
    NSString *boot_key;
    BOOL sms_use;
}

//@property (copy, nonatomic) NSString *application_id;
@property (copy, nonatomic) NSString *pg;
@property (copy, nonatomic) NSString *method;
@property (nonatomic, strong) NSMutableArray *methods;

@property (copy, nonatomic) NSString *name;
@property (nonatomic, assign) double price;
@property (nonatomic, assign) double tax_free;

@property (copy, nonatomic) NSString *order_id;
@property (nonatomic, assign) BOOL use_order_id;
@property (nonatomic, strong) NSMutableDictionary *params;

@property (copy, nonatomic) NSString *account_expire_at;
@property (nonatomic, assign) BOOL show_agree_window;
@property (copy, nonatomic) NSString *boot_key;
@property (nonatomic, assign) BOOL sms_use;

- (void) setPG: (NSString*) value;

- (NSString*) generateScript: (NSString*) bridgeName :(NSMutableArray*)items :(BootpayCUser*)user :(BootpayCExtra*) extra;

@end

NS_ASSUME_NONNULL_END
