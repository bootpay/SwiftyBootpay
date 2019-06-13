//
//  BootpayCWebView.h
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 5..
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "BootpayCDefault.h"
//#import "BootpayCController.h"

NS_ASSUME_NONNULL_BEGIN


#define iOS_UNITY 1

#define C_BASE_URL @"https://inapp.bootpay.co.kr/3.0.4/production.html"
//#define C_BASE_URL @"https://www.naver.com"
#define C_BRIDGE_NAME @"Bootpay_iOS"

//NSString * const C_BASE_URL = @"https://inapp.bootpay.co.kr/3.0.4/production.html";
//NSString * const C_BRIDGE_NAME = @"Bootpay_iOS";

@protocol BootpayCRequestProtocol
- (void) onError:(NSDictionary *)data;
- (void) onReady:(NSDictionary *)data;
- (void) onClose;
- (void) onConfirm:(NSDictionary *)data;
- (void) onCancel:(NSDictionary *)data;
- (void) onDone:(NSDictionary *)data;
@end

@protocol BootpayCControllerProtocol
- (void) dismissController;
@end

@interface BootpayCWebView : UIView <WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>{
    WKWebView *wv;
    bool firstLoad;
    id<BootpayCRequestProtocol> requestSendable;
    id<BootpayCControllerProtocol> controllerSendable;
    NSString *bootpayScript;
}

- (void) doJavascript:(NSString*) script;
- (void) bootpayRequest: (NSString*) script;
- (void) transactionConfirm:(NSDictionary*)data;
- (void) removePaymentWindow;
- (void) dismiss;
- (BOOL) isPayingNow;
//- (void) setParentController: (BootpayCController*) controller;

//@property (nonatomic, retain) WKWebView *wv;
//@property (nonatomic, weak) id requestSendable;
//@property (nonatomic, weak) id controllerSendable;
- (void) setRequestSendable: (id<BootpayCRequestProtocol>) value;
- (void) setControllerSendable: (id<BootpayCControllerProtocol>) value;

@end

NS_ASSUME_NONNULL_END
