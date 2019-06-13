//
//  SMSPayload.h
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 4..
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define REMOTE_ORDER_TYPE_FORM 1
#define REMOTE_ORDER_TYPE_PRE 2

@interface SMSCPayload : NSObject {
    NSString *o_id;
    int o_t;
    NSString *sj;
    NSString *msg;
    int pt;
    NSString *sp;
    NSMutableArray *rps;
    long rq_at;
    long s_at;
    
    NSString *k_tp_id;
    NSString *k_msg;
    NSMutableDictionary *k_vals;
    NSMutableDictionary *k_btns;
    int k_sms_t;
    
    NSString *img_url;
    NSString *img_link;
    int ad;
    NSMutableArray *files;
}

- (NSString*) toString;

@property (copy, nonatomic) NSString *o_id;
@property(nonatomic, assign) int o_t;
@property (copy, nonatomic) NSString *sj;
@property (copy, nonatomic) NSString *msg;
@property(nonatomic, assign) int pt;
@property (copy, nonatomic) NSString *sp;
@property (nonatomic, strong) NSMutableArray *rps;
@property(nonatomic, assign) long rq_at;
@property(nonatomic, assign) long s_at;
@property (copy, nonatomic) NSString *k_tp_id;
@property (copy, nonatomic) NSString *k_msg;
@property (nonatomic, strong) NSMutableDictionary *k_vals;
@property (nonatomic, strong) NSMutableDictionary *k_btns;
@property(nonatomic, assign) int k_sms_t;
@property (copy, nonatomic) NSString *img_url;
@property (copy, nonatomic) NSString *img_link;
@property(nonatomic, assign) int ad;
@property (nonatomic, strong) NSMutableArray *files;

@end

NS_ASSUME_NONNULL_END
