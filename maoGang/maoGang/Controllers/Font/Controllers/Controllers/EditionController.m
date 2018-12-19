//
//  EditionController.m
//  maoGang
//
//  Created by xl on 2018/11/24.
//  Copyright © 2018年 bilin. All rights reserved.
//

#import "EditionController.h"
#import "MaogangDictionaryViewController.h"
#import "CustomAlertView.h"
#import "TypesettingViewController.h"// 排版
#import "EditionAddViewController.h"
#import "GXWaterCollectionViewLayout.h"
#import "GXWaterCVCell.h"
#import "YLAlertAddBookTool.h"
#import "AFURLSessionManager.h"
NSString const *textStr = @"";
@interface EditionController ()<EditionAddViewControllerDelegate,UICollectionViewDelegate, UICollectionViewDataSource,GXWaterCollectionViewLayoutDelegate>
{
    
}
@property (weak, nonatomic) IBOutlet UIView *yView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, strong) UIButton *rightBtn;

@property (weak, nonatomic) IBOutlet UIView *bottomContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMargin;

@property (weak, nonatomic) IBOutlet UIImageView *ttpView;

@property (nonatomic) NSInteger fontTypeIndex;// 字体大小
@property (nonatomic, copy) NSString *text;// 网页文字

@property (nonatomic, strong) CustomAlertModel *customAlertModel;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) NSInteger numberOfColumns;

@property (nonatomic, assign) NSInteger numberLineCount;

@property (nonatomic, strong) GXWaterCollectionViewLayout *waterLayout;

@property (nonatomic, assign) NSInteger wenziCount;
@property(nonatomic,strong) YLAlertAddBookTool * AddbookVc ;

@end


//@"SIMKAI",@"方正瘦金书GBK_宋徵宗瘦金体",@"报隶-简常规体",@"德彪钢笔行书字库",@"方正苏新诗柳楷简体",@"李旭科书法"
@implementation EditionController


-(YLAlertAddBookTool * )AddbookVc{
    if (!_AddbookVc) {
        _AddbookVc = [[YLAlertAddBookTool alloc]initWithFrame:CGRectMake((kScreenWidth-AdaptedWidthValue(584)/2)/2, (kScreenHeight-AdaptedHeightValue(150))/2, AdaptedWidthValue(584)/2, AdaptedHeightValue(150))];
    }
    return _AddbookVc;
    
}
- (void)downLoadFontWithCellmodel:(FontModel *)model{
    
    if ([FontMnager  fontPathisExist:model.DownloadUrl])  {// 下载过了直接将字体替换掉
        [[FontMnager fontInstance] registerFontWithPath:[[FontMnager fontInstance]fileURLWithUrlPath:model.DownloadUrl]];
        return;
    }
    // 下载字体弹框
    __weak typeof(self)weakSelf = self;
    [TipAlert centerAlertShowtipAlertisSureBlock:^(BOOL isSure) {
        if (!isSure) return;
        [weakSelf.AddbookVc show];
        
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *fonPath = [path stringByAppendingPathComponent:@"XLFont"];
        NSFileManager *fileManger = [NSFileManager defaultManager];
        BOOL isDirectory = NO;
        BOOL isFileExists =  [fileManger fileExistsAtPath:fonPath isDirectory:&isDirectory];
        if (!isFileExists && isDirectory == NO) {
            [[NSFileManager defaultManager] createDirectoryAtPath:fonPath withIntermediateDirectories:YES attributes:nil error:nil];
            
        }
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        NSString *baseUrl = nil;
        if ([UIDevice currentDevice].systemName.floatValue <= 9.0) {
            baseUrl = [model.DownloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }else{
            baseUrl = [model.DownloadUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<>"].invertedSet];
        }
        
        NSURL *URL = [NSURL URLWithString:baseUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.AddbookVc.progressView.progress =  downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
                weakSelf.AddbookVc.numberProgressL.text = [NSString stringWithFormat:@"%d%%", (int)floor(weakSelf.AddbookVc.progressView.progress * 100)];
            });
            
        } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            NSURL *documentsDirectoryURL = [NSURL fileURLWithPath:[fonPath stringByAppendingPathComponent:baseUrl.md5]];
            return documentsDirectoryURL;
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            NSLog(@"File downloaded to: %@", filePath);
            [[FontMnager fontInstance] registerFontWithPath:filePath];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.AddbookVc close];
                _AddbookVc = nil;
                [weakSelf.collectionView reloadData];
            });
            
        }];
        [downloadTask resume];
    }];
    
}

- (void)configurateNumberOfColumns:(NSInteger)numberOfColumns numberLineCount:(NSInteger)numberLineCount vertical:(BOOL) isvertical {
    self.numberOfColumns = numberOfColumns;// 列数
    self.numberLineCount = numberLineCount;// 行数
    self.waterLayout.numberOfColumns = self.numberOfColumns;// 列数
    self.waterLayout.vertical = YES;// 本页面所有的都是横排
    [self.collectionView reloadData];
}
- (void)setFontTypeIndex:(NSInteger)xfontTypeIndex {
    if (!self.fontModelArray.count) return;
    if (xfontTypeIndex < 0) {
        xfontTypeIndex = self.fontModelArray.count?(self.fontModelArray.count - 1):0;
    } else if (xfontTypeIndex > self.fontModelArray.count - 1) {
        xfontTypeIndex = 0;
    }
    _fontTypeIndex = xfontTypeIndex;
    self.customAlertModel.fontType = @(_fontTypeIndex);
    FontModel *fontModel = self.fontModelArray[xfontTypeIndex];
    self.customAlertModel.TypefaceId = fontModel.TypefaceId;//字体的编号
    [self downLoadFontWithCellmodel:fontModel];
    [self.ttpView sd_setImageWithURL:[NSURL URLWithString:fontModel.SwitchPic] placeholderImage:nil];
    [self.collectionView reloadData];
    #pragma mark -- 执行javarscrip

}


- (void)configurateTXT:(NSString *)TXT shiCiId:(NSString *)shiCiId contentId:(NSString *)contentId
{
    self.customAlertModel.shiciId = shiCiId;
    self.customAlertModel.contentId = contentId;
    self.text = TXT;
}

- (IBAction)previous:(UIButton *)sender {
    self.fontTypeIndex-=1;
}

- (IBAction)next:(UIButton *)sender {
    self.fontTypeIndex+=1;
}

- (void)dealloc {
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (NSString*)stringByTrimAllWhitespace:(NSString *)text {
    NSCharacterSet*set = [NSCharacterSet whitespaceCharacterSet];//空格的字符集
    return[[text componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
}
- (NSString *)noWhiteSpaceString:(NSString *)text {
    NSString *newString = text;
    //去除掉首尾的空白字符和换行字符
    NSArray *array = @[@"\n",@"\r",@"\n ",@"/n"];
    NSInteger index = 0;
    newString = [self stringByTrimAllWhitespace:newString];
    while (index < array.count - 1) {
        NSString *str = array[index];
        newString = [newString stringByReplacingOccurrencesOfString:str withString:@""];
        index++;
    }
    return newString;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.yView.layer.cornerRadius = 3;
    self.yView.layer.masksToBounds = YES;
    __weak typeof(self)weakSelf = self;
    if (IS_VALID_STRING(self.fontModel.TypefaceName)) {
        self.navigationItem.title =  self.fontModel.TypefaceName;
    }
    self.rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rightBtn setImage:[UIImage imageNamed:@"xiayibu_a"] forState:UIControlStateNormal];
    [self.rightBtn addTarget:self action:@selector(netAction:) forControlEvents:UIControlEventTouchUpInside];

    
    GXWaterCollectionViewLayout *waterLayout = [[GXWaterCollectionViewLayout alloc] init];
    self.waterLayout = waterLayout;
    waterLayout.delegate = self;
    self.waterLayout.lineSpacing = 10;
    self.waterLayout.interitemSpacing = 10;
    self.waterLayout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
    self.waterLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.collectionView.bounds collectionViewLayout:waterLayout];
    [self.collectionView registerNib:[UINib nibWithNibName:@"GXWaterCVCell" bundle:nil] forCellWithReuseIdentifier:@"GXWaterCVCell"];
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.contentView addSubview:self.collectionView];
    [self.contentView addSubview:self.rightBtn];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.contentView.mas_left).offset(5);
        make.right.mas_equalTo(weakSelf.contentView.mas_right).offset(-5);
        make.top.mas_equalTo(weakSelf.contentView.mas_top);
        make.bottom.mas_equalTo(weakSelf.bottomContentView.mas_top);
        iPhoneXR||iPhoneXM||iPhoneX?(weakSelf.bottomMargin.constant = 20):0;
    }];
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).offset(-21);
        make.bottom.mas_equalTo(self.bottomContentView.mas_top).offset(-40);
    }];
    CustomAlertModel *customAlertModel = [CustomAlertModel new];
    customAlertModel.fontTypeArray = self.fontModelArray;
    customAlertModel.colorIndex = @(101);
    customAlertModel.tiziGeIndex = @(103);
    customAlertModel.percent = 1.00f;
    if ([self.fontModel.PenType isEqualToString:@"1"]) {
        customAlertModel.a3orA4 = @"A4";
    } else {
        customAlertModel.a3orA4 = @"A3";
    }
    customAlertModel.fontSizeIndex = 101;
    customAlertModel.maoGangType = IS_VALID_STRING(self.fontModel.PenType)?@(self.fontModel.PenType.integerValue):@(1);
    NSInteger index = [self.fontModelArray indexOfObject:self.fontModel];
    self.fontTypeIndex = index;
    self.customAlertModel = customAlertModel;
    UIBarButtonItem *rightBarbutton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"cidian"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(rightItemAction:)];
    self.navigationItem.rightBarButtonItem = rightBarbutton;
    [self configurateNumberOfColumns:7 numberLineCount:4 vertical:YES];

}

- (void)rightItemAction:(UIBarButtonItem *)rightBarbutton {
    MaogangDictionaryViewController *vc = [[MaogangDictionaryViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil titleName:(NSString *)titlename {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSAssert(titlename, @"描述不能为空");
        self.navigationItem.title = titlename;
    }
    return self;
}

#pragma mark -  添加字帖的文字
- (void)editionAddViewControllerfinishWithTxt:(NSString *)txt isloop:(BOOL)loop{
    if (loop) {// 循环的话
        NSMutableString *mutableStr = [NSMutableString stringWithString:txt];
        while (mutableStr.length < 20) {
             [mutableStr appendString:txt];
        }
        txt = [mutableStr copy];
    }
    [self configurateTXT:txt shiCiId:@"" contentId:@""];
}

- (void)setText:(NSString *)text {
    if ([_text isEqualToString:text])return;
    @synchronized (self) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            self.customAlertModel.txt = [self noWhiteSpaceString:text];
            _text = [self noWhiteSpaceString:text];
           NSInteger yushu = _text.length % 7;
            self.wenziCount = 0;
            if (yushu != 0) {
                self.wenziCount += (7 - yushu + self.text.length);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        });
    }
        
    

}

#pragma mark -  编辑文字
- (IBAction)bianji:(UIButton *)sender {
    EditionAddViewController *edadd = [[EditionAddViewController alloc] init];
    edadd.text = self.text;
    edadd.delegate = self;
    [self.navigationController pushViewController:edadd animated:YES];
}

#pragma mark -  纸张大小
- (void)netAction:(UIButton *)sender {
    __weak typeof(self)weakSelf = self;
    NSInteger selectIndex = 0;
    if ([self.customAlertModel.a3orA4 isEqualToString:@"A3"]) {
        selectIndex = 0;
    } else if ([self.customAlertModel.a3orA4 isEqualToString:@"A4"]) {
        selectIndex = 1;
    } else {
        selectIndex = 0;
    }
    NSArray *array = @[];
    if ([self.customAlertModel.maoGangType.stringValue isEqualToString:@"1"]) { // 钢笔
        array = @[@"2"];
        selectIndex = 0;

    } else if ([self.customAlertModel.maoGangType.stringValue isEqualToString:@"2"]) {// 毛笔
        array = @[@"1",@"2"];
    }
    [[[CustomSize customSizeAlertPool].index(selectIndex).paper(array) selectIndex:^(NSString *A3orA4) {
        if (!IS_VALID_STRING(weakSelf.customAlertModel.txt)) {
            [AlertPool alertMessage:@"请输入文字后再操作！" xlViewController:weakSelf WithBlcok:nil];
            return;
        }
        weakSelf.customAlertModel.a3orA4 =  A3orA4;
        dispatch_async(dispatch_get_main_queue(), ^{
            TypesettingViewController *vc = [[TypesettingViewController alloc] init];
            vc.customAlertModel = weakSelf.customAlertModel;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        });
        
    }] alertShow];
    
}

#pragma mark -  设置字帖属性
- (IBAction)editionClick:(UIButton *)sender {
    __weak typeof(self)weakSelf = self;
    [[[[[[CustomAlertPool customAlertPool].tagNumber(sender.tag) alpha:^(CGFloat alpha) {
        weakSelf.customAlertModel.percent = alpha;
        NSString *xalpha = self.customAlertModel.alphaDic[[NSString stringWithFormat:@"%.2f",alpha]];
        NSString *alphaTXT = [NSString stringWithFormat:@"color('%@')",xalpha];
        [weakSelf.collectionView reloadData];
//        [weakSelf.wkWebView evaluateJavaScript:alphaTXT completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//
//        }];
    }] color:^(NSNumber *colorIndex) {
        weakSelf.customAlertModel.colorIndex = colorIndex;
        NSInteger backgroundView = weakSelf.customAlertModel.tiziGeIndex.integerValue;// 田子
        NSString *backTXT = [NSString stringWithFormat:@"background('%@','%@')",[NSString stringWithFormat:@"%ld",backgroundView - 100 + 1] ,[NSString stringWithFormat:@"%@",weakSelf.customAlertModel.colorNameArray[colorIndex.integerValue-100]]];
//        [weakSelf.wkWebView evaluateJavaScript:backTXT completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//            DLog(@"%@ %@",result,error);
//        }];
        [weakSelf.collectionView reloadData];
        
    }] tiziGe:^(NSNumber *tiziIndex) {
        weakSelf.customAlertModel.tiziGeIndex = tiziIndex;
        NSInteger colorIndex = weakSelf.customAlertModel.colorIndex.integerValue;
        NSString *backTXT = [NSString stringWithFormat:@"background('%@','%@')",[NSString stringWithFormat:@"%ld",tiziIndex.integerValue - 100 + 1] ,self.customAlertModel.colorNameArray[colorIndex-100]];
//        [weakSelf.wkWebView evaluateJavaScript:backTXT completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//            DLog(@"%@ %@",result,error);
//        }];
        [weakSelf.collectionView reloadData];
        
    }] font:^(NSInteger font) {
        weakSelf.customAlertModel.fontSizeIndex = font;
        NSString *backTXT = [NSString stringWithFormat:@"fontSize('%@')",[NSString stringWithFormat:@"%ld",font - 100 + 1]];
//        [weakSelf.wkWebView evaluateJavaScript:backTXT completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//            DLog(@"%@ %@",result,error);
//        }];
        //
        [weakSelf.collectionView reloadData];
        
    }].color(self.customAlertModel.colorIndex.integerValue).percent(self.customAlertModel.percent).tiziGe(self.customAlertModel.tiziGeIndex.integerValue).fontSize(self.customAlertModel.fontSizeIndex) alertShow];
}



- (void)configureWebText:(NSString *)text {
    text = IS_VALID_STRING(text)?text:@"";
    NSString *jsTxt = [NSString stringWithFormat:@"text('%@')",text];
    __weak typeof(self)weakSelf = self;
#pragma mark -- 执行javarscrip
//    [self.wkWebView evaluateJavaScript:jsTxt completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//        DLog(@"%@ %@",result,error);
//        weakSelf.fontTypeIndex = weakSelf.fontTypeIndex;;// 设置字体
//    }];
}

- (void)configureProerty:(CustomAlertModel *)customAlertModel {
    NSInteger colorIndex = customAlertModel.colorIndex.integerValue -100;
    NSInteger tianziGeLeiXing = customAlertModel.tiziGeIndex.intValue - 100 + 1;
    NSString *backTXT = [NSString stringWithFormat:@"background('%@','%@')",@(tianziGeLeiXing),self.customAlertModel.colorNameArray[colorIndex]];
//    [self.wkWebView evaluateJavaScript:backTXT completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//        DLog(@"%@ %@",result,error);
//    }];
    #pragma mark -- 执行javarscrip
    NSInteger fontIndex =  customAlertModel.fontSizeIndex - 100;
    NSString *fonbackTXT = [NSString stringWithFormat:@"fontSize('%@')",[NSString stringWithFormat:@"%ld",fontIndex - 100 + 1]];
//    [self.wkWebView evaluateJavaScript:fonbackTXT completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//        DLog(@"%@ %@",result,error);
//    }];
    #pragma mark -- 执行javarscrip
    NSString *alpha = self.customAlertModel.alphaDic[[NSString stringWithFormat:@"%.2f",customAlertModel.percent]];
    
    NSString *alphaTXT = [NSString stringWithFormat:@"color('%@')",alpha];
//    [self.wkWebView evaluateJavaScript:alphaTXT completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//
//    }];
    #pragma mark -- 执行javarscrip
}



- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.wenziCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GXWaterCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GXWaterCVCell" forIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.alertModel = self.customAlertModel;
    return cell;
}

- (CGFloat)sizeWithLayout:(GXWaterCollectionViewLayout*)layout indexPath:(NSIndexPath*)indexPath itemSize:(CGFloat)itemSize {
    return layout.viewHeightOrWidth;
}

@end
