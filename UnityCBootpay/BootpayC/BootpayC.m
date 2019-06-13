//
//  BootpayC.m
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 5..
//

#import "BootpayC.h"

@interface BootpayC ()

@end

@implementation BootpayC

static id sharedInstance;

- (NSString*)toBase64:(NSString*)value
{
    NSData *plainData = [value dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String;
    if ([plainData respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
        base64String = [plainData base64EncodedStringWithOptions:kNilOptions];  // iOS 7+
    } else {
        base64String = [plainData base64Encoding];                              // pre iOS7
    }
    
    return base64String;
}

+ (id) sharedInstance {
    if (self == [BootpayC class]) {
        if(sharedInstance == nil) {
            sharedInstance = [[self alloc] init];
        }        
    }
    return sharedInstance;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(id)init{
    self = [super init];
    if(self){
        ver = @"3.0.4";
        user = [[BootpayCUser alloc] init];
        key = [self getRandomKey:32];
        iv = [self getRandomKey:16];
    }
    return self;
}

- (void) loadSessionValues {
    [self loadUuid];
    [self loadSkTime];
    
}

- (void) loadUuid {
    uuid = [BootpayCDefault getUUID];
    if([@"" isEqualToString:uuid]) { 
        uuid = [[NSUUID UUID] UUIDString];
        [BootpayCDefault setKey:@"uuid" :uuid];
    }
}

- (void) loadSkTime {
    [self loadLastTime];
    

}

- (void) updateSkTime:(double) val {
    time = val;
    sk = [NSString stringWithFormat:@"%@_%f", uuid, time];
    [BootpayCDefault setKey:@"sk" :sk];
    [BootpayCDefault setKeyDouble:@"sk_time" :sk_time];
}

- (void) loadLastTime {
    double currentTime = [BootpayCDefault getLastTime];
    if (last_time != 0 && fabs(last_time - currentTime) >= 30 * 60 * 1000) {
        time = currentTime - last_time;
        last_time = currentTime;
        [BootpayCDefault setKeyDouble:@"time" :time];
        [BootpayCDefault setKeyDouble:@"last_time" :last_time];
        [self updateSkTime:currentTime];
    } else if (sk_time == 0) {
        [self updateSkTime:currentTime];
    }
}

- (double) currentTimeInMiliseconds {
    return [[NSDate date] timeIntervalSince1970] * 1000;
}

- (NSString*) getRandomKey:(int)len {
    NSString *keys = @"abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *result = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [result appendFormat: @"%C", [keys characterAtIndex: arc4random_uniform((uint32_t)[keys length])]];
    }
    return result;
}

- (NSString*) getSessionKey {
    return [NSString stringWithFormat:@"%@##%@", [self toBase64: key], [self toBase64: iv]];
}

+ (NSString*) dicToJsonString:(NSDictionary*) dic {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: dic
                                                       options: 0
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"%s: error: %@", __func__, error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

+ (void) appLanch:(NSString*) application_id {
    [BootpayCDefault setKey:@"application_id" :application_id];
}

+ (void) sessionActive:(BOOL) active {
    if(active == true) {
        [[self sharedInstance] loadSessionValues];
    } else {
        [BootpayCDefault setKeyDouble:@"last_time" :[[self sharedInstance] currentTimeInMiliseconds]];
    }    
}


@end
