//
//  RemoteOrderPre.m
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 4..
//

#import "RemoteOrderCPre.h"

@implementation RemoteOrderCPre

@synthesize e_p, is_r_n, is_sale, s_at, e_at;
@synthesize desc_html, n, cn;

-(id)init{
    self = [super init];
    if(self){
        e_p = @"";
        desc_html = @"";
        n = @"";
        cn = @"";
        s_at = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

- (NSString*) toString {
    return [NSString stringWithFormat:@"{e_p: '%@', is_r_n: %d, is_sale: %d, s_at: %ld, e_at: %ld, desc_html: '%@', n: '%@', cn: '%@'}"
            , e_p
            , is_r_n
            , is_sale
            , s_at
            , e_at
            , desc_html
            , n
            , cn];
}

@end
