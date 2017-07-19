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
    
    func resize(_ width: CGFloat) -> UIImage {
        return UIImage(cgImage: self.cgImage!, scale: size.height / width, orientation: .up)
    }
    

}

// 将颜色转换为背景图片
extension UIImage{

    func imageWithColor(_ color:UIColor, size:CGSize) -> UIImage {
        let rect:CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let theImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return theImage
    }
    
    func imageWithColor(_ color:UIColor) -> UIImage {
        return imageWithColor(color, size: CGSize(width: 1, height: 1))
    }
}


extension UIImage {
    // 裁剪图片
    func imageShape(_ image:UIImage, size:CGSize) -> UIImage {
        let rect:CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let cgImage:CGImage = image.cgImage!.cropping(to: rect)!
        let result:UIImage = UIImage.init(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
        return result
    }
    
    // 等比例缩放
    func scaleToSize(_ size: CGSize) -> UIImage {
        var width: CGFloat = CGFloat(self.cgImage!.width)
        var height: CGFloat = CGFloat(self.cgImage!.height)
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
        draw(in: CGRect(x: xPos, y: yPos, width: width, height: height))
        // 从当前context中创建一个改变大小后的图片
        let scaleImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        // 使当前的context出栈
        UIGraphicsEndImageContext()
        return scaleImage
    
    }
}
