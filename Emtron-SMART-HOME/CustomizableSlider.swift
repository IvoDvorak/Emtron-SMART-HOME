  //
//  CustomizableSlider.swift
//  Emtron-SMART-HOME
//
//  Created by Ivo Dvorak on 31/10/2019.
//  Copyright © 2019 Ivo Dvorak. All rights reserved.
//

import UIKit
@IBDesignable
  
  
class CustomizableSlider: UISlider {

    @IBInspectable var thumbImage: UIImage? {
        didSet{
            setThumbImage(thumbImage, for: .normal)
            
        }
    }
    
    @IBInspectable var thumbHighlightedImage: UIImage? {
           didSet{
               setThumbImage(thumbHighlightedImage, for: .highlighted)
               
           }
       }
    
   
}
