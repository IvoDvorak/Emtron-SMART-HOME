//
//  AppSetupController.swift
//  Emtron-SMART-HOME
//
//  Created by Ivo Dvorak on 17/11/2019.
//  Copyright © 2019 Ivo Dvorak. All rights reserved.
//

import Foundation
import UIKit

class AppSetupController:UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var collectionView: UICollectionView!
    //@IBOutlet weak var textFieldSnazvemDomacnosti: UITextField!
    
    /* @IBAction func texctNaTexFielduSnazvemSeZmenil(_ sender: UITextField) {
     nazevDomacnosti=textFieldSnazvemDomacnosti.text ?? "Emtron SmartHome"
     UserDefaults.standard.setValue(nazevDomacnosti, forKey: "nazevDomacnosti")
     print("zadal nazev domacnosti: \(nazevDomacnosti)")
     
     }
     */
    @IBOutlet weak var labelVerzeAplikace: UILabel!
    @IBAction func KonecEditaceMinimalniTeplota(_ sender: Any) {
        //minimalniTeplota=Int(minimalniTeplotaTextbox.text!) ?? 0
        var num = Float(minimalniTeplotaTextbox.text ?? "0");
        if num == nil{
            num = 20.0
            ZobrazAlertMessage(message: "Neplatne zadani")
        }
        else{
            minimalniTeplota=Int(minimalniTeplotaTextbox.text!) ?? 0
            
        }
        UserDefaults.standard.setValue(minimalniTeplota, forKey: "minimalniTeplota")
    }
    
    @IBAction func KonecEditaceMaximalniTeplota(_ sender: Any) {
        var num = Float(maximalniTeplotaTextBox.text ?? "0");
        if num == nil{
            num = 20.0
            ZobrazAlertMessage(message: "Neplatne zadani")
        }
        else{
            maximalniTeplota=Int(maximalniTeplotaTextBox.text!) ?? 0
            
        }
        UserDefaults.standard.setValue(maximalniTeplota, forKey: "maximalniTeplota")
    }
    
    func ZobrazAlertMessage(message:String)
    {
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        let message  = message
        var messageMutableString = NSMutableAttributedString()
        messageMutableString = NSMutableAttributedString(string: message as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Aller", size: 18.0)!])
        messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 61/255, green: 61/255, blue: 61/255, alpha: 1), range:NSRange(location:0,length:message.count))
        alertController.setValue(messageMutableString, forKey: "attributedMessage")
        
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            if DEBUGMSG{
                print("Alert Click OK")
            }
            //self.dismiss(animated: true, completion: nil)
        }
        
        
        alertController.addAction(okAction)
        
        
        alertController.view.tintColor = UIColor.init(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        //alertController.view.backgroundColor = UIColor.black
        alertController.view.layer.cornerRadius = 40
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    @IBOutlet weak var minimalniTeplotaTextbox: UITextField!
    
    @IBOutlet weak var maximalniTeplotaTextBox: UITextField!
    
    @IBAction func btnClearALL(_ sender: Any) {
        seznamMACZarizeni.removeAll()
        seznamOnlineZarizeni.removeAll()
        seznamNazvuZarizeni.removeAll()
        seznamIPZarizeni.removeAll()
        seznamUmisteniZarizeni.removeAll()
        seznamObrazkuZarizeni.removeAll()
        poradoveCisloRele.removeAll()
        kalendarTyden.removeAll()
        poleZobrazenychteplotnaTopeni.removeAll()
        seznamCasuVmodulech.removeAll()
        UserDefaults.standard.setValue(seznamMACZarizeni, forKey: "seznamMACZarizeni")
        UserDefaults.standard.setValue(seznamNazvuZarizeni, forKey: "seznamNazvuZarizeni")
        UserDefaults.standard.setValue(seznamOnlineZarizeni, forKey: "seznamOnlineZarizeni")
        UserDefaults.standard.setValue(seznamIPZarizeni, forKey: "seznamIPZarizeni")
        UserDefaults.standard.setValue(seznamUmisteniZarizeni, forKey: "seznamUmisteniZarizeni")
        UserDefaults.standard.setValue(seznamObrazkuZarizeni, forKey: "seznamObrazkuZarizeni")
        UserDefaults.standard.setValue(poradoveCisloRele, forKey: "poradoveCisloRele")
        UserDefaults.standard.setValue(" ", forKey: "JizByloSpusteno")
        print("clear all")
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WelcomeController")
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true, completion: nil)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        //setGradientBackground()
        super.viewWillAppear(animated)
        print("willAppear")
        hideKeyboardWhenTappedAround()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        seznamZarizeniDleIpAdres=seznamIPZarizeni.removingDuplicates()
        print("seznamIPadres:\(seznamZarizeniDleIpAdres)")
        print("mam zarizeni:\(seznamZarizeniDleIpAdres.count)")
        //let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        //view.addGestureRecognizer(recognizer)
        
        // minimalniTeplotaTextbox.text=("\(minimalniTeplota)")
        // maximalniTeplotaTextBox.text=("\(maximalniTeplota)")
        let version : String! = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build : String! = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        labelVerzeAplikace.text=("\(version ?? "0")(\(build ?? "0"))")
    }
    
    //--------------------------------------------------------
    // MARK: detekce dlouheho stisku tlacitka --------------------------------
    //--------------------------------------------------------
    @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){//detekce dlouheho stisku tlacitka
        
        if gestureRecognizer.state == UIGestureRecognizer.State.ended {
            return
        }
        else if gestureRecognizer.state == UIGestureRecognizer.State.began
        {
            
            
            let point = gestureRecognizer.location(in: collectionView)
            
            if let indexPath = collectionView.indexPathForItem(at: point),
                let cell = collectionView.cellForItem(at: indexPath) {
                // do stuff with your cell, for example print the indexPath
                if indexPath.item < seznamMACZarizeni.count {
                    
                    //UIView.animate(withDuration: 1){
                    //   cell.transform = CGAffineTransform(scaleX: 4, y: 4)
                    //
                    //}
                    
                    print("Long press:\(indexPath.row)")
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
                        /*  var seznamNazvuZarizeni = [String]()
                         var seznamMACZarizeni = [String]()
                         var seznamOnlineZarizeni = [String]()
                         var seznamIPZarizeni = [String]()
                         var seznamUmisteniZarizeni = [String]()
                         var seznamObrazkuZarizeni = [String]()
                         var poradoveCisloRele = [String]()
                         var seznamMerenychTeplot = [String]()
                         var seznamPozadovanychTeplot = [String]()
                         var seznamProvoznichRezimu = [String]()
                         var seznamZarizeniDleIpAdres = [String]()*/
                        //let index = indexPath.item
                        //print("indexPath.item:\(indexPath.item)")
                        seznamMACZarizeni.remove(at: 2*indexPath.item)//smaze z pole a pole se rovnou zkrati
                        seznamMACZarizeni.remove(at: 2*indexPath.item)//takze bude zase mazat na puvodnim miste jen uz jinou hodnotu
                        seznamNazvuZarizeni.remove(at: 2*indexPath.item)
                        seznamNazvuZarizeni.remove(at: 2*indexPath.item)
                        seznamIPZarizeni.remove(at: 2*indexPath.item)
                        seznamIPZarizeni.remove(at: 2*indexPath.item)
                        seznamOnlineZarizeni.remove(at: 2*indexPath.item)
                        seznamOnlineZarizeni.remove(at: 2*indexPath.item)
                        seznamUmisteniZarizeni.remove(at: 2*indexPath.item)
                        seznamUmisteniZarizeni.remove(at: 2*indexPath.item)
                        seznamObrazkuZarizeni.remove(at: 2*indexPath.item)
                        seznamObrazkuZarizeni.remove(at: 2*indexPath.item)
                        poradoveCisloRele.remove(at: 2*indexPath.item)
                        poradoveCisloRele.remove(at: 2*indexPath.item)
                        seznamMerenychTeplot.remove(at: 2*indexPath.item)
                        seznamMerenychTeplot.remove(at: 2*indexPath.item)
                        seznamPozadovanychTeplot.remove(at: 2*indexPath.item)
                        seznamPozadovanychTeplot.remove(at: 2*indexPath.item)
                        seznamProvoznichRezimu.remove(at: 2*indexPath.item)
                        seznamProvoznichRezimu.remove(at: 2*indexPath.item)
                        seznamZarizeniDleIpAdres.remove(at: indexPath.item)
                        seznamVerziFirmwaru.remove(at: 2*indexPath.item)
                        seznamVerziFirmwaru.remove(at: 2*indexPath.item)
                        seznamCasuVmodulech.remove(at: 2*indexPath.item)
                        seznamCasuVmodulech.remove(at: 2*indexPath.item)
                        seznamDostupnychAktualizaciVmodulech.remove(at: 2*indexPath.item)
                        seznamDostupnychAktualizaciVmodulech.remove(at: 2*indexPath.item)
                        seznamZparovanychZarizeni.remove(at: 2*indexPath.item)
                        seznamZparovanychZarizeni.remove(at: 2*indexPath.item)
                        seznamPripojenychTeplomeru.remove(at: 2*indexPath.item)
                        seznamPripojenychTeplomeru.remove(at: 2*indexPath.item)
                        //kalendarTyden.remove(at: 2*indexPath.item)
                        //kalendarTyden.remove(at: 2*indexPath.item)
                        //poleZobrazenychteplotnaTopeni.remove(at: 2*indexPath.item)
                        //poleZobrazenychteplotnaTopeni.remove(at: 2*indexPath.item)
                        //poleKalendaru.remove(at: 2*indexPath.item)
                        //poleKalendaru.remove(at: 2*indexPath.item)
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
                        //UserDefaults.standard.setValue(kalendarTyden, forKey: "kalendarTyden")
                        //UserDefaults.standard.setValue(poleZobrazenychteplotnaTopeni, forKey: "poleZobrazenychteplotnaTopeni")
                        //UserDefaults.standard.setValue(poleKalendaru, forKey: "poleKalendaru")
                        
                        self.collectionView.reloadData()
                        
                    }
                    
                    alertController.addAction(backAction)
                    //alertController.addAction(editAction)
                    alertController.addAction(deleteAction)
                    
                    alertController.view.tintColor = UIColor.init(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
                    //alertController.view.backgroundColor = UIColor.black
                    alertController.view.layer.cornerRadius = 40
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                }
                
            }
            else {
                print("Could not find index path")
            }
        }
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        return seznamZarizeniDleIpAdres.count//tolik mam zarizeni
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCellSeznamZarizeni
        
        print(indexPath.item)
        //cell.casZarizeni.text=seznamCasuVmodulech[2*indexPath.item]
        //cell.IPadressa.text=seznamZarizeniDleIpAdres[indexPath.item]
        cell.nazevZarizeni1.text=seznamNazvuZarizeni[2*indexPath.item]
        cell.umisteniZarizeni2.text=seznamUmisteniZarizeni[2*indexPath.item+1]
        cell.umisteniZarizeni1.text=seznamUmisteniZarizeni[2*indexPath.item]
        cell.nazevZarizeni2.text=seznamNazvuZarizeni[2*indexPath.item+1]
        cell.UIImageOutletZarizeni1.image=UIImage(named: seznamObrazkuZarizeni[2*indexPath.item])
        //potrebuju kdyz mam prvni index 0 tak to vzalo 01, kdyz je 1 tak 23, kdyz 2 tak 45,3 je 67,4 je 89
        cell.UIImageOutletZarizeni1.alpha=1
        cell.UIImageOutletZarizeni2.alpha=1
        cell.UIImageOutletZarizeni2.image=UIImage(named: seznamObrazkuZarizeni[(2*indexPath.item)+1])
        cell.contentView.layer.cornerRadius=15
        // cell.backgroundColor=seznamBarevModulu[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
        indexVybranehoZarizeni=indexPath.item//*2
        self.performSegue(withIdentifier: "SequeDetailedSettings", sender: Any?.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //let width  = (view.frame.width-60)/3//trojnasobek toho co je nastaveny jako mezera
        let width  = (view.frame.width-30)/2//trojnasobek toho co je nastaveny jako mezera 45
        return CGSize(width: width, height: width)
    }
    
    
    
}//konec controler

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
