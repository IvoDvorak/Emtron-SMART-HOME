//
//  NavodKpouzitiController.swift
//  Emtron-SMART-HOME
//
//  Created by Ivo Dvorak on 18.11.2020.
//  Copyright © 2020 Ivo Dvorak. All rights reserved.
//

import Foundation
import UIKit
import youtube_ios_player_helper

class NavodKpouzitiController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,YTPlayerViewDelegate {
    
    
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
               
               return seznamNavoduNaYoutube.count/2//tolik mam navodu
           }
           
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
               let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCellSeznamNavodu
        cell.playerView.delegate=self
        cell.playerView.layer.cornerRadius = 10
        cell.playerView.layer.masksToBounds = true
        cell.labelNavod.text=seznamNavoduNaYoutube[indexPath.item*2];
        cell.playerView.load(withVideoId: seznamNavoduNaYoutube[indexPath.item*2+1])//, playerVars:["playsinline": 1])
        cell.layer.cornerRadius=20
               return cell
           }
           
       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
              // indexVybranehoObrazku=indexPath.item
               
           
       }
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
                
               //let width  = (view.frame.width-60)/3//trojnasobek toho co je nastaveny jako mezera
                let width  = (collectionView.frame.width-25)/2//trojnasobek toho co je nastaveny jako mezera
                let height  = (collectionView.frame.height-5)/2
                return CGSize(width: width, height: height)
           }
    
}
