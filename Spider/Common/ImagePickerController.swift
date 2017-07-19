//
//  ImagePickerController.swift
//  Spider
//
//  Created by ooatuoo on 16/8/10.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

extension TZImagePickerController {
    
    convenience init(maxCount: Int, animated: Bool = true, completion: @escaping ([UIImage]) -> Void) {
        
        self.init(maxImagesCount: maxCount, delegate: nil)
        
        maxImagesCount = maxCount
        allowPickingVideo = false
        allowPickingOriginalPhoto = false
        
        didFinishPickingPhotosHandle = { [weak self] (photos, assets, isOriginal) in
            // TODO: - 图片质量的处理
//            let requestOptions                  = PHImageRequestOptions()
//            requestOptions.synchronous          = true
//            requestOptions.version              = .Current
//            requestOptions.deliveryMode         = .Opportunistic
//            requestOptions.resizeMode           = .Exact
//            requestOptions.networkAccessAllowed = true
            
            self?.dismiss(animated: animated, completion: nil)
            
            completion(photos!)
        }
    }
}
