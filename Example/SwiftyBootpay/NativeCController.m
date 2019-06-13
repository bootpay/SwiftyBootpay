//
//  NativeCControllerViewController.m
//  SwiftyBootpay_Example
//
//  Created by YoonTaesup on 2019. 6. 5..
//  Copyright © 2019년 CocoaPods. All rights reserved.
//

#import "NativeCController.h"

@interface NativeCController ()

@end

@implementation NativeCController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUI];
}

- (void) setUI {
    NSArray* nameArr = [NSArray arrayWithObjects: @"Native 결제요청", @"RemoteLink 결제", @"RemoteOrder 결제", @"RemotePre 결제", nil];
    int i = 0;
    for(NSString *name in nameArr) {
        UIButton *button = [UIButton buttonWithType: UIButtonTypeSystem];
        button.frame = CGRectMake(0, 60 + 100 * i, self.view.frame.size.width, 100);
        [button setTitle: name forState: UIControlStateNormal];
        [button addTarget:self action: [self getButtonEvent:i] forControlEvents:UIControlEventTouchUpInside];
        i++;
        [self.view addSubview:button];
    }
    
    
    
}

- (SEL) getButtonEvent:(int)tag {
    if(tag == 0) return @selector(nativeClick);
    else if(tag == 1) return @selector(remoteLinkClick);
    else if(tag == 2) return @selector(remoteOrderClick);
    else if(tag == 3) return @selector(remotePreClick);
    return @selector(nativeClick);
}

- (void) sendAnaylticsUserLogin {
    
}

- (void) sendAnaylticsPageCall {
    
}

- (void) nativeClick {
    BootpayCItem *item1 = [[BootpayCItem alloc] init];
    item1.item_name = @"미키마우스";
    item1.qty = 1;
    item1.unique = @"ITEM_CODE_MOUSE";
    item1.price = 1000;
    
    NSMutableArray *items = [NSMutableArray arrayWithObjects:item1, nil];
    
    BootpayCUser *user = [[BootpayCUser alloc] init];
    user.username = @"사용자 이름";
    user.email = @"user1234@gmail.com";
    user.area = @"서울";
    user.phone = @"010-1234-5678";
    
    
    BootpayCRequest *request = [[BootpayCRequest alloc] init];
    request.price = 1000;
    request.name = @"마스카라";
    request.order_id = @"1243_1234";
    request.pg = @"danal";
//    [request setPg:@"inicis"];
    request.show_agree_window = false;
    request.method = @"phone";
    
    BootpayCExtra *extra = [[BootpayCExtra alloc] init];
    extra.quotas = [NSMutableArray arrayWithObjects: 0, 2, 3, nil];
    
    BootpayCController *vc = [[BootpayCController alloc] init];
    [vc setRequest: request];
    [vc setUser: user];
    [vc setExtra: extra];
    [vc setSendable:self];
    [vc setItems:items];
    [self presentViewController:vc animated:true completion:nil];
    
    
}

- (void) remoteLinkClick {
    
}

- (void) remoteOrderClick {
    
}

- (void) remotePreClick {
    
}

- (void) presentBootpayController {
    
}


- (void) onError:(NSDictionary *)data {
    NSLog(@"%@", data);
}

- (void) onReady:(NSDictionary *)data {
    NSLog(@"%@", data);
}

- (void) onClose {
    
}

- (void) onConfirm:(NSDictionary *)data  {
    NSLog(@"%@", data);
}

- (void) onCancel:(NSDictionary *)data  {
    NSLog(@"%@", data);
}

- (void) onDone:(NSDictionary *)data  {
    NSLog(@"%@", data);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
