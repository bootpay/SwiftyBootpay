//
//  BootpayCWebView.m
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 5. 31..
//

#import <UIKit/UIKit.h>
@import WebKit;


//extern UIViewController *UnityGetGLViewController();
//extern void UnitySendMessage(const char *, const char *, const char *);

NSString * const BASE_URL = @"https://inapp.bootpay.co.kr/3.0.0/production.html";
NSString * const BRIDGE_NAME = @"Bootpay_iOS";

@protocol BootpayCRequestProtocol <NSObject>

- (void) onError:(NSDictionary *)data;
- (void) onReady:(NSDictionary *)data;
- (void) onClose;
- (void) onConfirm:(NSDictionary *)data;
- (void) onCancel:(NSDictionary *)data;
- (void) onDone:(NSDictionary *)data;

@end

@interface BootpayCWebView: UIView <UIWebViewDelegate, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>{
    WKWebView *wv;
    bool firstLoad;
    id<BootpayCRequestProtocol> sendable;
    NSString *bootpayScript;
}
@end

@implementation BootpayCWebView
- (void) bootpayRequest: (NSString*) script {
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy: NSHTTPCookieAcceptPolicyAlways];
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    [[config userContentController] addScriptMessageHandler:self name: BRIDGE_NAME];
    
    wv = [[WKWebView alloc] initWithFrame:self.bounds configuration:config];
    [wv setUIDelegate:self];
    [wv setNavigationDelegate:self];
    [self addSubview:wv];
    bootpayScript = script;
    [self loadUrl:BASE_URL];
}

- (void) doJavascript:(NSString*) script {
    [wv evaluateJavaScript:script completionHandler:nil];
}

- (void) loadUrl:(NSString*) urlString {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [wv loadRequest:request];
}

- (NSString*) getApplicationId {
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:@"application_id"];
    return value == nil ? @"" : (NSString*) value;
}

- (NSString*) getUUID {
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:@"uuid"];
    return value == nil ? @"" : (NSString*) value;
}

- (NSString*) getSk {
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:@"sk"];
    return value == nil ? @"" : (NSString*) value;
}

- (int) getSkTime {
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:@"sk_time"];
    return value == nil ? 0 : (int) value;
}

- (int) getTime {
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:@"time"];
    return value == nil ? 0 : (int) value;
}

- (void) registerAppId {
    [self doJavascript:[NSString stringWithFormat: @"window.BootPay.setApplicationId('%@');", [self getApplicationId]]];
}

- (void) setDevice {
    [self doJavascript: @"window.BootPay.setDevice('IOS');"];
}

- (void) setAnalytics {
    if([self getSkTime] == 0) {
        NSLog(@"Bootpay Analytics Warning: setAnalytics() not Work!! Please session active in AppDelegate");
        return;
    }
    
    [self doJavascript:[NSString stringWithFormat:@"window.BootPay.setAnalyticsData({sk: '%@', sk_time: %d, time: %d, uuid: '%@'});", [self getSk], [self getSkTime], [self getTime], [self getUUID]]];
}

- (void) loadBootapyRequest {
    [self doJavascript:bootpayScript];
}

- (void)webViewDidFinishLoad:(UIWebView *)uiWebView {
    if (firstLoad == false) {
        firstLoad = true;
        [self registerAppId];
        [self setDevice];
        [self setAnalytics];
        [self loadBootapyRequest];
    }
}

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
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else if(![url.absoluteString hasPrefix:@"http:"] && ![url.absoluteString hasPrefix:@"https:"]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction: [UIAlertAction actionWithTitle:@"OK"
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *action) {
                                                           completionHandler();
                                                       }]];
    [UnityGetGLViewController() presentViewController:alertController animated:YES completion:^{}];
}

@end



