//
//  ViewController.m
//  WebView内容高度计算
//
//  Created by chendy on 16/11/7.
//  Copyright © 2016年 chendy. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "TwoViewController.h"

@interface ViewController ()<WKNavigationDelegate,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>{
    
    CGFloat _wbContentHeight;
    CGFloat _headerBeforeYoffset;
    
    CGFloat _heightOfWebToBottom;
    BOOL _isPullDown;                 //是不是往下拉
}

@property (strong,nonatomic) UIScrollView *bgScrollView;
@property (strong,nonatomic) UIScrollView *wbScrollView;
@property (strong,nonatomic) WKWebView *wkWebView;

@property (strong,nonatomic) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.bgScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.bgScrollView.backgroundColor = [UIColor orangeColor];
    self.bgScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)*2);
    self.bgScrollView.scrollEnabled = NO;
    self.bgScrollView.bounces = NO;
    self.bgScrollView.delegate = self;
    self.bgScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.bgScrollView];
    
    //@"http://app.res.cmhongbao.com/static/agreement.html?t=%.f",[[NSDate date] timeIntervalSince1970]
    //@"http://www.cocoachina.com/bbs/read.php?tid=216001"
//    NSString *urlStr = [NSString stringWithFormat:@"http://www.cocoachina.com/bbs/read.php?tid=216001"];
    //https://www.oschina.net
    //https://mp.weixin.qq.com/s/ktG31Tdow11csCxqkitMdA
    NSString *urlStr = [NSString stringWithFormat:@"https://mp.weixin.qq.com/s/XPTOEoBIqwsCRhMy6KH-dg"];
    self.wkWebView = [[WKWebView alloc] initWithFrame:self.bgScrollView.bounds];
    self.wkWebView.backgroundColor = [UIColor yellowColor];
    self.wkWebView.navigationDelegate = self;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [self.wkWebView loadRequest:request];
    self.wbScrollView = self.wkWebView.scrollView;
    self.wbScrollView.delegate = self;
    self.wbScrollView.bounces = NO;
    self.wbScrollView.scrollEnabled = YES;
    
    //表
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.wkWebView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.bounces = NO;
    
    
    [self.bgScrollView addSubview:self.wkWebView];
    [self.bgScrollView addSubview:self.tableView];
    
    //声明一个滑动手势
    UIPanGestureRecognizer *panGesture1 = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panTableView:)];
    [panGesture1 setDelegate:self];
    [self.wbScrollView addGestureRecognizer:panGesture1];
    
    
    //方案二button
    UIButton *buttton = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttton setFrame:CGRectMake(0, 50, 100, 20)];
    [buttton setBackgroundColor:[UIColor purpleColor]];
    [buttton setTitle:@"方案二" forState:UIControlStateNormal];
    [buttton addTarget:self action:@selector(eventButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttton];
}

-(void)eventButton{
    TwoViewController *twoVC = [[TwoViewController alloc] init];
    [self presentViewController:twoVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    }
    aCell.textLabel.text = [NSString stringWithFormat:@"我是评论：%ld",indexPath.row];
    
    return aCell;
}

#pragma mark - WKNavigationDelegate
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
//    NSLog(@"加载完成");
     
    [webView evaluateJavaScript:@"document.body.scrollHeight"completionHandler:^(id _Nullable result,NSError * _Nullable error){
        
        _wbContentHeight = [result floatValue];
//        NSLog(@"scrollHeight高度：%.2f",[result floatValue]);
    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

//滑动的时候调用
- (void)panTableView:(UIPanGestureRecognizer *)gesture{
    
    if ([gesture state] == UIGestureRecognizerStateChanged){
        CGPoint panPoint = [gesture translationInView:self.view];
        CGFloat panYoff = panPoint.y;
        //偏移值
        float delteFloat = _headerBeforeYoffset - panYoff;
        _headerBeforeYoffset = panYoff;
        
        CGFloat bgSVOffY = self.bgScrollView.contentOffset.y;
        if (delteFloat > 0){
            //往上推
//            NSLog(@"上");
            _isPullDown = NO;
            if (bgSVOffY == 0) {
                //说明还在webView浏览中
                if (_heightOfWebToBottom > 0) {
                    //说明还在看webView
                    _bgScrollView.scrollEnabled = NO;
                    _wbScrollView.scrollEnabled = YES;
                }else{
                    //说明了已经到达边界
                    _bgScrollView.scrollEnabled = YES;
                    _wbScrollView.scrollEnabled = NO;
                }
            }else if (bgSVOffY < CGRectGetHeight(self.bgScrollView.frame)){
                //说明在背景滚动视图滚动中
                _bgScrollView.scrollEnabled = YES;
                _wbScrollView.scrollEnabled = NO;
                _tableView.scrollEnabled = NO;
            }else{
                //说明table全部展现出来
                if (self.tableView.contentOffset.y <= 0) {
                    //table全出来，还要往上拉
                    _bgScrollView.scrollEnabled = NO;
                    _wbScrollView.scrollEnabled = NO;
                    _tableView.scrollEnabled = YES;
                }else{
                    _bgScrollView.scrollEnabled = NO;
                    _wbScrollView.scrollEnabled = NO;
                    _tableView.scrollEnabled = YES;
                }
            }
        }else if (delteFloat < 0){
            //往下推
//            NSLog(@"下");
            _isPullDown = YES;
            if (bgSVOffY == 0) {
                //说明还在webView浏览中
                if (_heightOfWebToBottom > 0) {
                    //说明还在看webView
                    _bgScrollView.scrollEnabled = NO;
                    _wbScrollView.scrollEnabled = YES;
                }else{
                    //说明了已经到达边界
                    _bgScrollView.scrollEnabled = NO;
                    _wbScrollView.scrollEnabled = YES;
                }
            }else if (bgSVOffY < CGRectGetHeight(self.bgScrollView.frame)){
                //说明在背景滚动视图滚动中
                _bgScrollView.scrollEnabled = YES;
                _wbScrollView.scrollEnabled = NO;
                _tableView.scrollEnabled = NO;
            }else{
                //说明table全部展现出来
                if (self.tableView.contentOffset.y <= 0) {
                    //table全出来，还要往上拉
                    _bgScrollView.scrollEnabled = YES;
                    _wbScrollView.scrollEnabled = NO;
                    _tableView.scrollEnabled = NO;
                }else{
                    _bgScrollView.scrollEnabled = NO;
                    _wbScrollView.scrollEnabled = NO;
                    _tableView.scrollEnabled = YES;
                }
            }

        }
    }

}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if ([scrollView isEqual:self.wbScrollView]) {
//        NSLog(@"webView");
//        
//        CGFloat yOffSet = scrollView.contentOffset.y;
//        NSLog(@"偏移%.2f",yOffSet);
//        _heightOfWebToBottom =  roundf(fabs(_wbContentHeight-CGRectGetHeight(self.wkWebView.frame)-yOffSet));
        
//        if (aaa > 0) {
//            self.bgScrollView.scrollEnabled = NO;
//            self.wbScrollView.scrollEnabled = YES;
//            NSLog(@"1");
//        }else{
//            //webView 和 tableView交接处
//            if (_isPullDown) {
//                //交接处往下，是要看webView
//                self.bgScrollView.scrollEnabled = NO;
//                self.wbScrollView.scrollEnabled = YES;
//                self.tableView.scrollEnabled = NO;
//                NSLog(@"1.2");
//            }else{
//                //交接处往上，是要滚动到表视图
//                self.bgScrollView.scrollEnabled = YES;
//                self.wbScrollView.scrollEnabled = NO;
//                self.tableView.scrollEnabled = NO;
//                NSLog(@"1.3");
//            }
//        }
        
    }else if ([scrollView isEqual:self.bgScrollView]){
        //滚动的是底部的scrollView
//        NSLog(@"scrollView");
//        CGFloat yOffSet = scrollView.contentOffset.y;
//        NSLog(@"偏移%.2f",yOffSet);
//        if (yOffSet == CGRectGetHeight(self.bgScrollView.frame)){
//            //全部滚到到tableview
//            if (_isPullDown) {
//                //如果往下，那就是是webView
//                self.bgScrollView.scrollEnabled = YES;
//                self.wbScrollView.scrollEnabled = NO;
//                self.tableView.scrollEnabled = NO;
//                NSLog(@"2.1");
//            }else{
//                //如果往上，那就是要翻到table
//                self.bgScrollView.scrollEnabled = NO;
//                self.wbScrollView.scrollEnabled = NO;
//                self.tableView.scrollEnabled = YES;
//                 NSLog(@"2.2");
//            }
//            
//        }
//        else if (yOffSet == 0){
//            //webView 和 tableView交接处
//            if (_isPullDown) {
//                //交接处往下，是要看webView
//                self.bgScrollView.scrollEnabled = NO;
//                self.wbScrollView.scrollEnabled = YES;
//                self.tableView.scrollEnabled = NO;
//                 NSLog(@"2.3");
//            }else{
//                //交接处往上，是要滚动到表视图
//                self.bgScrollView.scrollEnabled = YES;
//                self.wbScrollView.scrollEnabled = NO;
//                self.tableView.scrollEnabled = NO;
//                NSLog(@"2.4");
//            }
//        }else{
//            //正常滚动
//            self.bgScrollView.scrollEnabled = YES;
//            self.wbScrollView.scrollEnabled = NO;
//            self.tableView.scrollEnabled = NO;
//            NSLog(@"2.5");
//        }
    }else if ([scrollView isEqual:self.tableView]){
//        NSLog(@"tableView");
//        CGFloat yOffSet = scrollView.contentOffset.y;
//        NSLog(@"偏移%.2f",yOffSet);
//        if (yOffSet <= 0) {
//            if (_isPullDown) {
//                //如果往下，是要进入webView
//                self.bgScrollView.scrollEnabled = YES;
//                self.wbScrollView.scrollEnabled = NO;
//                self.tableView.scrollEnabled = NO;
//            }else{
//                //如果往上，是要看表示图本身内容
//                self.bgScrollView.scrollEnabled = NO;
//                self.wbScrollView.scrollEnabled = NO;
//                self.tableView.scrollEnabled = YES;
//                
//            }
//        }else{
//            self.bgScrollView.scrollEnabled = NO;
//            self.tableView.scrollEnabled = YES;
//        }
    }
}
 


@end
