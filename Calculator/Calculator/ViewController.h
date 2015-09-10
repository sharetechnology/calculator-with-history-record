//
//  ViewController.h
//  Calculator
//
//  Created by 高阳 on 15/9/7.
//  Copyright (c) 2015年 gaoyang. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ViewController : UIViewController
@property (nonatomic,strong) NSMutableArray* buttons;
@property (nonatomic,weak) UILabel* firstNumberLab;
@property (nonatomic,weak) UILabel* secondNumberLab;
@property (nonatomic,weak) UILabel* resultNumberLab;
@property (nonatomic,weak) UILabel* symbolLab;
@property (nonatomic,strong) UITableViewController* historyViewController;

@property (nonatomic,strong) NSMutableArray* historyResults;
@end

