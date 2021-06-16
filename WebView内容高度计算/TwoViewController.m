//
//  TwoViewController.m
//  WebView内容高度计算
//
//  Created by chendy on 16/11/9.
//  Copyright © 2016年 chendy. All rights reserved.
//

#import "TwoViewController.h"
#import <WebKit/WebKit.h>


@interface TwoViewController ()<WKNavigationDelegate,UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic) WKWebView *wkWebView;
@property (strong,nonatomic) UIScrollView *wbScrollView;

@property (strong,nonatomic) UITableView *tableView;
@end

@implementation TwoViewController{
    
    CGFloat webContentHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //https://www.oschina.net
    //https://mp.weixin.qq.com/s/ktG31Tdow11csCxqkitMdA
    NSString *urlStr = [NSString stringWithFormat:@"https://mp.weixin.qq.com/s/XPTOEoBIqwsCRhMy6KH-dg"];
//    NSString *urlStr = [NSString stringWithFormat:@"http://blog.csdn.net/u011171043/article/details/51086563"];
//    NSString *urlStr = [NSString stringWithFormat:@"https://www.baidu.com"];
//    NSString *urlStr = [NSString stringWithFormat:@"http://182.254.217.55/host-manager/html"];
    
//    NSString *urlStr = [NSString stringWithFormat:@"http://mil.news.sina.com.cn/jssd/2016-11-10/doc-ifxxsmif2631923.shtml"];
    self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero];
    self.wkWebView.backgroundColor = [UIColor yellowColor];
    self.wkWebView.navigationDelegate = self;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [self.wkWebView loadRequest:request];
    
    self.wbScrollView = self.wkWebView.scrollView;
    self.wbScrollView.bounces = NO;
    self.wbScrollView.scrollEnabled = YES;
    
    
    //表
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableHeaderView = self.wkWebView;
    
    [self.view addSubview:self.tableView];
    
    // Do any additional setup after loading the view.
}

-(void)resetWebViewFrameWithHeight:(CGFloat)height{
    /**去掉这个if 是因为KVO 监听的时候有时候网页会由原来的大值变小值 额**/
//    if (CGRectGetHeight(self.wkWebView.frame) == CGRectGetHeight(self.view.frame)) {
//        //如果高度已经达到最高，那么就不用设置，只有记录一下
//        webContentHeight = height;
//    }else{
        //如果是新高度，那就重置
        if (height != webContentHeight) {
            if(height >= CGRectGetHeight(self.view.frame)){
                [self.wkWebView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
            }else{
                [self.wkWebView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), height)];
            }
            [self.tableView reloadData];
            webContentHeight = height;
        }
//    }
}

#pragma mark - UITableViewDatasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifer = @"AAAAAAA";
    UITableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (!aCell) {
        aCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
        aCell.backgroundColor = [UIColor redColor];
    }
    aCell.textLabel.text = [NSString stringWithFormat:@"我是评论：%ld",indexPath.row];
    
    return aCell;
}

#pragma mark - WKNavigationDelegate

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"加载完成");
    //这个方法也可以计算出webView滚动视图滚动的高度
    [webView evaluateJavaScript:@"document.body.scrollWidth"completionHandler:^(id _Nullable result,NSError * _Nullable error){
        
        NSLog(@"scrollWidth高度：%.2f",[result floatValue]);
        CGFloat ratio =  CGRectGetWidth(self.wkWebView.frame) /[result floatValue];
        
        [webView evaluateJavaScript:@"document.body.scrollHeight"completionHandler:^(id _Nullable result,NSError * _Nullable error){
            NSLog(@"scrollHeight高度：%.2f",[result floatValue]);
            NSLog(@"scrollHeight计算高度：%.2f",[result floatValue]*ratio);
            CGFloat newHeight = [result floatValue]*ratio;
            
            [self resetWebViewFrameWithHeight:newHeight];
            
            if (newHeight < CGRectGetHeight(self.view.frame)) {
                //如果webView此时还不是满屏，就需要监听webView的变化  添加监听来动态监听内容视图的滚动区域大小
                [self.wbScrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
            }
        }];
        
    }];
}

#pragma mark  - KVO回调
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    //更具内容的高重置webView视图的高度
    CGFloat newHeight = self.wbScrollView.contentSize.height;
    NSLog(@"kvo算出的高度啊：%.f",newHeight);
    [self resetWebViewFrameWithHeight:newHeight];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if ([scrollView isEqual:self.tableView]) {
        NSLog(@"tableView");
        CGFloat yOffSet = scrollView.contentOffset.y;
        NSLog(@"偏移%.2f",yOffSet);
        if (yOffSet <= 0) {
            self.wbScrollView.scrollEnabled = YES;
            self.tableView.bounces = NO;
        }else{
            self.wbScrollView.scrollEnabled = NO;
            self.tableView.bounces = YES;
        }
    }
}

@end
