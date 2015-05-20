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
    precondition(kernel.count == 9 || kernel.count == 25 || kernel.count == 49, "Kernel size must be 3x3, 5x5 or 7x7.")
    let kernelSide = UInt32(sqrt(Float(kernel.count)))
    
    let imageRef = image.CGImage
    
    let inProvider = CGImageGetDataProvider(imageRef)
    let inBitmapData = CGDataProviderCopyData(inProvider)
    
    var inBuffer = vImage_Buffer(data: UnsafeMutablePointer(CFDataGetBytePtr(inBitmapData)), height: UInt(CGImageGetHeight(imageRef)), width: UInt(CGImageGetWidth(imageRef)), rowBytes: CGImageGetBytesPerRow(imageRef))
    
    var pixelBuffer = malloc(CGImageGetBytesPerRow(imageRef) * CGImageGetHeight(imageRef))
    
    var outBuffer = vImage_Buffer(data: pixelBuffer, height: UInt(CGImageGetHeight(imageRef)), width: UInt(CGImageGetWidth(imageRef)), rowBytes: CGImageGetBytesPerRow(imageRef))
    
    var backgroundColor : Array<UInt8> = [0,0,0,0]
    
    var error = vImageConvolve_ARGB8888(&inBuffer, &outBuffer, nil, 0, 0, kernel, kernelSide, kernelSide, Int32(divisor), &backgroundColor, UInt32(kvImageBackgroundColorFill))
    
    let outImage = UIImage(fromvImageOutBuffer: outBuffer, scale: image.scale, orientation: .Up)
    
    free(pixelBuffer)
    
    return outImage!
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
