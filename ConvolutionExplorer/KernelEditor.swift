//
//  KernelEditor.swift
//  ConvolutionExplorer
//
//  Created by Simon Gladman on 18/05/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

import UIKit

class KernelEditor: UIControl
{
    let mainGroup = SLVGroup()
    let topSpacer = SLSpacer(percentageSize: nil, explicitSize: nil)
    let bottomSpacer = SLSpacer(percentageSize: nil, explicitSize: nil)
    
    var cells = [KernelEditorCell]()
    
    required init(kernel: [Int])
    {
        self.kernel = kernel
        
        super.init(frame: CGRectZero)

        mainGroup.children.append(topSpacer)
        mainGroup.margin = 7
        
        for i in 0 ... 6
        {
            let row = KernelEditorRow(rowNumber: i, kernelEditor: self)
            mainGroup.children.append(row)
        }
        
        mainGroup.children.append(topSpacer)
        
        addSubview(mainGroup)
        
        updateCellsFromKernel()
    }

    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    
    var kernel: [Int]
    {
        didSet
        {
            updateCellsFromKernel()
        }
    }
    
    func updateCellsFromKernel()
    {
        for (index: Int, value: (Int, KernelEditorCell)) in enumerate(zip(kernel, cells))
        {
            // println("row = \(Int(index / 7)) | column = \(index % 7)")
            value.1.text = "\(value.0)"
        }
    }
    
    var kernelSize: KernelSize = KernelSize.ThreeByThree
    {
        didSet
        {
            for cell in cells
            {
                switch kernelSize
                {
                case .ThreeByThree:
                    cell.enabled = cell.rowNumber >= 2 && cell.rowNumber <= 4 && cell.columnNumber >= 2 && cell.columnNumber <= 4
                case .FiveByFive:
                    cell.enabled = cell.rowNumber >= 1 && cell.rowNumber <= 5 && cell.columnNumber >= 1 && cell.columnNumber <= 5
                case .SevenBySeven:
                    cell.enabled = true
                }
            }
        }
    }
    
    var touchedCells = [KernelEditorCell]()
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        super.touchesBegan(touches, withEvent: event)
        touchedCells = [KernelEditorCell]()
        
        if let touch = touches.first as? UITouch
        {
            let obj = (hitTest(touch.locationInView(self), withEvent: event))
            
            if let obj = obj as? KernelEditorCell where obj.enabled
            {
                obj.selected = !obj.selected
                touchedCells.append(obj)
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        super.touchesMoved(touches, withEvent: event)
        
        if let touch = touches.first as? UITouch
        {
            let obj = (hitTest(touch.locationInView(self), withEvent: event))
            
            if let obj = obj as? KernelEditorCell where obj.enabled && find(touchedCells, obj) == nil
            {
                obj.selected = !obj.selected
                touchedCells.append(obj)
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        super.touchesEnded(touches, withEvent: event)
        
        sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
    
    var selectedCellIndexes: [Int]
    {
        return cells.filter({ $0.selected }).map({ $0.index })
    }
    
    override func layoutSubviews()
    {
        topSpacer.explicitSize = frame.width / 4
        bottomSpacer.explicitSize = frame.width / 4
        mainGroup.frame = frame
    }
}

// MARK: KernelEditorRow

class KernelEditorRow: SLHGroup
{
    var kernelEditor: KernelEditor
    
    required init(rowNumber: Int, kernelEditor: KernelEditor)
    {
        self.kernelEditor = kernelEditor
        
        super.init()
        
        margin = 7
        
        for i in 0 ... 6
        {
            let cell = KernelEditorCell(rowNumber: rowNumber, columnNumber: i, kernelEditor: kernelEditor)
            children.append(cell)
        }
    }
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    required init()
    {
        fatalError("init() has not been implemented")
    }
}

// MARK: KernelEditorCell

class KernelEditorCell: SLLabel
{
    var kernelEditor: KernelEditor
    var rowNumber: Int
    var columnNumber: Int
    
    required init(rowNumber: Int, columnNumber: Int, kernelEditor: KernelEditor)
    {
        self.kernelEditor = kernelEditor
        self.rowNumber = rowNumber
        self.columnNumber = columnNumber
        
        super.init(frame: CGRectZero)
     
        userInteractionEnabled = true
        
        textAlignment = NSTextAlignment.Center

        layer.backgroundColor = UIColor.lightGrayColor().CGColor
        layer.borderWidth = 1
        layer.cornerRadius = 3
        text = "\(rowNumber):\(columnNumber)"
        
        kernelEditor.cells.append(self)
    }
    
    var index: Int
    {
        return (rowNumber * 7) + columnNumber
    }
    
    var selected: Bool = false
    {
        didSet
        {
            layer.backgroundColor = selected ? UIColor.blueColor().CGColor : UIColor.lightGrayColor().CGColor
            textColor = selected ? UIColor.whiteColor() : UIColor.blackColor()
        }
    }
    
    override var enabled: Bool
    {
        didSet
        {
            alpha = enabled ? 1 : 0.5
        }
    }
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}

enum KernelSize: String
{
    case ThreeByThree = "3 x 3"
    case FiveByFive = "5 x 5"
    case SevenBySeven = "7 x 7"
}
