//
//  BootpayCStatItem.m
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 4..
//

#import "BootpayCStatItem.h"

@implementation BootpayCStatItem

@synthesize item_name, item_img, unique;
@synthesize cat1, cat2, cat3;


-(id)init{
    self = [super init];
    if(self){
        item_name = @"";
        item_img = @"";
        unique = @"";
        cat1 = @"";
        cat2 = @"";
        cat3 = @"";
    }
    return self;
}


- (NSString*) toString {
    return [NSString stringWithFormat:@"{item_name: '%@', item_img: '%@', unique: '%@', cat1: '%@', cat2: '%@', cat3: '%@'}"
            ,item_name
            ,item_img
            ,unique
            ,cat1
            ,cat2
            ,cat3];
}

@end
