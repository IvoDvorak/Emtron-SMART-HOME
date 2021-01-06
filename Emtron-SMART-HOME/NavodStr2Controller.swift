//
//  Navod1Controller.swift
//  Control center
//
//  Created by Ivo Dvorak on 12/07/2019.
//  Copyright © 2019 Ivo Dvorak. All rights reserved.
//


import Foundation

import UIKit


class NavodStr2Controller: UIViewController {
    
    
    @IBAction func btnNeClick(_ sender: Any) {
      let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)

        let message  = "Zkontrolujte, že je modul správně připojen a zopakujte jeho připojení"
        var messageMutableString = NSMutableAttributedString()
        messageMutableString = NSMutableAttributedString(string: message as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Aller", size: 18.0)!])
        messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 60/255, green: 60/255, blue: 60/255, alpha: 1), range:NSRange(location:0,length:message.count))
        alertController.setValue(messageMutableString, forKey: "attributedMessage")


        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            if DEBUGMSG{
            print("Alert Click OK")
            }
            self.performSegue(withIdentifier: "showNavodOne", sender: Any?.self)
        }

        
        alertController.addAction(okAction)

        
        alertController.view.tintColor = UIColor.init(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        
        //alertController.view.backgroundColor = UIColor.black
        alertController.view.layer.cornerRadius = 40

        present(alertController, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var labelNavod2: UILabel!
    
    
    @IBOutlet weak var imageOutletNavod1: UIImageView!
    //--------------------------------------------------------
    // MARK: viewDidLoad --------------------------------
    //--------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if volbaZarizeni=="termostat"{
            imageOutletNavod1.image=UIImage(named: "termostatBluetooth")
          labelNavod2.text="Sviti na displeji symbol bluetooth?"
            
        }
        if volbaZarizeni=="modul"{
            labelNavod2.text="Bliká na modulu modrá kontrolka?"
            imageOutletNavod1.image  = UIImage(named: "Asset 12")
            let timer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true, block: { timer in
             timer.tolerance = 0.1
                if self.imageOutletNavod1.image  == UIImage(named: "Asset 12"){
                    self.imageOutletNavod1.image  = UIImage(named: "Asset 13")
                }
                else{
                    self.imageOutletNavod1.image  = UIImage(named: "Asset 12")
                }
                
            })
        }
    }
    //--------------------------------------------------------
    // MARK: viewDidAppear --------------------------------
    //--------------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //--------------------------------------------------------
    // MARK: viewDidDisappear --------------------------------
    //--------------------------------------------------------
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        
    }
    
    
    
}

