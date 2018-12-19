//
//  MyViewController.m
//  maoGang
//
//  Created by xl on 2018/11/13.
//  Copyright © 2018年 bilin. All rights reserved.
//

#import "MyViewController.h"
#import "LoginViewController.h"
#import "HeaderCell.h"
#import "AdvertisementCell.h"
#import "MyCustomCell.h"
#import "SetViewController.h"
#import "MessageViewController.h"
#import "MyModel.h"
#import "BasicDataViewController.h"
#import "MyZiTieViewController.h"
#import "YLReleaseWorksCell.h"
#import "YLACollectionOfPersonalTableViewCell.h"
#import "CircleItem.h"
#import "YLWorkDetailsViewController.h"
#import "YLAllIndividualWorkViewController.h"
#import "YLPublishedWorksViewController.h"
#import "YLMyFansOfViewController.h"
#import "YLMyAttentionViewController.h"
#import "YLMyCollectionViewController.h"
#import "BadgeButton.h"
#import "YLNacigationViewController.h"



@interface MyViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, strong) MyModel *myMode;

@end

@implementation MyViewController

- (void)viewDidLoad {
    self.noAddBackBtn  = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor yellowColor];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.myTableView registerNib:[UINib nibWithNibName:@"HeaderCell" bundle:nil] forCellReuseIdentifier:@"HeaderCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"MyCustomCell" bundle:nil] forCellReuseIdentifier:@"MyCustomCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"AdvertisementCell" bundle:nil] forCellReuseIdentifier:@"AdvertisementCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"YLReleaseWorksCell" bundle:nil] forCellReuseIdentifier:@"YLReleaseWorksCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"YLACollectionOfPersonalTableViewCell" bundle:nil] forCellReuseIdentifier:@"YLACollectionOfPersonalTableViewCell"];
    [self rightsButtonsWithSessionNumTitle:@""];
}

- (void)rightsButtonsWithSessionNumTitle:(NSString *)numTitle {
    UIBarButtonItem *setBarbutton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"shezhi"]imageWithRenderingMode:(UIImageRenderingModeAlwaysOriginal)] style:UIBarButtonItemStylePlain target:self action:@selector(setAction:)];
    BadgeButton *btn = [[BadgeButton alloc] init];
    [btn setImage:[UIImage imageNamed:@"xiaoxi-3"] forState:UIControlStateNormal];
    btn.badgeValue = numTitle.integerValue;//红点的值   _btn.isRedBall = YES;此bool值的设置只显示红点
    [btn addTarget:self action:@selector(messageAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarbutton = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItems = @[setBarbutton,rightBarbutton];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self networkAction];
}
- (void)networkAction {
    NSString *token = TOKEN;
    if (IS_VALID_STRING(token)) {
        [GiFHUD setGifWithMBProgress:@"" toView:self.view];
        [self.dataArray removeAllObjects];
        [[YXHTTPRequst shareInstance] networking:MyMY parameters:@{@"token":token} method:(YXRequstMethodTypePOST) success:^(NSDictionary *dic) {
            BaseModel *model = [BaseModel loadModelWithDictionary:dic];
            [GiFHUD hideHUDForView:self.view];
            if ([model.Result isEqualToString:@"200"]) {
                MyModel *myModel = [MyModel loadModelWithDictionary:dic[@"Info"][@"member"]];
                self.myMode = myModel;
                if (IS_VALID_STRING(myModel.NotReasdNum)) {
                     [self rightsButtonsWithSessionNumTitle:myModel.NotReasdNum];
                }
                NSArray * listArr = dic[@"Info"][@"PostList"];
                if (IS_VALID_ARRAY(listArr)) {
                    for (NSDictionary * dicB in listArr) {
                        CircleItem * model = [CircleItem loadModelWithDictionary:dicB];
                        [self.dataArray addObject:model];
                    }
                    
                }
                
                [self.myTableView reloadData];
            }
        } failsure:^(NSError *error) {
            [GiFHUD hideHUDForView:self.view];
        }];
    } else {// 没有登录 清空数据
        self.myMode = nil;
        [self.dataArray removeAllObjects];
        [self rightsButtonsWithSessionNumTitle:@""];
        [self.myTableView reloadData];
    }
   
}

- (void)setAction:(UIBarButtonItem *)setBarButton {
    isCanLogin
    SetViewController *setVC = [[SetViewController alloc] init];
    [self.navigationController pushViewController:setVC animated:YES];
}


- (void)messageAction:(UIButton *)messageBarButton {
    isCanLogin
    MessageViewController *messageVC = [[MessageViewController alloc] init];
    [self.navigationController pushViewController:messageVC animated:YES];
}


#pragma mark - 收藏
- (void)collectionAction:(UIButton *)sender {
    isCanLogin;
    YLMyCollectionViewController * vc = [[YLMyCollectionViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - 关注
- (void)founseAction:(UIButton *)sender {
    isCanLogin;
    YLMyAttentionViewController * vc = [[YLMyAttentionViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - 粉丝
- (void)fansAction:(UIButton *)sender {
    isCanLogin;
    YLMyFansOfViewController * vc  =[[YLMyFansOfViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - 我的资料mySelfAction

- (void)mySelfAction:(UIButton *)sender {
    isCanLogin;
    BasicDataViewController *dataView = [[BasicDataViewController alloc] init];
    [self.navigationController pushViewController:dataView animated:YES];
}
#pragma mark - 我的作品
- (void)myZuoPin {
    isCanLogin;
    YLAllIndividualWorkViewController * vc = [[YLAllIndividualWorkViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - 我的字帖
- (void)myZitie {
    isCanLogin;
    MyZiTieViewController *myZiTieVC = [[MyZiTieViewController alloc] init];
    [self.navigationController pushViewController:myZiTieVC animated:YES];
}
#pragma mark - 我的广告
- (void)myAdvertis {
    isCanLogin;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (IS_VALID_STRING(self.myMode.AdvertisementPic)) {
          return 5+self.dataArray.count;
    }else{
          return 4+self.dataArray.count;
    }
  
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    if (IS_VALID_STRING(self.myMode.AdvertisementPic)) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell" forIndexPath:indexPath];
            HeaderCell *header = (HeaderCell *)cell;
            if (isLogin) {
                header.nameL.hidden = NO;
                header.desL.hidden = NO;
                header.L_longinOrRegister.hidden = YES;
                
            }else{
                header.nameL.hidden = YES;
                header.desL.hidden = YES;
                header.L_longinOrRegister.hidden = NO;
                header.L_longinOrRegister.text = @"登录/注册";
                
            }
            if (self.myMode) {
                if (IS_VALID_STRING(self.myMode.Nick)) {
                     header.nameL.text = self.myMode.Nick;
                }else{
                     header.nameL.text = @"毛钢用户";
                }
               
                header.desL.text = self.myMode.Autograph;
                header.collectionCountL.text = self.myMode.MyCollectionNum;
                header.founseCountL.text = self.myMode.MyFollowNum;
                header.fanCountL.text = self.myMode.MyFansNum;
                [header.header sd_setImageWithURL:[NSURL URLWithString:self.myMode.HeadPic] placeholderImage:[UIImage imageNamed:@"touxiang_moren"]];
            } else {
                header.nameL.text = @"毛钢用户";
                header.desL.text = @"";
                header.collectionCountL.text = @"0";
                header.founseCountL.text = @"0";
                header.fanCountL.text = @"0";
                header.header.image = [UIImage imageNamed:@"touxiang_moren"];
            }
            [header.collectionBtn addTarget:self action:@selector(collectionAction:) forControlEvents:UIControlEventTouchUpInside];
            [header.founseBtn addTarget:self action:@selector(founseAction:) forControlEvents:UIControlEventTouchUpInside];
            [header.fansBtn addTarget:self action:@selector(fansAction:) forControlEvents:UIControlEventTouchUpInside];
            [header.dataConfigurateBtn addTarget:self action:@selector(mySelfAction:) forControlEvents:UIControlEventTouchUpInside];
            
        } else if (indexPath.row == 1) {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"AdvertisementCell" forIndexPath:indexPath];
            AdvertisementCell * adCell =(AdvertisementCell *) cell;
            [adCell.advertisImageView sd_setImageWithURL:[NSURL URLWithString:self.myMode.AdvertisementPic]];
            
        } else if (indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MyCustomCell" forIndexPath:indexPath];
            ((MyCustomCell *)cell).nameL.text = @"我的字帖";
            ((MyCustomCell *)cell).desL.text = @"";
            
        }else if (indexPath.row==3){
            cell = [tableView dequeueReusableCellWithIdentifier:@"MyCustomCell" forIndexPath:indexPath];
            ((MyCustomCell *)cell).nameL.text = @"作品集";
            ((MyCustomCell *)cell).desL.text = @"查看全部";
        }else if (indexPath.row==4){
            cell = [tableView dequeueReusableCellWithIdentifier:@"YLReleaseWorksCell" forIndexPath:indexPath];
        }
        else {
            
            YLACollectionOfPersonalTableViewCell * ylCell = [tableView dequeueReusableCellWithIdentifier:@"YLACollectionOfPersonalTableViewCell" forIndexPath:indexPath];
            if (self.dataArray.count>indexPath.row-5) {
                CircleItem * model = self.dataArray[indexPath.row-5];
                [ylCell addCircleModel:model];
            }
            return ylCell;
        }
    }else{
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell" forIndexPath:indexPath];
            HeaderCell *header = (HeaderCell *)cell;
            if (isLogin) {
                header.nameL.hidden = NO;
                header.desL.hidden = NO;
                header.L_longinOrRegister.hidden = YES;
                
            }else{
                header.nameL.hidden = YES;
                header.desL.hidden = YES;
                header.L_longinOrRegister.hidden = NO;
                header.L_longinOrRegister.text = @"登录/注册";
                
            }
            if (self.myMode) {
                if (IS_VALID_STRING(self.myMode.Nick)) {
                    header.nameL.text = self.myMode.Nick;
                }else{
                    header.nameL.text = @"毛钢用户";
                }
                
                header.desL.text = self.myMode.Autograph;
                header.collectionCountL.text = self.myMode.MyCollectionNum;
                header.founseCountL.text = self.myMode.MyFollowNum;
                header.fanCountL.text = self.myMode.MyFansNum;
                [header.header sd_setImageWithURL:[NSURL URLWithString:self.myMode.HeadPic] placeholderImage:[UIImage imageNamed:@"touxiang_moren"]];
            } else {
               
                header.nameL.text = @"毛钢用户";
                header.desL.text = @"";
                header.collectionCountL.text = @"0";
                header.founseCountL.text = @"0";
                header.fanCountL.text = @"0";
                header.header.image = [UIImage imageNamed:@"touxiang_moren"];
            }
            [header.collectionBtn addTarget:self action:@selector(collectionAction:) forControlEvents:UIControlEventTouchUpInside];
            [header.founseBtn addTarget:self action:@selector(founseAction:) forControlEvents:UIControlEventTouchUpInside];
            [header.fansBtn addTarget:self action:@selector(fansAction:) forControlEvents:UIControlEventTouchUpInside];
            [header.dataConfigurateBtn addTarget:self action:@selector(mySelfAction:) forControlEvents:UIControlEventTouchUpInside];
            
        }
//        else if (indexPath.row == 1) {
//            cell = [tableView dequeueReusableCellWithIdentifier:@"AdvertisementCell" forIndexPath:indexPath];
//        }
        else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MyCustomCell" forIndexPath:indexPath];
            ((MyCustomCell *)cell).nameL.text = @"我的字帖";
            ((MyCustomCell *)cell).desL.text = @"";
            
        }else if (indexPath.row==2){
            cell = [tableView dequeueReusableCellWithIdentifier:@"MyCustomCell" forIndexPath:indexPath];
            ((MyCustomCell *)cell).nameL.text = @"作品集";
            ((MyCustomCell *)cell).desL.text = @"查看全部";
        }else if (indexPath.row==3){
            cell = [tableView dequeueReusableCellWithIdentifier:@"YLReleaseWorksCell" forIndexPath:indexPath];
        }
        else {
            
            YLACollectionOfPersonalTableViewCell * ylCell = [tableView dequeueReusableCellWithIdentifier:@"YLACollectionOfPersonalTableViewCell" forIndexPath:indexPath];
            if (self.dataArray.count>indexPath.row-4) {
                CircleItem * model = self.dataArray[indexPath.row-4];
                [ylCell addCircleModel:model];
            }
            return ylCell;
        }
        
    }
   
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    isCanLogin;
    if (IS_VALID_STRING(self.myMode.AdvertisementPic)) {
        if (indexPath.row == 0) {
            
        } else if (indexPath.row == 1) {
            [self myAdvertis];
        } else if (indexPath.row == 2) {
            [self myZitie];
        } else if (indexPath.row == 3) {
            [self myZuoPin];
        }else if (indexPath.row==4){
            DLog(@"发布");
            [self pushVCfb];
 
        }else{
            if (self.dataArray.count>indexPath.row-5) {
                CircleItem * model = self.dataArray[indexPath.row-5];
                YLWorkDetailsViewController * vc = [[YLWorkDetailsViewController alloc]init];
                vc.postId = model.PostId;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }else{
        if (indexPath.row == 0) {
            
        } else if (indexPath.row == 1) {
             [self myZitie];
        } else if (indexPath.row == 2) {
            [self myZuoPin];
        } else if (indexPath.row == 3) {
            DLog(@"发布");
            [self pushVCfb];
        
        }else{
            if (self.dataArray.count>indexPath.row-4) {
                CircleItem * model = self.dataArray[indexPath.row-4];
                YLWorkDetailsViewController * vc = [[YLWorkDetailsViewController alloc]init];
                vc.postId = model.PostId;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
   
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IS_VALID_STRING(self.myMode.AdvertisementPic)) {
        if (indexPath.row == 0) {
            return 202.5f;
        } else if (indexPath.row == 1) {
            return 80.5f;
        } else if (indexPath.row == 2) {
            return 48.f;
        } else if (indexPath.row == 3) {
            return 48.f;
        }
        else{
            return 50+27;
        }
    }else{
        if (indexPath.row == 0) {
            return 202.5f;
        } else if (indexPath.row == 1) {
            return 48.f;
        } else if (indexPath.row == 2) {
            return 48.f;
        }
        else{
            return 50+27;
        }
    }
   
    return 0.f;
}




-(void)pushVCfb{
    
    YLPublishedWorksViewController * vc = [[YLPublishedWorksViewController alloc]initWithNibName:@"YLPublishedWorksViewController" bundle:nil];
    YLNacigationViewController * nav = [[YLNacigationViewController alloc]initWithRootViewController:vc ];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:nav animated:YES completion:^{
            
        }];
    });
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
