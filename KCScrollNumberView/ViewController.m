//
//  ViewController.m
//  KCScrollNumberView
//
//  Created by Fidetro on 2018/8/31.
//  Copyright © 2018年 Fidetro. All rights reserved.
//

#import "ViewController.h"
#import "KCScrollNumberView.h"
@interface ViewController ()
@property (nonatomic, strong) KCScrollNumberView *numberView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.numberView = [[KCScrollNumberView alloc] initWithFrame:CGRectMake(100, 100, 100, 20)];
    [self.view addSubview:self.numberView];
    //    self.numberView.layer.masksToBounds = YES;
    self.numberView.value = @(9);
    [self.numberView startAnimation];
    
    
}
- (IBAction)aAction:(id)sender {
    self.numberView.value = @(123);
    [self.numberView startAnimation];
}
- (IBAction)bAction:(id)sender {
    self.numberView.value = @(3456);
    [self.numberView startAnimation];
}

- (IBAction)cAction:(id)sender {
    self.numberView.value = @(13456);
    [self.numberView startAnimation];
}
- (IBAction)randomAction:(id)sender {
    self.numberView.value = @(99999);
    self.numberView.scrollType = KCScrollTypeSync;
    [self.numberView randomCycleAnimation];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
