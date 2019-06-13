//
//  BootpayCExtra.m
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 4..
//

#import "BootpayCExtra.h"

@implementation BootpayCExtra

@synthesize start_at, end_at, expire_month, vbank_result;
@synthesize quotas, app_scheme_host, ux;

-(id)init{
    self = [super init];
    if(self){
        start_at = @"";
        end_at = @"";
        app_scheme_host = @"";
        quotas = [[NSMutableArray alloc] init];
        ux = @"";
    }
    return self;
}

- (NSString*) getURLSchema {
    NSString * scheme = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLSchemes"];
    if([scheme length] == 0 || [@"(null)" isEqualToString:scheme]) return @"";
    return scheme;
}

- (NSString *) toJson {
    return [NSString stringWithFormat:@"{start_at: '%@', end_at: '%@', expire_month: '%d', vbank_result: %d, quotas: '%@', app_scheme: '%@', app_scheme_host: '%@', ux: '%@'}"
            , start_at
            , end_at
            , expire_month
            , vbank_result == true ? 1 : 0
            , [quotas componentsJoinedByString:@","]
            , [self getURLSchema]
            , app_scheme_host
            , ux];
}

@end
