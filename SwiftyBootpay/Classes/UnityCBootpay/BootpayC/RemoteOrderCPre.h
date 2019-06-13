//
//  RemoteOrderPre.h
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 4..
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RemoteOrderCPre : NSObject {
    NSString *e_p;
    BOOL is_r_n;
    BOOL is_sale;
    long s_at;
    long e_at;
    NSString *desc_html;
    NSString *n;
    NSString *cn;
}

- (NSString*) toString;

@property (copy, nonatomic) NSString *e_p;
@property(nonatomic, assign) BOOL is_r_n;
@property(nonatomic, assign) BOOL is_sale;
@property(nonatomic, assign) long s_at;
@property(nonatomic, assign) long e_at;
@property (copy, nonatomic) NSString *desc_html;
@property (copy, nonatomic) NSString *n;
@property (copy, nonatomic) NSString *cn;

@end

NS_ASSUME_NONNULL_END
