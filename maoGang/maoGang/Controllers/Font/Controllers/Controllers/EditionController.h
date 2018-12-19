//
//  EditionController.h
//  maoGang
//
//  Created by xl on 2018/11/24.
//  Copyright © 2018年 bilin. All rights reserved.
//

#import "YLRootViewController.h"
#import "FontModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface EditionController : YLRootViewController
@property (nonatomic, strong) FontModel *fontModel;// 字体
@property (nonatomic, strong) NSArray<FontModel *> *fontModelArray;// 字体数组
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil titleName:(NSString *)titlename;
- (void)configurateTXT:(NSString *)TXT shiCiId:(NSString *)shiCiId contentId:(NSString *)contentId;
@end

NS_ASSUME_NONNULL_END
