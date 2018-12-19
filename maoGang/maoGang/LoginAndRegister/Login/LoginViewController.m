//
//  LoginViewController.m
//  LvJie
//
//  Created by bilin on 2017/1/5.
//  Copyright © 2017年 Bilin-Apple. All rights reserved.
//

#import "LoginViewController.h"
#import "ForgetPassWordViewController.h"
#import "RegisterViewController.h"
#import "UserModel.h"
//#import "IQKeyboardManager.h"
//#import "LawyerBXTabBarController.h"
//
//#import <ShareSDK/ShareSDK.h>
//#import <ShareSDKUI/ShareSDK+SSUI.h>
//#import <ShareSDKConnector/ShareSDKConnector.h>
//#import <ShareSDKExtension/SSEThirdPartyLoginHelper.h>
//#import <ShareSDKExtension/ShareSDK+Extension.h>
#import <ShareSDK/ShareSDK.h>
#import "YLWXLoginModel.h"
#import "XLBindingMobilePhoneViewController.h"
//#import "ThirdPartyLoginManager.h"
//#import "UMessage.h"
//
//#import "XLRemotoNotificationWebViewController.h"
//#import "PushSingleton.h"

typedef NS_ENUM(NSInteger, SelectStateType) {
    SelectStateTypeNO,
    SelectStateTypeYES,
};
@interface LoginViewController ()<RegisterViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *passWord;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceToTop;
// 选中的状态
@property (weak, nonatomic) IBOutlet UIImageView *pictureImage;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pictureDictanceToTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomToDistance;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userOrPasswordH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *longBtnToUserDistance;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slectToDistanceToLoginBtn;
@property (weak, nonatomic) IBOutlet UIView *blackLine;


/**
 *微信按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *WXBt;
/**
 *微信文字
 */
@property (weak, nonatomic) IBOutlet UILabel *WXL;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bakBtnToTop;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *theThirdLoginHeight;
@property (nonatomic, assign) BOOL  isSecurity;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
//    [IQKeyboardManager sharedManager].enable = NO;
    self.activityView.hidden = YES;
//    self.view.backgroundColor = [UIColor whiteColor];
//   [ThirdPartyLoginManager manager].delegate = self;
    
    self.isSecurity = YES;
    self.passWord.secureTextEntry = self.isSecurity;
    [self addNotificationCenter];
    if (IS_VALID_STRING(xlPhone)) { // 写入了手机号 有值的话说明登录过了
        self.userName.text = xlPhone;
    }
    CGFloat h =  _distanceToTop.constant;
    _distanceToTop.constant = XFSH(h);
    CGFloat pH =  _pictureDictanceToTop.constant;
    _pictureDictanceToTop.constant = XFSH(pH);
    CGFloat bh = _bottomToDistance.constant;
    _bottomToDistance.constant = XFSH(bh);
    CGFloat loginH = _loginH.constant;
    _loginH.constant = XFSH(loginH);
    CGFloat userOrPasswordH = _userOrPasswordH.constant;
    _userOrPasswordH.constant = XFSH(userOrPasswordH);
    CGFloat longBtnToUserDistance = _longBtnToUserDistance.constant;
    _longBtnToUserDistance.constant = XFSH(longBtnToUserDistance);
    CGFloat slectToDistanceToLoginBtn = _slectToDistanceToLoginBtn.constant;
    _slectToDistanceToLoginBtn.constant = XFSH(slectToDistanceToLoginBtn);
    
    
    if (iPhoneX||iPhoneXM||iPhoneXR) {
        self.bakBtnToTop.constant = 44;
    } else {
        self.bakBtnToTop.constant = 20;

    }
    if (iPhone5) {
        _distanceToTop.constant = XFSH(250);
    }
    if (IPHONE6HEIGHT || IPHONE6PHEIGHT || iPhoneX||iPhoneXR||iPhoneXM ) {
        self.theThirdLoginHeight.constant = 170;

    }else {
        self.theThirdLoginHeight.constant = 115;

    }
    self.blackLine.backgroundColor = RGBCOLOR(220,220,220);
    self.view.backgroundColor = [UIColor whiteColor];
    
}

- (void)addNotificationCenter
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowKeyBoard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHiddenKeyBoard:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginEding:) name:UITextFieldTextDidBeginEditingNotification object:nil];
}
- (void)willShowKeyBoard:(NSNotification *)notification
{
    if (self.view.window) {
        _pictureImage.transform = CGAffineTransformMakeScale(0.0, 0.0);
        
    }
 
    

}

// 密码安全的操作
- (IBAction)PasswordSecurity:(UIButton *)sender {
    self.isSecurity = !self.isSecurity;
    self.passWord.secureTextEntry = self.isSecurity;
    self.isSecurity ? [sender setImage:[UIImage imageNamed:@"icon_yan_a"] forState:UIControlStateNormal] : [sender setImage:[UIImage imageNamed:@"icon_yan_b"] forState:UIControlStateNormal];
    
    
}

- (void)beginEding:(NSNotification *)notification
{

    if (self.view.window) {
        
        [UIView animateWithDuration:0.1 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
            if (kScreenHeight == 480.0) {
                _distanceToTop.constant = XFSH(100);
                return ;
            }
            
            if (iPhone4 | iPhone5) {
                _distanceToTop.constant = XFSH(120);
            } else {
                _distanceToTop.constant = XFSH(150);//200
            }
            
            
        } completion:^(BOOL finished) {
            
        }];
    }

 
    
}
- (void)willHiddenKeyBoard:(NSNotification *)notification
{
    if (self.view.window) {
        _pictureImage.transform = CGAffineTransformMakeScale(1.0, 1.0);
        [UIView animateWithDuration:0.1 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
            if (iPhone5) {
                _distanceToTop.constant = XFSH(250);
            } else {
                _distanceToTop.constant = XFSH(230);
            }
            
        } completion:^(BOOL finished) {
            
        }];
        
    }

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self configurationPushSingleTonClear];// 清空单利里面的导航控制器以及试图控制器

}

//http://lvjie.chongfa.com/User/Login 登陆
//参数：code, time, phone=手机号  password=密码

/** 关闭注册btn的交互和开启动画*/
- (void)actioncloseUserInteractionEnabledAction {
    self.loginBtn.userInteractionEnabled = NO;
    self.activityView.hidden = NO;
    [self.activityView startAnimating];
}
/**打开注册btn的交互和关闭动画*/
- (void)actionOpenUserInteractionEnabledAction {
    self.loginBtn.userInteractionEnabled = YES;
    self.activityView.hidden = YES;
    [self.activityView stopAnimating];
}
// 登录
- (IBAction)loginAction:(UIButton *)sender {
    if ((IS_VALID_STRING(_userName.text) && IS_VALID_STRING(_passWord.text))) {
        // 关闭交互 开启动画
        [self actioncloseUserInteractionEnabledAction];
        [self netWorkHelperWithPOST:loginin parameters:@{@"phone" : self.userName.text, @"password" : self.passWord.text} success:^(id responseObject) {

            NSDictionary *dic = responseObject;
            BaseModel *model = [BaseModel loadModelWithDictionary:dic];
//            sender.userInteractionEnabled = YES;
            // 打开交互 关闭动画
            [self actionOpenUserInteractionEnabledAction];
            switch ([model.Result integerValue]) {/** 网络请求的返回的状态 200 ---成功， 500 -- 系统内部错误， 404 ---- 信息不存在， 300 ---- 信息不存在*/
                case 200://成功
                {

                        // 将手机号写入 将密码密码清除
                        writePhoneOrPassword(self.userName.text, @"");

                    model.userModel = [UserModel loadModelWithDictionary:dic[@"Info"]];
//                    model.userModel.Auth = dic[@"Auth"];




                    // 清除之前的用户信息
                    [[UserManager sharedManager] cleanUserInfo];
                    // 保存登录的信息
                    [[UserManager sharedManager] savaUserInfoWith:model.userModel];
                    [self.userName resignFirstResponder];
                    [self.passWord resignFirstResponder];

                    [self.navigationController popViewControllerAnimated:YES];
                    PushSingleton *pushSingleton = [PushSingleton pushSharedInstance];// 遥远的推送
                    [pushSingleton configurationRemoToPushWith:model];

                }
                    break;


                default:
                    break;
            }
        } failure:^(NSError *error) {
            // 开启交互关闭动画
            [self actionOpenUserInteractionEnabledAction];
        }];

    } else {
        [AlertPool alertMessage:@"请输入账号或密码" xlViewController:self WithBlcok:nil];
    }
}
// 将singleTon 里面的导航控制器以及试图控制器清空
- (void)configurationPushSingleTonClear
{
//    PushSingleton *pushSingleton = [PushSingleton pushSharedInstance];
//    pushSingleton.vc = nil;
//    pushSingleton.navc = nil;
}


// 忘记密码
- (IBAction)registerAction:(UIButton *)sender {
    ForgetPassWordViewController *forgetPasswordVC = [[ForgetPassWordViewController alloc] initWithNibName:@"ForgetPassWordViewController" bundle:nil];
    [self.navigationController pushViewController:forgetPasswordVC animated:YES];
}

// 注册
- (IBAction)forgetPassWordAction:(UIButton *)sender {
  
    
    RegisterViewController *registerVC = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
    registerVC.delegate = self;
    [self.navigationController pushViewController:registerVC animated:YES];
}


#pragma mark - RegisterViewControllerDelegate
- (void)registerViewControllerMakeLoginVCToLoginWithModel:(UserModel *)model
{
//    self.userName.text = model.userName;
//    self.passWord.text = model.passWord;
//    [self loginAction:nil];
}
- (IBAction)backAction:(UIButton *)sender {
    [self.passWord resignFirstResponder];
    [self.userName resignFirstResponder];
    [self configurationPushSingleTonClear];// 清空单利里面的导航控制器以及试图控制器

    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -- 底部按钮点击事件
- (IBAction)buttonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case 10://微信 授权登录不需要判断微信是否存在，支持网页版
            {
                [self loginWXWithSender:sender withType:@"2"];
            }
            break;
        case 11://崇法
        {
            [self loginWXWithSender:sender withType:@"1"];
        }
            break;
        default:
            break;
    }

}
#pragma mark -- ThirdPartyLoginManagerDelegate
// 律界通过崇法登录的回调
- (void)ThirdPartyLoginManagerLoginAction:(NSString *)token
{
//    NSLog(@"%@", token);
//    if (IS_VALID_STRING(token)) {
//
//        [self loginLvJieWithUid:token withType:@"1"];
//
//    }else {
//
//        [GiFHUD show:@"服务器返回异常~" view:self.view];
//
//    }
    
    
    
    
}
#pragma mark  --- 微信授权登录
-(void)loginWXWithSender:(UIButton *)sender withType:(NSString *)type{
    SSDKPlatformType wxorQQ = 0;
    if ([type isEqualToString:@"2"]) {
        wxorQQ = SSDKPlatformTypeWechat;
    } else {
        wxorQQ    =SSDKPlatformTypeQQ;
    }
    __weak typeof(self)weakSelf = self;
    [ShareSDK getUserInfo:wxorQQ
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
     {
         sender.userInteractionEnabled =YES;
         if (state == SSDKResponseStateSuccess)
         {

//             NSLog(@"uid=%@",user.uid);
//             NSLog(@"%@",user.credential);
//             NSLog(@"token=%@",user.credential.token);
//             NSLog(@"nickname=%@",user.nickname);
//             NSLog(@"icon=%@",user.icon);
//             NSLog(@"gender=%ld",user.gender);
             //取消授权
             [ShareSDK cancelAuthorize:wxorQQ];

             if (IS_VALID_STRING(user.uid)) {

                 [weakSelf loginLvJieWithUid:user.uid withType:type];
             }

         }else
         {
             [GiFHUD show:@"授权失败" view:self.view];

         }

     }];
    
}
-(void)loginLvJieWithUid:(NSString * )uid withType:(NSString * )type{
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
    NSString * url = [NSString string];
    NSDictionary * dic = [NSDictionary dictionary];
    if ([type isEqualToString:@"2"]) {
        url = WeChatOAuthOpenId;// 授权
        dic = @{@"openId":uid};
    }else {

        url = QQOAuthOpenid;// 授权
        dic = @{@"openId":uid};
    }

    [[YXHTTPRequst shareInstance]networking:url parameters:dic method:YXRequstMethodTypePOST success:^(NSDictionary * obj) {
//        NSLog(@"%@",obj);

        YLWXLoginModel * model = [YLWXLoginModel loadModelWithDictionary:obj];
        if ([model.Result isEqualToString:@"200"]) {//返回成功
            if ([model.IsLogin isEqualToString:@"0"]&&IS_VALID_STRING(model.OpenId)) {//授权成功  跳到注册

//                NSLog(@"授权成功  跳到注册");

//                XLBindingMobilePhoneViewController * vc = [[XLBindingMobilePhoneViewController alloc]init];
//                vc.OpenId = model.OpenId;
//                vc.type = type;
//                [self.navigationController pushViewController:vc animated:YES];

                RegisterViewController *registVC = [[RegisterViewController alloc] init];
                registVC.dic = @{@"url":[type isEqualToString:@"1"]?QQReg:WeChatReg,@"openId":model.OpenId,@"qqOrwx":type};
                [self.navigationController pushViewController:registVC animated:YES];

            }else{//返回 用户信息

                model.userModel = [UserModel loadModelWithDictionary:obj[@"Info"]];
                model.userModel.Auth = obj[@"Auth"];
                // 清除之前的用户信息
                [[UserManager sharedManager] cleanUserInfo];
                // 保存登录的信息
                [[UserManager sharedManager] savaUserInfoWith:model.userModel];
                [self.userName resignFirstResponder];
                [self.passWord resignFirstResponder];
                [self.navigationController popViewControllerAnimated:YES];
                PushSingleton *pushSingleton = [PushSingleton pushSharedInstance];
                [pushSingleton configurationRemoToPushWith:model];
            }
            
            

        }else{//返回失败

            [AlertPool alertMessage:model.message xlViewController:self WithBlcok:nil];

        }
    } failsure:^(NSError *error) {


    }];

    
    
    
    
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
     [self.navigationController setNavigationBarHidden:NO animated:NO];
    
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
