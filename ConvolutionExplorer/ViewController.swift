//
//  ViewController.swift
//  ConvolutionExplorer
//
//  Created by Simon Gladman on 18/05/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let mainGroup = SLVGroup()
    let workspace = SLHGroup()
    let toolbar = SLHGroup()
    let imageView = UIImageView()
    let kernelEditor = KernelEditor(kernel: [Int](count: 49, repeatedValue: 0))
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
        
        kernelEditor.kernel[17] = -1
        kernelEditor.kernel[23] = -1
        kernelEditor.kernel[24] = 6
        kernelEditor.kernel[25] = -1
        kernelEditor.kernel[31] = -1
        
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
        
        imageView.image = applyConvolutionFilterToImage(image!, kernel: kernel, divisor: 4)
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


