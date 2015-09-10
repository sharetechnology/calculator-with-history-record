//
//  MyNaviViewController.m
//  Calculator
//
//  Created by 高阳 on 15/9/7.
//  Copyright (c) 2015年 gaoyang. All rights reserved.
//

#import "MyNaviViewController.h"
#import "ViewController.h"


@interface MyNaviViewController ()

@end

@implementation MyNaviViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.barTintColor=[UIColor colorWithRed:204.0/255.0 green:214.0/255.0 blue:235.0/255.0 alpha:1.0];

    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void) backToCalculator {
    [self popViewControllerAnimated:YES];
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
