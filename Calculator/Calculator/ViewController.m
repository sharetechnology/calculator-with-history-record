//
//  ViewController.m
//  Calculator
//
//  Created by 高阳 on 15/9/7.
//  Copyright (c) 2015年 gaoyang. All rights reserved.
//

#import "ViewController.h"
@interface ViewController () <UITableViewDelegate,UITableViewDataSource>

@end

@implementation ViewController
{
    float firstNumber;
    float secondNumber;
    float result;
    short resultAccuracy;//结果保留小数点后几位
    NSString* firstNumberStr;
    NSString* secondNumberStr;
    NSString* resultStr;
    NSString* symbol;
    
    BOOL shouldRefreshLab;//按下下一个按钮时是否应该清除所有显示的内容
    BOOL inputFirstNum;//是否正在输入第一个数，反之则输入第二个数
    BOOL continuousSymbol;
    
    int symbolType;//代表用户输入的运算符的种类：0-加法，1-减法，2-乘法，3-除法
    
    NSString* dataFilePath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //load data
    NSString* documentDirectory=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    dataFilePath=[documentDirectory stringByAppendingPathComponent:@"historyData.plist"];

    self.historyResults=[[NSMutableArray new] initWithContentsOfFile:dataFilePath];

    NSLog(@"%@",self.historyResults);

    
    //创建导航按钮
    UIImage* historyImage=[UIImage imageNamed:@"history"];
    UIBarButtonItem* historyButton=[[UIBarButtonItem alloc] initWithImage:historyImage style:UIBarButtonItemStylePlain target:self action:@selector(pushHistoryView)];
    historyButton.tintColor=[UIColor colorWithRed:21.0/255.0 green:44.0/255.0 blue:94.0/255.0 alpha:0.6];
    self.navigationItem.rightBarButtonItem=historyButton;
    
    //设置背景
    UIView* rootV=self.view;
    rootV.backgroundColor=[UIColor colorWithRed:173.0/255.0 green:183.0/255.0 blue:204.0/255.0 alpha:1.0];
    //设置按钮大小，添加按钮
    CGFloat buttonW=80;
    CGFloat buttonH=70;
    //4列
    int totalCol=4;
    CGFloat margin=(rootV.frame.size.width-totalCol*buttonW)/(totalCol+1);
    for (int i=0; i<=8; i++) {
        int row=i/3;//行0~2
        int col=i%3;//列0~2
        CGFloat buttonX=margin+(margin+buttonW)*col;
        CGFloat buttonY=rootV.frame.size.height-4*(margin+buttonH)+(margin+buttonH)*row;
        
        //创建按钮1-9
        UIButton* b=[UIButton buttonWithType:UIButtonTypeSystem];
        [b setFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
        b.backgroundColor=[UIColor colorWithRed:21.0/255.0 green:44.0/255.0 blue:94.0/255.0 alpha:0.6];
        b.tag=i+1;
        NSAttributedString* showNum=[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d",(int)b.tag] attributes:@{
        NSFontAttributeName:[UIFont fontWithName:@"Courier-Oblique" size:30],
        NSForegroundColorAttributeName:[UIColor whiteColor]             }];
        [b setAttributedTitle:showNum forState:UIControlStateNormal];
        [b addTarget:self action:@selector(inputNumber:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:b];
        [rootV addSubview:b];
    }

    //按钮加
    CGFloat buttonX=4*margin+3*buttonW;
    CGFloat buttonY=rootV.frame.size.height-4*(margin+buttonH);
    UIButton* addButton=[UIButton buttonWithType:UIButtonTypeSystem];
    [addButton setFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
    addButton.backgroundColor=[UIColor colorWithRed:21.0/255.0 green:44.0/255.0 blue:94.0/255.0 alpha:0.6];
    addButton.tag=10;
    char c='+';
    NSAttributedString* showAdd=[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%c",c] attributes:@{
        NSFontAttributeName:[UIFont fontWithName:@"Courier-Oblique" size:30],
        NSForegroundColorAttributeName:[UIColor whiteColor]             }];
    [addButton setAttributedTitle:showAdd forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(inputSymbol:) forControlEvents:UIControlEventTouchUpInside];
    [rootV addSubview:addButton];
    //按钮减
    buttonY+=buttonH+margin;
    UIButton* minusButton=[UIButton buttonWithType:UIButtonTypeSystem];
    [minusButton setFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
    minusButton.backgroundColor=[UIColor colorWithRed:21.0/255.0 green:44.0/255.0 blue:94.0/255.0 alpha:0.6];
    minusButton.tag=11;
    c='-';
    NSAttributedString* showMin=[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%c",c] attributes:@{
            NSFontAttributeName:[UIFont fontWithName:@"Courier-Oblique" size:30],
            NSForegroundColorAttributeName:[UIColor whiteColor]             }];
    [minusButton setAttributedTitle:showMin forState:UIControlStateNormal];
    [minusButton addTarget:self action:@selector(inputSymbol:) forControlEvents:UIControlEventTouchUpInside];
    [rootV addSubview:minusButton];
    //按钮*
    buttonY+=buttonH+margin;
    UIButton* multiButton=[UIButton buttonWithType:UIButtonTypeSystem];
    [multiButton setFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
    multiButton.backgroundColor=[UIColor colorWithRed:21.0/255.0 green:44.0/255.0 blue:94.0/255.0 alpha:0.6];
    multiButton.tag=12;
    c='*';
    NSAttributedString* showMul=[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%c",c] attributes:@{
            NSFontAttributeName:[UIFont fontWithName:@"Courier-Oblique" size:30],
            NSForegroundColorAttributeName:[UIColor whiteColor]             }];
    [multiButton setAttributedTitle:showMul forState:UIControlStateNormal];
    [multiButton addTarget:self action:@selector(inputSymbol:) forControlEvents:UIControlEventTouchUpInside];
    [rootV addSubview:multiButton];
    //按钮/
    buttonY+=buttonH+margin;
    UIButton* divButton=[UIButton buttonWithType:UIButtonTypeSystem];
    [divButton setFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
    divButton.backgroundColor=[UIColor colorWithRed:21.0/255.0 green:44.0/255.0 blue:94.0/255.0 alpha:0.6];
    divButton.tag=13;
    c='/';
    NSAttributedString* showDiv=[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%c",c] attributes:@{
            NSFontAttributeName:[UIFont fontWithName:@"Courier-Oblique" size:30],
            NSForegroundColorAttributeName:[UIColor whiteColor]             }];
    [divButton setAttributedTitle:showDiv forState:UIControlStateNormal];
    [divButton addTarget:self action:@selector(inputSymbol:) forControlEvents:UIControlEventTouchUpInside];
    [rootV addSubview:divButton];
    //按钮=
    buttonX=buttonX-buttonW-margin;
    UIButton* equalButton=[UIButton buttonWithType:UIButtonTypeSystem];
    [equalButton setFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
    equalButton.backgroundColor=[UIColor colorWithRed:21.0/255.0 green:44.0/255.0 blue:94.0/255.0 alpha:0.6];
    equalButton.tag=14;
    c='=';
    NSAttributedString* showEqual=[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%c",c] attributes:@{
            NSFontAttributeName:[UIFont fontWithName:@"Courier-Oblique" size:30],
            NSForegroundColorAttributeName:[UIColor whiteColor]             }];
    [equalButton setAttributedTitle:showEqual forState:UIControlStateNormal];
    [equalButton addTarget:self action:@selector(inputEqua) forControlEvents:UIControlEventTouchUpInside];
    [rootV addSubview:equalButton];
    //按钮0
    buttonX=buttonX-buttonW-margin;
    UIButton* zeroButton=[UIButton buttonWithType:UIButtonTypeSystem];
    [zeroButton setFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
    zeroButton.backgroundColor=[UIColor colorWithRed:21.0/255.0 green:44.0/255.0 blue:94.0/255.0 alpha:0.6];
    zeroButton.tag=0;
    NSAttributedString* showZero=[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d",(int)zeroButton.tag] attributes:@{
            NSFontAttributeName:[UIFont fontWithName:@"Courier-Oblique" size:30],
            NSForegroundColorAttributeName:[UIColor whiteColor]             }];
    [zeroButton setAttributedTitle:showZero forState:UIControlStateNormal];
    [zeroButton addTarget:self action:@selector(inputNumber:) forControlEvents:UIControlEventTouchUpInside];
    [rootV addSubview:zeroButton];
    //按钮小数点
    buttonX=buttonX-buttonW-margin;
    UIButton* pointButton=[UIButton buttonWithType:UIButtonTypeSystem];
    [pointButton setFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
    pointButton.backgroundColor=[UIColor colorWithRed:21.0/255.0 green:44.0/255.0 blue:94.0/255.0 alpha:0.6];
    pointButton.tag=15;
    c='.';
    NSAttributedString* showPoint=[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%c",c] attributes:@{
            NSFontAttributeName:[UIFont fontWithName:@"Courier-Oblique" size:30],
            NSForegroundColorAttributeName:[UIColor whiteColor]             }];
    [pointButton setAttributedTitle:showPoint forState:UIControlStateNormal];
    [pointButton addTarget:self action:@selector(inputPoint:) forControlEvents:UIControlEventTouchUpInside];
    [rootV addSubview:pointButton];
    //按钮删除
    buttonY=buttonY-4*(margin+buttonH);
    buttonW=2*buttonW+margin;
    UIButton* ACButton=[UIButton buttonWithType:UIButtonTypeSystem];
    [ACButton setFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
    ACButton.backgroundColor=[UIColor colorWithRed:21.0/255.0 green:44.0/255.0 blue:94.0/255.0 alpha:0.6];
    ACButton.tag=16;
    NSAttributedString* showAC=[[NSAttributedString alloc] initWithString:@"AC" attributes:@{
            NSFontAttributeName:[UIFont fontWithName:@"Courier-Oblique" size:30],
            NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [ACButton setAttributedTitle:showAC forState:UIControlStateNormal];
    [ACButton addTarget:self action:@selector(deleteInput:) forControlEvents:UIControlEventTouchUpInside];
    [rootV addSubview:ACButton];
    //按钮answer
    buttonX=buttonX+buttonW+margin;
    UIButton* ansButton=[UIButton buttonWithType:UIButtonTypeSystem];
    [ansButton setFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
    ansButton.backgroundColor=[UIColor colorWithRed:21.0/255.0 green:44.0/255.0 blue:94.0/255.0 alpha:0.6];
    ansButton.tag=17;
    NSAttributedString* showAns=[[NSAttributedString alloc] initWithString:@"Ans" attributes:@{
        NSFontAttributeName:[UIFont fontWithName:@"Courier-Oblique" size:30],
        NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [ansButton setAttributedTitle:showAns forState:UIControlStateNormal];
    [ansButton addTarget:self action:@selector(showLastAns) forControlEvents:UIControlEventTouchUpInside];
    [rootV addSubview:ansButton];

    
    //添加label显示
    CGFloat labelY=rootV.frame.size.height-4*(margin+buttonH)-margin-3.5*buttonH;
    CGFloat labelX=buttonX-buttonW-margin;
    CGFloat labelW=rootV.frame.size.width-2*margin;
    CGFloat labelH=48;
    UILabel* lab1=[[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelW, labelH)];
    lab1.backgroundColor=[UIColor colorWithRed:21.0/255.0 green:44.0/255.0 blue:94.0/255.0 alpha:0.6];
    lab1.textColor=[UIColor whiteColor];
    [lab1 setTextAlignment:NSTextAlignmentRight];
    lab1.font=[UIFont fontWithName:@"Courier-Oblique" size:30];
    lab1.adjustsFontSizeToFitWidth=YES;
    self.firstNumberLab=lab1;
    [rootV addSubview:self.firstNumberLab];
    
    labelY=labelY+labelH;
    labelH=20;
    UILabel* labSymbol=[[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelW, labelH)];
    labSymbol.backgroundColor=[UIColor colorWithRed:21.0/255.0 green:44.0/255.0 blue:94.0/255.0 alpha:0.6];
    labSymbol.textColor=[UIColor whiteColor];
    [labSymbol setTextAlignment:NSTextAlignmentLeft];
    labSymbol.font=[UIFont fontWithName:@"Courier-Oblique" size:30];
    labSymbol.adjustsFontSizeToFitWidth=YES;
    self.symbolLab=labSymbol;
    [rootV addSubview:self.symbolLab];
    
    labelY+=labelH;
    labelH=48;
    UILabel* lab2=[[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelW, labelH)];
    lab2.backgroundColor=[UIColor colorWithRed:21.0/255.0 green:44.0/255.0 blue:94.0/255.0 alpha:0.6];
    lab2.textColor=[UIColor whiteColor];
    [lab2 setTextAlignment:NSTextAlignmentRight];
    lab2.font=[UIFont fontWithName:@"Courier-Oblique" size:30];
    lab2.adjustsFontSizeToFitWidth=YES;
    self.secondNumberLab=lab2;
    [rootV addSubview:self.secondNumberLab];
 
    
    labelY+=labelH;
    UILabel* lab3=[[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelW, labelH)];
    lab3.backgroundColor=[UIColor colorWithRed:21.0/255.0 green:44.0/255.0 blue:94.0/255.0 alpha:0.6];
    lab3.textColor=[UIColor whiteColor];
    [lab3 setTextAlignment:NSTextAlignmentRight];
    lab3.font=[UIFont fontWithName:@"Courier-Oblique" size:30];
    lab3.adjustsFontSizeToFitWidth=YES;
    self.resultNumberLab=lab3;
    [rootV addSubview:self.resultNumberLab];
    
    //history view
    UITableViewController* htc=[UITableViewController new];
    htc.tableView.backgroundColor=[UIColor colorWithRed:173.0/255.0 green:183.0/255.0 blue:204.0/255.0 alpha:1.0];
    htc.tableView.dataSource=self;
    htc.tableView.delegate=self;
    
    UIImage* calculatorIm=[UIImage imageNamed:@"calculator"];
    UIBarButtonItem* backButton=[[UIBarButtonItem alloc] initWithImage:calculatorIm style:UIBarButtonItemStylePlain target:self action:@selector(backToCalculator)];
    backButton.tintColor=[UIColor colorWithRed:21.0/255.0 green:44.0/255.0 blue:94.0/255.0 alpha:0.6];
    htc.navigationItem.leftBarButtonItem=backButton;
    
    UIImage* clearIm=[UIImage imageNamed:@"clear"];
    UIBarButtonItem* clearButton=[[UIBarButtonItem alloc] initWithImage:clearIm style:UIBarButtonItemStylePlain target:self action:@selector(doClear)];
    clearButton.tintColor=[UIColor colorWithRed:21.0/255.0 green:44.0/255.0 blue:94.0/255.0 alpha:0.6];
    htc.navigationItem.rightBarButtonItem=clearButton;
    
    self.historyViewController=htc;

    //other initiation settings
    shouldRefreshLab=NO;
    firstNumberStr=@"";
    secondNumberStr=@"";
    inputFirstNum=YES;
    continuousSymbol=NO;
}

#pragma mark - button AC pressed
-(void) deleteInput:(UIButton*)sender {
    if (shouldRefreshLab) {
        firstNumberStr=@"";
        secondNumberStr=@"";
        [self.firstNumberLab setText:nil];
        [self.secondNumberLab setText:nil];
        [self.resultNumberLab setText:nil];
        [self.symbolLab setText:nil];
        shouldRefreshLab=NO;
        inputFirstNum=YES;
    }
    if (inputFirstNum) {
        firstNumberStr=@"";
        [self.firstNumberLab setText:firstNumberStr];
    }
    else {
        secondNumberStr=@"";
        [self.secondNumberLab setText:secondNumberStr];
    }
}

#pragma mark - button Ans pressed
-(void) showLastAns {
    if (shouldRefreshLab) {
        firstNumber=result;
        firstNumberStr=resultStr;
        secondNumberStr=@"";
        [self.firstNumberLab setText:firstNumberStr];
        [self.secondNumberLab setText:nil];
        [self.resultNumberLab setText:nil];
        [self.symbolLab setText:@""];
        shouldRefreshLab=NO;
        inputFirstNum=NO;
        return;
    }
    else {
        secondNumber=result;
        secondNumberStr=resultStr;
        [self.secondNumberLab setText:secondNumberStr];
        inputFirstNum=NO;
        return;
    }
}

#pragma mark - button in history view
-(void) backToCalculator {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) doClear {
    [self.historyResults removeAllObjects];
    [self.historyResults writeToFile:dataFilePath atomically:YES];
    
    [self.historyViewController.tableView reloadData];
}

#pragma mark - button 1~9 pressed
-(void) inputNumber: (UIButton*)sender {
    if (shouldRefreshLab) {
        firstNumberStr=@"";
        secondNumberStr=@"";
        [self.firstNumberLab setText:nil];
        [self.secondNumberLab setText:nil];
        [self.resultNumberLab setText:nil];
        [self.symbolLab setText:nil];
        shouldRefreshLab=NO;
        inputFirstNum=YES;
    }
    if (inputFirstNum) {
        firstNumberStr=[NSString stringWithFormat:@"%@%d",firstNumberStr,(int)sender.tag];
        //最多不能输入超过30个数字
        if (firstNumberStr.length > 30) {
            return;
        }
        [self.firstNumberLab setText:firstNumberStr];
    }
    else {
        secondNumberStr=[NSString stringWithFormat:@"%@%d",secondNumberStr,(int)sender.tag];
        if (secondNumberStr.length >30) {
            return;
        }
        [self.secondNumberLab setText:secondNumberStr];
        continuousSymbol=YES;//开启连续输入模式
    }

}

-(void) inputPoint: (UIButton*)sender {
    if (inputFirstNum) {
        firstNumberStr=[NSString stringWithFormat:@"%@%c",firstNumberStr,'.'];
        self.firstNumberLab.text=[NSString stringWithFormat:@"%@",firstNumberStr];
    }
    else {
        secondNumberStr=[NSString stringWithFormat:@"%@%c",secondNumberStr,'.'];
        [self.secondNumberLab setText:secondNumberStr];
    }
}

//判断一个小数的小数点后有多少位
-(short) decimalPosition: (NSString*)inputNumStr {
    NSRange	Pointrange;
    Pointrange=[inputNumStr rangeOfString:[NSString stringWithFormat:@"%c",'.']];
    if (Pointrange.location==NSNotFound) {
        return 0;
    }
    else
        return (short)(inputNumStr.length-Pointrange.location-1);
}

#pragma mark - button symbol pressed
-(void)determineSymbol:(NSInteger) input{
    switch (input) {
        case 10:
            self.symbolLab.text=[NSString stringWithFormat:@"%c",'+'];
            symbolType=0;
            break;
            
        case 11:
            self.symbolLab.text=[NSString stringWithFormat:@"%c",'-'];
            symbolType=1;
            break;
            
        case 12:
            self.symbolLab.text=[NSString stringWithFormat:@"%c",'*'];
            symbolType=2;
            break;
            
        case 13:
            self.symbolLab.text=[NSString stringWithFormat:@"%c",'/'];
            symbolType=3;
            break;
            
        default:
            break;
    }

}

-(void) inputSymbol: (UIButton*)sender {
    if (continuousSymbol) {
        [self inputEqua];
        firstNumber=result;
        firstNumberStr=resultStr;
        secondNumberStr=@"";
        [self.firstNumberLab setText:firstNumberStr];
        [self.secondNumberLab setText:nil];
        [self.resultNumberLab setText:nil];
        shouldRefreshLab=NO;
        inputFirstNum=NO;
        [self determineSymbol:sender.tag];

        return;
    }
    if (shouldRefreshLab) {
        firstNumber=result;
        firstNumberStr=resultStr;
        secondNumberStr=@"";
        [self.firstNumberLab setText:firstNumberStr];
        [self.secondNumberLab setText:nil];
        [self.resultNumberLab setText:nil];
        [self determineSymbol:sender.tag];
        shouldRefreshLab=NO;
        inputFirstNum=NO;
        return;
    }
    inputFirstNum=NO;
    firstNumber=[firstNumberStr doubleValue];
    resultAccuracy=[self decimalPosition:firstNumberStr];
    [self determineSymbol:sender.tag];

}


#pragma mark - button '=' pressed
-(void) inputEqua {
    shouldRefreshLab=YES;
    continuousSymbol=NO;
    secondNumber=[secondNumberStr floatValue];
    short secondDecimalPosition=[self decimalPosition:secondNumberStr];
    NSString* finalResult=firstNumberStr;
    switch (symbolType) {
        case 0:
            result=firstNumber+secondNumber;
            finalResult=[NSString stringWithFormat:@"%@%c",finalResult,'+'];
            break;
        case 1:
            result=firstNumber-secondNumber;
            finalResult=[NSString stringWithFormat:@"%@%c",finalResult,'-'];
            break;
        case 2:
            result=firstNumber*secondNumber;
            finalResult=[NSString stringWithFormat:@"%@%c",finalResult,'*'];
            break;
        case 3:
            result=firstNumber/secondNumber;
            finalResult=[NSString stringWithFormat:@"%@%c",finalResult,'/'];
            break;
            
        default:
            break;
    }
    
    resultStr=[NSString stringWithFormat:@"%f",result];
    resultAccuracy=resultAccuracy>=secondDecimalPosition?resultAccuracy:secondDecimalPosition;
    NSDecimalNumberHandler* resultHandler=[NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:resultAccuracy raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber* resultDecimal=[NSDecimalNumber decimalNumberWithString:resultStr];
    resultDecimal=[resultDecimal decimalNumberByRoundingAccordingToBehavior:resultHandler];
    resultStr=[NSString stringWithFormat:@"%@",resultDecimal];
    [self.resultNumberLab setText:resultStr];
    
    finalResult=[finalResult stringByAppendingString:secondNumberStr];
    finalResult=[finalResult stringByAppendingString:[NSString stringWithFormat:@"%c",'=']];
    finalResult=[finalResult stringByAppendingString:resultStr];

    [self.historyResults insertObject:finalResult atIndex:0];
    
    [self.historyResults writeToFile:dataFilePath atomically:YES];
    //NSLog(@"%@",self.historyResults);
    [self.historyViewController.tableView reloadData];
}

#pragma mark - tableview datasource related
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section
    return [self.historyResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.backgroundColor=[UIColor colorWithRed:173.0/255.0 green:183.0/255.0 blue:204.0/255.0 alpha:1.0];
        cell.textLabel.textColor=[UIColor colorWithRed:21.0/255.0 green:44.0/255.0 blue:94.0/255.0 alpha:0.8];
    }
    
    cell.textLabel.text=self.historyResults[indexPath.row];
    // Configure the cell...
    return cell;
}

-(void) pushHistoryView {
    [self.navigationController pushViewController:self.historyViewController animated:YES];
}

#pragma mark - others
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
