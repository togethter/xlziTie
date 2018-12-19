//
//  YLMyCollectionViewController.m
//  maoGang
//
//  Created by zhangzhen on 2018/12/6.
//  Copyright © 2018 bilin. All rights reserved.
//

#import "YLMyCollectionViewController.h"

#import "CircleItem.h"
#import "CircleUserCell.h"//评论cell
#import "LikeUserTableViewCell.h"//点赞 cell
#import "FriendCircleViewModel.h"
#import "SectionHeaderView.h"
#import "SectionFooterView.h"
#import "ZLPhotoPickerBrowserViewController.h"

#import "XLScrollowContainCommentView.h"

#import "LSActionSheet.h"
#import "YLTiJiaoHearingAlertView.h"

#import "YLReplyPostModel.h"
#import "YLLikeMemberModel.h"
#import "YLPersonalDetailsPageViewController.h"
#import "BasicDataViewController.h"

static NSString *const kCellId = @"CircleCell";
static NSString *const kCellId1 = @"LikeUserCell";
@interface YLMyCollectionViewController ()<CircleUserCellDelegate,XLScrollowContainCommentViewDelegate>{
    NSInteger _page;
}
@property (nonatomic, strong) NSMutableArray *dataMuArr;
@property (nonatomic, strong) NSMutableArray *headerMuArr;
@property (nonatomic, assign) NSInteger selectedSection;
@property (nonatomic, strong) NSDictionary *toPeople;


@property(nonatomic,strong)UITableView * tableV;

@end

@implementation YLMyCollectionViewController

-(NSMutableArray *)dataMuArr
{
    if (!_dataMuArr) {
        _dataMuArr = [NSMutableArray array];
    }
    return _dataMuArr;
}
-(NSMutableArray *)headerMuArr
{
    if (!_headerMuArr) {
        _headerMuArr = [NSMutableArray array];
    }
    return _headerMuArr;
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self loadNewData];
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationItem.title = @"我的收藏";
    [self creatUI];

    // Do any additional setup after loading the view, typically from a nib.
}
-(void)creatUI{
    
    _page = 1;
    
    self.tableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-  TOPBAR_HEIGHT) style:UITableViewStyleGrouped];
    self.tableV.delegate = self;
    self.tableV.dataSource = self;
    if (iOS11) {
        self.tableV.estimatedRowHeight = 0;
        self.tableV.estimatedSectionHeaderHeight = 0;
        self.tableV.estimatedSectionFooterHeight = 0;
    }
    [self.view addSubview:self.tableV];
    
    [self.tableV registerClass:[CircleUserCell class] forCellReuseIdentifier:kCellId];
    [self.tableV registerClass:[LikeUserTableViewCell class] forCellReuseIdentifier:kCellId1];
    self.tableV.rowHeight = UITableViewAutomaticDimension;
    self.tableV.estimatedRowHeight = 90;//预设 cell高度 可不设置
    self.tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableV.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    // 禁止自动加载
    footer.automaticallyRefresh = NO;
    
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    [footer setTitle:@"正在加载..." forState:MJRefreshStateRefreshing];
    
    // 设置字体
    footer.stateLabel.font = [UIFont systemFontOfSize:14];
    // 设置footer
    self.tableV.mj_footer = footer;
    
    
    [self.tableV addSubview:self.Icon_label];
    [self.tableV addSubview:self.Icon_backImage];
    [self.Icon_backImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.tableV);
        make.centerY.equalTo(self.tableV).offset(-20);
    }];
    
    [self.Icon_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.Icon_backImage.mas_bottom).offset(5);
        make.centerX.equalTo(self.Icon_backImage);
    }];
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

-(void)downLoad{
 
    [self netWorkHelperWithPOST:MyMyCollection parameters:@{@"page":@(_page),@"token":TOKEN} success:^(id responseObject) {
        
        BaseModel * model = [BaseModel loadModelWithDictionary:responseObject];
        if ([model.Result isEqualToString:@"200"]) {
            
            NSMutableArray * arr  = [[FriendCircleViewModel new]loadDatasDic:responseObject[@"Info"]];
            [self.dataMuArr addObjectsFromArray:arr];
            
        }
        //        else{
        //            [GiFHUD show:model.message view:self.view];
        //        }
        self.Icon_backImage.hidden = self.dataMuArr.count;
        self.Icon_label.hidden = self.dataMuArr.count;
        [self.tableV.mj_footer endRefreshing ];
        [self.tableV.mj_header endRefreshing ];
        [self.tableV reloadData];
        
        
    } failure:^(NSError *error) {
        
    }];
    
}

-(void)loadNewData{
    _page = 1;
    [self.dataMuArr removeAllObjects];
    [self downLoad];
    
}

-(void)loadMoreData{
    _page++;
    [self downLoad];
    
}

#pragma mark - Table view data source
//分组
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataMuArr.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.dataMuArr.count>section) {
        CircleItem * item = self.dataMuArr[section];
        if (item.LikeList.count>0) {
            return item.replys.count +1;
        }else{
            return item.replys.count;
        }
    }
   
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataMuArr.count>indexPath.row) {
        CircleItem *item = self.dataMuArr[indexPath.section];
        if (item.LikeList.count > 0) {
            if (indexPath.row == 0) {//点赞
                LikeUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId1 forIndexPath:indexPath];
                cell.delegate = self;
                [cell setContentData:item];
                return cell;
            } else {//评论
                CircleUserCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId forIndexPath:indexPath];
                [cell setContentData:item index:indexPath.row - 1];
                cell.delegate = self;
                return cell;
            }
        } else {//评论
            CircleUserCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId forIndexPath:indexPath];
            [cell setContentData:item index:indexPath.row];
            cell.delegate = self;
            return cell;
        }
    }
   
    return [UITableViewCell new];
}

-(UIView * )tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    static NSString * viewIdentfier = @"headView";
    SectionHeaderView * headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:viewIdentfier];
    if (!headerView) {
        headerView = [[SectionHeaderView alloc]initWithReuseIdentifier:viewIdentfier];
    }
    CircleItem * item = self.dataMuArr[section];
    headerView.delegate = self;
    [headerView setContentData:item section:section withIsShowDeleteButton:YES];
    return headerView;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.dataMuArr.count>section) {
        CircleItem * item = self.dataMuArr[section];
        return item.headerHeight;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    static NSString * viewIdentfier = @"footerView";
    SectionFooterView * footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:viewIdentfier];
    if (!footerView) {
        footerView = [[SectionFooterView alloc]initWithReuseIdentifier:viewIdentfier];
        [self.headerMuArr addObject:footerView];
    }
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (self.dataMuArr.count>section) {
        CircleItem * item = self.dataMuArr[section];
        return item.footerHeight;
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //    CircleItem *item = self.dataMuArr[indexPath.section];
    //    NSDictionary *dic = nil;
    //    if (item.LikeList.count > 0) {
    //        if (indexPath.row > 0) {
    //            dic = item.replys[indexPath.row - 1];
    //        }
    //    } else {
    //            dic = item.replys[indexPath.row];
    //    }
    //    if (dic) {
    //        self.selectedSection = indexPath.section;
    //        self.toPeople = @{
    //                          @"comment_to_user_id": [dic valueForKey:@"comment_user_id"],
    //                          @"comment_to_user_name": [dic valueForKey:@"comment_user_name"],
    //                          };
    //        [self startComment];
    //    }
}

#pragma mark - SectionHeaderViewDelegate
//收起 or 全文
- (void)spreadContent:(BOOL)isSpread section:(NSUInteger)section{
    if (self.dataMuArr.count>section) {
        CircleItem *item = self.dataMuArr[section];
        item.isSpread = isSpread;
        item.headerHeight = [[FriendCircleViewModel new] getHeaderHeight:item];
        [self.tableV reloadData];
    }
  
    
}
#pragma mark  --- 点击  姓名 或 头像
- (void)didTapPeople:(CircleItem *)circleItem {
    
    if (IS_VALID_STRING(circleItem.MemberId)) {
        YLPersonalDetailsPageViewController * vc= [[YLPersonalDetailsPageViewController alloc]init];
        vc.memberId = circleItem.MemberId;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (void)didTapImageListView:(NSInteger)section  withImageIndex:(NSInteger)imageIndex{
    if (self.dataMuArr.count>section) {
        
        CircleItem *item = self.dataMuArr[section];
        NSMutableArray *zlPhotos = [NSMutableArray array];
        for (int i = 0; i < item.Pic.count; i++) {
            NSDictionary * urlDic = item.Pic[i];
            NSString * url = [urlDic valueForKey:@"PicPath"];
            ZLPhotoPickerBrowserPhoto *photod = [ZLPhotoPickerBrowserPhoto photoAnyImageObjWith:url];
            [zlPhotos addObject:photod];
        }
        ZLPhotoPickerBrowserViewController *pickerBrowser = [[ZLPhotoPickerBrowserViewController alloc] init];
        // 淡入淡出效果
        // pickerBrowser.status = UIViewAnimationAnimationStatusFade;
        // 数据源/delegate
        pickerBrowser.editing = NO;
        pickerBrowser.photos = zlPhotos;
        // 当前选中的cell
        pickerBrowser.section = section;
        // 能够删除
        pickerBrowser.delegate = self;
        // 当前选中的值
        pickerBrowser.currentIndex = imageIndex;
        
        // 展示控制器
        [pickerBrowser showPickerVc:self];
    }
    
    
}
#pragma mark --- 长按图片
-(void)photoBrowserStateBegan:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoDidSelectView:(UIView *)scrollBoxView atIndex:(NSInteger)index cellIndex:(NSInteger)cellSection{
    
    DLog(@"----==%d  cellIndex:%d",index,cellSection);
    if (self.dataMuArr.count>cellSection) {
        
        CircleItem *item = self.dataMuArr[cellSection];
        if (item.WaterPic.count>index) {
            NSDictionary * imageUrlDic = item.WaterPic[index];
            NSString * imageUrl  = [imageUrlDic valueForKey:@"PicPath"];
            [LSActionSheet showWithTitle:@"提示" destructiveTitle:nil otherTitles:@[@"保存到相册"] block:^(int index) {
                
                LRWeakSelf(self)
                switch (index) {
                    case 0:
                    {
                        [weakself writePhonePhtotoUrl:imageUrl withView:pickerBrowser];
                    }
                        break;
                        
                    default:
                        
                        break;
                }
                
            }withImages:nil withBgBackgroundColor:[UIColor clearColor]];
        }
        
    }
    
    
}

- (void)writePhonePhtotoUrl:(NSString *)url withView:(UIViewController *)vcs{
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    
    dispatch_async(globalQueue, ^{
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        UIImage *image = [UIImage imageWithData:data]; // 取得图片
        
        if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
            ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]init];
            [assetsLibrary writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
                if (error) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        DLog(@"图片保存失败");
                        [GiFHUD show:@"图片保存失败~" view:vcs.view];
                    });
                    
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        DLog(@"图片保存成功");
                        
                        [GiFHUD show:@"图片保存成功~" view:vcs.view];
                        
                    });
                    
                }
            }];
        }
        
    });
}


#pragma mark --- 点赞
- (void)didClickLikeButton:(NSInteger)section withButton:(nonnull UIButton *)btn{
    isCanLogin
    if (self.dataMuArr.count>section) {
        CircleItem *item = self.dataMuArr[section];
        [self MyPostesLikesToModel:item withButton:btn withSection:section];
        
    }
   
}
-(void)MyPostesLikesToModel:(CircleItem *)model  withButton:(UIButton *)btn withSection:(NSInteger)section{
    
    if (IS_VALID_STRING(model.PostId)) {
        btn.userInteractionEnabled = NO;
        [self netWorkHelperWithPOST:MyPostesLikes parameters:@{@"token":TOKEN,@"postId":model.PostId} success:^(id responseObject) {
            btn.userInteractionEnabled = YES;
            BaseModel * Bmodel = [BaseModel loadModelWithDictionary:responseObject];
            if ([Bmodel.Result isEqualToString:@"200"]) {
                
                NSString * info = [NSString stringWithFormat:@"%@",responseObject[@"Info"]];
                NSMutableArray *muArr = [NSMutableArray arrayWithArray:model.LikeList];
                NSDictionary *containDic = nil;
                
                if (IS_VALID_STRING(info)&&[info isEqualToString:@"1"]) {//点赞成功
                    
                    model.IsLike = @"1";
                    model.LikesNum =[NSString stringWithFormat:@"%ld",model.LikesNum.integerValue+1];
                    //作者自己 后期添加
                    [muArr addObject:@{@"LikeMemberId": [UserManager sharedManager].userModel.MemberId, @"LikeMemberNick": [UserManager sharedManager].userModel.Nick,@"PostMemberId":@"",@"LikeId":@"",@"PostId":@""}];
                    
                }else{//取消点赞
                    model.IsLike = @"0";
                    model.LikesNum =[NSString stringWithFormat:@"%ld",model.LikesNum.integerValue-1];
                    if (IS_VALID_ARRAY(model.LikeList)) {
                        
                        for (NSDictionary *dic in model.LikeList) {
                            YLLikeMemberModel * likeModel = [YLLikeMemberModel loadModelWithDictionary:dic];
                            if ([likeModel.LikeMemberId  isEqualToString:[UserManager sharedManager].userModel.MemberId]) {
                                
                                containDic = dic;
                                break;
                            }
                        }
                        
                    }
                    
                    [muArr removeObject:containDic];
                    
                }
                model.LikeList = [muArr copy];
                [[FriendCircleViewModel new] calculateItemHeight:model];
                
                [self.dataMuArr replaceObjectAtIndex:section withObject:model];
                
                [self.tableV reloadData];
                
                
            }
            else if ([Bmodel.Result isEqualToString:@"201"]){//去完善资料
                DLog(@"去完善资料");
                LRWeakSelf(self)
                YLTiJiaoHearingAlertView * vc = [[YLTiJiaoHearingAlertView alloc]initWithTitle:@"去完善资料" Iconimage:@"" message:@"完善资料才可使用此功能！" messageTitleCentect:YES cancelBtnTitle:@"否" otherBtnTitle:@"是" clickIndexBlock:^(NSInteger clickIndex) {
                    DLog(@"-==--%ld",clickIndex);
                    switch (clickIndex) {
                        case 239://是
                        {
                            BasicDataViewController * vc = [[BasicDataViewController alloc]init];
                            [weakself.navigationController pushViewController:vc animated:YES];
                        }
                            break;
                            
                        default:
                            break;
                    }
                    
                }];
                [vc showLXAlertView];
                
                
                
                
            }
            //            else{
            //                [GiFHUD show:Bmodel.message view:self.view];
            //            }
            
        } failure:^(NSError *error) {
            btn.userInteractionEnabled = YES;
        }];
        
        
    }
    
}
#pragma mark --  收藏
- (void)didClickShouCangButton:(NSInteger)section withButton:(UIButton *)btn {
    isCanLogin
    if (self.dataMuArr.count>section) {
        CircleItem *item = self.dataMuArr[section];
        [self MyPostesCollectionToModel:item withButton:btn withSection:section];
    }
    
    
}
-(void)MyPostesCollectionToModel:(CircleItem *)model  withButton:(UIButton *)btn withSection:(NSInteger)section{
    
    if (IS_VALID_STRING(model.PostId)) {
        btn.userInteractionEnabled = NO;
        [self netWorkHelperWithPOST:MyPostesCollection parameters:@{@"token":TOKEN,@"postId":model.PostId} success:^(id responseObject) {
            btn.userInteractionEnabled = YES;
            BaseModel * Bmodel = [BaseModel loadModelWithDictionary:responseObject];
            if ([Bmodel.Result isEqualToString:@"200"]) {
                
//                NSString * info = [NSString stringWithFormat:@"%@",responseObject[@"Info"]];
//                if (IS_VALID_STRING(info)&&[info isEqualToString:@"1"]) {//收藏成功
//                    model.IsCollection = @"1";
//                }else{//取消收藏
//                    model.IsCollection = @"0";
//                }
                if (self.dataMuArr.count>section) {
                    [self.dataMuArr removeObjectAtIndex:section];
                }
                [self.tableV reloadData];
                
                
            }
           
            
        } failure:^(NSError *error) {
            btn.userInteractionEnabled = YES;
        }];
        
    }
    
}



#pragma mark -- 评论
- (void)didClickCommentButton:(NSInteger)section withButton:(UIButton *)btn {
    if (self.dataMuArr.count>section) {
        
        CircleItem *item = self.dataMuArr[section];
        [XLScrollowContainCommentView xlScrollowContainCommentViewWith:item withDelegate:self WithIndexPath:section];
    }
   
    
}

-(void)showNewReplyCommentDic:(NSDictionary *)contentDic withCellSection:(NSInteger)section{
    
    if (self.dataMuArr.count>section) {
        CircleItem *item = self.dataMuArr[section];
        NSMutableArray *comments = [NSMutableArray arrayWithArray:item.replys];
        [comments addObject:contentDic];
        item.replys = [comments copy];
        [[FriendCircleViewModel new] calculateItemHeight:item];
        [self.dataMuArr replaceObjectAtIndex:section withObject:item];
        [self.tableV reloadData];
    }
   
    
}

- (void)XLScrollowContainCommentViewLogin
{
    DLog(@"登录去");
    isCanLogin
}
#pragma mark --- 完善资料
-(void)XLScrollowContainCommentViewBasicDataViewController{
    
    LRWeakSelf(self)
    YLTiJiaoHearingAlertView * vc = [[YLTiJiaoHearingAlertView alloc]initWithTitle:@"去完善资料" Iconimage:@"" message:@"完善资料才可使用此功能！" messageTitleCentect:YES cancelBtnTitle:@"否" otherBtnTitle:@"是" clickIndexBlock:^(NSInteger clickIndex) {
        DLog(@"-==--%ld",clickIndex);
        switch (clickIndex) {
            case 239://是
            {
                BasicDataViewController * vc = [[BasicDataViewController alloc]init];
                [weakself.navigationController pushViewController:vc animated:YES];
            }
                break;
                
            default:
                break;
        }
        
    }];
    [vc showLXAlertView];
}



#pragma mark - CircleCellDelegate,LikeUserCellDelegate

- (void)didSelectPeople:(NSDictionary *)dic {
    NSLog(@"%@",dic);
    //    UIViewController *vc = [UIViewController new];
    //    vc.view.backgroundColor = [UIColor whiteColor];
    //    vc.navigationItem.title = [dic valueForKey:@"user_name"];
    //    [self.navigationController pushViewController:vc animated:YES];
    
    
    //    YLViewDetailsViewController * vc = [[YLViewDetailsViewController alloc]init];
    //    [self.navigationController pushViewController:vc animated:YES];
    
}


- (void)dealloc {
    DLog(@"%@--dealloc",[self class]);
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
