//
//  SMSPayload.m
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 4..
//

#import "SMSCPayload.h"
#import "PushCType.h"

@implementation SMSCPayload

@synthesize o_id, o_t, sj, msg, pt, sp, rps, rq_at, s_at;
@synthesize k_tp_id, k_msg, k_vals, k_btns, k_sms_t;
@synthesize img_url, img_link, ad, files;


-(id)init{
    self = [super init];
    if(self){
        o_id = @"";
        sj = @"";
        msg = @"";
        sp = @"";
        k_tp_id = @"";
        k_msg = @"";
        img_url = @"";
        img_link = @"";
        o_t = REMOTE_ORDER_TYPE_FORM;
        pt = SMS;
        k_sms_t = SMS;

        rq_at = [[NSDate date] timeIntervalSince1970];
        rps = [[NSMutableArray alloc] init];
        k_vals = [[NSMutableDictionary alloc] init];
        k_btns = [[NSMutableDictionary alloc] init];
        ad = 1;
        files = [[NSMutableArray alloc] init];
    }
    return self;
}


- (NSString*) toString {
    return [NSString stringWithFormat:@"{o_id: '%@', o_t: %d, sj: '%@', msg: '%@', pt: %d, sp: '%@', rps: %@, rq_at: %ld, s_at: %ld, k_tp_id: '%@', k_msg: '%@', k_vals: %@, k_btns: %@, img_url: '%@', img_link: '%@', ad: %d, files: %@}"
            , o_id
            , o_t
            , sj
            , msg
            , pt
            , sp
            , @""
            , rq_at
            , s_at
            , k_tp_id
            , k_msg
            , @""
            , @""
            , img_url
            , img_link
            , ad
            , @""];
}

@end
