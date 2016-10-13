//
//  ViewController.m
//  RBNetworkDemo
//
//  Created by baxiang on 16/9/29.
//  Copyright © 2016年 baxiang. All rights reserved.
//

#import "ViewController.h"
#import "RBNetwork.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    RBNetworkRequest *request= [[RBNetworkRequest alloc] initWithURLString:@"hh" method:@"" params:nil];
    [request start];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
