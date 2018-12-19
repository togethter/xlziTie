//
//  RegisterViewController.m
//  LvJie
//
//  Created by bilin on 2017/1/5.
//  Copyright © 2017年 Bilin-Apple. All rights reserved.
//


#import "RegisterViewController.h"
//#import "LawyerBXTabBarController.h"
#import "sys/utsname.h"
#import "WorshipTheJudgeNetworkViewController.h"
#import "RegCodeModel.h"
#import "AlertForRegister.h"
#import <ShareSDK/ShareSDK.h>
#import "TBTabBarController.h"
typedef NS_ENUM(NSInteger, SelectStateType) {
    SelectStateTypeNO,
    SelectStateTypeYES,
};
@interface RegisterViewController ()<UITextFieldDelegate>
// 手机号
@property (weak, nonatomic) IBOutlet UITextField *userName;
// 验证码
@property (weak, nonatomic) IBOutlet UITextField *VerificationCode;
// 密码
@property (weak, nonatomic) IBOutlet UITextField *passWord;
@property (nonatomic, assign) SelectStateType select;
// 距离上边的距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceToTop;
// 获取验证码的的button
@property (weak, nonatomic) IBOutlet UIButton *getVerificationBtn;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;

@property (nonatomic, strong) UserModel *model;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
// 三个控件的高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userOrPassOrVerificationH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backBtnToTop;

@property (nonatomic, strong) RegCodeModel *codeModel;

//记录 是否弹框 1弹  2不弹
@property (nonatomic, copy) NSString * ShowAlertWX;

/** 取消*/
@property (nonatomic, assign) BOOL isCancel;

@end

@implementation RegisterViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
}

/** 关闭注册btn的交互和开启动画*/
- (void)actioncloseUserInteractionEnabledAction {
    self.registerBtn.userInteractionEnabled = NO;
    self.activityView.hidden = NO;
    [self.activityView startAnimating];
}
/**打开注册btn的交互和关闭动画*/
- (void)actionOpenUserInteractionEnabledAction {
    self.registerBtn.userInteractionEnabled = YES;
    self.activityView.hidden = YES;
    [self.activityView stopAnimating];
}

// 获取验证码的方法
- (IBAction)getVerifcationCodeAction:(UIButton *)sender {
    // 需要判断当前网络吗？
    if (IS_VALID_STRING(self.userName.text) && [self.userName.text isTelephone]) {// 有值并且是手机号
        sender.userInteractionEnabled = NO;
        NSString *time = [LCMD5Tool returnsTheTimestamp];
        NSString *code = [LCMD5Tool returnsTheMD5EncryptionTimestamp:time];
        [self netWorkHelperWithPOST:ReginsterSendRegCode parameters:@{@"phone" : self.userName.text,@"time":time,@"code":code} success:^(id responseObject) {

            NSDictionary *dic = responseObject;
            RegCodeModel *model = [RegCodeModel loadModelWithDictionary:dic];
            switch ([model.Result integerValue]) {/** 网络请求的返回的状态 200 ---成功， 500 -- 系统内部错误， 404 ---- 信息不存在， 300 ---- 信息不存在*/
                case 200://成功
                {
                    NSString *SkipTime = model.SkipTime;
                    if (IS_VALID_STRING(SkipTime)) {
                        [self startTimeWithAlertTime:[SkipTime intValue]];
                    } else {
                        // 这里定时器显示倒计时
                        [self startTimeWithAlertTime:VerificationCodeTime];
                    }


                }
                    break;


                default:{

                sender.userInteractionEnabled = YES;

                }
                    break;
            }


        } failure:^(NSError *error) {
            sender.userInteractionEnabled = YES;
        }];

    } else {
        [AlertPool alertMessage:@"请输入11位有效的手机号" xlViewController:self WithBlcok:nil];
    }

    
    
}
#pragma mark - 注册
// 注册的方法code  time phone = 手机号, password=密码, captch=验证码
- (IBAction)registerActopm:(UIButton *)sender {
    if (!(IS_VALID_STRING(self.userName.text) && IS_VALID_STRING(self.passWord.text))) {// 手机号以及密码不能为空

        [AlertPool alertMessage:@"手机号或者密码不能为空" xlViewController:self WithBlcok:nil];
        return;
    }

    if (![self.userName.text isTelephone]) {// 是手机号
        [AlertPool alertMessage:@"请输入有效的手机号" xlViewController:self WithBlcok:nil];
        return;
    }

    if (!IS_VALID_STRING(self.VerificationCode.text)) {

        [AlertPool alertMessage:@"请输入有效的验证码" xlViewController:self WithBlcok:nil];

        return;
    }

    if (_select == SelectStateTypeNO) {
        [AlertPool alertMessage:@"未同意服务条款" xlViewController:self WithBlcok:nil];
        return;
    }
    NSString * platform = [self datePlatform];
    if (!IS_VALID_STRING(platform)) {
        platform = @"";
    }
    NSString *url = @"";
    NSMutableDictionary *dic = @{@"code" : self.VerificationCode.text, @"phone" : self.userName.text, @"password" : self.passWord.text , @"phoneType" : @(1),@"phoneModel":platform,@"province":@"",@"city":@"",@"area":@""}.mutableCopy;
    if (self.dic && [self.dic isKindOfClass:[NSDictionary class]]) {// 字典
        url = self.dic[@"url"];
        NSString *openId = self.dic[@"openId"];
        [dic setValue:[NSString stringWithFormat:@"%@",openId] forKey:@"openId"];
    } else {
        url = Reginster;
    }

    // 注册的网络请求
    // 关闭交互 开启动画
    [self actioncloseUserInteractionEnabledAction];
    [self netWorkHelperWithPOST:url parameters:dic success:^(id responseObject) {
        // 开启交互 关闭动画
        [self actionOpenUserInteractionEnabledAction];
        NSDictionary *dic = responseObject;
        BaseModel *baseModel = [BaseModel loadModelWithDictionary:dic];

        switch ([baseModel.Result integerValue]) {/** 网络请求的返回的状态 200 ---成功， 500 -- 系统内部错误， 404 ---- 信息不存在， 300 ---- 信息不存在*/
            case 200://成功
            {
                self.isCancel = NO;// 点击获取验证码的时候
                LRWeakSelf(self);
                baseModel.userModel = [UserModel loadModelWithDictionary:dic[@"Info"]];
                baseModel.userModel.Auth = dic[@"Auth"];
                [AlertPool alertMessage:@"注册成功" xlViewController:self WithBlcok:^{ // 点击确定话直接进入APP
                    // 将手机号写入 将密码清空
                    writePhoneOrPassword(self.userName.text, @"");
                    // 清除用户保存的数据
                    [[UserManager sharedManager] cleanUserInfo];
                    // 保存新的用户数据
                    [[UserManager sharedManager] savaUserInfoWith:baseModel.userModel];
                    // 直接进入 APP 或者 登录页
                    TBTabBarController *tbBar = [[TBTabBarController alloc] init];
                    weakself.view.window.rootViewController =   tbBar;
                    
                }];


            }
                break;

            default:
                break;
        }

    } failure:^(NSError *error) {
        // 开启交互关闭动画
        [self actionOpenUserInteractionEnabledAction];
    }];
}


//获取手机类型
- (NSString *)datePlatform{
    
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    //（公司的应用不支持iPad）
    // iPhone
    if ([deviceString isEqualToString:@"iPhone1,1"]) return @"iPhone2G";
    if ([deviceString isEqualToString:@"iPhone1,2"]) return @"iPhone3G";
    if ([deviceString isEqualToString:@"iPhone2,1"]) return @"iPhone3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"]) return @"iPhone4";
    if ([deviceString isEqualToString:@"iPhone3,2"]) return @"iPhone4";
    if ([deviceString isEqualToString:@"iPhone3,3"]) return @"iPhone4";
    if ([deviceString isEqualToString:@"iPhone4,1"]) return @"iPhone4S";
    if ([deviceString isEqualToString:@"iPhone5,1"]) return @"iPhone5";
    if ([deviceString isEqualToString:@"iPhone5,2"]) return @"iPhone5";
    if ([deviceString isEqualToString:@"iPhone5,3"]) return @"iPhone5c";
    if ([deviceString isEqualToString:@"iPhone5,4"]) return @"iPhone5c";
    if ([deviceString isEqualToString:@"iPhone6,1"]) return @"iPhone5s";
    if ([deviceString isEqualToString:@"iPhone6,2"]) return @"iPhone5s";
    if ([deviceString isEqualToString:@"iPhone7,2"]) return @"iPhone6";
    if ([deviceString isEqualToString:@"iPhone7,1"]) return @"iPhone6Plus";
    if ([deviceString isEqualToString:@"iPhone8,1"]) return @"iPhone6s";
    if ([deviceString isEqualToString:@"iPhone8,2"]) return @"iPhone6sPlus";
    if ([deviceString isEqualToString:@"iPhone8,3"]) return @"iPhoneSE";
    if ([deviceString isEqualToString:@"iPhone8,4"]) return @"iPhoneSE";
    if ([deviceString isEqualToString:@"iPhone9,1"]) return @"iPhone7";
    if ([deviceString isEqualToString:@"iPhone9,2"]) return @"iPhone7Plus";
    //如果没有匹配直接返回系统提供的类似@"iPhone5,3"这种型号
    return deviceString;
}

- (void)startTimeWithAlertTime:(int)alertTime
{
    __block int timeout=VerificationCodeTime; //倒计时时间
    __block NSString * isShow = @"1";//是否显示  1显示  2不显示
    __weak typeof(self)wsSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                [wsSelf.getVerificationBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
                [wsSelf.getVerificationBtn setTitleColor:RGBCOLOR(0, 128, 252) forState:UIControlStateNormal];
                wsSelf.getVerificationBtn.userInteractionEnabled = YES;
                wsSelf.ShowAlertWX = @"1";
                if (self.isCancel) {// 点击叉号
                    isShow = @"1";
                }
                if ([isShow isEqualToString:@"1"]) {
                    [wsSelf showAlert];// 弹框
                }
               
            });
        }else{ // 倒计时开始
            int seconds = timeout ;
            int alertTimeShow = VerificationCodeTime - alertTime;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                [wsSelf.getVerificationBtn setTitle:[NSString stringWithFormat:@"%@秒后重新发送", strTime] forState:UIControlStateNormal];
                [wsSelf.getVerificationBtn setTitleColor:[UIColor colorWithWhite:0.702 alpha:1.000] forState:UIControlStateNormal];
                wsSelf.getVerificationBtn.userInteractionEnabled = NO;
                if (seconds == alertTimeShow) {// 如果恒等于改时间的话
                    wsSelf.ShowAlertWX = @"1";
                    isShow = @"2";
                    [wsSelf showAlert];
                } else {
                    if (![wsSelf.ShowAlertWX isEqualToString:@"1"]) {
                        wsSelf.ShowAlertWX = @"2";
                    }
                }
               
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
    
}


- (void)showAlert
{
    __weak typeof(self)weakSelf = self;
    if (self.view.window) {// 当该试图控制器在window里的下
        AlertForRegister *alert = [[AlertForRegister alloc] initWithalertWithWithModel:nil withAlertBlock:^(clickEnum toWhathEnum) {
            weakSelf.ShowAlertWX = @"2";
            weakSelf.isCancel = YES;
            switch (toWhathEnum) {
                case wxLogin:// 微信登录
                    [weakSelf loginWX];
                    break;
                default:
                    break;
            }

        } ClickItem:nil withViewSubViewView:nil];

        [alert show];
    }
}
#pragma mark -- 微信登录
- (void)loginWX
{
    if (!IS_VALID_STRING(self.userName.text)) {
        [GiFHUD show:@"请输入正确的手机号~" view:self.view];
        return;
    }
    NSString *qqorwx = @"";
    __weak typeof(self)weakSelf = self;
    if (self.dic && [self.dic isKindOfClass:[NSDictionary class]]) {
        qqorwx = self.dic[@"qqOrwx"];
        SSDKPlatformType type = 0;
        if ([qqorwx isEqualToString:@"2"]) {// WX
            type = SSDKPlatformTypeWechat;
        } else {// QQ
            type = SSDKPlatformTypeQQ;
        }
        [ShareSDK getUserInfo:type
               onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
         {
             if (state == SSDKResponseStateSuccess)
             {
                 
                 //取消授权
                 [ShareSDK cancelAuthorize:type];
                 
                 if (IS_VALID_STRING(user.uid)) {// 微信注册
                     
                     [weakSelf loginLvJieWithUid:user.uid withtype:qqorwx];
                 }
                 
             }
             
             else
             {
                 [GiFHUD show:@"授权失败~" view:self.view];
                 
             }
             
         }];
        
        
    }else {
        [ShareSDK getUserInfo:SSDKPlatformTypeWechat
               onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
         {
             if (state == SSDKResponseStateSuccess)
             {
                 
                 
                 //取消授权
                 [ShareSDK cancelAuthorize:SSDKPlatformTypeWechat];
                 
                 if (IS_VALID_STRING(user.uid)) {// 微信注册
                     
                     [weakSelf loginLvJieWithUid:user.uid withtype:@"2"];
                 }
                 
             }
             
             else
             {
                 [GiFHUD show:@"授权失败~" view:self.view];
                 
             }
             
         }];
    }
    

}

- (void)loginLvJieWithUid:(NSString *)uid withtype:(NSString *)type
{
    NSString * platform = [self datePlatform];
    if (!IS_VALID_STRING(platform)) {
        platform = @"";
    }
    if (!IS_VALID_STRING(uid)) {
        [AlertPool alertMessage:@"uid为空" xlViewController:self WithBlcok:nil];
        return;
    }
#pragma mark ---  用户手机号为空提示
    if (!IS_VALID_STRING(self.userName.text)) {
        [AlertPool alertMessage:@"手机号为空" xlViewController:self WithBlcok:nil];
        return;
    }

    NSString *time = [LCMD5Tool returnsTheTimestamp];// time
    NSString *code = [LCMD5Tool returnsTheMD5EncryptionTimestamp:time]; //code
    // 注册的网络请求
    // 关闭交互 开启动画
    [self actioncloseUserInteractionEnabledAction];
    NSString *url = @"";
    if ([type isEqualToString:@"1"]) {// qq
        url = QQRegSkip;
    } else {// wx
        url = WeChatRegSkip;
    }
    [self netWorkHelperWithPOST:url parameters:@{@"sign" : code,@"time":time,@"phone" : self.userName.text,@"openId":uid , @"phoneType" : @"1",@"phoneModel":platform,@"province":@"",@"city":@"",@"area":@""} success:^(id responseObject) {
        // 开启交互 关闭动画
        [self actionOpenUserInteractionEnabledAction];
        NSDictionary *dic = responseObject;
        BaseModel *baseModel = [BaseModel loadModelWithDictionary:dic];

        switch ([baseModel.Result integerValue]) {/** 网络请求的返回的状态 200 ---成功， 500 -- 系统内部错误， 404 ---- 信息不存在， 300 ---- 信息不存在*/
            case 200://成功
            {
                self.isCancel = NO;// 点击获取验证码的时候
                LRWeakSelf(self);
                baseModel.userModel = [UserModel loadModelWithDictionary:dic[@"Info"]];
                baseModel.userModel.Auth = dic[@"Auth"];
                [AlertPool alertMessage:@"注册成功" xlViewController:self WithBlcok:^{ // 点击确定话直接进入APP
                    // 将手机号写入 将密码清空
                    writePhoneOrPassword(self.userName.text, @"");
                    // 清除用户保存的数据
                    [[UserManager sharedManager] cleanUserInfo];
                    // 保存新的用户数据
                    [[UserManager sharedManager] savaUserInfoWith:baseModel.userModel];
                    // 直接进入 APP 或者 登录页
                    TBTabBarController *tbBar = [[TBTabBarController alloc] init];
                    weakself.view.window.rootViewController =   tbBar;
                    
                }];


            }
                break;

            default:
                break;
        }

    } failure:^(NSError *error) {
        // 开启交互关闭动画
        [self actionOpenUserInteractionEnabledAction];
    }];
}
#pragma mark--协议
- (IBAction)buttonClickedZhuCe:(UIButton *)sender {
    
    
    WorshipTheJudgeNetworkViewController * worshipVC = [[WorshipTheJudgeNetworkViewController alloc] init];
//    worshipVC.webType = WebAgreement;
//
    [self.navigationController pushViewController:worshipVC animated:YES];
    
    
}


// 返回的点击事件
- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (IS_VALID_STRING(self.ShowAlertWX)&&[self.ShowAlertWX isEqualToString:@"1"]) {
        [self showAlert];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // 默认是选中的
    _select = SelectStateTypeYES;
    self.activityView.hidden = YES;
    self.registerBtn.backgroundColor = ButtotUnNormalRGB;

    [self addNotificationCenter];
    CGFloat distanceToTop = _distanceToTop.constant;
    _distanceToTop.constant = XFSH(distanceToTop);
    CGFloat userOrPassOrVerificationH = _userOrPassOrVerificationH.constant;
    _userOrPassOrVerificationH.constant = XFSH(userOrPassOrVerificationH);
    
    self.view.backgroundColor = [UIColor whiteColor];
    
//    self.userName.delegate = self;
//    self.VerificationCode.delegate = self;
//    self.passWord.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    if (iPhoneX||iPhoneXM||iPhoneXR) {
        self.backBtnToTop.constant = 44;
    } else {
        self.backBtnToTop.constant = 20;
    }
     self.ShowAlertWX = @"2";
    self.isCancel = NO;// 是否点击取消
}

-(void)textFieldDidChange{


    if (IS_VALID_STRING(self.passWord.text)&&IS_VALID_STRING(self.VerificationCode.text)&&IS_VALID_STRING(self.userName.text)) {
        
        self.registerBtn.userInteractionEnabled = YES;
        self.registerBtn.backgroundColor = ButtonBackGroudRGB;
    }else{
        self.registerBtn.userInteractionEnabled = NO;
        self.registerBtn.backgroundColor =  ButtotUnNormalRGB;
        
    }
    
   
}


- (void)addNotificationCenter
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowKeyBoard) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHiddenKeyBoard) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginEding:) name:UITextFieldTextDidBeginEditingNotification object:nil];
}
- (void)willShowKeyBoard
{
    
    
}

- (void)beginEding:(NSNotification *)notification
{
    
    if (self.view.window) {
        [UIView animateWithDuration:0.1 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
            if (kScreenHeight == 480.0) {
                _distanceToTop.constant = XFSH(20);
                return ;
            }
            
            if (iPhone4 | iPhone5) {
                _distanceToTop.constant = XFSH(20);
            } else {
                _distanceToTop.constant = XFSH(116);
            }
            ;
            
        } completion:^(BOOL finished) {
            
        }];
        
    }

    
    
    
}
- (void)willHiddenKeyBoard
{
    
    
    if (self.view.window) {
        [UIView animateWithDuration:0.1 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
            _distanceToTop.constant = XFSH(116);
            
        } completion:^(BOOL finished) {
            
        }];
        
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 选中改变状态
- (IBAction)SelectState:(UIButton *)sender {
    if (_select == SelectStateTypeNO) {
        [sender setImage:[UIImage imageNamed:@"btn_xuanzhong_b"]forState:UIControlStateNormal];
        _select = SelectStateTypeYES;
    } else {
        [sender setImage:[UIImage imageNamed:@"btn_xuanzhong_a"] forState:UIControlStateNormal];
        _select = SelectStateTypeNO;
    }
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
