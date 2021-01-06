//
//  SelectAddDeviceController.swift
//  Emtron-SMART-HOME
//
//  Created by Ivo Dvorak on 03/06/2020.
//  Copyright © 2020 Ivo Dvorak. All rights reserved.
//

import Foundation
import UIKit
var volbaZarizeni=""
class SelectAddDeviceController: UIViewController {
    
    @IBAction func ButtonTermostatClick(_ sender: UIButton) {
        if (seznamMACZarizeni.count==0){
            let alert = UIAlertController(title: "ERROR", message: "Pro spárování termostatu je nutné mít přidaný releový modul", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        else{
            volbaZarizeni="termostat"
            self.performSegue(withIdentifier: "connectionSegue", sender: Any?.self)
        }
    }
    
    @IBAction func ButtonModuleClick(_ sender: UIButton) {
        self.performSegue(withIdentifier: "connectionSegue", sender: Any?.self)
        volbaZarizeni="modul"
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        probehloDiscovery=false
        super.viewWillDisappear(animated)
    }
}
