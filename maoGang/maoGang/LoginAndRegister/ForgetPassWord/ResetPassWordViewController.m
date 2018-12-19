//
//  ResetPassWordViewController.m
//  LvJie
//
//  Created by bilin on 2017/1/14.
//  Copyright © 2017年 Bilin-Apple. All rights reserved.
//

#import "ResetPassWordViewController.h"
#import "LoginViewController.h"
@interface ResetPassWordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *passsword;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UIView *resetPasswordView;
@property (weak, nonatomic) IBOutlet UIView *resetPasswordSussessView;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceToTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *_MariginTo_top;
@property (weak, nonatomic) IBOutlet UIButton *backLoginBtn;

@end

@implementation ResetPassWordViewController
- (void)addNotificationCenter
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowKeyBoard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHiddenKeyBoard:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginEding:) name:UITextFieldTextDidBeginEditingNotification object:nil];
}
- (void)willShowKeyBoard:(NSNotification *)notification
{
    if (self.view.window) {
        
    }
    
    
    
}

- (void)beginEding:(NSNotification *)notification
{
    
    if (self.view.window) {
        
        [UIView animateWithDuration:0.1 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
            if (kScreenHeight == 480.0) {
                _distanceToTop.constant = XFSH(44);
                return ;
            }
            
            if (iPhone4 | iPhone5) {
                _distanceToTop.constant = XFSH(84);
            } else {
                _distanceToTop.constant = XFSH(84);
            }
            
            
        } completion:^(BOOL finished) {
            
        }];
    }
    
    
    
}
- (void)willHiddenKeyBoard:(NSNotification *)notification
{
    if (self.view.window) {
        [UIView animateWithDuration:0.1 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
            _distanceToTop.constant = XFSH(84);
            
        } completion:^(BOOL finished) {
            
        }];
        
    }
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.backLoginBtn.backgroundColor = ButtonBackGroudRGB;
    if (iPhoneX||iPhoneXR||iPhoneXM) {
        self._MariginTo_top.constant = 44;
    } else {
        self._MariginTo_top.constant = 20;
    }

    [self LightColor:self.sureBtn];
    self.sureBtn.layer.cornerRadius = 5.0f;
    self.sureBtn.layer.masksToBounds = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    // 重置密码成功的View 隐藏掉
    self.resetPasswordSussessView.hidden = YES;
    // 重置密码的view 显示
    self.resetPasswordView.hidden = NO;
    [self addNotificationCenter];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    
    CGFloat loginH = _loginH.constant;
    _loginH.constant = XFSH(loginH);
    
    CGFloat distanceToTop = _distanceToTop.constant;
    _distanceToTop.constant = XFSH(distanceToTop);
    
}
- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldDidChange
{
    if (self.view.window) {
        if (IS_VALID_STRING(self.passsword.text)) {
            [self normalColor:self.sureBtn];
        } else {
            [self LightColor:self.sureBtn];
        }
    }
}
// 这个颜色是浅色的 下一步 不能点击的 没有交互
- (void)LightColor:(UIButton *)button
{
    [UIView animateWithDuration:0.3 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        button.backgroundColor = ButtotUnNormalRGB;
        
    } completion:^(BOOL finished) {
        button.enabled = NO;
    }];
}
// 这个颜色是正常的 下一步 能点击的 有交互
- (void)normalColor:(UIButton *)button
{
    [UIView animateWithDuration:0.3 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        button.backgroundColor = ButtonBackGroudRGB;
        
    } completion:^(BOOL finished) {
        button.enabled = YES;
    }];
}
// 将重置密码的View 隐藏掉 将重置密码的成功的View 显示出来
- (void)hiddenResetPasswordViewAndVisibleresetPasswordSussessView
{
    if (self.view.window) {
        [UIView animateWithDuration:0.5 delay:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.resetPasswordView.hidden = YES;
            self.resetPasswordSussessView.hidden = NO;
            
        } completion:^(BOOL finished) {
            self.backBtn.hidden = YES;
        }];
        
    }
}
// 点击确定的 重置密码的点击事件
- (IBAction)sureOkAction:(UIButton *)sender {
    [self.passsword resignFirstResponder];
    if (IS_VALID_STRING(self.passsword.text)) {
        sender.userInteractionEnabled = NO;
        [self netWorkHelperWithPOST:backPassword parameters:@{@"code" : self.userModel.verificationCode, @"phone" : self.userModel.userName, @"password" : self.passsword.text} success:^(id responseObject) {
            NSDictionary *dic = responseObject;
            BaseModel *baseModel = [BaseModel loadModelWithDictionary:dic];
            sender.userInteractionEnabled = YES;
            switch ([baseModel.Result integerValue]) {/** 网络请求的返回的状态 200 ---成功， 500 -- 系统内部错误， 404 ---- 信息不存在， 300 ---- 信息不存在*/
                case 200://成功
                {
                    // 将重置密码的View 隐藏掉 将重置密码的成功的View 显示出来
                    [self hiddenResetPasswordViewAndVisibleresetPasswordSussessView];

                }
                    break;

                default:
                    break;
            }

        } failure:^(NSError *error) {

        }];
    } else {
        [AlertPool alertMessage:@"请输入重置密码" xlViewController:self WithBlcok:^{
            sender.userInteractionEnabled = YES;
        }];
    }
    
}

// 返回到登录页面
- (IBAction)backToLogin:(UIButton *)sender {
    
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[LoginViewController class]]) {
            [self.navigationController popToViewController:obj animated:YES];
            *stop = YES;
        }
    }];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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