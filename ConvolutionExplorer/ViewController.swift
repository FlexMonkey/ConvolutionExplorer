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
    let imageView = UIImageView()
    let kernelEditor = KernelEditor(kernel: [Int](count: 49, repeatedValue: 0))
    let valueSlider = UISlider()
    
    let toolbar = SLHGroup()
    let leftToolbar = SLVGroup()
    let leftToolbarButtonGroup = SLHGroup()
    
    let clearSelectionButton = ViewController.borderedButton("Clear Selection")
    let selectAllButton = ViewController.borderedButton("Select All")
    let invertSelectionButton = ViewController.borderedButton("Invert Selection")
    let zeroSelectionButton = ViewController.borderedButton("Zero Selection")
    
    let kernelSizeSegmentedControl = UISegmentedControl(items: [KernelSize.ThreeByThree.rawValue, KernelSize.FiveByFive.rawValue, KernelSize.SevenBySeven.rawValue])
    
    let image = UIImage(named: "image.jpg")
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        valueSlider.minimumValue = -20
        valueSlider.maximumValue = 20
        valueSlider.enabled = false
        
        kernelEditor.kernel[17] = -1
        kernelEditor.kernel[23] = -1
        kernelEditor.kernel[24] = 6
        kernelEditor.kernel[25] = -1
        kernelEditor.kernel[31] = -1
        
        kernelSizeSegmentedControl.selectedSegmentIndex = 0

        createLayout()
        createControlEvenHandlers()
        kernelSizeChange()
    }
    
    func createLayout()
    {
        workspace.children = [kernelEditor, imageView]
        
        leftToolbarButtonGroup.margin = 5
        leftToolbarButtonGroup.children = [clearSelectionButton, selectAllButton, invertSelectionButton, zeroSelectionButton]
        
        leftToolbar.children = [leftToolbarButtonGroup, valueSlider]
        toolbar.children = [leftToolbar, kernelSizeSegmentedControl]
        toolbar.explicitSize = 80
        
        mainGroup.children = [workspace, toolbar]
        
        view.addSubview(mainGroup)
    }
    
    func createControlEvenHandlers()
    {
        valueSlider.addTarget(self, action: "sliderChange", forControlEvents: UIControlEvents.ValueChanged)
        
        kernelSizeSegmentedControl.addTarget(self, action: "kernelSizeChange", forControlEvents: UIControlEvents.ValueChanged)
        kernelEditor.addTarget(self, action: "selectionChanged", forControlEvents: UIControlEvents.ValueChanged)
        
        clearSelectionButton.addTarget(self, action: "clearSelection", forControlEvents: UIControlEvents.TouchDown)
        selectAllButton.addTarget(self, action: "selectAll", forControlEvents: UIControlEvents.TouchDown)
        invertSelectionButton.addTarget(self, action: "invertSelection", forControlEvents: UIControlEvents.TouchDown)
        zeroSelectionButton.addTarget(self, action: "setSelectedToZero", forControlEvents: UIControlEvents.TouchDown)
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
        let newValue = Int(valueSlider.value)
        
        kernelEditor.selectedCellIndexes.map({ self.kernelEditor.kernel[$0] = newValue })
        
        applyKernel()
    }
    
    func setSelectedToZero()
    {
        kernelEditor.selectedCellIndexes.map({ self.kernelEditor.kernel[$0] = 0 })
        
        selectionChanged()
        applyKernel()
    }
    
    func clearSelection()
    {
        kernelEditor.cells.map({ $0.selected = false })
        selectionChanged()
    }
    
    func selectAll()
    {
        kernelEditor.cells.map({ $0.selected = true })
        selectionChanged()
    }
    
    func invertSelection()
    {
        kernelEditor.cells.map({ $0.selected = !$0.selected })
        selectionChanged()
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
        
        mainGroup.frame = CGRect(x: 0, y: top, width: view.frame.width, height: view.frame.height - top - bottom).rectByInsetting(dx: 5, dy: 5)
    }
    
    override func supportedInterfaceOrientations() -> Int
    {
        return Int(UIInterfaceOrientationMask.Landscape.rawValue)
    }

    class func borderedButton(text: String) -> SLButton
    {
        let button = SLButton()
        button.setTitle(text, forState: UIControlState.Normal)
        
        button.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        button.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Highlighted)
        
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor.blueColor().CGColor
        button.layer.borderWidth = 1
        
        return button
    }
    
}


