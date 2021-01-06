//
//  CollectionViewCell.swift
//  UICollectionView
//
//  Created by Ivo Dvorak on 22/10/2019.
//  Copyright © 2019 Ivo Dvorak. All rights reserved.
//

import UIKit
var animaceHotova = true
class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var UIViewOutlet: UIView!
    @IBOutlet weak var UIImageOutlet: UIImageView!
    
    @IBOutlet weak var labelNastavenaTeplota: UILabel!
    @IBOutlet weak var ImageFWupgradeAvailabel: UIImageView!
    @IBOutlet weak var imageRezimKalendare: UIImageView!
    @IBOutlet weak var labelNazev: UILabel!
   
    @IBOutlet weak var imageProBezdratTerm: UIImageView!
    
    @IBOutlet weak var labelNazevStred: UILabel!
    
    @IBOutlet weak var labelUmisteniStred: UILabel!
    
    
    @IBOutlet weak var outletImageTimer: UIImageView!
    
    //MARK:- Events
    
    @IBOutlet weak var outletSaktualniTeplotou: UILabel!
    @IBOutlet weak var labelPlusko: UILabel!
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        print("Touch began CollectionViewCell")
        animaceHotova=false
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear, animations:   {//0.19
                        self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        },completion :{ finished in
            
                print("zavolan reloadCollectionView")
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("reloadCollectionView"), object: nil)
            animaceHotova=true
                
            
        })
        
        //animate(isHighlighted: true)
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        print("Touch cancel CollectionViewCell")
        animaceHotova=false
        UIView.animate(withDuration: 0, animations:  {
            self.transform = .identity
        },completion :{ finished in
          animaceHotova=true
            
        })
        
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        print("Touch end CollectionViewCell")
        /*
        animaceHotova=false
        UIView.animate(withDuration: 0.2, animations:  {
            self.transform = .identity
        },completion :{ finished in
          animaceHotova=true
            
        })*/
        //while(animaceHotova==false){}
        UIView.animate(withDuration: 0.25, delay: 0.2, options: .curveLinear, animations:   {//0.19
            self.transform = .identity
        },completion :
            { finished in
              print("Touch UP")
            })
    }

   /*

    //MARK:- Private functions
    private func animate(isHighlighted: Bool, completion: ((Bool) -> Void)?=nil) {
        let animationOptions: UIView.AnimationOptions = [.curveEaseInOut]
        if isHighlighted {
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 0,
                           options: animationOptions, animations: {
                            self.transform = .init(scaleX: 0.9, y: 0.9)
            }, completion: completion)
        } else {
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 0,
                           options: animationOptions, animations: {
                            self.transform = .identity
            }, completion: completion)
        }
    }*/
}
