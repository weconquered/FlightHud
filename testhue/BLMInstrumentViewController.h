//
//  BLMInstrumentViewController.h
//  drawYIBIAO
//
//  Created by apple on 12/17/14.
//  Copyright (c) 2014 liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLMInstrumentViewController : UIViewController{
    UIView* _instrumentView;
    double width;
    double height;
    //放置方位仪表尺、方位仪表尺刻度、当前值
    UIView* _YawView;
    //方位仪表尺
    CAShapeLayer* _YawLayer;
    //放置速度仪表尺、速度刻度、当前速度
    UIView* _SpeedView;
    //当前速度
    UILabel* _currentSpeedLable;
    //放置高度仪表尺、高度刻度、当前高度
    UIView* _HeightView;
    //当前高度
    UILabel* _currentHeightLable;
    //放置高度仪表尺、高度刻度、当前高度
    UIView* _pitchView;
    //当前高度
    UILabel* _currentPitchLable;
    //高度尺
    CAShapeLayer* _pitchLayer;
    //天空、土地颜色
    CAShapeLayer* _airGroundLayer;
    //其他固定位置layer
    CAShapeLayer* _otherToolsLayer;
    //背景（毛玻璃、边框）
    UIImageView* _instrumentBGImageView;

    double _currentHeight;
    double _currentSpeed;
    double _currentYaw;
    double _currentPitch;
}
//整个仪表
@property(nonatomic,strong) UIView* instrumentView;
//放置方位仪表尺、方位仪表尺刻度、当前值
@property(nonatomic,strong) UIView* YawView;
//当前方位角度
@property(nonatomic,strong) UILabel* currentYawAngleLable;
//方位仪表尺
@property(nonatomic,strong) CAShapeLayer* YawLayer;
//放置速度仪表尺、速度刻度、当前速度
@property(nonatomic,strong) UIView* SpeedView;
//当前速度
@property(nonatomic,strong) UILabel* currentSpeedLable;
//速度尺
@property(nonatomic,strong) CAShapeLayer* SpeedLayer;
//放置高度仪表尺、高度刻度、当前高度
@property(nonatomic,strong) UIView* HeightView;
//当前高度
@property(nonatomic,strong) UILabel* currentHeightLable;
//高度尺
@property(nonatomic,strong) CAShapeLayer* HeightLayer;
//天空、土地颜色
@property(nonatomic,strong) CAShapeLayer* airGroundLayer;
//放置高度仪表尺、高度刻度、当前高度
@property(nonatomic,strong) UIView* pitchView;
//当前高度
@property(nonatomic,strong) UILabel* currentPitchLable;
//高度尺
@property(nonatomic,strong) CAShapeLayer* pitchLayer;
//其他固定位置layer
@property(nonatomic,strong) CAShapeLayer* otherToolsLayer;
//背景（毛玻璃、边框）
@property(nonatomic,strong) UIImageView* instrumentBGImageView;
/*!
 *  @Author liupengbo, 14-12-17 10:12:47
 *
 *  @brief  单例函数
 *
 *  @return 仪表控制器单例
 */
+(BLMInstrumentViewController* )shared;
- (void)setYawAngle:(double)angle;
- (void)setHeight:(double)newHeight;
- (void)setSpeed:(double)newSpeed;
- (void)setPitchAngle:(double)newPitchAngle;
- (void)setRollAnle:(double)newRollAngle;
@end
