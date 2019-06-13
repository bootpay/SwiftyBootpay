//
//  RemoteCLink.h
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 4..
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RemoteCLink : NSObject {
    NSString *member;
    BOOL is_receive_member;
    NSString *seller_name;
    NSString *memo;
    NSString *img_url;
    NSString *desc_html;
    double delivery_area_price_jeju;
    double delivery_area_price_nonjeju;
    
    BOOL is_addr;
    BOOL is_delivery_area;
    BOOL is_memo;
    
    double item_price;
    double promotion_price;
    double delivery_price;
    int push_policy_type;
}

- (NSString*) toString;


@property (copy, nonatomic) NSString *member;
@property(nonatomic, assign) BOOL is_receive_member;
@property (copy, nonatomic) NSString *seller_name;
@property (copy, nonatomic) NSString *memo;
@property (copy, nonatomic) NSString *img_url;
@property (copy, nonatomic) NSString *desc_html;

@property(nonatomic, assign) double delivery_area_price_jeju;
@property(nonatomic, assign) double delivery_area_price_nonjeju;

@property(nonatomic, assign) BOOL is_addr;
@property(nonatomic, assign) BOOL is_delivery_area;
@property(nonatomic, assign) BOOL is_memo;

@property(nonatomic, assign) double item_price;
@property(nonatomic, assign) double promotion_price;
@property(nonatomic, assign) double delivery_price;
@property(nonatomic, assign) int push_policy_type;
@end

NS_ASSUME_NONNULL_END
