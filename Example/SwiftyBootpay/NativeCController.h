//
//  NativeCControllerViewController.h
//  SwiftyBootpay_Example
//
//  Created by YoonTaesup on 2019. 6. 5..
//  Copyright © 2019년 CocoaPods. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BootpayCController.h"

//#import "RemoteOrderCPre.h"

NS_ASSUME_NONNULL_BEGIN

@interface NativeCController : UIViewController <BootpayCRequestProtocol> {
    BootpayCController *vc;
}


@end

NS_ASSUME_NONNULL_END
