//
//  BootpayCUX.m
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 4..
//

#import "BootpayCUX.h"

@implementation BootpayCUX


+ (NSString*) valueOfUX:(int)val {
    switch (val) {
        case PG_DIALOG:
            return @"PG_DIALOG";
            break;
        case PG_SUBSCRIPT:
            return @"PG_SUBSCRIPT";
            break;
        case PG_SUBSCRIPT_RESERVE:
            return @"PG_SUBSCRIPT_RESERVE";
            break;
        case BOOTPAY_DIALOG:
            return @"BOOTPAY_DIALOG";
            break;
        case BOOTPAY_ROCKET:
            return @"BOOTPAY_ROCKET";
            break;
        case BOOTPAY_ROCKET_TEMPORARY:
            return @"BOOTPAY_ROCKET_TEMPORARY";
            break;
        case BOOTPAY_REMOTE_LINK:
            return @"BOOTPAY_REMOTE_LINK";
            break;
        case BOOTPAY_REMOTE_ORDER:
            return @"BOOTPAY_REMOTE_ORDER";
            break;
        case BOOTPAY_REMOTE_PRE:
            return @"BOOTPAY_REMOTE_PRE";
            break;
        case APP2APP_REMOTE:
            return @"APP2APP_REMOTE";
            break;
        case APP2APP_CARD_SIMPLE:
            return @"APP2APP_CARD_SIMPLE";
            break;
        case APP2APP_NFC:
            return @"APP2APP_NFC";
            break;
        case APP2APP_SAMSUNGPAY:
            return @"APP2APP_SAMSUNGPAY";
            break;
        case APP2APP_SUBSCRIPT:
            return @"APP2APP_SUBSCRIPT";
            break;
        case APP2APP_CASH_RECEIPT:
            return @"APP2APP_CASH_RECEIPT";
            break;
        case APP2APP_OCR:
            return @"APP2APP_OCR";
            break;
        case NONE:
            return @"NONE";
            break;
        default:
            return @"NONE";
            break;
    }
}


@end

