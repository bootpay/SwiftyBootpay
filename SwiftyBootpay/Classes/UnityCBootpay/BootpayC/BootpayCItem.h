//
//  BootpayCItem.h
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 4..
//

#import <Foundation/Foundation.h>
//#import "BootpayCCController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BootpayCItem : NSObject {
    NSString *item_name;
    int qty;
    NSString *unique;
    double price;
    NSString *cat1;
    NSString *cat2;
    NSString *cat3;
}

@property (copy, nonatomic) NSString *item_name;
@property(nonatomic, assign) int qty;
@property (copy, nonatomic) NSString *unique;
@property(nonatomic, assign) double price;
@property (copy, nonatomic) NSString *cat1;
@property (copy, nonatomic) NSString *cat2;
@property (copy, nonatomic) NSString *cat3;

- (NSString*) toString;

@end

NS_ASSUME_NONNULL_END
