//
//  BootpayUnity.cpp
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 11..
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "BootpayCRequest.h"
#import "BootpayCWebView.h"
#import "BootpayCUser.h"



//extern UIViewController *UnityGetGLViewController();
//extern void UnitySendMessage(const char *, const char *, const char *);

@interface BootpayUnity : NSObject<BootpayCRequestProtocol, BootpayCControllerProtocol>
{
//    UIView <WebViewProtocol> *webView;
    BootpayCWebView *wv;
    NSString *gameObjectName;
    NSMutableDictionary *customRequestHeader;
    
    BootpayCRequest *request;
    BootpayCUser *user;
    BootpayCExtra *extra;
    NSMutableArray *items;
}

- (void) dismiss;
- (void) setApplicationId: (NSString *)applicationId;
- (void) setPrice: (double) price;
- (void) setPG: (NSString*)pg;
- (void) setItemName: (NSString*)name;
- (void) addItem: (NSString*)name :(int)qty :(NSString*) unique :(double)price :(NSString*) cat1 :(NSString*) cat2 :(NSString*) cat3;
- (void) setIsShowAgree: (bool)isShow;
- (void) useOrderId: (bool) use_order_id;
- (void) setMethod: (NSString*) method;
- (void) setMethods: (NSMutableArray*) methods;
- (void) setParams: (NSString*) params;
- (void) setUX: (NSString*) ux;
- (void) transactionConfirm;
- (void) bootpayRequest;
@end


@implementation BootpayUnity

- (id)initWithGameObjectName:(const char *)gameObjectName {
    wv = [[BootpayCWebView alloc] init];
    [wv setRequestSendable:self];
    [wv setControllerSendable:self];
    
    request = [[BootpayCRequest alloc] init];
    user = [[BootpayCUser alloc] init];
    extra = [[BootpayCExtra alloc] init];
    items = [[NSMutableArray alloc] init];
    
    //////////////
//    UIView *view = UnityGetGLViewController().view;
//    [view addSubview: wv];
    
    return self;
}


- (void) dismiss {
    [wv removePaymentWindow];
    [wv removeFromSuperview];
    wv = nil;
    gameObjectName = nil;
}


- (void) setApplicationId: (NSString *)applicationId {
    [BootpayCDefault setKey:@"application_id" :applicationId];
}

- (void) setPrice: (double) price {
    request.price = price;
}

- (void) setPG: (NSString*)pg {
    request.pg = pg;
}

- (void) setItemName: (NSString*)name {
    request.name = name;
}

- (void) addItem: (NSString*)name :(int)qty :(NSString*) unique :(double)price :(NSString*) cat1 :(NSString*) cat2 :(NSString*) cat3 {
    BootpayCItem *item = [[BootpayCItem alloc] init];
    item.item_name = name;
    item.qty = qty;
    item.unique = unique;
    item.price = price;
    item.cat1 = cat1;
    item.cat2 = cat2;
    item.cat3 = cat3;
    [items addObject: item];
}

- (void) setIsShowAgree: (bool)isShow {
    request.show_agree_window = isShow;
}

- (void) useOrderId: (bool) use_order_id {
    request.use_order_id = use_order_id;
}

- (void) setMethod: (NSString*) method {
    request.method = method;
}

- (void) setMethods: (NSMutableArray*) methods {
    request.methods = methods;
}

- (void) setParams: (NSString*) params {
//    request.params = params;
}

- (void) setUX: (NSString*) ux {
//    request.ux = ux;
}

- (void) transactionConfirm {
//    [wv transactionConfirm];
}

- (void) bootpayRequest {
    NSString *script = [request generateScript:C_BRIDGE_NAME :items :user :extra];
    [wv bootpayRequest:script];
}


- (void)onCancel:(nonnull NSDictionary *)data {
    
}

- (void)onClose {
    
}

- (void)onConfirm:(nonnull NSDictionary *)data {
    
}

- (void)onDone:(nonnull NSDictionary *)data {
    
}

- (void)onError:(nonnull NSDictionary *)data {
    
}

- (void)onReady:(nonnull NSDictionary *)data {
    
}

- (void)dismissController {
    
}

@end

extern "C" {
    void *_BootpayUnity_Init(const char *gameObjectName);
    void _BootpayUnity_Destroy(void *instance);
    void _BootpayUnity_SetApplicationId(void *instance, const char * applicationId);
    void _BootpayUnity_SetPrice(void *instance, double price);
    void _BootpayUnity_SetPG(void *instance, const char * pg);
    void _BootpayUnity_SetItemName(void *instance, const char * name);
    void _BootpayUnity_AddItem(void *instance, const char * name, int qty, const char * unique, double price, const char * cat1, const char * cat2, const char * cat3);
    void _BootpayUnity_SetIsShowAgree(void *instance, bool isShow);
    void _BootpayUnity_UseOrderId(void *instance, const char * use_order_id);
    void _BootpayUnity_SetMethod(void *instance, const char * method);
    void _BootpayUnity_SetMethods(void *instance, const char ** methods);
    void _BootpayUnity_SetParams(void *instance, const char * paramString);
    void _BootpayUnity_SetUX(void *instance, const char * ux);
    void _BootpayUnity_TransactionConfirm(void *instance);
    void _BootpayUnity_BootpayRequest(void *instance);
}

void *_BootpayUnity_Init(const char *gameObjectName) {
    id instance = [[BootpayUnity alloc] initWithGameObjectName:gameObjectName];
    return (__bridge_retained void *)instance;
}

void _BootpayUnity_Destroy(void *instance)
{
    BootpayUnity *bootpayUnity = (__bridge_transfer BootpayUnity *)instance;
    [bootpayUnity dismiss];
    bootpayUnity = nil;
}

void _BootpayUnity_SetApplicationId(void *instance, const char * applicationId) {
    BootpayUnity *bootpayUnity = (__bridge_transfer BootpayUnity *)instance;
    NSString *value = [NSString stringWithUTF8String: applicationId];
    [bootpayUnity setApplicationId: value];
}

void _BootpayUnity_SetPrice(void *instance, double price) {
    BootpayUnity *bootpayUnity = (__bridge_transfer BootpayUnity *)instance;
    [bootpayUnity setPrice: price];
}

void _BootpayUnity_SetPG(void *instance, const char * pg) {
    BootpayUnity *bootpayUnity = (__bridge_transfer BootpayUnity *)instance;
    NSString *value = [NSString stringWithUTF8String: pg];
    [bootpayUnity setPG: value];
}

void _BootpayUnity_SetItemName(void *instance, const char * name) {
    BootpayUnity *bootpayUnity = (__bridge_transfer BootpayUnity *)instance;
    NSString *value = [NSString stringWithUTF8String: name];
    [bootpayUnity setItemName: value];
}

void _BootpayUnity_AddItem(void *instance, const char * name, int qty, const char * unique, double price, const char * cat1, const char * cat2, const char * cat3) {
    BootpayUnity *bootpayUnity = (__bridge_transfer BootpayUnity *)instance;
    NSString *nameValue = [NSString stringWithUTF8String: name];
    NSString *uniqueValue = [NSString stringWithUTF8String: unique];
    NSString *cat1Value = [NSString stringWithUTF8String: cat1];
    NSString *cat2Value = [NSString stringWithUTF8String: cat2];
    NSString *cat3Value = [NSString stringWithUTF8String: cat3];
    [bootpayUnity addItem:nameValue :qty :uniqueValue :price :cat1Value :cat2Value :cat3Value];
}

void _BootpayUnity_SetIsShowAgree(void *instance, bool isShow) {
    BootpayUnity *bootpayUnity = (__bridge_transfer BootpayUnity *)instance;
    [bootpayUnity setIsShowAgree: isShow];
}

void _BootpayUnity_UseOrderId(void *instance, bool use_order_id) {
    BootpayUnity *bootpayUnity = (__bridge_transfer BootpayUnity *)instance;
    [bootpayUnity useOrderId: use_order_id];
}


void _BootpayUnity_SetMethod(void *instance, const char * method) {
    BootpayUnity *bootpayUnity = (__bridge_transfer BootpayUnity *)instance;
    NSString *value = [NSString stringWithUTF8String: method];
    [bootpayUnity setMethod: value];
}

void _BootpayUnity_SetMethods(void *instance, const char ** methods) {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    while(*methods != NULL) {
        NSString *value = [NSString stringWithUTF8String: *methods];
        [result addObject:value];
        methods++;
    }
    
    BootpayUnity *bootpayUnity = (__bridge_transfer BootpayUnity *)instance;
    [bootpayUnity setMethods: result];
}

void _BootpayUnity_SetParams(void *instance, const char * params) {
    BootpayUnity *bootpayUnity = (__bridge_transfer BootpayUnity *)instance;
    NSString *value = [NSString stringWithUTF8String: params];
    [bootpayUnity setParams: value];
}

void _BootpayUnity_SetUX(void *instance, const char * ux) {
    BootpayUnity *bootpayUnity = (__bridge_transfer BootpayUnity *)instance;
    NSString *value = [NSString stringWithUTF8String: ux];
    [bootpayUnity setUX: value];
}

void _BootpayUnity_TransactionConfirm(void *instance) {
    BootpayUnity *bootpayUnity = (__bridge_transfer BootpayUnity *)instance;
    [bootpayUnity transactionConfirm];
}

void _BootpayUnity_BootpayRequest(void *instance) {
    BootpayUnity *bootpayUnity = (__bridge_transfer BootpayUnity *)instance;
    [bootpayUnity bootpayRequest];
}
