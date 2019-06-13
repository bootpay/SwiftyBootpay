//
//  BootpayCWebView.m
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 5..
//

#import "BootpayCWebView.h"

@implementation BootpayCWebView

//@synthesize requestSendable, controllerSendable;

-(id)init{
    self = [super init];
    if(self){        
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy: NSHTTPCookieAcceptPolicyAlways];
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        [[config userContentController] addScriptMessageHandler:self name: C_BRIDGE_NAME];
//        [self configuration]
//        [self initWithFrame:CGRectMake(0,
//                                       0,
//                                       [[UIScreen mainScreen] bounds].size.width,
//                                       [[UIScreen mainScreen] bounds].size.height) configuration:config];
//        self.configuration = config;
        
        wv = [[WKWebView alloc] initWithFrame: CGRectMake(0,
                                                          0,
                                                          [[UIScreen mainScreen] bounds].size.width,
                                                          [[UIScreen mainScreen] bounds].size.height) configuration:config];
//        wv = [[WKWebView alloc] initWithFrame: self.frame configuration:config];
        
//        [wv setBackgroundColor:[UIColor redColor]];
//        [self setBackgroundColor:[UIColor yellowColor]];
        [wv setUIDelegate:self];
        [wv setNavigationDelegate:self];
        [self addSubview: wv];
//
    }
    return self;
}

- (void) setRequestSendable: (id<BootpayCRequestProtocol>) value {
    requestSendable = value;
}

- (void) setControllerSendable: (id<BootpayCControllerProtocol>) value {
    controllerSendable = value;
}


- (void) bootpayRequest: (NSString*) script { 
    
    bootpayScript = script;
    [self loadUrl: C_BASE_URL];
}

- (void) doJavascript:(NSString*) script {
    [wv evaluateJavaScript:script completionHandler:nil];
}

- (void) loadUrl:(NSString*) urlString {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [wv loadRequest:request];
}


- (void) registerAppId {
    [self doJavascript:[NSString stringWithFormat: @"window.BootPay.setApplicationId('%@');", [BootpayCDefault getApplicationId]]];
}

- (void) setDevice {
    [self doJavascript: @"window.BootPay.setDevice('IOS');"];
}

- (void) setAnalytics {
    if([BootpayCDefault getSkTime] == 0) {
        NSLog(@"Bootpay Analytics Warning: setAnalytics() not Work!! Please session active in AppDelegate");
        return;
    }
    
    [self doJavascript:[NSString stringWithFormat:@"window.BootPay.setAnalyticsData({sk: '%@', sk_time: %ld, time: %ld, uuid: '%@'});", [BootpayCDefault getSk], [BootpayCDefault getSkTime], [BootpayCDefault getTime], [BootpayCDefault getUUID]]];
}

- (void) loadBootapyRequest {
    [self doJavascript:bootpayScript];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    if (firstLoad == false) {
        firstLoad = true;
        [self registerAppId];
        [self setDevice];
        [self setAnalytics];
        [self loadBootapyRequest];
    }
}
//- (void)webViewDidFinishLoad:(UIWebView *)uiWebView {
//    if (firstLoad == false) {
//        firstLoad = true;
//        [self registerAppId];
//        [self setDevice];
//        [self setAnalytics];
//        [self loadBootapyRequest];
//    }
//}

- (BOOL) isMatch: (NSString *) urlString :(NSString *) pattern {
    NSRange range = [urlString rangeOfString:pattern options:NSRegularExpressionSearch];
    return range.location != NSNotFound;
}

- (BOOL) isItunesURL: (NSString*) urlString {
    return [self isMatch:urlString :@"\\/\\/itunes\\.apple\\.com\\/"];
}

- (void)webView:(WKWebView *)wkWebView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = [navigationAction.request URL];
    if([self isItunesURL: url.absoluteString]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:url];
            // Fallback on earlier versions
        }
        decisionHandler(WKNavigationActionPolicyCancel);
    } else if(![url.absoluteString hasPrefix:@"http:"] && ![url.absoluteString hasPrefix:@"https:"]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } else {
            // Fallback on earlier versions
            [[UIApplication sharedApplication] openURL:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

//alert
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction: [UIAlertAction actionWithTitle:@"확인"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
                                                           completionHandler();
                                                       }]];
    
    [alertController addAction: [UIAlertAction actionWithTitle:@"결제창 닫기"
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *action) {
                                                           completionHandler();
                                                           //                                                           [parentController dismiss];
                                                       }]];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self->controllerSendable != nil) {
            [self->controllerSendable dismissController];
        }  
    });
}

// confirm
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"확인"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler(YES);
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"취소"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler(NO);
                                                      }]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self->controllerSendable != nil) {
            [self->controllerSendable dismissController];
        }
    });
}

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    if([message.name isEqualToString:C_BRIDGE_NAME]) {
        if (message.body == nil) { return; }
        if ([@"close" isEqualToString: message.body]) {
            if(requestSendable != nil) { [requestSendable onClose]; }
            return;
        }
        NSString * action = [message.body objectForKey:@"action"];
        if ([@"BootpayCancel" isEqualToString: action]) {
            if(requestSendable != nil) {
                [requestSendable onCancel: message.body];
            }
            
            if(controllerSendable != nil) {
                [controllerSendable dismissController];
            }
        } else if([@"BootpayError" isEqualToString: action]) {
            if(requestSendable != nil) { [requestSendable onError: message.body]; }
        } else if([@"BootpayBankReady" isEqualToString: action]) {
            if(requestSendable != nil) { [requestSendable onReady: message.body]; }
        } else if([@"BootpayConfirm" isEqualToString: action]) {
            if(requestSendable != nil) { [requestSendable onConfirm: message.body]; }
        } else if([@"BootpayDone" isEqualToString: action]) {
            if(requestSendable != nil) { [requestSendable onDone: message.body]; }
        }
    }
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust){
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        }
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}
 

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration*)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures*)windowFeatures {
    NSURL *url = [navigationAction.request URL];
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:url];
    }
    return nil;
}

@end
