//
//  BootpayCDefault.m
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 5..
//

#import "BootpayCDefault.h"

@implementation BootpayCDefault

+ (NSString*) getApplicationId {
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:@"application_id"];
    return value == nil ? @"" : (NSString*) value;
}

+ (NSString*) getUUID {
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:@"uuid"];
    return value == nil ? @"" : (NSString*) value;
}

+ (NSString*) getSk {
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:@"sk"];
    return value == nil ? @"" : (NSString*) value;
}

+ (long) getSkTime {
    NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"sk_time"];
    return value == nil ? 0 : value.longValue;
}

+ (long) getTime {
    NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"time"];
    return value == nil ? 0 : value.longValue;
}

+ (long) getLastTime {
    NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_time"];
    return value == nil ? 0 : value.longValue;
}

+ (void) setKeyDouble:(NSString*) key :(double)val {
    [self setKey:key :[NSString stringWithFormat:@"%f", val]];
}

+ (void) setKey:(NSString*)key :(NSString*)val {
    [[NSUserDefaults standardUserDefaults] setObject:val forKey:key];
}

@end
