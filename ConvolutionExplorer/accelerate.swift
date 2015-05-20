//
//  accelerate.swift
//  ConvolutionExplorer
//
//  Created by Simon Gladman on 20/05/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//
// Thanks to https://github.com/j4nnis/AImageFilters

import UIKit
import Accelerate

func applyConvolutionFilterToImage(image: UIImage, #kernel: [Int16], #divisor: Int) -> UIImage
{
    precondition(kernel.count == 9 || kernel.count == 25 || kernel.count == 49, "Kernel count must be 9, 25 or 49.")
    let size: UInt32 = kernel.count == 9 ? 3 : kernel.count == 25 ? 5 : 7
    
    let imageRef = image.CGImage
    
    let inProvider = CGImageGetDataProvider(imageRef)
    let inBitMapData = CGDataProviderCopyData(inProvider)
    
    var inBuffer: vImage_Buffer = vImage_Buffer(data: UnsafeMutablePointer(CFDataGetBytePtr(inBitMapData)), height: UInt(CGImageGetHeight(imageRef)), width: UInt(CGImageGetWidth(imageRef)), rowBytes: CGImageGetBytesPerRow(imageRef))
    
    var pixelBuffer = malloc(CGImageGetBytesPerRow(imageRef) * CGImageGetHeight(imageRef))
    
    var outBuffer = vImage_Buffer(data: pixelBuffer, height: UInt(CGImageGetHeight(imageRef)), width: UInt(CGImageGetWidth(imageRef)), rowBytes: CGImageGetBytesPerRow(imageRef))
    
    var bColor : Array<UInt8> = [0,0,0,0]
    
    var error = vImageConvolve_ARGB8888(&inBuffer, &outBuffer, nil, 0, 0, kernel, size, size, Int32(divisor), &bColor, UInt32(kvImageBackgroundColorFill))
    
    let out = UIImage(fromvImageOutBuffer: outBuffer, scale: image.scale, orientation: .Up)
    
    free(pixelBuffer)
    
    return out!
}

private extension UIImage
{
    convenience init?(fromvImageOutBuffer outBuffer:vImage_Buffer, scale:CGFloat, orientation: UIImageOrientation)
    {
        var colorSpace = CGColorSpaceCreateDeviceRGB()
        
        var context = CGBitmapContextCreate(outBuffer.data, Int(outBuffer.width), Int(outBuffer.height), 8, outBuffer.rowBytes, colorSpace, CGBitmapInfo(CGImageAlphaInfo.NoneSkipLast.rawValue))
        
        var outCGimage = CGBitmapContextCreateImage(context)
        
        self.init(CGImage: outCGimage, scale:scale, orientation:orientation)
    }
}
