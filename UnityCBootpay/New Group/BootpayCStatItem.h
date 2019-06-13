//
//  BootpayCStatItem.h
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 4..
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BootpayCStatItem : NSObject {
    NSString *item_name;
    NSString *item_img;
    NSString *unique;
    NSString *cat1;
    NSString *cat2;
    NSString *cat3;    
}

@property (copy, nonatomic) NSString *item_name;
@property (copy, nonatomic) NSString *item_img;
@property (copy, nonatomic) NSString *unique;
@property (copy, nonatomic) NSString *cat1;
@property (copy, nonatomic) NSString *cat2;
@property (copy, nonatomic) NSString *cat3;

@end

NS_ASSUME_NONNULL_END
