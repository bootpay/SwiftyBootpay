//
//  RemoteOrderCForm.h
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 4..
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RemoteOrderCForm : NSObject {
    NSString *m_id;
    NSString *pg;
    NSMutableArray *fm;
    double tfp;
    NSString *n;
    NSString *cn;
    double ip;
    double dp;
    double dap;
    
    BOOL is_r_n;
    BOOL is_r_p;
    BOOL is_addr;
    BOOL is_da;
    BOOL is_memo;
    
    NSString *desc_html;
    double dap_jj;
    double dap_njj;
    NSString *o_key;
}
- (NSString*) toString;

@property (copy, nonatomic) NSString *m_id;
@property (copy, nonatomic) NSString *pg;
@property (nonatomic, strong) NSMutableArray *fm;
@property(nonatomic, assign) double tfp;
@property (copy, nonatomic) NSString *n;
@property (copy, nonatomic) NSString *cn;

@property(nonatomic, assign) double ip;
@property(nonatomic, assign) double dp;
@property(nonatomic, assign) double dap;

@property(nonatomic, assign) BOOL is_r_n;
@property(nonatomic, assign) BOOL is_r_p;
@property(nonatomic, assign) BOOL is_addr;
@property(nonatomic, assign) BOOL is_da;
@property(nonatomic, assign) BOOL is_memo;

@property (copy, nonatomic) NSString *desc_html;
@property(nonatomic, assign) double dap_jj;
@property(nonatomic, assign) double dap_njj;
@property (copy, nonatomic) NSString *o_key;

@end

NS_ASSUME_NONNULL_END
