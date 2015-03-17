//
//  BLMInstrumentViewController.m
//  drawYIBIAO
//
//  Created by apple on 12/17/14.
//  Copyright (c) 2014 liu. All rights reserved.
//

#import "BLMInstrumentViewController.h"

@interface BLMInstrumentViewController (){
    int yawMin;
    int yawMax;
    int yawIndex;
    CAShapeLayer* copyYawLayer;
}

@end

@implementation BLMInstrumentViewController
@synthesize instrumentView;
@synthesize YawView;
@synthesize YawLayer;
@synthesize currentYawAngleLable;
@synthesize HeightView;
@synthesize HeightLayer;
@synthesize currentHeightLable;
@synthesize SpeedView;
@synthesize SpeedLayer;
@synthesize currentSpeedLable;
@synthesize currentPitchLable;
@synthesize pitchLayer;
@synthesize pitchView;
@synthesize otherToolsLayer;
@synthesize instrumentBGImageView;
@synthesize airGroundLayer;
// 设定固定值
#define BIAOJIFONTSIZE 15
#define DELTAX 5
#define XIANGAO 10
#define PITCHXIANGAO 40

#define PITCHDELTA 30
#define PITCHDELTAVALUE 15
#define PITCHDEVIDE 1
#define PITCHLINEWIDTH 30

#define YAWDELTA 50
#define YAWDELTAVALUE 20
#define YAWMAX 3600
#define YAWDEVIDE 3
#define YAWXIANGAO 8

#define HEIGHTDELTA 30
#define HEIGHTDELTAVALUE 2
#define HEIGHTMAX 200
#define HEIGHTDEVIDE 3
#define HEIGHTXIANGAO 8

#define SPEEDDELTA 30
#define SPEEDDELTAVALE 0.5
#define SPEEDMAX 10
#define SPEEDDEVIDE 3
#define SPEEDXIANGAO 8
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (BLMInstrumentViewController *)shared{
    static BLMInstrumentViewController* shared = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        shared = [[BLMInstrumentViewController alloc] initWithWidth:323 height:200];
    });
    return shared;
}
- (instancetype)initWithWidth:(double)newWidth height:(double)newHeight{
    self = [super init];
    //设置大小
    width = newWidth;
    height = newHeight;
    _currentPitch = 0;
    _currentHeight = 0;
    _currentSpeed = 0;
    _currentYaw = 0;
    yawMin=0;
    yawMax = 360;
    yawIndex = 0;
    //初始化仪表
    [self initInstrument];
    return self;
}

- (void)initInstrument{
    //初始化仪表View
    instrumentView = [UIView new];
    [instrumentView setClipsToBounds:YES];
    //添加背景
    instrumentBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"instrumentBG_frame"]];
    [instrumentBGImageView setFrame:CGRectMake(0, 0, width, height)];
    [instrumentView addSubview:instrumentBGImageView];
    //设置大小
    [instrumentView setFrame:CGRectMake(0, 0, width, height)];
    //========== 初始化天空、土地(开始) =================
    //地
    airGroundLayer = [CAShapeLayer new];
    airGroundLayer.anchorPoint = CGPointMake(0.5, 0.5);
    [airGroundLayer setFrame:CGRectMake(0,0,500,3000)];
    [instrumentView.layer addSublayer:airGroundLayer];
    //设置位置
    [airGroundLayer setBackgroundColor:[UIColor colorWithRed:107/457.0 green:154/457.0 blue:196/457.0 alpha:1].CGColor];
    airGroundLayer.position = CGPointMake(instrumentView.bounds.size.width/2, instrumentView.bounds.size.height - 75);
    CGMutablePathRef groundPath = CGPathCreateMutable();
    CGPathAddRect(groundPath, nil, CGRectMake(0,airGroundLayer.bounds.size.height/2,airGroundLayer.bounds.size.width,airGroundLayer.bounds.size.height));
    airGroundLayer.fillColor = [UIColor colorWithRed:133/195.0 green:47/195.0 blue:25/195.0 alpha:1].CGColor;
    airGroundLayer.strokeColor = [UIColor clearColor].CGColor;
    airGroundLayer.path = groundPath;
    //========== 初始化天空、土地(结束) =================
    //========== 初始化方位角度(开始) =================
    // 初始化方位角度View
    YawView = [UIView new];
    // 切割边界
    [YawView setClipsToBounds:YES];
    // 设置大小
    [YawView setFrame:CGRectMake(0, 0, width-90, 80)];
    // 假如到仪表View中
    [instrumentView addSubview:YawView];
    // 设置位置
    [YawView setCenter:CGPointMake(width/2, 50)];
    // 画标尺
    // 零度基准点
    CGPoint YawBasePoint = CGPointMake(YawView.bounds.size.width/2, YawView.bounds.size.height/2);
    // 初始化方位角度
    YawLayer = [CAShapeLayer new];
    // 创建新路径
    CGMutablePathRef path = CGPathCreateMutable();
    // 画原点
    CGPathMoveToPoint(path, nil,YawBasePoint.x, YawBasePoint.y+0.5*XIANGAO);
    CGPathAddLineToPoint(path, nil, YawBasePoint.x, YawBasePoint.y - XIANGAO*2);
    // 画0点标记
    // 新建标记
    CATextLayer* zeroBiaoJi = [CATextLayer new];
    zeroBiaoJi.alignmentMode = kCAAlignmentCenter;
    //设置锚点
    zeroBiaoJi.anchorPoint = CGPointMake(0.5,1);
    // 设置frame
    [zeroBiaoJi setFrame:CGRectMake(0, 0, 3*BIAOJIFONTSIZE, BIAOJIFONTSIZE)];
    // 设置标记位置
    zeroBiaoJi.position = CGPointMake(YawBasePoint.x, YawBasePoint.y - XIANGAO*2-2);
    // 设置标记字体
    zeroBiaoJi.fontSize = BIAOJIFONTSIZE;
    // 设置标记文字
    zeroBiaoJi.string = @"0";
    //添加
    [YawLayer addSublayer:zeroBiaoJi];
    for (int i =1; i<=YAWMAX/YAWDELTAVALUE; i++) {
        //1.画左边线
        CGPoint leftPoint = CGPointMake(YawBasePoint.x-i*YAWDELTA,YawBasePoint.y);
        //1.2 向上划线
        //1.1 移动到底部点
        CGPathMoveToPoint(path, nil, leftPoint.x, leftPoint.y);
        //1.2 向上画长线
        CGPathAddLineToPoint(path, nil, leftPoint.x, leftPoint.y-YAWXIANGAO*2);
        
        //画间隔线
        for(int j=0;j<YAWDEVIDE-1;j++){
            CGPoint jiangePoint = CGPointMake(leftPoint.x+(j+1)*YAWDELTA/YAWDEVIDE, leftPoint.y);
            //1.1 移动到底部点
            CGPathMoveToPoint(path, nil, jiangePoint.x, jiangePoint.y-0.5*YAWXIANGAO);
            //1.2 向上画长线
            CGPathAddLineToPoint(path, nil, jiangePoint.x, jiangePoint.y-1.5*YAWXIANGAO);
            
        }
        
        //新建标记
        CATextLayer* leftBiaoJi = [CATextLayer new];
        leftBiaoJi.alignmentMode = kCAAlignmentCenter;
        //设置锚点
        leftBiaoJi.anchorPoint = CGPointMake(0.5,1);
        [leftBiaoJi setFrame:CGRectMake(0, 0, 3*BIAOJIFONTSIZE, BIAOJIFONTSIZE)];
        //设置标记位置
        leftBiaoJi.position = CGPointMake(leftPoint.x,leftPoint.y-2-2*XIANGAO);
        //设置标记颜色
        leftBiaoJi.foregroundColor = [[UIColor whiteColor] CGColor];
        //设置标记背景颜色
        leftBiaoJi.backgroundColor = [[UIColor clearColor] CGColor];
        //设置标记字体
        leftBiaoJi.fontSize = BIAOJIFONTSIZE;
        //设置标记文字
        leftBiaoJi.string = [NSString stringWithFormat:@"%i",360-YAWDELTAVALUE*i%360];
        //添加
        [YawLayer addSublayer:leftBiaoJi];
        
        //2.画右边线
        CGPoint rightPoint = CGPointMake(YawBasePoint.x+i*YAWDELTA,YawBasePoint.y);
        
        //1.1 移动到底部点
        CGPathMoveToPoint(path, nil, rightPoint.x, rightPoint.y);
        //1.2 向上画长线
        CGPathAddLineToPoint(path, nil, rightPoint.x, rightPoint.y-YAWXIANGAO*2);
        //画间隔线
        for(int j=0;j<YAWDEVIDE-1;j++){
            CGPoint jiangePoint = CGPointMake(rightPoint.x-(j+1)*YAWDELTA/YAWDEVIDE, rightPoint.y);
            //1.1 移动到底部点
            CGPathMoveToPoint(path, nil, jiangePoint.x, jiangePoint.y-0.5*YAWXIANGAO);
            //1.2 向上画长线
            CGPathAddLineToPoint(path, nil, jiangePoint.x, jiangePoint.y-1.5*YAWXIANGAO);
            
        }
        //1.3 标记刻度
        //新建标记
        CATextLayer* rightBiaoJi = [CATextLayer new];
        rightBiaoJi.alignmentMode = kCAAlignmentCenter;
        //设置锚点
        rightBiaoJi.anchorPoint = CGPointMake(0.5,1);
        [rightBiaoJi setFrame:CGRectMake(0, 0, 3*BIAOJIFONTSIZE, BIAOJIFONTSIZE)];
        //设置标记位置
        rightBiaoJi.position = CGPointMake(rightPoint.x, rightPoint.y-2-2*XIANGAO);
        //设置标记颜色
        rightBiaoJi.backgroundColor = [[UIColor clearColor] CGColor];
        //设置标记字体
        rightBiaoJi.fontSize = BIAOJIFONTSIZE;
        //设置标记文字
        rightBiaoJi.string = [NSString stringWithFormat:@"%i",YAWDELTAVALUE*i%360];
        //添加
        [YawLayer addSublayer:rightBiaoJi];
        
        
        //画横线
        //        if (i==90) {
        //            CGPathMoveToPoint(path, nil, leftPoint.x, leftPoint.y);
        //            CGPathAddLineToPoint(path, nil, rightPoint.x, rightPoint.y);
        //        }
    }
    YawLayer.path = path;
    YawLayer.lineWidth = 2;
    YawLayer.strokeColor = [[UIColor greenColor] CGColor];
    YawLayer.fillColor = [[UIColor greenColor] CGColor];
    YawLayer.position = CGPointMake(0,0);
    //将方位角度标尺添加到仪表视图
    [YawView.layer addSublayer:YawLayer];
    //添加北京
    UIImage* imgYaw = [UIImage imageNamed:@"speedAndHeightBgRect"];
    imgYaw = [imgYaw resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    UIImageView* YawBG = [[UIImageView alloc] initWithImage:imgYaw];
    [YawBG setFrame:CGRectMake(0, 0, imgYaw.size.width*1.7, imgYaw.size.height)];
    [YawBG setCenter:CGPointMake(YawBasePoint.x, YawBasePoint.y-XIANGAO)];
    [YawView addSubview:YawBG];
    
    //添加当前刻度值
    currentYawAngleLable = [UILabel new];
    currentYawAngleLable.text = @"0";
    [currentYawAngleLable setBackgroundColor:[UIColor clearColor]];
    currentYawAngleLable.textColor = [UIColor greenColor];
    [currentYawAngleLable setTextAlignment:NSTextAlignmentCenter];
    [currentYawAngleLable setFrame:CGRectMake(0, 0, 60, 20)];
    [currentYawAngleLable setCenter:CGPointMake(YawBasePoint.x, YawBasePoint.y -XIANGAO)];
    [YawView addSubview:currentYawAngleLable];
    //========== 初始化方位角度(结束) =================
    //========== 初始化高度(开始) =================
    //
    // 初始化方位角度View
    HeightView = [UIView new];
    // 切割边界
    [HeightView setClipsToBounds:YES];
    // 设置大小
    [HeightView setFrame:CGRectMake(0, 0, 90, height-80)];
    [HeightView setBackgroundColor:[UIColor clearColor]];
    // 假如到仪表View中
    [instrumentView addSubview:HeightView];
    // 设置位置
    [HeightView setCenter:CGPointMake(width - HeightView.bounds.size.width/2-5, height/2+20)];
    // 画标尺
    // 零度基准点
    CGPoint heightBasePoint = CGPointMake(HeightView.bounds.size.width - 30 - 10, HeightView.bounds.size.height/2);
    // 初始化方位角度
    HeightLayer = [CAShapeLayer new];
    // 创建新路径
    CGMutablePathRef heightPath = CGPathCreateMutable();
    // 画原点
    CGPathMoveToPoint(heightPath, nil,heightBasePoint.x-0.5*HEIGHTXIANGAO, heightBasePoint.y);
    CGPathAddLineToPoint(heightPath, nil, heightBasePoint.x + HEIGHTXIANGAO*2.5, heightBasePoint.y);
    // 画0点标记
    // 新建标记
    CATextLayer* heightZeroBiaoJi = [CATextLayer new];
    //设置锚点
    heightZeroBiaoJi.anchorPoint = CGPointMake(0,0.5);
    // 设置frame
    [heightZeroBiaoJi setFrame:CGRectMake(0, 0, 20, 20)];
    // 设置标记位置
    heightZeroBiaoJi.position = CGPointMake(heightBasePoint.x - 21, heightBasePoint.y+4);
    // 设置标记颜色
    heightZeroBiaoJi.backgroundColor = [[UIColor clearColor] CGColor];
    // 设置标记字体
    heightZeroBiaoJi.fontSize = BIAOJIFONTSIZE;
    // 设置标记文字
    heightZeroBiaoJi.string = @"";
    //添加
    [HeightLayer addSublayer:heightZeroBiaoJi];
    for (int i =1; i<=HEIGHTMAX/HEIGHTDELTAVALUE; i++) {
        //得到上方点
        CGPoint currentPointTop = CGPointMake(heightBasePoint.x,heightBasePoint.y-i*HEIGHTDELTA);
        //移动到线左侧点
        CGPathMoveToPoint(heightPath, nil, currentPointTop.x, currentPointTop.y);
        // 向右划线
        CGPathAddLineToPoint(heightPath, nil, currentPointTop.x+HEIGHTXIANGAO*2, currentPointTop.y);
        //画间隔点
        for (int j=0; j<HEIGHTDEVIDE-1; j++) {
            CGPoint currentDivideTop = CGPointMake(currentPointTop.x+0.5*HEIGHTXIANGAO, currentPointTop.y+(j+1)*HEIGHTDELTA/HEIGHTDEVIDE);
            //移动到线左侧点
            CGPathMoveToPoint(heightPath, nil, currentDivideTop.x, currentDivideTop.y);
            // 向右划线
            CGPathAddLineToPoint(heightPath, nil, currentDivideTop.x+HEIGHTXIANGAO, currentDivideTop.y);
        }
        // 标记刻度
        //新建标记
        CATextLayer* heightBiaoJi = [CATextLayer new];
        heightBiaoJi.alignmentMode = kCAAlignmentLeft;
        //设置锚点
        heightBiaoJi.anchorPoint = CGPointMake(0,0.5);
        [heightBiaoJi setFrame:CGRectMake(0, 0, 20, 20)];
        //设置标记位置
        heightBiaoJi.position = CGPointMake(currentPointTop.x+2*HEIGHTXIANGAO+1, currentPointTop.y+4);
        //设置标记颜色
        heightBiaoJi.backgroundColor = [[UIColor clearColor] CGColor];
        //设置标记字体
        heightBiaoJi.fontSize = BIAOJIFONTSIZE;
        //设置标记文字
        heightBiaoJi.string = [NSString stringWithFormat:@"%i",i*HEIGHTDELTAVALUE];
        //添加
        [HeightLayer addSublayer:heightBiaoJi];
        
        //得到下方点
        CGPoint currentPointBottom = CGPointMake(heightBasePoint.x,heightBasePoint.y+i*HEIGHTDELTA);
        //移动到线做侧点
        CGPathMoveToPoint(heightPath, nil, currentPointBottom.x, currentPointBottom.y);
        // 向右划线
        CGPathAddLineToPoint(heightPath, nil, currentPointBottom.x+HEIGHTXIANGAO*2, currentPointBottom.y);
        //画间隔点
        for (int j=0; j<HEIGHTDEVIDE-1; j++) {
            CGPoint currentDivideBottom = CGPointMake(currentPointBottom.x+0.5*HEIGHTXIANGAO, currentPointBottom.y-(j+1)*HEIGHTDELTA/HEIGHTDEVIDE);
            //移动到线左侧点
            CGPathMoveToPoint(heightPath, nil, currentDivideBottom.x, currentDivideBottom.y);
            // 向右划线
            CGPathAddLineToPoint(heightPath, nil, currentDivideBottom.x+HEIGHTXIANGAO, currentDivideBottom.y);
        }
        // 标记刻度
        //新建标记
        CATextLayer* heightBiaoJiBottom = [CATextLayer new];
        heightBiaoJiBottom.alignmentMode = kCAAlignmentLeft;
        //设置锚点
        heightBiaoJiBottom.anchorPoint = CGPointMake(0,0.5);
        [heightBiaoJiBottom setFrame:CGRectMake(0, 0, 20, 20)];
        //设置标记位置
        heightBiaoJiBottom.position = CGPointMake(currentPointBottom.x+2*HEIGHTXIANGAO+1, currentPointBottom.y+4);
        //设置标记颜色
        heightBiaoJiBottom.backgroundColor = [[UIColor clearColor] CGColor];
        //设置标记字体
        heightBiaoJiBottom.fontSize = BIAOJIFONTSIZE;
        //设置标记文字
        heightBiaoJiBottom.string = [NSString stringWithFormat:@"%i",i*HEIGHTDELTAVALUE];
        //添加
        [HeightLayer addSublayer:heightBiaoJiBottom];
        //画竖线
        //        if (i==500) {
        //            CGPathMoveToPoint(heightPath, nil, currentPointTop.x, currentPointTop.y);
        //            CGPathAddLineToPoint(heightPath, nil, currentPointBottom.x, currentPointBottom.y);
        //        }
    }
    HeightLayer.path = heightPath;
    HeightLayer.lineWidth = 2;
    HeightLayer.strokeColor = [[UIColor greenColor] CGColor];
    HeightLayer.position = CGPointMake(0,0);
    //将高度标尺添加到仪表视图
    [HeightView.layer addSublayer:HeightLayer];
    //添加当前刻度值
    //1.添加背景
    UIImage* img = [UIImage imageNamed:@"speedAndHeightBgRect"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    UIImageView* heightBG = [[UIImageView alloc] initWithImage:img];
    [heightBG setFrame:CGRectMake(0, 0, img.size.width*1.7, img.size.height)];
    [heightBG setCenter:CGPointMake(heightBasePoint.x + HEIGHTXIANGAO, heightBasePoint.y)];
    [HeightView addSubview:heightBG];
    //2.添加标签
    currentHeightLable = [UILabel new];
    currentHeightLable.text = @"000";
    currentHeightLable.textColor = [UIColor greenColor];
    [currentHeightLable setBackgroundColor:[UIColor clearColor]];
    [currentHeightLable setTextAlignment:NSTextAlignmentCenter];
    [currentHeightLable setFrame:CGRectMake(0, 0, img.size.width*3, img.size.height*3)];
    [currentHeightLable setCenter:heightBG.center];
    [HeightView addSubview:currentHeightLable];
    [currentHeightLable adjustsFontSizeToFitWidth];
    
    //========== 初始化高度(结束) =================
    //========== 初始化速度(开始) =================
    //
    // 初始化方位角度View
    SpeedView = [UIView new];
    // 切割边界
    [SpeedView setClipsToBounds:YES];
    // 设置大小
    [SpeedView setFrame:CGRectMake(0, 0, 90, height-80)];
    [SpeedView setBackgroundColor:[UIColor clearColor]];
    // 假如到仪表View中
    [instrumentView addSubview:SpeedView];
    // 设置位置
    [SpeedView setCenter:CGPointMake(3*SPEEDXIANGAO+10, height/2+20)];
    // 画标尺
    // 零度基准点
    CGPoint speedBasePoint = CGPointMake(SpeedView.bounds.size.width - 3*SPEEDXIANGAO - 10, SpeedView.bounds.size.height/2);
    // 初始化方位角度
    SpeedLayer = [CAShapeLayer new];
    // 创建新路径
    CGMutablePathRef speedPath = CGPathCreateMutable();
    // 画原点
    CGPathMoveToPoint(speedPath, nil,speedBasePoint.x+0.5*SPEEDXIANGAO, speedBasePoint.y);
    CGPathAddLineToPoint(speedPath, nil, speedBasePoint.x - SPEEDXIANGAO*2.5, speedBasePoint.y);
    // 画0点标记
    // 新建标记
    CATextLayer* speedZeroBiaoJi = [CATextLayer new];
    speedZeroBiaoJi.alignmentMode = kCAAlignmentLeft;
    //设置锚点
    speedZeroBiaoJi.anchorPoint = CGPointMake(0,0.5);
    // 设置frame
    [speedZeroBiaoJi setFrame:CGRectMake(0, 0, 20, 20)];
    // 设置标记位置
    speedZeroBiaoJi.position = CGPointMake(speedBasePoint.x+1+2*SPEEDXIANGAO, speedBasePoint.y+4);
    // 设置标记颜色
    speedZeroBiaoJi.backgroundColor = [[UIColor clearColor] CGColor];
    // 设置标记字体
    speedZeroBiaoJi.fontSize = BIAOJIFONTSIZE;
    // 设置标记文字
    speedZeroBiaoJi.string = @"";
    //添加
    [SpeedLayer addSublayer:speedZeroBiaoJi];
    for (int i =1; i<=SPEEDMAX/SPEEDDELTAVALE; i++) {
        //得到上方点
        CGPoint currentPointTop = CGPointMake(speedBasePoint.x,speedBasePoint.y-i*SPEEDDELTA);
        //移动到线右侧点
        CGPathMoveToPoint(speedPath, nil, currentPointTop.x, currentPointTop.y);
        // 向左划线
        CGPathAddLineToPoint(speedPath, nil, currentPointTop.x-SPEEDXIANGAO*2, currentPointTop.y);
        //画间隔点
        for (int j=0; j<SPEEDDEVIDE-1; j++) {
            CGPoint currentDivideTop = CGPointMake(currentPointTop.x-0.5*SPEEDXIANGAO, currentPointTop.y+(j+1)*SPEEDDELTA/SPEEDDEVIDE);
            //移动到线左侧点
            CGPathMoveToPoint(speedPath, nil, currentDivideTop.x, currentDivideTop.y);
            // 向右划线
            CGPathAddLineToPoint(speedPath, nil, currentDivideTop.x-SPEEDXIANGAO, currentDivideTop.y);
        }
        
        // 标记刻度
        //新建标记
        CATextLayer* speedBiaoJi = [CATextLayer new];
        speedBiaoJi.alignmentMode = kCAAlignmentRight;
        //设置锚点
        speedBiaoJi.anchorPoint = CGPointMake(0,0.5);
        [speedBiaoJi setFrame:CGRectMake(0, 0, 20, 20)];
        //设置标记位置
        speedBiaoJi.position = CGPointMake(currentPointTop.x-2*SPEEDXIANGAO-21, currentPointTop.y+4);
        //设置标记颜色
        speedBiaoJi.backgroundColor = [[UIColor clearColor] CGColor];
        //设置标记字体
        speedBiaoJi.fontSize = BIAOJIFONTSIZE;
        //设置标记文字
        speedBiaoJi.string = [NSString stringWithFormat:@"%.1f",i*SPEEDDELTAVALE];
        //添加
        [SpeedLayer addSublayer:speedBiaoJi];
        
        //得到下方点
        CGPoint currentPointBottom = CGPointMake(speedBasePoint.x,speedBasePoint.y+i*SPEEDDELTA);
        //移动到线右侧点
        CGPathMoveToPoint(speedPath, nil, currentPointBottom.x, currentPointBottom.y);
        // 向左划线
        CGPathAddLineToPoint(speedPath, nil, currentPointBottom.x-SPEEDXIANGAO*2, currentPointBottom.y);
        //画间隔点
        for (int j=0; j<SPEEDDEVIDE-1; j++) {
            CGPoint currentDivideBottom = CGPointMake(currentPointBottom.x-0.5*SPEEDXIANGAO, currentPointBottom.y+(j+1)*SPEEDDELTA/SPEEDDEVIDE);
            //移动到线左侧点
            CGPathMoveToPoint(speedPath, nil, currentDivideBottom.x, currentDivideBottom.y);
            // 向右划线
            CGPathAddLineToPoint(speedPath, nil, currentDivideBottom.x-SPEEDXIANGAO, currentDivideBottom.y);
        }
        // 标记刻度
        //新建标记
        CATextLayer* speedBiaoJiBottom = [CATextLayer new];
        speedBiaoJiBottom.alignmentMode = kCAAlignmentRight;
        //设置锚点
        speedBiaoJiBottom.anchorPoint = CGPointMake(0,0.5);
        [speedBiaoJiBottom setFrame:CGRectMake(0, 0, 20, 20)];
        //设置标记位置
        speedBiaoJiBottom.position = CGPointMake(currentPointBottom.x-2*SPEEDXIANGAO-21, currentPointBottom.y+4);
        //设置标记颜色
        speedBiaoJiBottom.backgroundColor = [[UIColor clearColor] CGColor];
        //设置标记字体
        speedBiaoJiBottom.fontSize = BIAOJIFONTSIZE;
        //设置标记文字
        speedBiaoJiBottom.string = [NSString stringWithFormat:@"%.1f",i*SPEEDDELTAVALE];
        //添加
        [SpeedLayer addSublayer:speedBiaoJiBottom];
        //画竖线
        //        if (i==500) {
        //            CGPathMoveToPoint(speedPath, nil, currentPointTop.x, currentPointTop.y);
        //            CGPathAddLineToPoint(speedPath, nil, currentPointBottom.x, currentPointBottom.y);
        //        }
    }
    SpeedLayer.path = speedPath;
    SpeedLayer.lineWidth = 2;
    SpeedLayer.strokeColor = [[UIColor greenColor] CGColor];
    SpeedLayer.position = CGPointMake(0,0);
    //将速度标尺添加到仪表视图
    [SpeedView.layer addSublayer:SpeedLayer];
    //1.添加背景
    UIImage* imgSpeed = [UIImage imageNamed:@"speedAndHeightBgRect"];
    imgSpeed = [imgSpeed resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    UIImageView* speedBG = [[UIImageView alloc] initWithImage:imgSpeed];
    [speedBG setFrame:CGRectMake(0, 0, img.size.width*1.7, img.size.height)];
    [speedBG setCenter:CGPointMake(speedBasePoint.x - SPEEDXIANGAO, speedBasePoint.y)];
    [SpeedView addSubview:speedBG];
    //2.添加标签
    //添加当前刻度值
    currentSpeedLable = [UILabel new];
    currentSpeedLable.text = @"000";
    [currentSpeedLable setBackgroundColor:[UIColor clearColor]];
    [currentSpeedLable setTextAlignment:NSTextAlignmentCenter];
    [currentSpeedLable setFrame:CGRectMake(0, 0, 60, 20)];
    [currentSpeedLable setCenter:speedBG.center];
    [currentSpeedLable setTextColor:[UIColor greenColor]];
    [SpeedView addSubview:currentSpeedLable];
    
    //========== 初始化速度(结束) =================
    
    //========== 初始化俯仰(开始) =================
    // 初始化方位角度View
    pitchView = [UIView new];
    // 切割边界
    [pitchView setClipsToBounds:YES];
    // 设置大小
    [pitchView setFrame:CGRectMake(0, 0, 200, 130)];
    [pitchView setBackgroundColor:[UIColor clearColor]];
    // 假如到仪表View中
    [instrumentView addSubview:pitchView];
    // 设置位置
    [pitchView setCenter:CGPointMake(width/2, height - pitchView.bounds.size.height/2-10)];
    // 画标尺
    // 零度基准点
    CGPoint pitchBasePoint = CGPointMake(pitchView.bounds.size.width/2 , pitchView.bounds.size.height/2);
    // 初始化方位角度
    pitchLayer = [CAShapeLayer new];
    pitchLayer.anchorPoint = CGPointMake(0.5, 0.5);
    // 创建新路径
    CGMutablePathRef pitchPath = CGPathCreateMutable();
    //画零度线左侧
    //移到左侧起点
    CGPathMoveToPoint(pitchPath, nil, pitchBasePoint.x - PITCHXIANGAO*2, pitchBasePoint.y);
    //向右画
    CGPathAddLineToPoint(pitchPath, nil, pitchBasePoint.x - PITCHXIANGAO*0.3, pitchBasePoint.y);
    //画零度线右侧
    //移到右侧起点
    CGPathMoveToPoint(pitchPath, nil, pitchBasePoint.x + PITCHXIANGAO*2, pitchBasePoint.y);
    //向右画
    CGPathAddLineToPoint(pitchPath, nil, pitchBasePoint.x + PITCHXIANGAO*0.3, pitchBasePoint.y);
    for (int i =1; i<=6; i++) {
        //1.画左、上、横 线
        CGPoint topPoint = CGPointMake(pitchBasePoint.x,pitchBasePoint.y - i*PITCHDELTA);
        //1.1 移动到做、上、横起点
        CGPathMoveToPoint(pitchPath, nil, topPoint.x - PITCHXIANGAO*1.5, topPoint.y);
        //1.2 向右划线
        CGPathAddLineToPoint(pitchPath, nil, topPoint.x - PITCHXIANGAO*0.5,topPoint.y);
        //2.画左、上、竖 线
        //2.1 移动到做、上、竖起点
        CGPathMoveToPoint(pitchPath, nil, topPoint.x - PITCHXIANGAO*1.5, topPoint.y);
        //2.2 向下划线
        CGPathAddLineToPoint(pitchPath, nil, topPoint.x - PITCHXIANGAO*1.5,topPoint.y+PITCHXIANGAO*0.2);
        
        //1.3 标记刻度
        //新建标记
        CATextLayer* leftBiaoJi = [CATextLayer new];
        leftBiaoJi.alignmentMode = kCAAlignmentRight;
        //设置锚点
        leftBiaoJi.anchorPoint = CGPointMake(0,0);
        [leftBiaoJi setFrame:CGRectMake(0, 0, 2*BIAOJIFONTSIZE, BIAOJIFONTSIZE)];
        //设置标记位置
        leftBiaoJi.position = CGPointMake(topPoint.x-PITCHXIANGAO*1.5-leftBiaoJi.bounds.size.width-2, topPoint.y-0.5*BIAOJIFONTSIZE);
        //设置标记颜色
        leftBiaoJi.backgroundColor = [[UIColor clearColor] CGColor];
        //设置标记字体
        leftBiaoJi.fontSize = BIAOJIFONTSIZE;
        //设置标记文字
        leftBiaoJi.string = [NSString stringWithFormat:@"%i",i*PITCHDELTAVALUE];
        //添加
        [pitchLayer addSublayer:leftBiaoJi];
        
        //1.画右、上、横 线
        //1.1 移动到做、上、横起点
        CGPathMoveToPoint(pitchPath, nil, topPoint.x + PITCHXIANGAO*1.5, topPoint.y);
        //1.2 向做划线
        CGPathAddLineToPoint(pitchPath, nil, topPoint.x + PITCHXIANGAO*0.5,topPoint.y);
        //2.画右、上、竖 线
        //2.1 移动到右、上、竖起点
        CGPathMoveToPoint(pitchPath, nil, topPoint.x + PITCHXIANGAO*1.5, topPoint.y);
        //2.2 向下划线
        CGPathAddLineToPoint(pitchPath, nil, topPoint.x + PITCHXIANGAO*1.5,topPoint.y+PITCHXIANGAO*0.2);
        
        //1.3 标记刻度
        //新建标记
        CATextLayer* rightBiaoJi = [CATextLayer new];
        rightBiaoJi.alignmentMode = kCAAlignmentLeft;
        //设置锚点
        rightBiaoJi.anchorPoint = CGPointMake(0,0);
        [rightBiaoJi setFrame:CGRectMake(0, 0, 2*BIAOJIFONTSIZE, BIAOJIFONTSIZE)];
        //设置标记位置
        rightBiaoJi.position = CGPointMake(topPoint.x+PITCHXIANGAO*1.5+2, topPoint.y-0.5*BIAOJIFONTSIZE);
        //设置标记颜色
        rightBiaoJi.backgroundColor = [[UIColor clearColor] CGColor];
        //设置标记字体
        rightBiaoJi.fontSize = BIAOJIFONTSIZE;
        //设置标记文字
        rightBiaoJi.string = [NSString stringWithFormat:@"%i",i*PITCHDELTAVALUE];
        //添加
        [pitchLayer addSublayer:rightBiaoJi];
        
        //1.画左、下、横 线
        CGPoint bottomPoint = CGPointMake(pitchBasePoint.x,pitchBasePoint.y + i*PITCHDELTA );
        //1.1 移动到做、下、横起点
        CGPathMoveToPoint(pitchPath, nil, bottomPoint.x - PITCHXIANGAO*1.5, bottomPoint.y);
        //1.2 向右划线
        CGPathAddLineToPoint(pitchPath, nil, bottomPoint.x - PITCHXIANGAO*0.5,bottomPoint.y);
        //2.画左、下、竖 线
        //2.1 移动到左、下、竖起点
        CGPathMoveToPoint(pitchPath, nil, bottomPoint.x - PITCHXIANGAO*1.5, bottomPoint.y);
        //2.2 向上划线
        CGPathAddLineToPoint(pitchPath, nil, bottomPoint.x - PITCHXIANGAO*1.5,bottomPoint.y-PITCHXIANGAO*0.2);
        
        //1.3 标记刻度
        //新建标记
        CATextLayer* leftBottomBiaoJi = [CATextLayer new];
        leftBottomBiaoJi.alignmentMode = kCAAlignmentRight;
        //设置锚点
        leftBottomBiaoJi.anchorPoint = CGPointMake(0,0);
        [leftBottomBiaoJi setFrame:CGRectMake(0, 0, 2*BIAOJIFONTSIZE, BIAOJIFONTSIZE)];
        //设置标记位置
        leftBottomBiaoJi.position = CGPointMake(bottomPoint.x-PITCHXIANGAO*1.5-leftBiaoJi.bounds.size.width-2, bottomPoint.y - 0.5*BIAOJIFONTSIZE);
        //设置标记颜色
        leftBottomBiaoJi.backgroundColor = [[UIColor clearColor] CGColor];
        //设置标记字体
        leftBottomBiaoJi.fontSize = BIAOJIFONTSIZE;
        //设置标记文字
        leftBottomBiaoJi.string = [NSString stringWithFormat:@"%i",i*PITCHDELTAVALUE];
        //添加
        [pitchLayer addSublayer:leftBottomBiaoJi];
        
        //1.画右、下、横 线
        //1.1 移动到做、下、横起点
        CGPathMoveToPoint(pitchPath, nil, bottomPoint.x + PITCHXIANGAO*1.5, bottomPoint.y);
        //1.2 向做划线
        CGPathAddLineToPoint(pitchPath, nil, bottomPoint.x + PITCHXIANGAO*0.5,bottomPoint.y);
        //2.画右、下、竖 线
        //2.1 移动到右、下、竖起点
        CGPathMoveToPoint(pitchPath, nil, bottomPoint.x + PITCHXIANGAO*1.5, bottomPoint.y);
        //2.2 向上划线
        CGPathAddLineToPoint(pitchPath, nil, bottomPoint.x + PITCHXIANGAO*1.5,bottomPoint.y-PITCHXIANGAO*0.2);
        
        //1.3 标记刻度
        //新建标记
        CATextLayer* rightBottoomBiaoJi = [CATextLayer new];
        rightBottoomBiaoJi.alignmentMode = kCAAlignmentLeft;
        //设置锚点
        rightBottoomBiaoJi.anchorPoint = CGPointMake(0,0);
        [rightBottoomBiaoJi setFrame:CGRectMake(0, 0, 2*BIAOJIFONTSIZE, BIAOJIFONTSIZE)];
        //设置标记位置
        rightBottoomBiaoJi.position = CGPointMake(bottomPoint.x+PITCHXIANGAO*1.5+2, bottomPoint.y - 0.5*BIAOJIFONTSIZE);
        //设置标记颜色
        rightBottoomBiaoJi.backgroundColor = [[UIColor clearColor] CGColor];
        //设置标记字体
        rightBottoomBiaoJi.fontSize = BIAOJIFONTSIZE;
        //设置标记文字
        rightBottoomBiaoJi.string = [NSString stringWithFormat:@"%i",i*PITCHDELTAVALUE];
        //添加
        [pitchLayer addSublayer:rightBottoomBiaoJi];
    }
    pitchLayer.path = pitchPath;
    pitchLayer.lineWidth = 2;
    [pitchLayer setBackgroundColor:[UIColor clearColor].CGColor];
    [pitchLayer setFrame:pitchView.bounds];
    pitchLayer.strokeColor = [[UIColor greenColor] CGColor];
    pitchLayer.anchorPoint = CGPointMake(0.5, 0.5);
    pitchLayer.position = CGPointMake(pitchView.bounds.size.width/2, pitchView.bounds.size.height/2);
    //将方位角度标尺添加到仪表视图
    [pitchView.layer addSublayer:pitchLayer];
    //添加当前刻度值
    currentPitchLable = [UILabel new];
    currentPitchLable.text = @"0";
    [currentPitchLable setBackgroundColor:[UIColor clearColor]];
    [currentPitchLable setTextAlignment:NSTextAlignmentCenter];
    [currentPitchLable setFrame:CGRectMake(0, 0, 60, 20)];
    [currentPitchLable setCenter:CGPointMake(pitchView.bounds.size.width/2, pitchView.bounds.size.height/2)];
    //[pitchView addSubview:currentPitchLable];
    
    //========== 初始化俯仰(结束) =================
    //========== 初始化其他工具(开始) =================
    // 初始化方位角度
    otherToolsLayer = [CAShapeLayer new];
    otherToolsLayer.anchorPoint = CGPointMake(0.5, 0.5);
    // 创建新路径
    CGMutablePathRef otherToolsPath = CGPathCreateMutable();
    CGPoint YawDingWei = [YawView convertPoint:YawBasePoint toView:instrumentView];
    //画定位三角形
    CGPathMoveToPoint(otherToolsPath, nil, YawDingWei.x, YawDingWei.y+2);
    CGPathAddLineToPoint(otherToolsPath, nil, YawDingWei.x+0.5*XIANGAO, YawDingWei.y+0.5*XIANGAO*sqrt(3)+2);
    CGPathAddLineToPoint(otherToolsPath, nil, YawDingWei.x-0.5*XIANGAO, YawDingWei.y+0.5*XIANGAO*sqrt(3)+2);
    CGPathAddLineToPoint(otherToolsPath, nil, YawDingWei.x, YawDingWei.y+2);
    //中间标识
    UIImage* instrumentCenterImage =[UIImage imageNamed:@"instrumentCenter"];
    UIImageView* instrumentCenterImageView = [[UIImageView alloc] initWithImage:instrumentCenterImage];
    [instrumentCenterImageView setFrame:CGRectMake(0, 0, instrumentCenterImage.size.width, instrumentCenterImage.size.height)];
    [instrumentView addSubview:instrumentCenterImageView];
    [instrumentCenterImageView setCenter:pitchView.center];
    //设置layer的path
    otherToolsLayer.path = otherToolsPath;
    otherToolsLayer.lineWidth = 2;
    otherToolsLayer.strokeColor = [[UIColor greenColor] CGColor];
    otherToolsLayer.fillColor = [[UIColor greenColor] CGColor];
    [otherToolsLayer setFrame:instrumentView.bounds];
    otherToolsLayer.position = instrumentView.center;
    //将方位角度标尺添加到仪表视图
    [instrumentView.layer addSublayer:otherToolsLayer];
    //========== 初始化工具(结束) =================
    
}
- (void)setYawAngle:(double)angle{
    currentYawAngleLable.text = [NSString stringWithFormat:@"%.1f",angle];
    //超过360*i
    if (angle<_currentYaw && abs(_currentYaw-angle)>90) {
        yawIndex++;
    }
    //低过0+360*i
    if (angle>_currentYaw && abs(_currentYaw-angle)>90) {
        yawIndex--;
    }
    if (abs(yawIndex)>=9) {
        yawIndex =0 ;
    }
    YawLayer.transform = CATransform3DMakeTranslation((yawIndex*360+angle) * (-1.0*YAWDELTA/YAWDELTAVALUE), 0, 0);
    _currentYaw = angle;
    
}
- (void)setRollAnle:(double)newRollAngle{
    CATransform3D translate = CATransform3DMakeTranslation(0,(_currentPitch) * (PITCHDELTA*1.0/PITCHDELTAVALUE), 0);
    CATransform3D rotation = CATransform3DMakeRotation(-1*M_PI*(newRollAngle)/180.0 , 0, 0, 1);
    pitchLayer.transform = CATransform3DConcat(translate,rotation);
    airGroundLayer.transform = CATransform3DConcat(translate,rotation);
}
- (void)setHeight:(double)newHeight{
    HeightLayer.transform = CATransform3DMakeTranslation(0,newHeight * (HEIGHTDELTA*1.0/HEIGHTDELTAVALUE), 0);
    currentHeightLable.text = [NSString stringWithFormat:@"%.1f",newHeight];
    _currentHeight = newHeight;
}
- (void)setSpeed:(double)newSpeed{
    SpeedLayer.transform = CATransform3DMakeTranslation(0,newSpeed * (SPEEDDELTA*1.0/SPEEDDELTAVALE), 0);
    currentSpeedLable.text = [NSString stringWithFormat:@"%.1f",newSpeed];
    _currentSpeed = newSpeed;
}
- (void)setPitchAngle:(double)newPitchAngle{
    CATransform3D translate = CATransform3DMakeTranslation(0,(newPitchAngle) * (PITCHDELTA*1.0/PITCHDELTAVALUE), 0);
    CATransform3D rotation = CATransform3DMakeRotation(M_PI*(_currentYaw)/180.0 , 0, 0, 1);
    pitchLayer.transform = CATransform3DConcat(translate,rotation);
    airGroundLayer.transform = CATransform3DConcat(translate,rotation);
    currentPitchLable.text = [NSString stringWithFormat:@"%.1f",newPitchAngle];
    _currentPitch = newPitchAngle;
}
@end
