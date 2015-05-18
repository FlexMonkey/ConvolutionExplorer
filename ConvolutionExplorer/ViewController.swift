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
    let kernelEditor = KernelEditor()
    let valueSlider = UISlider()
    
    let kernelSizeSegmentedControl = UISegmentedControl(items: [KernelSize.ThreeByThree.rawValue, KernelSize.FiveByFive.rawValue, KernelSize.SevenBySeven.rawValue])
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        let image = UIImage(named: "image.jpg")
        imageView.image = image
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        kernelSizeSegmentedControl.addTarget(self, action: "kernelSizeChange", forControlEvents: UIControlEvents.ValueChanged)
        
        workspace.children = [kernelEditor, imageView]
        
        toolbar.children = [valueSlider, kernelSizeSegmentedControl]
        toolbar.explicitSize = 40
        
        mainGroup.children = [workspace, toolbar]
        view.addSubview(mainGroup)
        
        kernelSizeSegmentedControl.selectedSegmentIndex = 0
        kernelSizeChange()
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

