//
//  CropImage.swift
//  textRecognitionApp
//
//  Created by Sasan Baho on 2020-04-09.
//  Copyright © 2020 Sasan Baho. All rights reserved.
//

import UIKit

class CropImage {
    func scaleAndCropImage(_ image:UIImage, toSize size: CGSize) -> UIImage {
        // Make sure the image isn't already sized.
        guard !image.size.equalTo(size) else {
            return image
        }

        let widthFactor = size.width / image.size.width
        let heightFactor = size.height / image.size.height
        var scaleFactor: CGFloat = 0.0

        scaleFactor = heightFactor

        if widthFactor > heightFactor {
            scaleFactor = widthFactor
        }

        var thumbnailOrigin = CGPoint.zero
        let scaledWidth  = image.size.width * scaleFactor
        let scaledHeight = image.size.height * scaleFactor

        if widthFactor > heightFactor {
            thumbnailOrigin.y = (size.height - scaledHeight) / 2.0
        }

        else if widthFactor < heightFactor {
            thumbnailOrigin.x = (size.width - scaledWidth) / 2.0
        }

        var thumbnailRect = CGRect.zero
        thumbnailRect.origin = thumbnailOrigin
        thumbnailRect.size.width  = scaledWidth
        thumbnailRect.size.height = scaledHeight

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.draw(in: thumbnailRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return scaledImage
    }
}
