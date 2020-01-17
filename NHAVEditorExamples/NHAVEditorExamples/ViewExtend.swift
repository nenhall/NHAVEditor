//
//  ViewExtend.swift
//  NHAVEditorExamples
//
//  Created by nenhall on 2019/12/31.
//  Copyright © 2019 nenhall. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable
extension UIView {
    
   @IBInspectable var cornerRadius:CGFloat{
        get{
            return layer.cornerRadius
        }
        set{
            layer.cornerRadius = newValue
            layer.masksToBounds = (newValue > 0)
        }
    }
    
    @IBInspectable var borderWidth:CGFloat{
        get{
            return layer.borderWidth
        }
        set{
            layer.borderWidth = newValue
            layer.masksToBounds = (newValue > 0)
        }
    }
    
    @IBInspectable var borderColor:UIColor?{
        get{
            UIColor.clear
        }
        set{
            layer.borderColor = newValue?.cgColor
        }
    }
    
    //  设置边框阴影
    @IBInspectable var shadowColor: UIColor? {
        get{
            return UIColor.clear
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }

    //  设置边框阴影颜色
    @IBInspectable var shadowOffset: CGSize {
        get{
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    //  设置阴影透明度，取值 0 ~ 1.0
    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    //  设置阴影圆角
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius =  newValue
        }
    }
}
