//
//  BootpayCUser.h
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 4..
//

#import <UIKit/UIKit.h>
//@import ObjectMapper;


@interface BootpayCUser : NSObject {
    NSString *user_id;
    NSString *unique_id;
    NSString *username;
    NSString *email;
    int gender;
    NSString *birth;
    NSString *phone;
    NSString *area;
}

@property (copy, nonatomic) NSString *user_id;
@property (copy, nonatomic) NSString *unique_id;
@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *email;
@property (nonatomic, assign) int gender;
@property (copy, nonatomic) NSString *birth;
@property (copy, nonatomic) NSString *phone;
@property (copy, nonatomic) NSString *area;

- (NSString *) toJson;

@end
