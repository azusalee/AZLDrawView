//
//  UIImage+AZLProcess.m
//  ALExampleTest
//
//  Created by yangming on 2018/7/12.
//  Copyright © 2018年 Mac. All rights reserved.
//

#import "UIImage+AZLProcess.h"
#import <Accelerate/Accelerate.h>

@implementation UIImage (AZLProcess)

+ (UIImage *)azl_imageFromFilePath:(NSString *)path size:(CGSize)pointSize{
    NSData *imgData = [[NSData alloc] initWithContentsOfFile:path];
    return [self azl_imageFromData:imgData size:pointSize];
    
}

+ (UIImage *)azl_imageFromData:(NSData *)imgData size:(CGSize)pointSize{
    if (!imgData) {
        return nil;
    }
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CFStringRef sourceKeys[1];
    CFTypeRef sourceValues[1];
    sourceKeys[0] = kCGImageSourceShouldCache;
    sourceValues[0] = (CFTypeRef)kCFBooleanFalse;
    CFDictionaryRef sourceOptRef = CFDictionaryCreate(NULL, (const void **)sourceKeys, (const void **)sourceValues, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)imgData, sourceOptRef);
    CFRelease(sourceOptRef);
    
    
    int maxDimension = (int)MAX(pointSize.width, pointSize.height)*scale;
    CFStringRef imageKeys[3];
    CFTypeRef imageValues[3];
    CFNumberRef thumbnailSize;
    //创建缩略图等比缩放大小，会根据长宽值比较大的作为imageSize进行缩放
    thumbnailSize = CFNumberCreate(NULL, kCFNumberIntType, &maxDimension);
    imageKeys[0] = kCGImageSourceCreateThumbnailWithTransform;
    imageValues[0] = (CFTypeRef)kCFBooleanTrue;
    
    imageKeys[1] = kCGImageSourceCreateThumbnailFromImageAlways;
    imageValues[1] = (CFTypeRef)kCFBooleanTrue;
    //缩放键值对
    imageKeys[2] = kCGImageSourceThumbnailMaxPixelSize;
    imageValues[2] = (CFTypeRef)thumbnailSize;
    
    CFDictionaryRef imageOptions = CFDictionaryCreate(NULL, (const void **) imageKeys,
                                                      (const void **) imageValues, 3,
                                                      &kCFTypeDictionaryKeyCallBacks,
                                                      &kCFTypeDictionaryValueCallBacks);
    CGImageRef cgimg = CGImageSourceCreateThumbnailAtIndex(source, 0, imageOptions);
    CFRelease(thumbnailSize);
    CFRelease(imageOptions);
    CFRelease(source);
    
    
    UIImage *image = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    
    return image;
}


+ (UIImage *)azl_imageFromColor:(UIColor *)color{
    CGRect rect=CGRectMake(0,0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return colorImage;
}


+ (UIImage *)azl_imageFromView:(UIView *)view{
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    
    UIImage *shotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return shotImage;
}

- (UIImage *)azl_imageFromSize:(CGSize)size{
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    
    [self drawInRect:CGRectMake(0,0,size.width,size.height)];
    
    UIImage* scaleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaleImage;
}

- (UIImage *)azl_imageClipFromRect:(CGRect)clipRect{
    CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, CGRectMake(clipRect.origin.x*self.scale, clipRect.origin.y*self.scale, clipRect.size.width*self.scale, clipRect.size.height*self.scale));

    
    UIImage *clipImage = [UIImage imageWithCGImage:subImageRef scale:self.scale orientation:self.imageOrientation];
    
    
    return clipImage;
}


- (UIImage *)azl_imageClipCircleFromRect:(CGRect)clipRect{
    
    UIGraphicsBeginImageContextWithOptions(clipRect.size, false, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //畫內切圓
    CGContextAddEllipseInRect(context, CGRectMake(0, 0, clipRect.size.width, clipRect.size.height));
    CGContextClip(context);
    
    [self drawAtPoint:CGPointMake(-clipRect.origin.x, -clipRect.origin.y)];
    UIImage* clipImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return clipImage;
    
}

- (UIImage *)azl_grayImage{
    int width = self.size.width*self.scale;
    int height = self.size.height*self.scale;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate (nil, width, height,8,0, colorSpace,kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);
    
    if (context == NULL) {
        return nil;
    }
    
    CGContextDrawImage(context,CGRectMake(0,0, width, height), self.CGImage);
    CGImageRef cgimg = CGBitmapContextCreateImage(context);
    UIImage *grayImage = [UIImage imageWithCGImage:cgimg scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(cgimg);
    CGContextRelease(context);
    
    return grayImage;
}

//需要引入Accelerate.Framework，#import <Accelerate/Accelerate.h>
- (UIImage *)azl_imageFromBoxBlur:(CGFloat)blur{
    UIImage *image = self;
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 50);
    boxSize = boxSize - (boxSize % 2) + 1;
    CGImageRef img = image.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    //从CGImage中获取数据
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    //设置从CGImage获取对象的属性
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    //模糊處理
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&outBuffer, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate( outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, kCGImageAlphaNoneSkipLast);
    
    
    //添加顏色蒙層
    //CGContextSaveGState(ctx);
    //CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] colorWithAlphaComponent:0.3].CGColor);
    //CGContextFillRect(ctx, CGRectMake(0, 0, self.size.width, self.size.height));
    //CGContextRestoreGState(ctx);
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    
    
    //clean up
    CGContextRelease(ctx);
    free(pixelBuffer);
    CFRelease(inBitmapData);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    return returnImage;
}

#define kBitsPerComponent (8)
#define kBitsPerPixel (32)
#define kPixelChannelCount (4)
- (UIImage *)azl_imageFromMosaicLevel:(NSUInteger)level
{
    UIImage *orginImage = self;
    //获取BitmapData
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imgRef = orginImage.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  kBitsPerComponent,        //每个颜色值8bit
                                                  width*kPixelChannelCount, //每一行的像素点占用的字节数，每个像素点的ARGB四个通道各占8个bit
                                                  colorSpace,
                                                  kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    unsigned char *bitmapData = CGBitmapContextGetData (context);
    
    //这里把BitmapData进行马赛克转换,就是用一个点的颜色填充一个level*level的正方形
    unsigned char pixel[kPixelChannelCount] = {0};
    NSUInteger index,preIndex;
    for (NSUInteger i = 0; i < height - 1 ; i++) {
        for (NSUInteger j = 0; j < width - 1; j++) {
            index = i * width + j;
            if (i % level == 0) {
                if (j % level == 0) {
                    memcpy(pixel, bitmapData + kPixelChannelCount*index, kPixelChannelCount);
                }else{
                    memcpy(bitmapData + kPixelChannelCount*index, pixel, kPixelChannelCount);
                }
            } else {
                preIndex = (i-1)*width +j;
                memcpy(bitmapData + kPixelChannelCount*index, bitmapData + kPixelChannelCount*preIndex, kPixelChannelCount);
            }
        }
    }
    
    NSInteger dataLength = width*height* kPixelChannelCount;
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, bitmapData, dataLength, NULL);
    //创建要输出的图像
    CGImageRef mosaicImageRef = CGImageCreate(width, height,
                                              kBitsPerComponent,
                                              kBitsPerPixel,
                                              width*kPixelChannelCount ,
                                              colorSpace,
                                              kCGBitmapByteOrderDefault,
                                              provider,
                                              NULL, NO,
                                              kCGRenderingIntentDefault);
    CGContextRef outputContext = CGBitmapContextCreate(nil,
                                                       width,
                                                       height,
                                                       kBitsPerComponent,
                                                       width*kPixelChannelCount,
                                                       colorSpace,
                                                       kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(outputContext, CGRectMake(0.0f, 0.0f, width, height), mosaicImageRef);
    CGImageRef resultImageRef = CGBitmapContextCreateImage(outputContext);
    UIImage *resultImage = nil;
//    if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
//        float scale = [[UIScreen mainScreen] scale];
//        resultImage = [UIImage imageWithCGImage:resultImageRef scale:scale orientation:UIImageOrientationUp];
//    } else {
        resultImage = [UIImage imageWithCGImage:resultImageRef scale:self.scale orientation:self.imageOrientation];
    //}
    
    
    //释放
    CFRelease(resultImageRef);
    
    CFRelease(mosaicImageRef);
    
    CGColorSpaceRelease(colorSpace);
    
    CGDataProviderRelease(provider);
    
    CGContextRelease(context);
    
    CGContextRelease(outputContext);
    
    return resultImage;
    
}


- (UIImage *)azl_imageFromRotate:(CGFloat)rotateAngle{
    
    double radian = M_PI*rotateAngle/180;
    CGAffineTransform transform = CGAffineTransformMakeRotation(radian);
    CGRect rotateRect =  CGRectApplyAffineTransform(CGRectMake(0, 0, self.size.width, self.size.height), transform);
    
    UIGraphicsBeginImageContextWithOptions(rotateRect.size, false, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, rotateRect.size.width/2, rotateRect.size.height/2);
    CGContextRotateCTM(context, radian);
    CGContextTranslateCTM(context, -self.size.width/2, -self.size.height/2);
    
    [self drawAtPoint:CGPointZero];
    
    UIImage *rotateImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return rotateImage;
}

- (UIImage *)azl_imageFromMirrorHorizon{
    
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, false, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToRect(context, rect);
    CGContextRotateCTM(context, M_PI);
    CGContextTranslateCTM(context, -rect.size.width, -rect.size.height);
    
    CGContextDrawImage(context, rect, self.CGImage);
    UIImage *mirrorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *flipImage = [UIImage imageWithCGImage:mirrorImage.CGImage scale:self.scale orientation:self.imageOrientation];
    
    UIGraphicsEndImageContext();
    return flipImage;
    
}

- (UIImage *)azl_imageFromMirrorVertical{
    
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, false, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToRect(context, rect);
    
    CGContextDrawImage(context, rect, self.CGImage);
    UIImage *mirrorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *flipImage = [UIImage imageWithCGImage:mirrorImage.CGImage scale:self.scale orientation:self.imageOrientation];
    
    UIGraphicsEndImageContext();
    return flipImage;
    
}

- (UIColor *)azl_colorFromPoint:(CGPoint)point{
    
    //    判断给定的点是否在圖片內
    UIImage *image = self;
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), point)) {
        return nil;
    }
    
    //    trunc（n1,n2），n1表示被截断的数字，n2表示要截断到那一位。n2可以是负数，表示截断小数点前。注意，TRUNC截断不是四舍五入。
    //    trunc(15.79)---15
    //    trunc(15.79,1)--15.7
    
    NSInteger pointX = trunc(point.x);
    
    NSInteger pointY = trunc(point.y);
    
    CGImageRef cgImage = image.CGImage;
    
    NSUInteger width = image.size.width;
    NSUInteger height = image.size.height;
    //    创建色彩标准
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    int bytesPerPixel = 4;
    
    int bytesPerRow = bytesPerPixel * 1;
    
    NSUInteger bitsPerComponent = 8;
    
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    
}



- (UIImage *)azl_imageWithGradientTintColor:(UIColor *)tintColor
{
    return [self azl_imageWithTintColor:tintColor blendMode:kCGBlendModeOverlay];
}

- (UIImage *)azl_imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    
    //Draw the tinted image in context
    [self drawInRect:bounds blendMode:blendMode alpha:1.0f];
    
    if (blendMode != kCGBlendModeDestinationIn) {
        [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    }
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

- (double)azl_getNoAlphaPixelRate{
    int width = (int)(self.size.width*self.scale);
    int height = (int)(self.size.height*self.scale);
    
    int bitmapByteCount = width*height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    int8_t * pixelData = malloc(sizeof(int8_t)*bitmapByteCount);
    CGContextRef context = CGBitmapContextCreate (pixelData,
                                                  width,
                                                  height,
                                                  kBitsPerComponent,        //每个颜色值8bit
                                                  width, //每一行的像素点占用的字节数
                                                  colorSpace,
                                                  kCGImageAlphaOnly);
    CGRect rect = CGRectMake(0, 0, width, height);
    CGContextClearRect(context, rect);
    CGContextDrawImage(context, rect, self.CGImage);
    CGContextRelease(context);
    
    int alphaPixelCount = 0;
    for (int x = 0; x < width; x++) {
        for (int y = 0; y < height; y++) {
            if (pixelData[y*width+x] != 0) {
                alphaPixelCount += 1;
            }
        }
    }
    
    free(pixelData);
    
    return (double)alphaPixelCount/(double)bitmapByteCount;
}


+ (NSArray *)azl_getEffectArray{
    NSArray* filters =  [CIFilter filterNamesInCategory:kCICategoryColorEffect];
//    for (NSString* filterName in filters) {
//        NSLog(@"filter name:%@",filterName);
//        // 我们可以通过filterName创建对应的滤镜对象
////        CIFilter* filter = [CIFilter filterWithName:filterName];
////        NSDictionary* attributes = [filter attributes];
////        // 获取属性键/值对（在这个字典中我们可以看到滤镜的属性以及对应的key）
////        NSLog(@"filter attributes:%@",attributes);
//    }
    
    return filters;
}


- (UIImage *)azl_imageFromFilterName:(NSString*)filterName{
    // 创建输入CIImage对象
    CIImage * inputImg = [CIImage imageWithCGImage:self.CGImage];
    // 创建滤镜
    CIFilter * filter = [CIFilter filterWithName:filterName];
    // 设置滤镜属性值为默认值
    [filter setDefaults];
    // 设置输入图像
    [filter setValue:inputImg forKey:kCIInputImageKey];
    // 获取输出图像
    CIImage * outputImg = filter.outputImage;
    
    // 创建CIContex上下文对象
    CIContext * context = [CIContext contextWithOptions:nil];
    CGImageRef cgImg = [context createCGImage:outputImg fromRect:outputImg.extent];
    UIImage *resultImg = [UIImage imageWithCGImage:cgImg scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(cgImg);
    
    return resultImg;
}

@end
