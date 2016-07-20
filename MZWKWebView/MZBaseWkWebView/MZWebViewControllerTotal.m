//
//  MZWebViewController.m
//  CaiHeAPP
//
//  Created by Mr.Yang on 16/4/20.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "MZWebViewController.h"
#import "JPUSHService.h"



#import "AppDelegate.h"
#import "LoginViewController.h"

//#import "UIScrollView+UITouch.h"

@interface MZWebViewController()

@property (nonatomic, strong)UIWebView * webView;
    
@end

@implementation MZWebViewController
//打电话使用
-(UIWebView *)webView{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:DEVICE_BOUNDS];
        //        [[[UIApplication sharedApplication].delegate window] addSubview:_webView];
    }
    return _webView;
}
//加载网页
- (void)setUrlName:(NSString *)urlName{
    _urlName = urlName;
    NSURLRequest * request = [MyTool loadUrlName:urlName];
    
    [self.WKView loadRequest:request];
}

- (void)setUrl:(NSString *)url{
    _url = url;
    [self.WKView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (MBProgressHUD *)hud{
    if (!_hud) {
        
        _hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:1];
//        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:1];
    }
    return _hud;
}
- (WKWebViewConfiguration *)configuretion{
    if (!_configuretion) {
        // 创建一个webiview的配置项
        _configuretion = [[WKWebViewConfiguration alloc] init];
        // Webview的偏好设置
        _configuretion.preferences = [[WKPreferences alloc] init];
        _configuretion.preferences.minimumFontSize = 15;//修改文字大小
        _configuretion.preferences.javaScriptEnabled = true;
        // 默认是不能通过JS自动打开窗口的，必须通过用户交互才能打开
        _configuretion.preferences.javaScriptCanOpenWindowsAutomatically = false;
        _configuretion.processPool = [[WKProcessPool alloc] init];//内容处理池
        // 通过js与webview内容交互配置
        _configuretion.userContentController = [[WKUserContentController alloc] init];
        [_configuretion.userContentController addScriptMessageHandler:self name:@"setTitle"];
        [_configuretion.userContentController addScriptMessageHandler:self name:@"reLogin"];
    }
    
    return _configuretion;
}
- (WKWebView *)WKView
{
    if (!_WKView) {
        _WKView = [[WKWebView alloc] initWithFrame:[UIScreen mainScreen].bounds configuration:self.configuretion];
        [self.view addSubview:_WKView];
        
        _WKView.navigationDelegate = self;
        _WKView.UIDelegate = self;
        _WKView.scrollView.delegate = self;
        _WKView.scrollView.bounces = 0;
        _WKView.scrollView.showsVerticalScrollIndicator = 0;
        _WKView.scrollView.showsHorizontalScrollIndicator = 0;
        [self.view addSubview:_WKView];
    }
    return _WKView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
}
#pragma mark- WKNavigationDelegate
//// 类型，在请求先判断能不能跳转（请求）
// 决定导航的动作，通常用于处理跨域的链接能否导航。WebKit对跨域进行了安全检查限制，不允许跨域，因此我们要对不能跨域的链接
// 单独处理。但是，对于Safari是允许跨域的，不用这么处理。
// 这个是决定是否Request
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    self.hud.labelText = @"加载中";
    //获取链接
    NSURL * url = navigationAction.request.URL;
    NSLog(@"url ----- %@", url);
    decisionHandler(WKNavigationActionPolicyAllow);//允许页内条转
    
}
// 在响应完成时，会回调此方法
// 决定是否接收响应
// 这个是决定是否接收response
// 要获取response，通过WKNavigationResponse对象获取
// 如果设置为不允许响应，web内容就不会传过来
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
    NSLog(@"%s", __FUNCTION__);
}
//当主框架导航开始时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    
    self.hud.labelText = @"加载中";
}

// 接收到重定向时会回调
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%s", __FUNCTION__);
}

//当开始加载数据时，会调用一个错误时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    [self hiddenFHL];
}

// 页面内容到达main frame时回调
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%s", __FUNCTION__);
}

//当主框架导航完成时，调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    [self hiddenFHL];
    
    if (self.WKView.title != nil && ![self.WKView.title  isEqual: @""] && ![self.WKView.title  isEqual: @"无"]) {
        [self setNavBarTitle:self.WKView.title];
    }
    else
    {
        [self setNavBarTitle:@""];
    }
    
    [webView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none';" completionHandler:nil];//禁用用户选择
    [webView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];//禁用长按弹出框
    //    [webView evaluateJavaScript:@"document.getElementById('titlebar').style.display = 'none';" completionHandler:nil];//隐藏titlebar
    //    [webView evaluateJavaScript:@"document.getElementById('back').href" completionHandler:nil];//获取back
}
// 导航失败时会回调
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"error");
}
// 对于HTTPS的都会触发此代理，如果不要求验证，传默认就行
// 如果需要证书验证，与使用AFN进行HTTPS证书验证是一样的
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler {
    NSLog(@"%s", __FUNCTION__);
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

// 9.0才能使用，web内容处理中断时会触发
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    NSLog(@"%s", __FUNCTION__);
}
//// 当web content处理完成时，会回调
//- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView NS_AVAILABLE(10_11, 9_0) {
//    NSLog(@"ddddd");
//}
#pragma mark-JS回调 -WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
     [self hiddenFHL];
    NSLog(@"-----name---%@\n---------Message---%@", message.name, message.body);
//    [self hiddenFHL];
    
    if ([message.name isEqualToString:@"setTitle"]) {//设置标题
        self.title = message.body;
    }
    else if ([message.name isEqualToString:@"reLogin"]){//登录失效
        //失效，退出到登录界面
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            //弹出提示框
            [weakSelf sessionInvalue];
        });
    } else if ([message.name isEqualToString:@"callPhone"]) {//打电话
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            //弹出提示框
            [weakSelf callPhone:message.body];
        });
    }
    
}


#define mark - WKUIDelegate
// 创建新的webview
// 可以指定配置对象、导航动作对象、window特性
#pragma mark-解决iOS8无法显示
-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    //防止超链接无效
    WKFrameInfo * frameInfo = navigationAction.targetFrame;
    if (![frameInfo isMainFrame]) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

// webview关闭时回调
- (void)webViewDidClose:(WKWebView *)webView NS_AVAILABLE(10_11, 9_0){
    NSLog(@"bbbbb");
    
}
// 这个方法是在HTML中调用了JS的alert()方法时，就会回调此API。
// 注意，使用了`WKWebView`后，在JS端调用alert()就不会在HTML
// 中显示弹出窗口。因此，我们需要在此处手动弹出ios系统的alert。
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    [self hiddenFHL];
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // We must call back js
        completionHandler();
    }]];
    [self presentViewController:alert animated:1 completion:nil];
}
// JS端调用confirm函数时，会触发此方法
// 通过message可以拿到JS端所传的数据
// 在iOS端显示原生alert得到YES/NO后
// 通过completionHandler回调给JS端
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    NSLog(@"%s", __FUNCTION__);
    [self hiddenFHL];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnullaction) {
        completionHandler(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnullaction) {
        completionHandler(NO);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
    
    NSLog(@"%@", message);
}
// JS端调用prompt函数时，会触发此方法
// 要求输入一段文本
// 在原生输入得到文本内容后，通过completionHandler回调给JS
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullableresult))completionHandler {
    NSLog(@"%s", __FUNCTION__);
    
    NSLog(@"%@", prompt);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"textinput"message:@"JS调用输入框"preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _NonnulltextField) {
//        textField.textColor = [UIColor redColor];
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnullaction) {
        completionHandler([[alert.textFields lastObject]text]);
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
}










//app调用js
- (void)toJavaScript:(WKWebView*)wkView :(NSString *)jsStr{
    [wkView evaluateJavaScript:jsStr completionHandler:nil];
}
//在键盘或者其他控件(下拉框)弹出时禁止webview里面的Content向上移动
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    [self hiddenFHL];//弹出sheet的时候调用
    return nil;
}
//- (void)webViewDidStartLoad:(UIWebView *)webView{
//    [self.activityIndicator startAnimating];
//}
//- (void)webViewDidFinishLoad:(UIWebView *)webView{
//    [self.activityIndicator stopAnimating];
//}
//设置标题
- (void)setNavBarTitle:(NSString *)barTitle{
    if (![barTitle isEqualToString:@""]) {
        self.navigationItem.title = barTitle;
    }
}
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
//    NSString * url = [request.URL absoluteString];
//    if ([url hasPrefix:@"tel://"] || [url hasPrefix:@"sms://"]) {
//        [[UIApplication sharedApplication] openURL:request.URL];
//        return false;
//    }
//    return true;
//}

//其他操作，隐藏风火轮
- (void)hiddenFHL{
    if (!_hud) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{

            [weakSelf.hud hide:0];
            weakSelf.hud = nil;
    });
}



//session失效，退出到登录界面

- (void)sessionInvalue
{
    __weak typeof(self) weakSelf = self;
    UIAlertController * warning  =[UIAlertController alertControllerWithTitle:@"提示" message:@"身份信息失效，请重新登录" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf toLoginWithSessionInval];
    }];
    [warning addAction:cancelAction];
    [self presentViewController:warning animated:YES completion:nil];
    
}
- (void)toLoginWithSessionInval{
    [MyTool logOutToLoginWithController:self];
}

#pragma mark-拨打电话
- (void)callPhone:(NSString *)number{
    [self hiddenFHL];
    NSLog(@"打电话：%@", number);
    if (![MyTool canCallPhone]) {
        [MyTool showWarningInformationTitle:@"提示" message:@"您的设备不支持电话功能" intoView:self];
        return;
    }
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", number]]]];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//
//    [self.view endEditing:1];
//}


@end