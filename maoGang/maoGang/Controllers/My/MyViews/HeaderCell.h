//
//  HeaderCell.h
//  maoGang
//
//  Created by xl on 2018/11/29.
//  Copyright © 2018年 bilin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HeaderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *header;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *desL;
@property (weak, nonatomic) IBOutlet UILabel *collectionCountL;
@property (weak, nonatomic) IBOutlet UILabel *founseCountL;
@property (weak, nonatomic) IBOutlet UILabel *fanCountL;
@property (weak, nonatomic) IBOutlet UIButton *collectionBtn;
@property (weak, nonatomic) IBOutlet UIButton *founseBtn;
@property (weak, nonatomic) IBOutlet UIButton *fansBtn;
@property (weak, nonatomic) IBOutlet UIButton *dataConfigurateBtn;
@property (weak, nonatomic) IBOutlet UILabel *L_longinOrRegister;

@end

NS_ASSUME_NONNULL_END
