//
//  EditionAddViewController.m
//  maoGang
//
//  Created by xl on 2018/11/28.
//  Copyright © 2018年 bilin. All rights reserved.
//

#import "EditionAddViewController.h"
#import "IWTextView.h"
#import "CustomAlertView.h"
@interface EditionAddViewController ()
@property (weak, nonatomic) IBOutlet IWTextView *txtView;

@end

@implementation EditionAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.txtView.placeholder = @"请输入您想要生成字帖的文字段落";
    self.txtView.font = [UIFont systemFontOfSize:14];
    UIBarButtonItem *leftTitle = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancle:)];
    leftTitle.tintColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem = leftTitle;
    UIBarButtonItem *rightTitle = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(finsh:)];
    rightTitle.tintColor = [UIColor redColor];
    self.navigationItem.rightBarButtonItem = rightTitle;
    self.view.backgroundColor = [UIColor whiteColor];
    self.text  = IS_VALID_STRING(self.text)?self.text:@"";
    self.txtView.text = self.text;
}

- (void)cancle:(UIBarButtonItem *)cancel {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)finsh:(UIBarButtonItem *)finish {
    [self.view endEditing:YES];
    if ([self.delegate respondsToSelector:@selector(editionAddViewControllerfinishWithTxt:isloop:)]) {
        [self.delegate editionAddViewControllerfinishWithTxt:self.txtView.text isloop:NO];
        [self.navigationController popViewControllerAnimated:YES];
    }
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
