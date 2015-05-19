//
//  ViewController.swift
//  ConvolutionExplorer
//
//  Created by Simon Gladman on 18/05/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

import UIKit
import Accelerate

class ViewController: UIViewController {

    let mainGroup = SLVGroup()
    let workspace = SLHGroup()
    let toolbar = SLHGroup()
    let imageView = UIImageView()
    let kernelEditor = KernelEditor(kernel: [Int](count: 49, repeatedValue: 1))
    let valueSlider = UISlider()
    
    let kernelSizeSegmentedControl = UISegmentedControl(items: [KernelSize.ThreeByThree.rawValue, KernelSize.FiveByFive.rawValue, KernelSize.SevenBySeven.rawValue])
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        let image = UIImage(named: "image.jpg")
        imageView.image = gaussBlur()(image!)
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        valueSlider.minimumValue = -10
        valueSlider.maximumValue = 10
        valueSlider.enabled = false
        valueSlider.addTarget(self, action: "sliderChange", forControlEvents: UIControlEvents.ValueChanged)
        
        kernelSizeSegmentedControl.addTarget(self, action: "kernelSizeChange", forControlEvents: UIControlEvents.ValueChanged)
        
        kernelEditor.addTarget(self, action: "selectionChanged", forControlEvents: UIControlEvents.ValueChanged)
        
        workspace.children = [kernelEditor, imageView]
        
        toolbar.children = [valueSlider, kernelSizeSegmentedControl]
        toolbar.explicitSize = 40
        
        mainGroup.children = [workspace, toolbar]
        view.addSubview(mainGroup)
        
        kernelSizeSegmentedControl.selectedSegmentIndex = 0
        kernelSizeChange()
        
        // ---- vImageConvolve_Planar8
    }
    
    typealias Filter = UIImage -> UIImage
    
    func gaussBlur() -> Filter {
        return filterWithConvolutionMatrix_xx([10,2,1 ,2,4,2 ,1,2,1], width: 3, height: 3, divisor: 16)
    }
    
    private func filterWithConvolutionMatrix_xx(kernel:[Int16], width:Int, height:Int, divisor:Int) -> Filter{
        return { image in
            let imageRef = image.CGImage
            
            let inProvider = CGImageGetDataProvider(imageRef)
            let inBitMapData = CGDataProviderCopyData(inProvider)
            
            var inBuffer: vImage_Buffer = vImage_Buffer(data: UnsafeMutablePointer(CFDataGetBytePtr(inBitMapData)), height: UInt(CGImageGetHeight(imageRef)), width: UInt(CGImageGetWidth(imageRef)), rowBytes: CGImageGetBytesPerRow(imageRef))
            
            var pixelBuffer = malloc(CGImageGetBytesPerRow(imageRef) * CGImageGetHeight(imageRef))
            
            var outBuffer = vImage_Buffer(data: pixelBuffer, height: UInt(CGImageGetHeight(imageRef)), width: UInt(CGImageGetWidth(imageRef)), rowBytes: CGImageGetBytesPerRow(imageRef))
            
            var bColor : Array<UInt8> = [0,0,0,0]
    
            var error = vImageConvolve_ARGB8888(&inBuffer, &outBuffer, nil, 0, 0, kernel, UInt32(height), UInt32(width), Int32(divisor), &bColor, UInt32(kvImageBackgroundColorFill))
            
            let out = UIImage(fromvImageOutBuffer: outBuffer, scale: image.scale, orientation: .Up)
            
            free(pixelBuffer)
            
            return out!
        }
    }
    
    func filterWithConvolutionMatrix(#kernel: Array<Array<Int16>>, divisor:Int) -> Filter {
        
        var input : [Int16] = kernel.reduce([Int16]()) { (var nArray:[Int16], row:[Int16]) -> Array<Int16> in
            var mutableNArray = nArray
            for i16 in row {
                mutableNArray.append(i16)
            }
            return mutableNArray
        }
        
        return filterWithConvolutionMatrix_xx(input, width: Int( kernel[0].count ), height: Int( kernel.count ), divisor: divisor)
    }
    
 
    
    
    func sliderChange()
    {
        let kernel = kernelEditor.kernel
        
        for index in kernelEditor.selectedCellIndexes
        {
            kernelEditor.kernel[index] = Int(valueSlider.value)
        }
    }
    
    func selectionChanged()
    {
        valueSlider.enabled = kernelEditor.selectedCellIndexes.count != 0
        
        if valueSlider.enabled
        {
            let selectionAverage = kernelEditor.selectedCellIndexes.reduce(0, combine: { $0 + kernelEditor.kernel[$1] }) / kernelEditor.selectedCellIndexes.count
            
            valueSlider.value = Float(selectionAverage);
        }
    }
    
    func kernelSizeChange()
    {
        if let kernelSize = KernelSize(rawValue: kernelSizeSegmentedControl.titleForSegmentAtIndex(kernelSizeSegmentedControl.selectedSegmentIndex)!)
        {
            kernelEditor.kernelSize = kernelSize
        }
    }

    override func viewDidLayoutSubviews()
    {
        let top = topLayoutGuide.length
        let bottom = bottomLayoutGuide.length
        
        mainGroup.frame = CGRect(x: 0, y: top, width: view.frame.width, height: view.frame.height - top - bottom).rectByInsetting(dx: 5, dy: 0)
    }

}


private extension UIImage {
    convenience init?(fromvImageOutBuffer outBuffer:vImage_Buffer, scale:CGFloat, orientation: UIImageOrientation){
        var colorSpace = CGColorSpaceCreateDeviceRGB()
        
        var context = CGBitmapContextCreate(outBuffer.data, Int(outBuffer.width), Int(outBuffer.height), 8, outBuffer.rowBytes, colorSpace, CGBitmapInfo(CGImageAlphaInfo.NoneSkipLast.rawValue))
        
        var outCGimage = CGBitmapContextCreateImage(context)
        
        self.init(CGImage: outCGimage, scale:scale, orientation:orientation)
    }
}

