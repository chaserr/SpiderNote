//
//  UIImage+Size.swift
//  Spider
//
//  Created by Atuooo on 5/19/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit

extension UIImage {
    func getHalfSize() -> CGSize {
        return CGSize(width: size.width / 2, height: size.height / 2)
    }
    
    func resize(width: CGFloat) -> UIImage {
        return UIImage(CGImage: self.CGImage!, scale: size.height / width, orientation: .Up)
    }
    

}

// 将颜色转换为背景图片
extension UIImage{

    func imageWithColor(color:UIColor, size:CGSize) -> UIImage {
        let rect:CGRect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context:CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let theImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return theImage
    }
    
    func imageWithColor(color:UIColor) -> UIImage {
        return imageWithColor(color, size: CGSizeMake(1, 1))
    }
}


extension UIImage {
    // 裁剪图片
    func imageShape(image:UIImage, size:CGSize) -> UIImage {
        let rect:CGRect = CGRectMake(0, 0, size.width, size.height)
        let cgImage:CGImageRef = CGImageCreateWithImageInRect(image.CGImage!, rect)!
        let result:UIImage = UIImage.init(CGImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
        return result
    }
    
    // 等比例缩放
    func scaleToSize(size: CGSize) -> UIImage {
        var width: CGFloat = CGFloat(CGImageGetWidth(self.CGImage!))
        var height: CGFloat = CGFloat(CGImageGetHeight(self.CGImage!))
        let verticalRadio: CGFloat = CGFloat(size.height * 1.0 / height)
        let horizontalRadio: CGFloat = CGFloat(size.width * 1.0 / width)
        var radio: CGFloat = 1
        if verticalRadio > 1 && horizontalRadio > 1 {
            radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio
        }else{
        
            radio = verticalRadio < horizontalRadio ? verticalRadio : horizontalRadio;
        }
        
        width = width * radio
        height = height * radio
        let xPos: CGFloat = (size.width - width) / 2
        let yPos: CGFloat = (size.height - height) / 2
        
        // 创建一个bitmap的context，并设置为当前context
        UIGraphicsBeginImageContext(size)
        drawInRect(CGRectMake(xPos, yPos, width, height))
        // 从当前context中创建一个改变大小后的图片
        let scaleImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        // 使当前的context出栈
        UIGraphicsEndImageContext()
        return scaleImage
    
    }
}
