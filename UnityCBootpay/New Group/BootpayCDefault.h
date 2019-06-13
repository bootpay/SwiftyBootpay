//
//  BootpayCDefault.h
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 5..
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BootpayCDefault : NSObject

+ (NSString*) getApplicationId;
+ (NSString*) getUUID;
+ (NSString*) getSk;
+ (long) getSkTime;
+ (long) getTime;
+ (long) getLastTime;
+ (void) setKeyDouble:(NSString*) key :(double)val;
+ (void) setKey:(NSString*)key :(NSString*)val;

@end

NS_ASSUME_NONNULL_END
