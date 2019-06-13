//
//  RemoteOrderCForm.m
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 4..
//

#import "RemoteOrderCForm.h"

@implementation RemoteOrderCForm

@synthesize m_id, pg, fm, tfp, n, cn, ip, dp, dap;
@synthesize is_r_n, is_r_p, is_addr, is_da, is_memo;
@synthesize desc_html, dap_jj, dap_njj, o_key;

-(id)init{
    self = [super init];
    if(self){
        fm = [[NSMutableArray alloc] init];
        m_id = @"";
        pg = @"";
        n = @"";
        cn = @"";
        desc_html = @"";
        o_key = @"";
        
    }
    return self;
}


- (NSString*) toString {
    return [NSString stringWithFormat:@"{m_id: '%@', pg: '%@', fm: %@, tfp: %lf, n: '%@', cn: '%@', ip: %lf, dp: %lf, dap: %lf, is_r_n: %d, is_r_p: %d, is_addr: %d, is_da: %d, is_memo: %d, desc_html: %@, dap_jj: %lf, dap_njj: %lf, o_key: %@}"
            , m_id
            , pg
            , @""
            , tfp
            , n
            , cn
            , ip
            , dp
            , dap
            , is_r_n
            , is_r_p
            , is_addr
            , is_da
            , is_memo
            , desc_html
            , dap_jj
            , dap_njj
            , o_key];
}

@end
