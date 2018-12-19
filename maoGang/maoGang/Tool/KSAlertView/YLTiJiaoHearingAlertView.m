//
//  LXAlertView.m
//  LXAlertViewDemo
//
//  Created by 刘鑫 on 16/4/15.
//  Copyright © 2016年 liuxin. All rights reserved.
//
#define MainScreenRect [UIScreen mainScreen].bounds
#define AlertView_W     AdaptedWidthValue(300)
#define MessageMin_H    20.0f       //messagelab的最小高度
#define MessageMAX_H    300.0f      //messagelab的最大高度，当超过时，文本会以...结尾
#define LXATitle_H      26.0f
#define LXABtn_H        45.0f

#define SFQBlueColor        [UIColor colorWithRed:9/255.0 green:170/255.0 blue:238/255.0 alpha:1]
#define SFQRedColor         [UIColor colorWithRed:255/255.0 green:92/255.0 blue:79/255.0 alpha:1]
#define SFQLightGrayColor   [UIColor colorWithRed:0.165 green:0.518 blue:0.824 alpha:1.000]

#define LXADTitleFonts      [UIFont boldSystemFontOfSize:22];
#define LXADTitleFont       [UIFont boldSystemFontOfSize:17];
#define LXADMessageFont     [UIFont systemFontOfSize:14];
#define LXADBtnTitleFont    [UIFont systemFontOfSize:15];



#import "YLTiJiaoHearingAlertView.h"
#import "UILabel+LXAdd.h"

@interface YLTiJiaoHearingAlertView()
@property (nonatomic,strong)UIWindow *alertWindow;
@property (nonatomic,strong)UIView *alertView;

@property (nonatomic,strong)UILabel *titleLab;
@property (nonatomic,strong)UILabel *messageLab;
@property (nonatomic,strong)UIButton *cancelBtn;
@property (nonatomic,strong)UIButton *otherBtn;
@property (nonatomic,strong)UIImageView *image;
@end

@implementation YLTiJiaoHearingAlertView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithTitle:(NSString *)title Iconimage:(NSString *)Iconimage message:(NSString *)message messageTitleCentect:(BOOL )isCentect cancelBtnTitle:(NSString *)cancelTitle otherBtnTitle:(NSString *)otherBtnTitle  clickIndexBlock:(LXAlertClickIndexBlock)block{
    if(self=[super init]){
        self.frame=MainScreenRect;
        self.backgroundColor=[UIColor colorWithWhite:.3 alpha:.7];
        NSInteger  UpAndDownSpacing = 27;
        _alertView=[[UIView alloc] init];
        _alertView.backgroundColor=[UIColor whiteColor];
        _alertView.layer.cornerRadius=6.0;
        _alertView.layer.masksToBounds=YES;
        _alertView.userInteractionEnabled=YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doTap)];
        // 允许用户交互
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:tap];
        
        
        if (IS_VALID_STRING(title) ) {
            
            _titleLab=[[UILabel alloc] initWithFrame:CGRectMake(0,UpAndDownSpacing , AlertView_W, LXATitle_H)];
            _titleLab.text=title;
            _titleLab.textAlignment=NSTextAlignmentCenter;
            _titleLab.textColor=RGBCOLOR(51, 51, 51);
//            _titleLab.backgroundColor = [UIColor greenColor];
            _titleLab.font=LXADTitleFont;
            
            [_alertView addSubview:_titleLab];
            
        }else{
            
         _titleLab=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        
        }
        
        if (IS_VALID_STRING(Iconimage)) {
            _image = [[UIImageView alloc]init];
            UIImage * M_image = [UIImage imageNamed:Iconimage];
            _image.image = M_image;
            _image.frame = CGRectMake((AlertView_W-M_image.size.width)/2, _titleLab.frame.size.height+_titleLab.frame.origin.y+UpAndDownSpacing, M_image.size.width, M_image.size.height);
            [_alertView addSubview:_image];
            
        }else{
            _image = [[UIImageView alloc]initWithFrame:CGRectMake(0, _titleLab.frame.size.height+_titleLab.frame.origin.y, 0, 0)];
        }
        
        
        CGFloat messageLabSpace = 20;

    
        if (IS_VALID_STRING(message) ) {
            
            _messageLab=[[UILabel alloc] init];
            _messageLab.backgroundColor=[UIColor clearColor];
            _messageLab.text=message;
            _messageLab.textColor = RGBCOLOR(10, 10, 10);
            _messageLab.font=LXADMessageFont;
            _messageLab.numberOfLines=0;
            if (isCentect) {
             _messageLab.textAlignment=NSTextAlignmentCenter;
            }else{
             _messageLab.textAlignment=NSTextAlignmentLeft;
            }
           
            _messageLab.lineBreakMode=NSLineBreakByTruncatingTail;
//            _messageLab.characterSpace=2;
            _messageLab.lineSpace=10;
            
            
            CGSize labSize = [_messageLab getLableRectWithMaxWidth:AlertView_W-messageLabSpace*2];
            CGFloat messageLabAotuH = labSize.height < MessageMin_H?MessageMin_H:labSize.height;
            CGFloat endMessageLabH = messageLabAotuH > MessageMAX_H?MessageMAX_H:messageLabAotuH;

            
            _messageLab.frame=CGRectMake(messageLabSpace, _image.frame.size.height+_image.frame.origin.y+UpAndDownSpacing, AlertView_W - 2 * messageLabSpace, endMessageLabH);
                


                  [_alertView addSubview:_messageLab];
            
        }else{
        
         _messageLab=[[UILabel alloc] initWithFrame:CGRectMake(messageLabSpace, _image.frame.size.height+_image.frame.origin.y, 0, 0)];
        

            
        }
 
        UILabel * line = [[UILabel alloc]initWithFrame:CGRectMake(0, _messageLab.frame.origin.y+_messageLab.frame.size.height+UpAndDownSpacing,AlertView_W, 1)];
        line.backgroundColor = RGBCOLOR(233, 237, 237);
        line.hidden = YES;
        [_alertView addSubview:line];
        
        DLog(@"_messageLab--%f", _messageLab.frame.origin.y+_messageLab.frame.size.height+5);
      
        if (IS_VALID_STRING(cancelTitle) ) {
            _cancelBtn=[UIButton buttonWithType:UIButtonTypeCustom];
            [_cancelBtn setTitle:cancelTitle forState:UIControlStateNormal];

            [_cancelBtn setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
            _cancelBtn.backgroundColor = ButtonBackGroudRGB;
            
            _cancelBtn.titleLabel.font=LXADBtnTitleFont;
            _cancelBtn.layer.cornerRadius=LXABtn_H/2;
            _cancelBtn.layer.masksToBounds=YES;
            [_cancelBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [_alertView addSubview:_cancelBtn];
        }
        
        if (IS_VALID_STRING(otherBtnTitle) ) {
            
            _otherBtn=[UIButton buttonWithType:UIButtonTypeCustom];
            [_otherBtn setTitle:otherBtnTitle forState:UIControlStateNormal];
            [_otherBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _otherBtn.titleLabel.font=LXADBtnTitleFont;
            _otherBtn.layer.cornerRadius=LXABtn_H/2;
            _otherBtn.layer.masksToBounds=YES;
            [_otherBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];

            [_alertView addSubview:_otherBtn];
        }

        
         CGFloat btnLeftSpace = 30;//btn到左边距

         CGFloat btn_y = line.frame.origin.y+line.frame.size.height+2;
        
        
        
            if (IS_VALID_STRING(cancelTitle)  && ! IS_VALID_STRING(otherBtnTitle)  ) {
                _cancelBtn.tag=121;
                _cancelBtn.frame=CGRectMake(btnLeftSpace, btn_y, AlertView_W-btnLeftSpace*2, LXABtn_H);
                _alertView.frame=CGRectMake(0, 0, AlertView_W, _cancelBtn.frame.size.height+_cancelBtn.frame.origin.y+UpAndDownSpacing);
                
            }else if (!IS_VALID_STRING(cancelTitle)  &&  IS_VALID_STRING(otherBtnTitle) ){
                
                _otherBtn.tag=600;
                _otherBtn.frame=CGRectMake(btnLeftSpace, btn_y, AlertView_W-btnLeftSpace*2, LXABtn_H);
                _alertView.frame=CGRectMake(0, 0, AlertView_W, _otherBtn.frame.size.height+_otherBtn.frame.origin.y+UpAndDownSpacing);
                
            }else if (IS_VALID_STRING(cancelTitle)  && IS_VALID_STRING(otherBtnTitle) ){

                _messageLab.textAlignment=NSTextAlignmentCenter;
                line.hidden = NO;
                _cancelBtn.backgroundColor = [UIColor clearColor];
                _otherBtn.backgroundColor = [UIColor clearColor];
                [_otherBtn setTitleColor:ButtonBackGroudRGB forState:UIControlStateNormal];
                [_cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                
                _cancelBtn.tag=900;
                _otherBtn.tag=239;
                CGFloat btn_w =(AlertView_W-1)/2;
                _cancelBtn.frame=CGRectMake(0, btn_y, btn_w, LXABtn_H);

                UILabel * contectLine = [[UILabel alloc]initWithFrame:CGRectMake(btn_w, btn_y, 1, LXABtn_H)];
                contectLine.backgroundColor = RGBCOLOR(233, 237, 237);
                [_alertView addSubview:contectLine];
                
                _otherBtn.frame=CGRectMake(CGRectGetMaxX(contectLine.frame), btn_y, btn_w, LXABtn_H);
                _alertView.frame=CGRectMake(0, 0, AlertView_W, _otherBtn.frame.size.height+_otherBtn.frame.origin.y);
                

        
        }

        self.clickBlock=block;
        _alertView.center=self.center;
        [self addSubview:_alertView];
   
    }
    return self;
}
#pragma mark  ---  点击事件
-(void)doTap{
    
    if (!_dontDissmiss) {
        [self dismissAlertView];
    }
    
}

- (void)startTime:(int)time{
    __weak typeof(self)wsSelf = self;
    __block int timeout=time; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [wsSelf.cancelBtn setTitle:@"默默忽视" forState:UIControlStateNormal];
                [wsSelf.cancelBtn setTitleColor:RGBCOLOR(51, 51, 51) forState:UIControlStateNormal];
                wsSelf.cancelBtn.userInteractionEnabled = YES;
                
                
            });
        }else{
            int seconds = timeout ;
            NSString *strTime = [NSString stringWithFormat:@"%d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                [wsSelf.cancelBtn setTitle:[NSString stringWithFormat:@"默默忽视(%@s)", strTime] forState:UIControlStateNormal];
                [wsSelf.cancelBtn setTitleColor:RGBCOLOR(158, 158, 158) forState:UIControlStateNormal];
                wsSelf.cancelBtn.userInteractionEnabled = NO;
                
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
    
}
-(void)btnClick:(UIButton *)btn{
    
    if (self.clickBlock) {
        self.clickBlock(btn.tag);
    }
    
    if (!_dontDissmiss) {
        [self dismissAlertView];
    }
    
}

-(void)setDontDissmiss:(BOOL)dontDissmiss{
    _dontDissmiss=dontDissmiss;
}
- (void)show:(NSString *)thing With:(NSString *)yuanString With:(NSString *)String    WithLabel:(UILabel *)btn
{
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:thing attributes:@{NSFontAttributeName : [UIFont fontWithName:FontName size:13], NSForegroundColorAttributeName :RGBCOLOR(52, 73, 94)}];
    NSMutableAttributedString *attrYanStr = [[NSMutableAttributedString alloc] initWithString:yuanString attributes:@{NSFontAttributeName : [UIFont fontWithName:FontName size:13],NSForegroundColorAttributeName :[UIColor redColor]}];
    NSMutableAttributedString *attrYansStr = [[NSMutableAttributedString alloc] initWithString:String attributes:@{NSFontAttributeName : [UIFont fontWithName:FontName size:13],NSForegroundColorAttributeName :RGBCOLOR(52, 73, 94)}];
    
    
    [attrStr appendAttributedString:attrYanStr];
    [attrStr appendAttributedString:attrYansStr];
    
    //添加到副文本
   
    btn.attributedText = attrStr;
    
}
-(void)showLXAlertView{
    
    
    
    _alertWindow=[[UIWindow alloc] initWithFrame:MainScreenRect];
    _alertWindow.windowLevel=UIWindowLevelAlert;
    [_alertWindow becomeKeyWindow];
    [_alertWindow makeKeyAndVisible];
    
    [_alertWindow addSubview:self];
    
    [self setShowAnimation];
    
    
}

-(void)dismissAlertView{
    [self removeFromSuperview];
    [_alertWindow resignKeyWindow];
}

-(void)setShowAnimation{
    
    switch (_animationStyle) {
            
        case YLLXASAnimationDefault:
        {
            [UIView animateWithDuration:0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [_alertView.layer setValue:@(0) forKeyPath:@"transform.scale"];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.23 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [_alertView.layer setValue:@(1.2) forKeyPath:@"transform.scale"];
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.09 delay:0.02 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        [_alertView.layer setValue:@(.9) forKeyPath:@"transform.scale"];
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.05 delay:0.02 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            [_alertView.layer setValue:@(1.0) forKeyPath:@"transform.scale"];
                        } completion:^(BOOL finished) {
                            
                        }];
                    }];
                }];
            }];
        }
            break;
            
        case YLLXASAnimationLeftShake:{
    
            CGPoint startPoint = CGPointMake(-AlertView_W, self.center.y);
            _alertView.layer.position=startPoint;
            
            //damping:阻尼，范围0-1，阻尼越接近于0，弹性效果越明显
            //velocity:弹性复位的速度
            [UIView animateWithDuration:.8 delay:0 usingSpringWithDamping:.5 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveLinear animations:^{
                _alertView.layer.position=self.center;
                
            } completion:^(BOOL finished) {
                
            }];
        }
            break;
            
        case YLLXASAnimationTopShake:{
            
            CGPoint startPoint = CGPointMake(self.center.x, -_alertView.frame.size.height);
            _alertView.layer.position=startPoint;
            
            //damping:阻尼，范围0-1，阻尼越接近于0，弹性效果越明显
            //velocity:弹性复位的速度
            [UIView animateWithDuration:.8 delay:0 usingSpringWithDamping:.5 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveLinear animations:^{
                _alertView.layer.position=self.center;
                
            } completion:^(BOOL finished) {
                
            }];
        }
            break;
            
        case YLLXASAnimationNO:{
            
        }
            
            break;
            
        default:
            break;
    }
    
}


-(void)setAnimationStyle:(YLLXAShowAnimationStyle)animationStyle{
    _animationStyle=animationStyle;
}

@end





@implementation UIImage (Colorful)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end