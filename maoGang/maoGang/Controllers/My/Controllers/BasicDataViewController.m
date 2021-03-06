//
//  BasicDataViewController.m
//  maoGang
//
//  Created by xl on 2018/11/30.
//  Copyright © 2018年 bilin. All rights reserved.
//

#import "BasicDataViewController.h"
#import "IWTextView.h"
#import<AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "UIImageUtils.h"
#import "UIButton+WebCache.h"
@interface BasicDataViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textFd;
@property (weak, nonatomic) IBOutlet IWTextView *textView;
@property (nonatomic, strong) UserModel *userModel;
@property (weak, nonatomic) IBOutlet UIButton *uploadBtn;
@property (nonatomic, strong) UIImage *seletedImage;
@property (nonatomic) BOOL configSelectedImage;



@end

@implementation BasicDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarbutton:)];
    right.tintColor =  RGBCOLOR(254, 62, 47);
    self.navigationItem.rightBarButtonItem = right;
    self.textView.placeholder = @"请填写您的个性签名";
    self.navigationItem.title = @"基础资料";
    self.configSelectedImage = NO;
      [self netUserInfo];// 获取用户信息
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.configSelectedImage) {
//        [self netUserInfo];// 获取用户信息
    }
    self.configSelectedImage = NO;
}

- (void)setUserModel:(UserModel *)userModel {
    _userModel = userModel;
    if (IS_VALID_STRING(userModel.Nick)) {
        self.textFd.text = userModel.Nick;
    } else {
        self.textFd.text = @"";
        self.textFd.placeholder = @"输入昵称";
    }
    if (IS_VALID_STRING(userModel.Autograph)) {
        self.textView.text = userModel.Autograph;
    } else {
        self.textView.text = @"";
        self.textView.placeholder = @"请填写您的个性签名";
    }
    [self.uploadBtn sd_setImageWithURL:[NSURL URLWithString:userModel.HeadPic] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"ziliao_touxiang"]];
}
// 获取用户信息
- (void)netUserInfo {
    NSString *token = TOKEN;
    
    [self netWorkHelperWithPOST:GetBasicInfo parameters:@{@"token":token} success:^(NSDictionary *responseObject) {
        BaseModel *baseModel = [BaseModel loadModelWithDictionary:responseObject];
        if ([baseModel.Result isEqualToString:@"200"]) {// 获取到用户基本信息
            UserModel *userModel = [UserModel loadModelWithDictionary:responseObject[@"Info"]];
            self.userModel = userModel;
        }
    } failure:^(NSError *error) {

    }];
    
}
// 编辑用户信息
- (void)editBasicInformation:(UIBarButtonItem *)sender {
    NSString *token = TOKEN;
    NSString *text = self.textFd.text.length ? self.textFd.text : @"";
    NSString *autogra = self.textView.text.length ? self.textView.text :@"";
    BOOL canUploadImage = self.seletedImage?YES:NO;// 是否可以上传头像
    if (text.length|| autogra.length ||canUploadImage) {
        sender.enabled = NO;
        if (canUploadImage) {
            [[YXHTTPRequst shareInstance] uploadImagesWithURL:EditBasicInfo parameters:@{@"token":token,@"nick":text,@"autograph":autogra} name:@"imageFile" images:@[self.seletedImage] fileNames:@[@"hhh"] imageScale:1 imageType:@"png" progress:^(NSProgress *progress) {
                
            } success:^(id responseObject) {
                sender.enabled = YES;
                BaseModel *model = [BaseModel loadModelWithDictionary:responseObject];
                if ([model.Result isEqualToString:@"200"]) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        UserModel * UModel = [UserManager sharedManager].userModel;
                        UModel.Nick = text;
                        [[UserManager sharedManager]savaUserInfoWith:UModel];
                        
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                }
                [GiFHUD show:model.message view:self.view];
            } failure:^(NSError *error) {
                sender.enabled = YES;

            }];
        } else {
            [self netWorkHelperWithPOST:EditBasicInfo parameters:@{@"token":token,@"nick":text,@"autograph":autogra} success:^(NSDictionary *responseObject) {
                BaseModel *model = [BaseModel loadModelWithDictionary:responseObject];
                sender.enabled = YES;
                if ([model.Result isEqualToString:@"200"]) {
                    UserModel * UModel = [UserManager sharedManager].userModel;
                    UModel.Nick = text;
                    [[UserManager sharedManager]savaUserInfoWith:UModel];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                }
                [GiFHUD show:model.message view:self.view];
            } failure:^(NSError *error) {
                sender.enabled = YES;
            }];
        }
    } else {
        [AlertPool alertMessage:@"请填写用户信息" xlViewController:self WithBlcok:nil];
    }
    
   
    
    
}

/** 开启权限*/
- (void)alertWithSomeMessage:(NSString *)message selectedType:(NSString *)selectedType
{
    UIAlertController *alerVC = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *queding = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:selectedType style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 跳转到设置项
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        
    }];
    [alerVC addAction:queding];
    [alerVC  addAction:ok];
    
    [self.navigationController presentViewController:alerVC animated:YES completion:nil];
    
}
- (IBAction)photoSender:(UIButton *)sender {
    [self MyalertControler];
}

- (void)rightBarbutton:(UIBarButtonItem *)rightBarbutton {
    [self editBasicInformation:rightBarbutton];
}

-(void)MyalertControler{
    UIAlertController *alertControler = [UIAlertController alertControllerWithTitle:@"上传照片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [cancelAction setValue:[UIColor colorWithWhite:0.800 alpha:1.000] forKey:@"titleTextColor"];
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied)
        {
            
            [weakSelf alertWithSomeMessage:@"您没有开启照片权限，前往设置。" selectedType:@"确定"];
            return;
            
        }
        
        
        [weakSelf selectAlbum];
    }];
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *mediaType = AVMediaTypeVideo;
        
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
            // 警示框前往开启权限
            [weakSelf alertWithSomeMessage:@"您没有开启相机权限，前往设置。" selectedType:@"确定"];
            return;
            
        }
        
        
        
        [weakSelf takePhoto];
    }];
    
    [alertControler addAction:cancelAction];
    [alertControler addAction:albumAction];
    [alertControler addAction:takePhotoAction];
    [self presentViewController:alertControler animated:YES completion:nil];
}

- (void)selectAlbum {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.view.backgroundColor = [UIColor whiteColor];
    
    //设置代理
    imagePicker.delegate = self;
    //设置Picker资源类型
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //    //过度类型
    //    imagePicker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    //是否需要编辑
    imagePicker.allowsEditing = YES;
    if (iOS8) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    
    [self presentViewController:imagePicker animated:YES completion:Nil];
}
#if 1
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    
    self.seletedImage= info[@"UIImagePickerControllerEditedImage"];
    CGFloat W = self.seletedImage.size.width;
    CGFloat H = self.seletedImage.size.height;
    CGFloat BL = H / W;
    self.seletedImage = [UIImageUtils scaleToSize: self.seletedImage size:CGSizeMake(1024, 1024 * BL)];
    [self.uploadBtn setImage:self.seletedImage forState:UIControlStateNormal];
    self.configSelectedImage = YES;
#pragma 上传图片
    [picker dismissViewControllerAnimated:YES completion:Nil];
    
}
#endif

#pragma mark---改变相册右边字体颜色
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    viewController.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
}
//拍照
- (void)takePhoto {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
    }
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    //设置代理
    imagePicker.delegate = self;
    //设置Picker资源类型
    imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
    //过度类型
    
    //是否需要编辑
    imagePicker.allowsEditing = YES;
    imagePicker.navigationBar.translucent = NO;
    imagePicker.navigationBar.barTintColor = [UIColor redColor];
    imagePicker.navigationBar.tintColor = [UIColor redColor];
    
    imagePicker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    [self presentViewController:imagePicker animated:YES completion:Nil];
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
