//
//  BootpayCExtra.h
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 4..
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BootpayCExtra : NSObject {
    NSString *start_at;
    NSString *end_at;
    int expire_month;
    BOOL vbank_result;
    NSMutableArray *quotas; //int array
//    NSString *app_scheme;
    NSString *app_scheme_host;
    NSString *ux;
}

@property (copy, nonatomic) NSString *start_at;
@property (copy, nonatomic) NSString *end_at;
@property (nonatomic, assign) int expire_month;
@property (nonatomic, assign) BOOL vbank_result;
@property (nonatomic, strong) NSMutableArray *quotas;
//@property (copy, nonatomic) NSString *app_scheme;
@property (copy, nonatomic) NSString *app_scheme_host;
@property (copy, nonatomic) NSString *ux;

- (NSString *) toJson;

@end

NS_ASSUME_NONNULL_END
