//
//  BootpayCCController.m
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 4..
//

#import "BootpayCController.h"
#import "BootpayC.h"

 

@implementation NSString (LocalizedError)
- (NSString *) errorDescription {
    return self;
}
@end

@implementation NSString (Bootpay)
- (NSString *) replace: (NSString*)target :(NSString*)replace {
    return [self stringByReplacingOccurrencesOfString:target withString:replace];
}
@end

@implementation BootpayCController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *script = [request generateScript:C_BRIDGE_NAME :items :user :extra];
    NSLog(@"%@", script);
    [wv setFrame:  CGRectMake(0,
                              0,
                              [[UIScreen mainScreen] bounds].size.width,
                              [[UIScreen mainScreen] bounds].size.height)];

    [wv setRequestSendable: sendable];
    [wv setControllerSendable: self];
     
//    wv.requestSendable = sendable;
//    wv.controllerSendable = self;
    [self.view addSubview:wv];
    [wv bootpayRequest:script];
}

-(id)init{
    self = [super init];
    if(self){
        request = [[BootpayCRequest alloc] init];
        user = [[BootpayCUser alloc] init];
        extra = [[BootpayCExtra alloc] init];
        items = [[NSMutableArray alloc] init];
        wv = [[BootpayCWebView alloc] init];
        
//        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
//        [[config userContentController] addScriptMessageHandler:self name: C_BRIDGE_NAME];
//        wv = [[WKWebView alloc] initWithFrame: CGRectMake(0,
//                                                          0,
//                                                          [[UIScreen mainScreen] bounds].size.width,
//                                                          [[UIScreen mainScreen] bounds].size.height) configuration:config];
//        wv.UIDelegate = self;
//        wv.navigationDelegate = self;
        

    }
    return self;
}


- (void) setSendable:(id<BootpayCRequestProtocol>) value {
    sendable = value;
}

- (void) transactionConfirm:(NSDictionary*)data {
    NSString *json = [[BootpayC dicToJsonString: data] replace:@"'" :@"\\'"];
    [wv doJavascript:[NSString stringWithFormat:@"window.BootPay.transactionConfirm(%@);", json]];
}

- (void) removePaymentWindow {
    [wv doJavascript:@"window.BootPay.removePaymentWindow();"];
}

- (void) setRequest: (BootpayCRequest*)value {
    request = value;
}
- (void) setUser: (BootpayCUser*)value {
    user = value;
}

- (void) setExtra: (BootpayCExtra*)value {
    extra = value;
}


- (void) setItems: (NSMutableArray*)value {
    items = value;
}

- (void) dismissController {    
    [self dismissViewControllerAnimated:true completion:nil];
}


/////////////


//- (void) bootpayRequest: (NSString*) script {
//    bootpayScript = script;
//    [self loadUrl: C_BASE_URL];
//}
//
//
//- (void) doJavascript:(NSString*) script {
//    [wv evaluateJavaScript:script completionHandler:nil];
//}
//
//- (void) loadUrl:(NSString*) urlString {
//    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
//    [wv loadRequest:request];
//}
//
//
//- (void) registerAppId {
//    [self doJavascript:[NSString stringWithFormat: @"window.BootPay.setApplicationId('%@');", [BootpayCDefault getApplicationId]]];
//}
//
//- (void) setDevice {
//    [self doJavascript: @"window.BootPay.setDevice('IOS');"];
//}
//
//- (void) setAnalytics {
//    if([BootpayCDefault getSkTime] == 0) {
//        NSLog(@"Bootpay Analytics Warning: setAnalytics() not Work!! Please session active in AppDelegate");
//        return;
//    }
//
//    [self doJavascript:[NSString stringWithFormat:@"window.BootPay.setAnalyticsData({sk: '%@', sk_time: %ld, time: %ld, uuid: '%@'});", [BootpayCDefault getSk], [BootpayCDefault getSkTime], [BootpayCDefault getTime], [BootpayCDefault getUUID]]];
//}
//
//- (void) loadBootapyRequest {
//    [self doJavascript:bootpayScript];
//}
//
//- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
//    if (firstLoad == false) {
//        firstLoad = true;
//        [self registerAppId];
//        [self setDevice];
//        [self setAnalytics];
//        [self loadBootapyRequest];
//    }
//}
//
//
//- (BOOL) isMatch: (NSString *) urlString :(NSString *) pattern {
//    NSRange range = [urlString rangeOfString:pattern options:NSRegularExpressionSearch];
//    return range.location != NSNotFound;
//}
//
//- (BOOL) isItunesURL: (NSString*) urlString {
//    return [self isMatch:urlString :@"\\/\\/itunes\\.apple\\.com\\/"];
//}
//
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
//    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
//        if (navigationAction.request.URL) {
//            NSLog(@"%@", navigationAction.request.URL.host);
//            if (![navigationAction.request.URL.resourceSpecifier containsString:@"ex path"]) {
//                if ([[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL]) {
//                    UIApplication *application = [UIApplication sharedApplication];
//                    [application openURL:navigationAction.request.URL options:@{} completionHandler:nil];
//                    decisionHandler(WKNavigationActionPolicyCancel);
//                }
//            } else {
//                decisionHandler(WKNavigationActionPolicyAllow);
//            }
//        }
//
////        NSURL *url = [navigationAction.request URL];
////        if([self isItunesURL: url.absoluteString]) {
////            if (@available(iOS 10.0, *)) {
////                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
////            } else {
////                [[UIApplication sharedApplication] openURL:url];
////                // Fallback on earlier versions
////            }
////            decisionHandler(WKNavigationActionPolicyCancel);
////        } else if(![url.absoluteString hasPrefix:@"http:"] && ![url.absoluteString hasPrefix:@"https:"]) {
////            if (@available(iOS 10.0, *)) {
////                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
////            } else {
////                // Fallback on earlier versions
////                [[UIApplication sharedApplication] openURL:url];
////            }
////            decisionHandler(WKNavigationActionPolicyCancel);
////        } else {
////            decisionHandler(WKNavigationActionPolicyAllow);
////        }
//    } else {
//        decisionHandler(WKNavigationActionPolicyAllow);
//    }
//}
//
////alert
//- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
//{
//
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
//                                                                             message:message
//                                                                      preferredStyle:UIAlertControllerStyleAlert];
//    [alertController addAction: [UIAlertAction actionWithTitle:@"확인"
//                                                         style:UIAlertActionStyleDefault
//                                                       handler:^(UIAlertAction *action) {
//                                                           completionHandler();
//                                                       }]];
//
//    [alertController addAction: [UIAlertAction actionWithTitle:@"결제창 닫기"
//                                                         style:UIAlertActionStyleCancel
//                                                       handler:^(UIAlertAction *action) {
//                                                           completionHandler();
//                                                           //                                                           [parentController dismiss];
//                                                       }]];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self presentViewController:alertController animated:true completion:nil];
////        if(self->parentController != nil) {
////            [self->parentController presentViewController:alertController animated:true completion:nil];
////        }
//        //                self.parentController.present(alertController, animated: true, completion: nil)
//    });
//}
//
//// confirm
//- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
//{
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
//                                                                             message:message
//                                                                      preferredStyle:UIAlertControllerStyleAlert];
//    [alertController addAction:[UIAlertAction actionWithTitle:@"확인"
//                                                        style:UIAlertActionStyleDefault
//                                                      handler:^(UIAlertAction *action) {
//                                                          completionHandler(YES);
//                                                      }]];
//    [alertController addAction:[UIAlertAction actionWithTitle:@"취소"
//                                                        style:UIAlertActionStyleCancel
//                                                      handler:^(UIAlertAction *action) {
//                                                          completionHandler(NO);
//                                                      }]];
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self presentViewController:alertController animated:true completion:nil];
////        if(self->parentController != nil) {
////            [self->parentController presentViewController:alertController animated:true completion:nil];
////        }
//    });
//}
//
//- (void)userContentController:(WKUserContentController *)userContentController
//      didReceiveScriptMessage:(WKScriptMessage *)message {
//    if([message.name isEqualToString:C_BRIDGE_NAME]) {
//        if (message.body == nil) { return; }
//        if ([@"close" isEqualToString: message.body]) {
//            if(sendable != nil) { [sendable onClose]; }
//            return;
//        }
//        NSString * action = [message.body objectForKey:@"action"];
//        if ([@"BootpayCancel" isEqualToString: action]) {
//            if(sendable != nil) { [sendable onCancel: message.body]; }
//        } else if([@"BootpayError" isEqualToString: action]) {
//            if(sendable != nil) { [sendable onError: message.body]; }
//        } else if([@"BootpayBankReady" isEqualToString: action]) {
//            if(sendable != nil) { [sendable onReady: message.body]; }
//        } else if([@"BootpayConfirm" isEqualToString: action]) {
//            if(sendable != nil) { [sendable onConfirm: message.body]; }
//        } else if([@"BootpayDone" isEqualToString: action]) {
//            if(sendable != nil) { [sendable onDone: message.body]; }
//        }
//    }
//}
//
//- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
//    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
//        if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust){
//            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
//            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
//        }
//    } else {
//        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
//    }
//}
//
//- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration*)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures*)windowFeatures {
//    NSURL *url = [navigationAction.request URL];
//    if (@available(iOS 10.0, *)) {
//        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
//    } else {
//        [[UIApplication sharedApplication] openURL:url];
//    }
//    return nil;
//}

@end
