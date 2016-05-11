//
//  TableViewPerformanceViewController.m
//  performance
//
//  Created by KudoCC on 16/1/19.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "TableViewPerformanceViewController.h"
#import <SDWebImageDecoder.h>
#import "CornerRadiusView.h"
#import "UIView+CornerRadius.h"
#import "UIImage+CCKit.h"

@interface ImageViewPerformanceCell : UITableViewCell

@property (nonatomic, strong) UIView *imgView1;
@property (nonatomic, strong) UIView *imgView2;
@property (nonatomic, strong) UIView *imgView3;

@end

@implementation ImageViewPerformanceCell

+ (CGFloat)cellHeight {
    return 88.0;
}

+ (CGFloat)imageHeight {
    return 66.0;
}

- (UIView *)createImageView {
    
    UIColor *borderColor = [UIColor blackColor];
    CGFloat borderWidth = 0.0;
    
#define Performance 3
    
#if Performance == 1
    
    /**
     在iPhone4上, masksToBounds==YES -> 帧率12左右；masksToBounds == NO -> 帧率将近30，应该是UIImageView对图片解压缩和缩放比较耗费cpu
     为了不让UIImageView在缩放上耗费时间，我把contentMode改成center，帧率将近40，说明确实有影响；
     下面要将图片提前解压缩，看一下是不是也有影响，发现貌似没什么影响，仍然是接近30的值。
     另外发现一个有趣的，如果只设置borderColor和borderWidth，那么帧率50左右；如果只设置cornerRadius并且masksToBounds为NO，帧率50以上。与上面的结论对比，看来带圆角的border也会造成一些性能损耗，即使不产生离屏渲染；如果横向对比，设置border会有性能损耗。
     
     在iPhone6上masksToBounds为YES，帧率接近40；masksToBounds为NO，帧率接近60。
     */
    UIImageView *v = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, [self.class imageHeight], [self.class imageHeight])];
//    v.contentMode = UIViewContentModeCenter;
    v.layer.cornerRadius = 10.0;
    v.layer.masksToBounds = YES;
    v.layer.borderColor = borderColor.CGColor;
    v.layer.borderWidth = borderWidth;
    
//    self.layer.shouldRasterize = YES;
//    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
#elif Performance == 2
    
    /**
     在iPhone4上帧率在20-30左右，与是否设置cornerRadius无关
     在iPhone6上帧率接近60；增加到3个imageView，接近60；
     
     总结下来，CornerRadiusView比较耗cpu，所以在cpu差的机器上表现不好
     */
    
    CornerRadiusView *v = [[CornerRadiusView alloc] initWithFrame:CGRectMake(0.0, 0.0, [self.class imageHeight], [self.class imageHeight])];
//    UIColor *color = v.backgroundColor;
//    CGFloat red, green, blue, alpha;
//    [color getRed:&red green:&green blue:&blue alpha:&alpha];
//    NSLog(@"000:%f, %f, %f, %f", red, green, blue, alpha);
    v.contentMode = UIViewContentModeScaleToFill;
    v.cornerRadius = 10.0;
    v.borderWidth = borderWidth;
    v.borderColor = borderColor;
    
//    UIView *vv = [[UIView alloc] initWithFrame:CGRectZero];
//    color = vv.backgroundColor;
//    [color getRed:&red green:&green blue:&blue alpha:&alpha];
//    NSLog(@"111:%f, %f, %f, %f", red, green, blue, alpha);
    
#elif Performance == 3
    
    /**
     在图的imageView上覆盖一个圆角的图，中间透明，让图片透出来
     在iPhone4开三个imageView，帧率在50以上(为啥刚刚测试就49了？？？？04-27)
     帧率上不是非常好，但是也还算不错了
     
     在项目中使用这个代码后发现，在cell highlighted，由于背景颜色改变，导致看上去圆角消失了，圆角位置填充的是之前的背景色，所以这个策略不能用于UIImageView的superView背景可变的情况
     */
    
    UIImageView *v = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, [self.class imageHeight], [self.class imageHeight])];
    [v cornerRadius_addCornerRadius:10.0 backgroundColor:[UIColor whiteColor] borderWidth:borderWidth borderColor:borderColor];
    
#else
    
    UIImageView *v = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, [self.class imageHeight], [self.class imageHeight])];
    v.tag = 1024;
    v.contentMode = UIViewContentModeScaleToFill;
    [v sd_setTransformDownloadedImageBlock:^UIImage *(UIImage *image, NSURL *imageUrl) {
        NSAssert(![NSThread isMainThread], @"can't be main thread");
        CGSize size = CGSizeMake(44, 44);
        CGFloat radius = 5;
        if (image.images) {
            NSMutableArray *mArray = [NSMutableArray array];
            for (UIImage *imageItem in image.images) {
                [mArray addObject:[imageItem cc_imageWithSize:size cornerRadius:radius borderWidth:0 borderColor:nil contentMode:UIViewContentModeScaleAspectFill]];
            }
            return [UIImage animatedImageWithImages:mArray duration:image.duration];
        } else {
            return [image cc_imageWithSize:size cornerRadius:radius borderWidth:0 borderColor:nil contentMode:UIViewContentModeScaleAspectFill];
        }
    } transformKey:@"roundCorner"];
    
#endif
    
    
    return v;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _imgView1 = [self createImageView];
        [self.contentView addSubview:_imgView1];
        
        _imgView2 = [self createImageView];
        [self.contentView addSubview:_imgView2];
        
        _imgView3 = [self createImageView];
        [self.contentView addSubview:_imgView3];
    }
    return self;
}

- (void)layoutSubviews {
    CGSize s = self.bounds.size;
    _imgView1.frame = CGRectMake(0.0, 10.0, _imgView1.bounds.size.height, _imgView1.bounds.size.height);
    _imgView2.frame = CGRectMake(s.height + 10.0, 10.0, _imgView2.bounds.size.height, _imgView2.bounds.size.height);
    _imgView3.frame = CGRectMake(s.height + 10.0 + s.height + 10.0, 10.0, _imgView3.bounds.size.height, _imgView3.bounds.size.height);
}

@end

@interface TableViewPerformanceViewController () <UITableViewDataSource, UITableViewDelegate> {
    pthread_mutex_t mutex;
    NSLock *lock;
    NSRecursiveLock *recursiveLock;
}

@property (nonatomic, strong) NSMutableArray *mArrayImage;

@end

@implementation TableViewPerformanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:tableView];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.estimatedRowHeight = 20.0;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.separatorInset = UIEdgeInsetsZero;
    
    /**
     decode之后效果并不明显，但是resize之后，效果非常明显
     */
    _mArrayImage = [NSMutableArray array];
    for (int i = 0; i < 11; ++i) {
        NSString *imageName = [NSString stringWithFormat:@"image%@.jpg", @(i)];
        UIImage *image = [UIImage imageNamed:imageName];
        // 不decode时，内存使用为7M，decode之后应用尼玛17M！！！！
//        image = [UIImage decodedImageWithImage:image];
        NSLog(@"before resize:%@", NSStringFromCGSize(image.size));
        image = [UIImage cc_resizeImage:image contentMode:UIViewContentModeScaleAspectFill size:CGSizeMake([ImageViewPerformanceCell imageHeight], [ImageViewPerformanceCell imageHeight])];
        NSLog(@"after resize:%@", NSStringFromCGSize(image.size));
        [_mArrayImage addObject:image];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ImageViewPerformanceCell cellHeight];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 400;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ImageViewPerformanceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id"];
    if (!cell) {
        cell = [[ImageViewPerformanceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"id"];
        cell.opaque = YES;
        cell.separatorInset = UIEdgeInsetsZero;
        if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
    }
    
#if Performance == 4
    [(UIImageView *)cell.imgView1 sd_setImageWithURL:[NSURL URLWithString:@"http://pic22.nipic.com/20120716/10469458_101024533116_2.jpg"]];
    [(UIImageView *)cell.imgView2 sd_setImageWithURL:[NSURL URLWithString:@"http://img5.imgtn.bdimg.com/it/u=3125965691,1960187158&fm=206&gp=0.jpg"]];
    [(UIImageView *)cell.imgView3 sd_setImageWithURL:[NSURL URLWithString:@"http://img5.duitang.com/uploads/item/201409/05/20140905221558_RmjAz.thumb.700_0.jpeg"]];
#else
    NSInteger i = indexPath.row % 11;
    UIImage *image = _mArrayImage[i];
    if ([cell.imgView1 respondsToSelector:@selector(setImage:)]) {
        CATransition *transition = [CATransition animation];
        transition.duration = 2;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        [cell.imgView1.layer addAnimation:transition forKey:@"key"];
        
        [cell.imgView1 performSelector:@selector(setImage:) withObject:image];
    }
    if ([cell.imgView2 respondsToSelector:@selector(setImage:)]) {
        [cell.imgView2 performSelector:@selector(setImage:) withObject:image];
    }
    if ([cell.imgView3 respondsToSelector:@selector(setImage:)]) {
        [cell.imgView3 performSelector:@selector(setImage:) withObject:image];
    }
#endif
    return cell;
}

@end
