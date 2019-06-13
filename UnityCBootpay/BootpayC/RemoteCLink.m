//
//  RemoteCLink.m
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 4..
//

#import "RemoteCLink.h"

@implementation RemoteCLink

@synthesize member, is_receive_member, seller_name, memo, img_url, desc_html;
@synthesize delivery_area_price_jeju, delivery_area_price_nonjeju;
@synthesize is_addr, is_delivery_area, is_memo;
@synthesize item_price, promotion_price, delivery_price, push_policy_type;


-(id)init{
    self = [super init];
    if(self){
        member = @"";
        seller_name = @"";
        memo = @"";
        img_url = @"";
        desc_html = @""; 
    }
    return self;
}


- (NSString*) toString {
    return [NSString stringWithFormat:@"{member: '%@', is_receive_member: %d, seller_name: '%@', memo: '%@', img_url: '%@', desc_html: '%@', delivery_area_price_jeju: %lf, delivery_area_price_nonjeju: %lf, is_addr: %d, is_delivery_area: %d, is_memo: %d, item_price: %lf, promotion_price: %lf, delivery_price: %lf, push_policy_type: %d}"
            , member
            , is_receive_member == true ? 1 : 0
            , seller_name
            , memo
            , img_url
            , desc_html
            , delivery_area_price_jeju
            , delivery_area_price_nonjeju
            , is_addr == true ? 1 : 0
            , is_delivery_area == true ? 1 : 0
            , is_memo == true ? 1 : 0
            , item_price
            , promotion_price
            , delivery_price
            , push_policy_type];
}

@end
