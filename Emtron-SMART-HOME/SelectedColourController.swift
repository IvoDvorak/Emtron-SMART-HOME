//
//  SelectedColourController.swift
//  Emtron-SMART-HOME
//
//  Created by Ivo Dvorak on 14/09/2020.
//  Copyright © 2020 Ivo Dvorak. All rights reserved.
//




import Foundation

import UIKit


class SelectedColourController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
   
    
    override func viewDidLoad() {
    super.viewDidLoad()
        
        
    }
    
    
    //--------------------------------------------------------
    // MARK: viewDidAppear --------------------------------
    //--------------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        
        
    }
    
    
    //--------------------------------------------------------
    // MARK: viewDidDisappear --------------------------------
    //--------------------------------------------------------
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
               
               return Colours.count//tolik mam zarizeni
           }
           
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
               let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewColour
               cell.backgroundColor=Colours[indexPath.item]
               cell.layer.cornerRadius=20
               print(indexPath.item)
               return cell
           }
           
       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
               indexVybranehoObrazku=indexPath.item
               print("indexVybranehoObrazku:\(indexVybranehoObrazku)")
                seznamBarevModulu[indexVybranehoZarizeni*2]=Colours[indexVybranehoObrazku]
                seznamBarevModulu[indexVybranehoZarizeni*2+1]=Colours[indexVybranehoObrazku]
        
        //UserDefaults.standard.set(seznamBarevModulu, forKey: "seznamBarevModulu")
        //UserDefaults.set(objectToarch)
                self.performSegue(withIdentifier: "SegueDetailedModuleSettings", sender: Any?.self)
           
       }
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
                
               //let width  = (view.frame.width-60)/3//trojnasobek toho co je nastaveny jako mezera
               let width  = (view.frame.width-80)/3//trojnasobek toho co je nastaveny jako mezera
               return CGSize(width: width, height: width)
           }
    
}


