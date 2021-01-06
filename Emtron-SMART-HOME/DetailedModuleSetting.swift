//
//  DetailedModuleSetting.swift
//  Emtron-SMART-HOME
//
//  Created by Ivo Dvorak on 10/09/2020.
//  Copyright © 2020 Ivo Dvorak. All rights reserved.
//



import Foundation

import UIKit


class DetailedModuleSetting: UIViewController {
    
    @IBOutlet weak var labelMacAdress: UILabel!
    @IBOutlet weak var labelIPadress: UILabel!
    @IBOutlet weak var labelSSID: UILabel!
    @IBOutlet weak var labelFWversion: UILabel!
    @IBOutlet weak var labelPairKey: UILabel!
    @IBOutlet weak var labelHomekitPaired: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var QRCodeImage: UIImageView!
    
    @IBOutlet weak var outletSelectedColour: UIView!
    @IBOutlet weak var outletSelectedCollurBTN: UIButton!
    
    @IBOutlet weak var outletHomekitView: UIView!
    @IBOutlet weak var outletRemoveButton: UIButton!
    
    @IBOutlet weak var outlewtViewsQR: UIView!
    @IBOutlet weak var outletNetworkInformations: UIView!
    @IBOutlet weak var outletTemperatureRange: UIView!
    @IBOutlet weak var outletFWversion: UIView!
    
    @IBOutlet weak var outletMinT1: UITextField!
    @IBOutlet weak var outletMaxT1: UITextField!
    
    @IBOutlet weak var outletMinT2: UITextField!
    @IBOutlet weak var outletMaxT2: UITextField!
    
    
    @IBOutlet weak var ShareButtonOutlet: UIButton!
    
    
    
    @IBAction func MinTemp1EditEnd(_ sender: Any) {
        outletMinT1.text=outletMinT1.text?.replacingOccurrences(of: ",", with: ".")
        seznamMinimalnichTeplot[indexVybranehoZarizeni*2]=outletMinT1.text ?? "0"
        UserDefaults.standard.setValue(seznamMinimalnichTeplot, forKey: "seznamMinimalnichTeplot")
        print("MinTemp1EditEnd")
    }
    
    @IBAction func MaxTemp1EditEnd(_ sender: Any) {
        outletMaxT1.text=outletMaxT1.text?.replacingOccurrences(of: ",", with: ".")
        seznamMaximalnichTeplot[indexVybranehoZarizeni*2]=outletMaxT1.text ?? "40"
        UserDefaults.standard.setValue(seznamMaximalnichTeplot, forKey: "seznamMaximalnichTeplot")
        print("MaxTemp1EditEnd")
    }
    
    @IBAction func MinTemp2EditEnd(_ sender: Any) {
        outletMinT2.text=outletMinT2.text?.replacingOccurrences(of: ",", with: ".")
        seznamMinimalnichTeplot[indexVybranehoZarizeni*2+1]=outletMinT2.text ?? "0"
        UserDefaults.standard.setValue(seznamMinimalnichTeplot, forKey: "seznamMinimalnichTeplot")
        print("MinTemp2EditEnd")
    }
    
    @IBAction func MaxTemp2EditEnd(_ sender: Any) {
        outletMaxT2.text=outletMaxT2.text?.replacingOccurrences(of: ",", with: ".")
        seznamMaximalnichTeplot[indexVybranehoZarizeni*2+1]=outletMaxT2.text ?? "40" 
        UserDefaults.standard.setValue(seznamMaximalnichTeplot, forKey: "seznamMaximalnichTeplot")
        print("MaxTemp2EditEnd")
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
       // print("dismissKeyboard")
        view.endEditing(true)
    }
    
    
    @IBAction func btnRemoveClick(_ sender: Any) {
    
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        let message  = "Opravdu chcete vybrané zařízení odstranit?"
        var messageMutableString = NSMutableAttributedString()
        messageMutableString = NSMutableAttributedString(string: message as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Aller", size: 18.0)!])
        messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 60/255, green: 60/255, blue: 60/255, alpha: 1), range:NSRange(location:0,length:message.count))
        alertController.setValue(messageMutableString, forKey: "attributedMessage")
        
        
        let backAction = UIAlertAction(title: "BACK", style: .default) { (action) in
            if DEBUGMSG{
                print("Alert Click BACK")
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
            }
            
        }
        
        
        let deleteAction = UIAlertAction(title: "DELETE", style: .default) { (action) in
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            print("Alert Click DELETE")
           
            seznamMACZarizeni.remove(at: indexVybranehoZarizeni*2)//smaze z pole a pole se rovnou zkrati
            seznamMACZarizeni.remove(at: 2*indexVybranehoZarizeni)//takze bude zase mazat na puvodnim miste jen uz jinou hodnotu
            seznamNazvuZarizeni.remove(at: 2*indexVybranehoZarizeni)
            seznamNazvuZarizeni.remove(at: 2*indexVybranehoZarizeni)
            seznamIPZarizeni.remove(at: 2*indexVybranehoZarizeni)
            seznamIPZarizeni.remove(at: 2*indexVybranehoZarizeni)
            seznamOnlineZarizeni.remove(at: 2*indexVybranehoZarizeni)
            seznamOnlineZarizeni.remove(at: 2*indexVybranehoZarizeni)
            seznamUmisteniZarizeni.remove(at: 2*indexVybranehoZarizeni)
            seznamUmisteniZarizeni.remove(at: 2*indexVybranehoZarizeni)
            seznamObrazkuZarizeni.remove(at: 2*indexVybranehoZarizeni)
            seznamObrazkuZarizeni.remove(at: 2*indexVybranehoZarizeni)
            poradoveCisloRele.remove(at: 2*indexVybranehoZarizeni)
            poradoveCisloRele.remove(at: 2*indexVybranehoZarizeni)
            seznamMerenychTeplot.remove(at: 2*indexVybranehoZarizeni)
            seznamMerenychTeplot.remove(at: 2*indexVybranehoZarizeni)
            seznamPozadovanychTeplot.remove(at: 2*indexVybranehoZarizeni)
            seznamPozadovanychTeplot.remove(at: 2*indexVybranehoZarizeni)
            seznamProvoznichRezimu.remove(at: 2*indexVybranehoZarizeni)
            seznamProvoznichRezimu.remove(at: 2*indexVybranehoZarizeni)
            seznamZarizeniDleIpAdres.remove(at: indexVybranehoZarizeni)
            seznamVerziFirmwaru.remove(at: 2*indexVybranehoZarizeni)
            seznamVerziFirmwaru.remove(at: 2*indexVybranehoZarizeni)
            seznamCasuVmodulech.remove(at: 2*indexVybranehoZarizeni)
            seznamCasuVmodulech.remove(at: 2*indexVybranehoZarizeni)
            seznamDostupnychAktualizaciVmodulech.remove(at: 2*indexVybranehoZarizeni)
            seznamDostupnychAktualizaciVmodulech.remove(at: 2*indexVybranehoZarizeni)
            seznamZparovanychZarizeni.remove(at: 2*indexVybranehoZarizeni)
            seznamZparovanychZarizeni.remove(at: 2*indexVybranehoZarizeni)
            seznamPripojenychTeplomeru.remove(at: 2*indexVybranehoZarizeni)
            seznamPripojenychTeplomeru.remove(at: 2*indexVybranehoZarizeni)
            seznamKoduHomekitu.remove(at: 2*indexVybranehoZarizeni)
            seznamKoduHomekitu.remove(at: 2*indexVybranehoZarizeni)
            seznamMinimalnichTeplot.remove(at: 2*indexVybranehoZarizeni)
            seznamMinimalnichTeplot.remove(at: 2*indexVybranehoZarizeni)
            seznamMaximalnichTeplot.remove(at: 2*indexVybranehoZarizeni)
            seznamMaximalnichTeplot.remove(at: 2*indexVybranehoZarizeni)
            seznamRSSI.remove(at: 2*indexVybranehoZarizeni)
            seznamRSSI.remove(at: 2*indexVybranehoZarizeni)
            seznamQRkodu.remove(at: 2*indexVybranehoZarizeni)
            seznamQRkodu.remove(at: 2*indexVybranehoZarizeni)
            seznamZparovanychShomekitem.remove(at: 2*indexVybranehoZarizeni)
            seznamZparovanychShomekitem.remove(at: 2*indexVybranehoZarizeni)
            seznamSSID.remove(at: 2*indexVybranehoZarizeni)
            seznamSSID.remove(at: 2*indexVybranehoZarizeni)
            seznamBarevModulu.remove(at: 2*indexVybranehoZarizeni)
            seznamBarevModulu.remove(at: 2*indexVybranehoZarizeni)
            seznamTopicu.remove(at: indexVybranehoZarizeni)
            
            UserDefaults.standard.setValue(seznamMACZarizeni, forKey: "seznamMACZarizeni")
            UserDefaults.standard.setValue(seznamNazvuZarizeni, forKey: "seznamNazvuZarizeni")
            UserDefaults.standard.setValue(seznamOnlineZarizeni, forKey: "seznamOnlineZarizeni")
            UserDefaults.standard.setValue(seznamIPZarizeni, forKey: "seznamIPZarizeni")
            UserDefaults.standard.setValue(seznamUmisteniZarizeni, forKey: "seznamUmisteniZarizeni")
            UserDefaults.standard.setValue(seznamObrazkuZarizeni, forKey: "seznamObrazkuZarizeni")
            UserDefaults.standard.setValue(poradoveCisloRele, forKey: "poradoveCisloRele")
            UserDefaults.standard.setValue(seznamMerenychTeplot, forKey: "seznamMerenychTeplot")
            UserDefaults.standard.setValue(seznamPozadovanychTeplot, forKey: "seznamPozadovanychTeplot")
            UserDefaults.standard.setValue(seznamProvoznichRezimu, forKey: "seznamProvoznichRezimu")
            
            self.performSegue(withIdentifier: "SegueBackToDeviceLIst", sender: Any?.self)
            
        }
        
        alertController.addAction(backAction)
        //alertController.addAction(editAction)
        alertController.addAction(deleteAction)
        
        alertController.view.tintColor = UIColor.init(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        //alertController.view.backgroundColor = UIColor.black
        alertController.view.layer.cornerRadius = 40
        
        self.present(alertController, animated: true, completion: nil)
        
    
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    //--------------------------------------------------------
    // MARK: parsujData --------------------------------
    //--------------------------------------------------------
    public func parsujData(prvniZnak:Character,druhyZnak:Character) -> String
    {
        if dataKeZpracovani.contains(prvniZnak)&&dataKeZpracovani.contains(druhyZnak){
            let startIndex = dataKeZpracovani.index(after:dataKeZpracovani.firstIndex(of: prvniZnak)!)
            let endIndex = dataKeZpracovani.firstIndex(of: druhyZnak)!
            let range = startIndex..<endIndex
            return(String(dataKeZpracovani[range]))//pokud najde platna data tak je vrati
        }
        else {
            return("      ")//pokud to slovo je nejaky spatny tak vraci prazdny retezec aby to nikdy nebylo NILL
        }
    }
    
    override func viewDidLoad() {
    super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        dataKeZpracovani=seznamMACZarizeni[indexVybranehoZarizeni*2]
        labelMacAdress.text=parsujData(prvniZnak: "{", druhyZnak: "}")
        labelIPadress.text=seznamIPZarizeni[indexVybranehoZarizeni*2]
        labelTime.text=seznamCasuVmodulech[indexVybranehoZarizeni*2]
        labelFWversion.text=seznamVerziFirmwaru[indexVybranehoZarizeni*2]
        
        
        if seznamZparovanychShomekitem[indexVybranehoZarizeni*2] == "1" {
            labelHomekitPaired.text = "Device is connect to HomeKit"
            labelHomekitPaired.layer.borderWidth = 2
            labelHomekitPaired.layer.borderColor = UIColor.green.cgColor
        }
        else{
        
            labelHomekitPaired.text = "Device is not connect to HomeKit"
            labelHomekitPaired.layer.borderWidth = 2
            labelHomekitPaired.layer.borderColor = UIColor.red.cgColor
        }
        ShareButtonOutlet.layer.cornerRadius=15
        labelHomekitPaired.layer.cornerRadius=15
        labelSSID.text = "\(seznamSSID[indexVybranehoZarizeni*2]) \(seznamRSSI[indexVybranehoZarizeni*2]) dBm"
        labelPairKey.text = seznamKoduHomekitu[indexVybranehoZarizeni*2]
        QRCodeImage.image = generateQRCode(from: seznamQRkodu[indexVybranehoZarizeni*2])
        outletNetworkInformations.layer.cornerRadius=20
        outletTemperatureRange.layer.cornerRadius=20
        outletFWversion.layer.cornerRadius=20
        outletSelectedColour.layer.cornerRadius=20
        outletSelectedCollurBTN.layer.cornerRadius=10
        outletMinT1.text=seznamMinimalnichTeplot[indexVybranehoZarizeni*2] //?? "0"
        outletMinT2.text=seznamMinimalnichTeplot[indexVybranehoZarizeni*2+1]
        outletMaxT1.text=seznamMaximalnichTeplot[indexVybranehoZarizeni*2]
        outletMaxT2.text=seznamMaximalnichTeplot[indexVybranehoZarizeni*2+1]
        outletSelectedCollurBTN.backgroundColor=seznamBarevModulu[indexVybranehoZarizeni*2]
        //outletSelectedCollurBTN.backgroundColor=seznamBarevModulu[indexVybranehoZarizeni*2+1]
        //outletSelectedCollurBTN.layer.borderColor = .white
        outletSelectedCollurBTN.layer.borderWidth = 2
        outletSelectedCollurBTN.layer.borderColor = UIColor.white.cgColor
        outletRemoveButton.layer.cornerRadius=8
        outletHomekitView.layer.cornerRadius=15
        outlewtViewsQR.layer.cornerRadius=10
        //QRCodeImage.layer.cornerRadius=
        //outletSelectedCollurBTN.
        //label
        //UIColor.init(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }

    //let image = generateQRCode(from: "Hacking with Swift is the best iOS coding tutorial I've ever read!")
    
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

