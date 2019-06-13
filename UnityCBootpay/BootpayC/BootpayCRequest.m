//
//  BootpayCRequest.m
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 4..
//

#import "BootpayCRequest.h"
#import "BootpayC.h"

@implementation NSString (Bootpay)
- (NSString *) replace: (NSString*)target :(NSString*)replace {
    return [self stringByReplacingOccurrencesOfString:target withString:replace];
}
@end

@implementation BootpayCRequest

@synthesize pg, method, methods;
@synthesize name, price, tax_free;
@synthesize order_id, use_order_id, params;
@synthesize account_expire_at, show_agree_window, boot_key, sms_use;
 

- (void) setPG: (NSString*) value {
    pg = value;
}

-(id)init{
    self = [super init];
    if(self){
        pg = @"";
        method = @"";
        name = @"";
        order_id = @"";
        account_expire_at = @"";
        boot_key = @"";
        methods = [[NSMutableArray alloc] init];
        params = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) validCheck {
//    if(price <= 0) [self throwsException:<#(NSString *)#>]
    if ([[BootpayCDefault getApplicationId] length] == 0) { [self throws: @"Application id is not configured."]; }
    if ([pg length] == 0) { [self throws: @"PG is not configured."]; }
    if ([order_id length] == 0) { [self throws: @"order_id is not configured."]; }
}

- (void) throws: (NSString *) msg {
    [NSException raise:NSInternalInconsistencyException format:msg, NSStringFromSelector(_cmd)];
}

- (NSString *) generateItems: (NSMutableArray*) items {
    NSString *result = @"";
    for(BootpayCItem *item in items) {
        result = [NSString stringWithFormat:@"%@%@", result, [item toString]];
    }
    return result;
}

- (NSString*) listToJson: (NSMutableArray*) strArray {
    NSString *result = @"";
    for(NSString *str in strArray) {
        if([result length] == 0) {
            result = [NSString stringWithFormat:@"'%@'", str];
        } else {
            result = [NSString stringWithFormat:@"%@,'%@'", result, str];
        }
    }
    return [NSString stringWithFormat:@"[%@]", result];
}

- (void) clear {
    price = 0;
//    application_id = [BootpayCDefault getApplicationId];
    name = @"";
    pg = @"";
    method = @"";
    order_id = @"";
    use_order_id = false;
    params = nil;
}


- (NSString*) generateScript: (NSString*) bridgeName :(NSMutableArray*)items :(BootpayCUser*)user :(BootpayCExtra*) extra {
    NSString *userPhone = user.phone;
    NSString *itemsString = [self generateItems:items];
    NSString *extraString = [extra toJson];
    
    NSString *result = [NSString stringWithFormat: @"BootPay.request({price: %lf, application_id: '%@', name: '%@', pg: '%@', phone: '%@', show_agree_window: %d, items: [%@], params: %@, order_id: '%@', use_order_id: %d, account_expire_at: '%@', extra: %@"
                        ,price
                        ,[BootpayCDefault getApplicationId]
                        ,[[name replace:@"\"" :@"'"] replace:@"'" :@"\\'"]
                        ,pg
                        ,userPhone
                        ,show_agree_window == true ? 1 : 0
                        ,itemsString
                        ,[[BootpayC dicToJsonString:params] replace:@"'" :@"\\'"]
                        ,order_id
                        ,use_order_id == true ? 1 : 0
                        ,account_expire_at
                        ,extraString];
    if([method length] != 0) { result = [NSString stringWithFormat:@"%@, method: '%@'", result, method]; }
    if([methods count] > 0) { result = [NSString stringWithFormat:@"%@, methods: '%@'", result, [self listToJson:methods]]; }
    result = [NSString stringWithFormat:@"%@, user_info: %@", result, [user toJson]];
    result = [NSString stringWithFormat:@"%@}).error(function (data) {webkit.messageHandlers.%@.postMessage(data);", result, bridgeName];
    result = [NSString stringWithFormat:@"%@}).confirm(function (data) {", result];
    result = [NSString stringWithFormat:@"%@webkit.messageHandlers.%@.postMessage(data);", result, bridgeName];
    result = [NSString stringWithFormat:@"%@}).ready(function (data) {", result];
    result = [NSString stringWithFormat:@"%@webkit.messageHandlers.%@.postMessage(data);", result, bridgeName];
    result = [NSString stringWithFormat:@"%@}).cancel(function (data) {", result];
    result = [NSString stringWithFormat:@"%@webkit.messageHandlers.%@.postMessage(data);", result, bridgeName];
    result = [NSString stringWithFormat:@"%@}).close(function () {", result];
    result = [NSString stringWithFormat:@"%@webkit.messageHandlers.%@.postMessage('close');", result, bridgeName];
    result = [NSString stringWithFormat:@"%@}).done(function (data) {", result];
    result = [NSString stringWithFormat:@"%@webkit.messageHandlers.%@.postMessage(data);", result, bridgeName];
    result = [NSString stringWithFormat:@"%@});", result];
    return result;
}


@end
