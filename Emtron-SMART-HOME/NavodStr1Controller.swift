//
//  Navod1Controller.swift
//  Control center
//
//  Created by Ivo Dvorak on 12/07/2019.
//  Copyright © 2019 Ivo Dvorak. All rights reserved.
//


import Foundation

import UIKit


class NavodStr1Controller: UIViewController {
    
    @IBOutlet weak var imageOutletNavod1: UIImageView!
    @IBOutlet weak var labelNavod: UILabel!
    //--------------------------------------------------------
    // MARK: viewDidLoad --------------------------------
    //--------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        if volbaZarizeni=="termostat"{
            imageOutletNavod1.image=UIImage(named: "termostatZarizeni")
            labelNavod.text="Stiskněte na 2s a poté uvolněte tlačítko na zadní straně pro připojení modulu k bluetooth"
        }
        if volbaZarizeni=="modul"{
            imageOutletNavod1.image=UIImage(named: "Asset 10")
            labelNavod.text="Stiskněte 5x tlačítko pro připojení modulu k bluetooth"
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
    
    
    
}

