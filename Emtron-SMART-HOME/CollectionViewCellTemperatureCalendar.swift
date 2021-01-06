//
//  CollectionViewCellTemperatureCalendar.swift
//  Emtron-SMART-HOME
//
//  Created by Ivo Dvorak on 11/11/2019.
//  Copyright © 2019 Ivo Dvorak. All rights reserved.
//

import UIKit

class CollectionViewCellTemperatureCalendar: UICollectionViewCell {
    
    @IBOutlet weak var ouletView: UIView!
    
    @IBOutlet weak var labelPozadovanaTeplota: UILabel!
    @IBOutlet weak var labelPlusko: UILabel!
    @IBOutlet weak var labelCas: UILabel!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        print("Touch began")
        UIView.animate(withDuration: 0.15, animations:  {
                        self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
        //animate(isHighlighted: true)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        print("Touch cancel")
        UIView.animate(withDuration: 0.3, animations:  {
            self.transform = .identity
        })
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        print("Touch end")
        UIView.animate(withDuration: 0.3, animations:  {
            self.transform = .identity
        })
    }
    
    }

   
