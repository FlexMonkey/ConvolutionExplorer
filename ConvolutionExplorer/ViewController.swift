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
        imageView.image = image
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        valueSlider.minimumValue = -10
        valueSlider.maximumValue = 10
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
        var accum = 0
        
        if kernelEditor.selectedCellIndexes.count > 0
        {
            for index in kernelEditor.selectedCellIndexes
            {
                accum += kernelEditor.kernel[index]
            }
            
            accum /= kernelEditor.selectedCellIndexes.count
        }
        valueSlider.value = Float(accum)
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

