//
//  SectionHeaderView.h
//  gaofangPenYouQuan
//
//  Created by zhangzhen on 2018/11/19.
//  Copyright © 2018 zhangzhen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
extern const CGFloat SectionHeaderHorizontalSpace; //水平方向控件之间的间隙距离
extern const CGFloat SectionHeaderVerticalSpace; //竖直方向控件之间的间隙距离
extern const CGFloat SectionHeaderTopSpace; //顶部的空白距离
extern const CGFloat SectionHeaderBottomSpace; //底部的空白距离
extern const CGFloat SectionHeaderPictureSpace; //图片之间的间隙距离
extern const CGFloat SectionHeaderLineSpace; //文本行间距
extern const CGFloat SectionHeaderBigFontSize; //除时间label外的其它控件字体大小
extern const CGFloat SectionHeaderNameFontSize; //姓名字体大小
extern const CGFloat SectionHeaderSmallFontSize; //时间label字体大小
extern const CGFloat SectionHeaderMoreBtnHeight; //全文按钮高度
extern const CGFloat SectionHeaderNameLabelHeight; //名字label高度
extern const CGFloat SectionHeaderTimeLabelHeight; //时间label高度
extern const CGFloat SectionHeaderMaxContentHeight; //文本最大高度
extern const CGFloat SectionHeaderOnePictureHeight; //只有一张图片时的图片高度
extern const CGFloat SectionHeaderSomePicturesHeight; //有多张图片时的单张图片高度
extern const CGFloat SectionHeaderHeaderImageHeight; //头像的 宽 高
extern const CGFloat SectionHeaderHeaderImageLeftWidth; //头像的 距离左侧的距离
extern const CGFloat SectionHeaderHeaderLiketNameLeftWidth; //点赞label 距离左侧的距离

@class CircleItem;
@protocol SectionHeaderViewDelegate <NSObject>
#pragma mark -- 全文or收起
- (void)spreadContent:(BOOL)isSpread section:(NSUInteger)section;
#pragma mark -- 点击姓名
- (void)didTapPeople:(CircleItem *)circleItem;
#pragma mark --  点赞
- (void)didClickLikeButton:(NSInteger)section withButton:(UIButton *)btn;
#pragma mark --  删除
- (void)didClickDeteleButton:(NSInteger)section withButton:(UIButton *)btn;
#pragma mark --  收藏
- (void)didClickShouCangButton:(NSInteger)section withButton:(UIButton *)btn;
#pragma mark -- 评论
- (void)didClickCommentButton:(NSInteger)section withButton:(UIButton *)btn;
#pragma mark -- 照片
- (void)didTapImageListView:(NSInteger)section  withImageIndex:(NSInteger)imageIndex;


@end

@interface SectionHeaderView : UITableViewHeaderFooterView
@property (nonatomic, weak) id <SectionHeaderViewDelegate> delegate;
/**
 *IsShow   yes隐藏  删除btn
 */
- (void)setContentData:(CircleItem *)circleItem section:(NSInteger)section  withIsShowDeleteButton:(BOOL)IsShow;



@end

NS_ASSUME_NONNULL_END
