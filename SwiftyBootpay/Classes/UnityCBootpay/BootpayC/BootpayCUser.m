//
//  BootpayCUser.m
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 4..
//

#import "BootpayCUser.h"


@implementation BootpayCUser

@synthesize user_id, unique_id, username, email;
@synthesize gender, birth, phone, area;

-(id)init{
    self = [super init];
    if(self){
        user_id = @"";
        unique_id = @"";
        username = @"";
        email = @"";
        birth = @"";
        phone = @"";
        area = @"";
        gender = 0;
    }
    return self;
}

- (NSString *) toJson {
    
    return [NSString stringWithFormat:@"{user_id: '%@', id: '%@', username: '%@', email: '%@', gender: %d, birth: '%@', phone: '%@', area: '%@'}", user_id, unique_id, username, email, gender, birth, phone, area];
}

@end
