//
//  EditionAddViewController.h
//  maoGang
//
//  Created by xl on 2018/11/28.
//  Copyright © 2018年 bilin. All rights reserved.
//

#import "YLRootViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EditionAddViewControllerDelegate <NSObject>
// 添加完成的回调
@required;
- (void)editionAddViewControllerfinishWithTxt:(NSString *)txt isloop:(BOOL)loop;

@end
@interface EditionAddViewController : YLRootViewController

@property (nonatomic, weak) id<EditionAddViewControllerDelegate>  delegate;

@property (nonatomic, copy) NSString *text;

@end

NS_ASSUME_NONNULL_END
