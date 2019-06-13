//
//  BootpayCItem.m
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 4..
//

#import "BootpayCItem.h"
#import "BootpayCUX.h"

@implementation NSString (Bootpay)
- (NSString *) replace: (NSString*)target :(NSString*)replace {
    return [self stringByReplacingOccurrencesOfString:target withString:replace];
}
@end

@implementation BootpayCItem

@synthesize item_name, qty, unique, price;
@synthesize cat1, cat2, cat3;


-(id)init{
    self = [super init];
    if(self){
        item_name = @"";
        unique = @"";
        cat1 = @"";
        cat2 = @"";
        cat3 = @"";
    }
    return self;
}

- (NSString*) toString {
    return [NSString stringWithFormat:@"{item_name: '%@', qty: %d, unique: '%@', price: %lf, cat1: '%@', cat2: '%@', cat3: '%@'}"
            ,[[item_name replace:@"\"" :@"'"] replace:@"'" :@"\\'"]
            ,qty
            ,unique
            ,price
            ,[[cat1 replace:@"\"" :@"'"] replace:@"'" :@"\\'"]
            ,[[cat2 replace:@"\"" :@"'"] replace:@"'" :@"\\'"]
            ,[[cat3 replace:@"\"" :@"'"] replace:@"'" :@"\\'"]];
}

@end
