//
//  UIImage+Category.m
//  SDIMApp
//
//  Created by lancely on 1/29/16.
//  Copyright © 2016 Rao. All rights reserved.
//

#import "UIImage+Category.h"

@implementation UIImage (Category)

- (UIImage*)transformImageToSize:(CGSize)Newsize
{
    // 创建一个bitmap的context
    UIGraphicsBeginImageContext(Newsize);
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0, 0, Newsize.width, Newsize.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* TransformedImg = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return TransformedImg;
}

- (UIImage*)compressedImage
{
    const CGFloat scaleSize = kImageCompressRate;
    UIGraphicsBeginImageContext(CGSizeMake(self.size.width * scaleSize, self.size.height * scaleSize));
    [self drawInRect:CGRectMake(0, 0, self.size.width * scaleSize, self.size.height * scaleSize)];
    UIImage* compressedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return compressedImage;
}

@end
