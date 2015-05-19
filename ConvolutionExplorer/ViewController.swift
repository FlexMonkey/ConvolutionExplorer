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
    
    let image = UIImage(named: "image.jpg")
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        valueSlider.minimumValue = -20
        valueSlider.maximumValue = 20
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
        
        applyKernel()
    }
    
    func applyConvolutionFilterToImage(image: UIImage, kernel: [Int16], width: Int, height: Int, divisor: Int) -> UIImage
    {
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

    func applyKernel()
    {
        var kernel = [Int16]()
        let size: Int = kernelEditor.kernelSize == .ThreeByThree ? 3 : kernelEditor.kernelSize == .FiveByFive ? 5 : 7
        
        for (idx, cell) in enumerate(kernelEditor.kernel)
        {
            let row = Int(idx / 7)
            let column = idx % 7

            switch kernelEditor.kernelSize
            {
            case .ThreeByThree:
                if row >= 2 && row <= 4 && column >= 2 && column <= 4
                {
                    kernel.append(Int16(cell))
                }
            case .FiveByFive:
                if row >= 1 && row <= 5 && column >= 1 && column <= 5
                {
                    kernel.append(Int16(cell))
                }
            case .SevenBySeven:
                kernel.append(Int16(cell))
            }
        }
        
        println(kernel.debugDescription)
        
        imageView.image = applyConvolutionFilterToImage(image!, kernel: kernel, width: size, height: size, divisor: 4)
    }
    
    func sliderChange()
    {
        for index in kernelEditor.selectedCellIndexes
        {
            kernelEditor.kernel[index] = Int(valueSlider.value)
        }
        
        applyKernel()
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
            applyKernel()
        }
    }

    override func viewDidLayoutSubviews()
    {
        let top = topLayoutGuide.length
        let bottom = bottomLayoutGuide.length
        
        mainGroup.frame = CGRect(x: 0, y: top, width: view.frame.width, height: view.frame.height - top - bottom).rectByInsetting(dx: 5, dy: 0)
    }
    
    override func supportedInterfaceOrientations() -> Int
    {
        return Int(UIInterfaceOrientationMask.Landscape.rawValue)
    }

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

