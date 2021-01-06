//
//  ViewController.swift
//  Control center
//
//  Created by Ivo Dvorak on 10/07/2019.
//  Copyright © 2019 Ivo Dvorak. All rights reserved.
//

import UIKit
import Foundation
import Socket
import AudioToolbox



var hostAdress = "127.0.0.1"
let port = 23
var ProvozniRezimRele1=""
var ProvozniRezimRele2=""
var teplota = "20.0"
var merenaTeplota = ""
var PozadovanaTeplota = ""
var indexKdeJeVpoliZarizeni=0
var nazevDomacnosti = "SmartHome"
var odeslanPrikazAktualizuj = false;
var ochranyInterval=false
var citacProOchranyInterval=0
//dodelat pole s teplomery
class DeviceListController: UIViewController,NetServiceBrowserDelegate,
NetServiceDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate {
    
    
    
    @IBOutlet weak var labelNazevDomacnosti: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var uiviewProNazevDomacnosti: UIView!
    var citacProDiscovery = 0
    //let Items = ["Svetlo obyvak","Ventilator","Topeni","Zarovka"]
    //var Images = ["zarovkaON","ventilatorON","radiatorON","zarovkaOFF"]
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        //setGradientBackground()
        super.viewWillAppear(animated)
        labelNazevDomacnosti.text=nazevDomacnosti
        print("willAppear")
        ActivityIndicator("  Connecting...")
    }
    
    
    
    //--------------------------------------------------------
    // MARK: viewDidLoad --------------------------------
    //--------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        print("device list controller DidLoad")
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        
        /**********TEST**********/
        //seznamObrazkuZarizeni[0]="radiatorON"
        //seznamObrazkuZarizeni[1]="ventilatorON"
        //seznamObrazkuZarizeni[2]="zarovkaON"
        //seznamObrazkuZarizeni[3]="Empty"
        /**********TEST**********/
        print("nacetl seznamy z pameti")
        browser = NetServiceBrowser()
        browser.delegate = self
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        recognizer.minimumPressDuration = 0.75
        view.addGestureRecognizer(recognizer)
        uiviewProNazevDomacnosti.layer.cornerRadius=20
        
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func appMovedToForeground() {
        print("App moved to ForeGround!")
        ochranyInterval=false
        citacProOchranyInterval=0
        if let url = URL(string: "http://77.242.91.210/Emtron/KS001003version.txt") {
            do {
                let contents = try String(contentsOf: url)
                print(contents)
                verzeFWnaServeru=contents.replacingOccurrences(of: "VERSION:", with: "")//orizne pouze verzi
                print("verzeFWnaServeru:\(verzeFWnaServeru)")
                
            } catch {
                verzeFWnaServeru=""
            }
        } else {
            verzeFWnaServeru=""
        }
        ActivityIndicator("")
        startDiscovery()
        removeActivityIndicator()
        //verzeFWnaServeru="2020011302"//jen testovani
    }
    
    @objc func appMovedToBackground() {
        print("App moved to Background!")
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
            
            citacProDiscovery=0//aby nebezelo discovery hned po kliknuti
            
            let point = gestureRecognizer.location(in: collectionView)
            
            if let indexPath = collectionView.indexPathForItem(at: point),
                let cell = collectionView.cellForItem(at: indexPath) {
                // do stuff with your cell, for example print the indexPath
                if indexPath.item < seznamMACZarizeni.count {
                    
                    //UIView.animate(withDuration: 1){
                    //   cell.transform = CGAffineTransform(scaleX: 4, y: 4)
                    //
                    //}
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                    print("Long press:\(indexPath.row)")
                    indexVybranehoZarizeni=indexPath.item
                    hostAdress=seznamIPZarizeni[indexVybranehoZarizeni]//nastavi IP adresu s kterou ma komunikovat
                    citacProOchranyInterval=0
                    if seznamVerziFirmwaru[indexVybranehoZarizeni]==verzeFWnaServeru || verzeFWnaServeru=="" || seznamOnlineZarizeni[indexVybranehoZarizeni]=="OFFline"{
                        
                        print("Firmware je aktualni")
                        //self.sendOverTCP(message: "AKTUALIZUJ")
                        if seznamObrazkuZarizeni[indexPath.row].contains("Prvni zarizeni") || seznamObrazkuZarizeni[indexPath.row].contains("Druhe zarizeni"){
                            self.performSegue(withIdentifier: "showFirtsDeviceSetup", sender: Any?.self)
                        }
                        
                        if seznamObrazkuZarizeni[indexPath.row].contains("zarovka")||seznamObrazkuZarizeni[indexPath.row].contains("ventilator"){
                            self.performSegue(withIdentifier: "showDeviceDetailZarovka", sender: Any?.self)
                        }
                        
                        if seznamObrazkuZarizeni[indexPath.row].contains("radiator"){
                            self.performSegue(withIdentifier: "showDeviceDetailTopeni", sender: Any?.self)
                        }
                    }
                    else {
                        
                        print("verzeFWnaServeru:\(verzeFWnaServeru)")
                        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
                        
                        let message  = "Je k dispozici aktualizace softwaru v modulu, přejete si ji nainstalovat nebo pokračovat?"
                        var messageMutableString = NSMutableAttributedString()
                        messageMutableString = NSMutableAttributedString(string: message as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Aller", size: 18.0)!])
                        messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 1), range:NSRange(location:0,length:message.count))
                        alertController.setValue(messageMutableString, forKey: "attributedMessage")
                        
                        
                        let AKTUALIZOVATAction = UIAlertAction(title: "Aktualizovat", style: .default) { (action) in
                            seznamOnlineZarizeni[indexPath.item]="OFFline"
                            print("Aktualizace firmware")
                            odeslanPrikazAktualizuj=true;
                            self.sendOverTCP(message: "AKTUALIZUJ")
                            self.collectionView.reloadData()
                            odeslanPrikazAktualizuj=false;
                              print("Aktualizace firmware relaod data")
                            //let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeviceListController")
                            //viewController.modalPresentationStyle = .fullScreen
                            //self.present(viewController, animated: true, completion: nil)
                        }
                        let POKRACOVATAction = UIAlertAction(title: "Pokračovat", style: .default) { (action) in
                            if DEBUGMSG{
                                print("Alert Click pokračovat")
                            }
                            //self.dismiss(animated: true, completion: nil)
                            
                            
                            if seznamObrazkuZarizeni[indexPath.row].contains("zarovka")||seznamObrazkuZarizeni[indexPath.row].contains("ventilator"){
                                self.performSegue(withIdentifier: "showDeviceDetailZarovka", sender: Any?.self)
                            }
                            
                            else if seznamObrazkuZarizeni[indexPath.row].contains("radiator"){
                                self.performSegue(withIdentifier: "showDeviceDetailTopeni", sender: Any?.self)
                            }
                            else {//if seznamObrazkuZarizeni[indexPath.row].contains("Prvni zarizeni") || seznamObrazkuZarizeni[indexPath.row].contains("Druhe zarizeni"){
                                self.performSegue(withIdentifier: "showFirtsDeviceSetup", sender: Any?.self)
                            }
                        }
                        
                        alertController.addAction(AKTUALIZOVATAction)
                        alertController.addAction(POKRACOVATAction)
                        
                        alertController.view.tintColor = UIColor.init(red: 255/255, green: 168/255, blue: 0, alpha: 1)
                        //alertController.view.backgroundColor = UIColor.black
                        alertController.view.layer.cornerRadius = 40
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                    
                    
                    
                    
                    
                    
                    
                } else {
                    print("Could not find index path")
                }
            }
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Mam v seznamu:\(seznamMACZarizeni.count) zarizeni")
        return seznamMACZarizeni.count+1//tolik mam zarizeni a jedno navic na plusko
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        if indexPath.item < seznamMACZarizeni.count{
            cell.myLabel.text = seznamUmisteniZarizeni[indexPath.item]
            cell.labelNazev.text = seznamNazvuZarizeni[indexPath.item]
            cell.labelNastavenaTeplota.layer.masksToBounds=true
            cell.labelNastavenaTeplota.layer.cornerRadius=5
            cell.labelNastavenaTeplota.alpha=0
            cell.outletSaktualniTeplotou.alpha=0
            indexKdeJeVpoliZarizeni=indexPath.item
           
            
            cell.UIImageOutlet.image=UIImage(named: seznamObrazkuZarizeni[indexPath.item])
            cell.UIImageOutlet.alpha=1
            cell.labelPlusko.alpha=0
            cell.imageRezimKalendare.image = UIImage(named: "Calendar")
            cell.labelNastavenaTeplota.alpha=0
            
            if seznamProvoznichRezimu.count>0{
                if (seznamProvoznichRezimu[indexKdeJeVpoliZarizeni] == "KALENDAR1"||seznamProvoznichRezimu[indexKdeJeVpoliZarizeni]=="KALENDAR2"||seznamProvoznichRezimu[indexKdeJeVpoliZarizeni]=="CASOVAC1"||seznamProvoznichRezimu[indexKdeJeVpoliZarizeni]=="CASOVAC2")&&seznamOnlineZarizeni[indexKdeJeVpoliZarizeni]=="ONline"{
                    cell.imageRezimKalendare.alpha=1
                }
                else if (seznamProvoznichRezimu[indexKdeJeVpoliZarizeni] == "TERMOSTAT1"||seznamProvoznichRezimu[indexKdeJeVpoliZarizeni]=="TERMOSTAT2")&&seznamOnlineZarizeni[indexKdeJeVpoliZarizeni]=="ONline"{
                    cell.imageRezimKalendare.image = UIImage(named: "teplomer")
                    cell.imageRezimKalendare.alpha=1
                }
                else{
                    cell.imageRezimKalendare.alpha=0
                }
            }
            if seznamMerenychTeplot[indexKdeJeVpoliZarizeni] != "-127.0"&&seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].contains("radiator")&&seznamOnlineZarizeni[indexKdeJeVpoliZarizeni]=="ONline"{
                cell.outletSaktualniTeplotou.text=("\(seznamMerenychTeplot[indexKdeJeVpoliZarizeni])°C")
                cell.outletSaktualniTeplotou.alpha=1
                
                
                //tady se jeste musi dodelat zobrazeni teploty aktualne nastavene v kalendari
            }//konec -127
            
            if (seznamProvoznichRezimu[indexKdeJeVpoliZarizeni] == "TERMOSTAT1"||seznamProvoznichRezimu[indexKdeJeVpoliZarizeni]=="TERMOSTAT2" || seznamProvoznichRezimu[indexKdeJeVpoliZarizeni]=="KALENDAR1"||seznamProvoznichRezimu[indexKdeJeVpoliZarizeni]=="KALENDAR2"){
                if seznamPozadovanychTeplot[indexKdeJeVpoliZarizeni].contains("°C"){//aby to nepridalo stupne celsia
                    cell.labelNastavenaTeplota.text=("\(seznamPozadovanychTeplot[indexKdeJeVpoliZarizeni])")
                }
                else{
                    cell.labelNastavenaTeplota.text=("\(seznamPozadovanychTeplot[indexKdeJeVpoliZarizeni])°C")
                }
                
                cell.labelNastavenaTeplota.alpha=0.8
                //print("vypisuji seznam pozadovanych teplot:\(seznamPozadovanychTeplot[indexKdeJeVpoliZarizeni])")
            }
            /*
            if (seznamProvoznichRezimu[indexKdeJeVpoliZarizeni]=="KALENDAR1"||seznamProvoznichRezimu[indexKdeJeVpoliZarizeni]=="KALENDAR2"){
                if poleZobrazenychteplotnaTopeni[indexKdeJeVpoliZarizeni].contains("°C"){//aby to nepridalo stupne celsia
                    cell.labelNastavenaTeplota.text=("\(poleZobrazenychteplotnaTopeni[indexKdeJeVpoliZarizeni])")
                }
                else{
                    cell.labelNastavenaTeplota.text=("\(poleZobrazenychteplotnaTopeni[indexKdeJeVpoliZarizeni])°C")
                }
                
                cell.labelNastavenaTeplota.alpha=1
                //print("vypisuji poleZobrazenychteplotnaTopeni teplot:\(poleZobrazenychteplotnaTopeni[indexKdeJeVpoliZarizeni])")
            }*/
            
            if seznamVerziFirmwaru[indexKdeJeVpoliZarizeni]==verzeFWnaServeru || verzeFWnaServeru=="" || seznamOnlineZarizeni[indexKdeJeVpoliZarizeni]=="OFFline"{
                cell.ImageFWupgradeAvailabel.alpha=0
                //print("verzeFWnaServeru:\(verzeFWnaServeru)")
                
            }
            else {
                cell.ImageFWupgradeAvailabel.alpha=1
                //print("verzeFWnaServeru:\(verzeFWnaServeru)")
            }
            
            if seznamOnlineZarizeni[indexKdeJeVpoliZarizeni]=="OFFline"{//zarizeni je offline musim namalovat jinou ikonu
                cell.labelNastavenaTeplota.alpha=0
                //print("zarizeni je offline")
                           if seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].contains("OFF"){
                               //print("obrazek obsahuje OFF")
                               let upravenyString = seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].replacingOccurrences(of: "OFF", with: "")
                               seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni]=upravenyString
                               seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni]="\(seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni])NoRespone"//nahradi stavajici obrazek za offline verzi
                           }
                           if seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].contains("ON"){
                               //print("obrazek obsahuje ON")
                               let upravenyString = seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].replacingOccurrences(of: "ON", with: "")
                               seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni]=upravenyString
                               seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni]="\(seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni])NoRespone"//nahradi stavajici obrazek za offline verzi
                           }
                           
                       }
            
        }
        else{
            cell.myLabel.text = ""
            cell.labelNazev.text = ""
            cell.UIImageOutlet.alpha=0
            cell.labelPlusko.alpha=1
            cell.imageRezimKalendare.alpha=0
            cell.outletSaktualniTeplotou.alpha=0
            cell.labelNastavenaTeplota.alpha=0
            cell.ImageFWupgradeAvailabel.alpha=0
        }
        //print("Maluju obrazek: \(seznamObrazkuZarizeni[indexPath.item]) na indexu: \(indexPath.item)")
        cell.UIViewOutlet.layer.cornerRadius = 20
        return cell
    }
    
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //print("vybrana bunka:\(indexPath.item)")
        
        citacProDiscovery=0//aby nebezelo discovery hned po kliknuti
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell
            else{return}
        if indexPath.item < seznamMACZarizeni.count{
            indexVybranehoZarizeni=indexPath.item
            hostAdress=seznamIPZarizeni[indexVybranehoZarizeni]//nastavi IP adresu s kterou ma komunikovat
            if seznamOnlineZarizeni[indexPath.item]=="ONline"{//aby to klikalo jen kdyz to je online
                //AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                citacProOchranyInterval=0
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: [],
                               animations: {
                                cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                                
                },
                               completion: { finished in
                                UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: .curveEaseInOut,
                                               animations: {
                                                cell.transform = CGAffineTransform(scaleX: 1, y: 1)
                                },
                                               completion: { (finished: Bool) in
                                                
                                                
                                                if (seznamProvoznichRezimu[indexVybranehoZarizeni] == "KALENDAR1"||seznamProvoznichRezimu[indexVybranehoZarizeni]=="KALENDAR2"||seznamProvoznichRezimu[indexVybranehoZarizeni]=="CASOVAC1"||seznamProvoznichRezimu[indexVybranehoZarizeni]=="CASOVAC2"){
                                                    let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
                                                    
                                                    let message  = "Zařízení je nastaveno dle rozvrhu kalendáře, opravdu si přejete kalendář deaktivovat a okmažitě změnit stav?"
                                                    var messageMutableString = NSMutableAttributedString()
                                                    messageMutableString = NSMutableAttributedString(string: message as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Aller", size: 18.0)!])
                                                    messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 1), range:NSRange(location:0,length:message.count))
                                                    alertController.setValue(messageMutableString, forKey: "attributedMessage")
                                                    
                                                    
                                                    let ANOAction = UIAlertAction(title: "ANO", style: .default) { (action) in
                                                        if DEBUGMSG{
                                                            print("Alert Click ANO")
                                                        }
                                                        if seznamObrazkuZarizeni[indexPath.item]=="zarovkaON"{
                                                            seznamObrazkuZarizeni[indexPath.item]="zarovkaOFF"
                                                            
                                                        }
                                                        else if seznamObrazkuZarizeni[indexPath.item]=="zarovkaOFF"{
                                                            seznamObrazkuZarizeni[indexPath.item]="zarovkaON"
                                                        }
                                                        
                                                        
                                                        
                                                        if seznamObrazkuZarizeni[indexPath.item]=="ventilatorON"{
                                                            seznamObrazkuZarizeni[indexPath.item]="ventilatorOFF"
                                                        }
                                                        else if seznamObrazkuZarizeni[indexPath.item]=="ventilatorOFF"{
                                                            seznamObrazkuZarizeni[indexPath.item]="ventilatorON"
                                                        }
                                                        
                                                        
                                                        if seznamObrazkuZarizeni[indexPath.item]=="radiatorON"{
                                                            seznamObrazkuZarizeni[indexPath.item]="radiatorOFF"
                                                        }
                                                        else if seznamObrazkuZarizeni[indexPath.item]=="radiatorOFF"{
                                                            seznamObrazkuZarizeni[indexPath.item]="radiatorON"
                                                        }
                                                        
                                                        if seznamObrazkuZarizeni[indexPath.item].contains("ON"){
                                                            self.sendOverTCP(message:"R\(poradoveCisloRele[indexVybranehoZarizeni])ON")//melo by to poslat R1ON nebo R2ON
                                                            print("switch R\(poradoveCisloRele[indexVybranehoZarizeni]) ON")
                                                        }
                                                        if seznamObrazkuZarizeni[indexPath.item].contains("OFF"){
                                                            self.sendOverTCP(message:"R\(poradoveCisloRele[indexVybranehoZarizeni])OFF")//melo by to poslat R1OFF nebo R2OFF
                                                            print("switch R\(poradoveCisloRele[indexVybranehoZarizeni]) OFF")
                                                        }
                                                        seznamProvoznichRezimu[indexVybranehoZarizeni]="RELE"
                                                        collectionView.reloadData()
                                                    }
                                                    
                                                    let NEAction = UIAlertAction(title: "NE", style: .default) { (action) in
                                                        if DEBUGMSG{
                                                            print("Alert Click NE")
                                                        }
                                                        //self.dismiss(animated: true, completion: nil)
                                                    }
                                                    
                                                    alertController.addAction(ANOAction)
                                                    alertController.addAction(NEAction)
                                                    
                                                    alertController.view.tintColor = UIColor.init(red: 255/255, green: 168/255, blue: 0, alpha: 1)
                                                    //alertController.view.backgroundColor = UIColor.black
                                                    alertController.view.layer.cornerRadius = 40
                                                    
                                                    self.present(alertController, animated: true, completion: nil)
                                                } else if (seznamProvoznichRezimu[indexVybranehoZarizeni] == "TERMOSTAT1"||seznamProvoznichRezimu[indexVybranehoZarizeni]=="TERMOSTAT2")
                                                {
                                                    let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
                                                    
                                                    let message  = "Zařízení udržuje nastavenou teplotu, opravdu si přejete termostat deaktivovat a okmažitě změnit stav?"
                                                    var messageMutableString = NSMutableAttributedString()
                                                    messageMutableString = NSMutableAttributedString(string: message as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Aller", size: 18.0)!])
                                                    messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 1), range:NSRange(location:0,length:message.count))
                                                    alertController.setValue(messageMutableString, forKey: "attributedMessage")
                                                    
                                                    
                                                    let ANOAction = UIAlertAction(title: "ANO", style: .default) { (action) in
                                                        if DEBUGMSG{
                                                            print("Alert Click ANO")
                                                        }
                                                        if seznamObrazkuZarizeni[indexPath.item]=="zarovkaON"{
                                                            seznamObrazkuZarizeni[indexPath.item]="zarovkaOFF"
                                                            
                                                        }
                                                        else if seznamObrazkuZarizeni[indexPath.item]=="zarovkaOFF"{
                                                            seznamObrazkuZarizeni[indexPath.item]="zarovkaON"
                                                        }
                                                        
                                                        
                                                        
                                                        if seznamObrazkuZarizeni[indexPath.item]=="ventilatorON"{
                                                            seznamObrazkuZarizeni[indexPath.item]="ventilatorOFF"
                                                        }
                                                        else if seznamObrazkuZarizeni[indexPath.item]=="ventilatorOFF"{
                                                            seznamObrazkuZarizeni[indexPath.item]="ventilatorON"
                                                        }
                                                        
                                                        
                                                        if seznamObrazkuZarizeni[indexPath.item]=="radiatorON"{
                                                            seznamObrazkuZarizeni[indexPath.item]="radiatorOFF"
                                                        }
                                                        else if seznamObrazkuZarizeni[indexPath.item]=="radiatorOFF"{
                                                            seznamObrazkuZarizeni[indexPath.item]="radiatorON"
                                                        }
                                                        
                                                        if seznamObrazkuZarizeni[indexPath.item].contains("ON"){
                                                            self.sendOverTCP(message:"R\(poradoveCisloRele[indexVybranehoZarizeni])ON")//melo by to poslat R1ON nebo R2ON
                                                            print("switch R\(poradoveCisloRele[indexVybranehoZarizeni]) ON")
                                                        }
                                                        if seznamObrazkuZarizeni[indexPath.item].contains("OFF"){
                                                            self.sendOverTCP(message:"R\(poradoveCisloRele[indexVybranehoZarizeni])OFF")//melo by to poslat R1OFF nebo R2OFF
                                                            print("switch R\(poradoveCisloRele[indexVybranehoZarizeni]) OFF")
                                                        }
                                                        seznamProvoznichRezimu[indexVybranehoZarizeni]="RELE"
                                                        collectionView.reloadData()
                                                    }
                                                    
                                                    let NEAction = UIAlertAction(title: "NE", style: .default) { (action) in
                                                        if DEBUGMSG{
                                                            print("Alert Click NE")
                                                        }
                                                        //self.dismiss(animated: true, completion: nil)
                                                    }
                                                    
                                                    alertController.addAction(ANOAction)
                                                    alertController.addAction(NEAction)
                                                    
                                                    alertController.view.tintColor = UIColor.init(red: 255/255, green: 168/255, blue: 0, alpha: 1)
                                                    //alertController.view.backgroundColor = UIColor.black
                                                    alertController.view.layer.cornerRadius = 40
                                                    
                                                    self.present(alertController, animated: true, completion: nil)
                                                }
                                                else{
                                                    
                                                    if seznamObrazkuZarizeni[indexPath.item]=="zarovkaON"{
                                                        seznamObrazkuZarizeni[indexPath.item]="zarovkaOFF"
                                                        
                                                    }
                                                    else if seznamObrazkuZarizeni[indexPath.item]=="zarovkaOFF"{
                                                        seznamObrazkuZarizeni[indexPath.item]="zarovkaON"
                                                    }
                                                    
                                                    
                                                    
                                                    if seznamObrazkuZarizeni[indexPath.item]=="ventilatorON"{
                                                        seznamObrazkuZarizeni[indexPath.item]="ventilatorOFF"
                                                    }
                                                    else if seznamObrazkuZarizeni[indexPath.item]=="ventilatorOFF"{
                                                        seznamObrazkuZarizeni[indexPath.item]="ventilatorON"
                                                    }
                                                    
                                                    
                                                    if seznamObrazkuZarizeni[indexPath.item]=="radiatorON"{
                                                        seznamObrazkuZarizeni[indexPath.item]="radiatorOFF"
                                                    }
                                                    else if seznamObrazkuZarizeni[indexPath.item]=="radiatorOFF"{
                                                        seznamObrazkuZarizeni[indexPath.item]="radiatorON"
                                                    }
                                                    
                                                    if seznamObrazkuZarizeni[indexPath.item].contains("ON"){
                                                        self.sendOverTCP(message:"R\(poradoveCisloRele[indexVybranehoZarizeni])ON")//melo by to poslat R1ON nebo R2ON
                                                        print("switch R\(poradoveCisloRele[indexVybranehoZarizeni]) ON")
                                                    }
                                                    if seznamObrazkuZarizeni[indexPath.item].contains("OFF"){
                                                        self.sendOverTCP(message:"R\(poradoveCisloRele[indexVybranehoZarizeni])OFF")//melo by to poslat R1OFF nebo R2OFF
                                                        print("switch R\(poradoveCisloRele[indexVybranehoZarizeni]) OFF")
                                                    }
                                                    //seznamProvoznichRezimu[indexVybranehoZarizeni]="RELE"
                                                }
                                                collectionView.reloadData()
                                                
                                                
                                })//konec druhe animace
                                
                }
                )//konec prvni animace
                
                
            }//konec if online
        }//konec if coiunt
        else{
            print("stisknul plusko")
            timer.invalidate()
            browser.stop()
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            self.performSegue(withIdentifier: "addDeviceSegue", sender: Any?.self)
        }
        
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //let width  = (view.frame.width-45)/2//trojnasobek toho co je nastaveny jako mezera
        
        //return CGSize(width: width, height: width)
        let width  = (view.frame.width-30)//-30
        let height  = (view.frame.height-45)/5
        return CGSize(width: width, height: height)
        
    }
    
    /*func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
     print("highlight")
     UIView.animate(withDuration: 0.5) {
     if let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell {
     cell.transform = .init(scaleX: 0.95, y: 0.95)
     //cell.contentView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
     }
     }
     }
     
     func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
     print("unhighlight")
     UIView.animate(withDuration: 0.5) {
     if let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell {
     cell.transform = .identity
     //cell.contentView.backgroundColor = .clear
     }
     }
     }
     */
    
    //--------------------------------------------------------
    // MARK: viewDidAppear --------------------------------
    //--------------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        
        //let kalendarTyden=[PondeliSpinaciCasyAteploty,UterySpinaciCasyAteploty,StredaSpinaciCasyAteploty,CtvrtekSpinaciCasyAteploty,PatekSpinaciCasyAteploty,SobotaSpinaciCasyAteploty,NedeleSpinaciCasyAteploty]//naplnim tyden aktualnimi casy
        //print("poleKalendaru\(poleKalendaru)")
        //print("PondeliSpinaciCasyAteploty\(PondeliSpinaciCasyAteploty)")
        //collectionView.reloadData()//tohle je novy
        
        //if spustenWelcomeController==true{
        
        startDiscovery()
            //calendar()
            //removeActivityIndicator()
            //spustenWelcomeController=false
        //}
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(funkcevykonanakazdouvterinu), userInfo: nil, repeats: true)
        timer.tolerance=0.4
        print("DidAppear")
    }
    
    
    
    @objc func funkcevykonanakazdouvterinu()
    {
        if (citacProDiscovery<5) {//bylo 5
            citacProDiscovery=citacProDiscovery+1
        }
        else{
            citacProDiscovery=0
            //print("Start discovery")
            if (ochranyInterval==false) {
                startDiscovery()
            }
            removeActivityIndicator()//aby to urcite po 5s zmizelo
            //calendar()
            
        }//konec else
        
        if ochranyInterval==true{
            if citacProOchranyInterval<4{
                citacProOchranyInterval=citacProOchranyInterval+1
                
            }
            else {
                ochranyInterval=false
                citacProOchranyInterval=0
            }
        }
    }
    
    
    func calendar(){
        let date = Date()
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        let weekday = Calendar.current.component(.weekday, from: date)
        DenVtydnu=trivialDayStringsORDINAL[weekday]
        print("Je \(DenVtydnu)")
        //musi se to rozdelit na dvoje topeni
        //var teplotaProZobrazeniNaTopeni1=""
        //var teplotaProZobrazeniNaTopeni2=""
        
        if DenVtydnu=="Pondeli"{
            for i in 0..<poleKalendaru.count {//tohle projde vsechny moduly
                //projde cele pole a naplni pole s teplotami
                //tohle vypise od kolika modulu ma informace o kalendari
                for t in 0..<poleKalendaru[i][0].count{//tohle projde teploty a cas u jendotlicych modulu
                    var cas = poleKalendaru[i][0][t][0]
                    let teplotaKalendar = poleKalendaru[i][0][t][1]
                    if cas.count>3{
                        cas.removeLast()
                        cas.removeLast()
                        cas.removeLast()
                        let hodiny=cas
                        cas = poleKalendaru[i][0][t][0]
                        cas.removeFirst()
                        cas.removeFirst()
                        cas.removeFirst()
                        let minuty=cas
                        print("cas z pole:\(hodiny):\(minuty)")
                        if (hour >= Int(hodiny)!) {//aktualni hodiny je vetsi nez cas na radku kalendare
                            if ((minute >= Int(minuty)!) || (hour>Int(hodiny)!)) {//aktualni minuty je vetsi nez cas na radku kalendare
                                poleZobrazenychteplotnaTopeni[i]=teplotaKalendar
                                
                                print("aktualni zvolena teplota dle kalendare je: \(teplotaKalendar) nastavena od \(hodiny):\(minuty) na modlu c:\(i)")
                            }
                        }
                    }
                    
                    //print("cas:\(cas)")
                    print("teplotaKalendar:\(teplotaKalendar)")
                }
                //if PondeliSpinaciCasyAteploty[i][0]<aktualnicas//cas
            }
            print("seznamPozadovanychTeplot na modulech v \(DenVtydnu): \(poleZobrazenychteplotnaTopeni)")
        }
        if DenVtydnu=="Utery"{
            for i in 0..<poleKalendaru.count {//tohle projde vsechny moduly
                //projde cele pole a naplni pole s teplotami
                //tohle vypise od kolika modulu ma informace o kalendari
                for t in 0..<poleKalendaru[i][1].count{//tohle projde teploty a cas u jendotlicych modulu
                    var cas = poleKalendaru[i][1][t][0]
                    let teplotaKalendar = poleKalendaru[i][1][t][1]
                    if cas.count>3{
                        cas.removeLast()
                        cas.removeLast()
                        cas.removeLast()
                        let hodiny=cas
                        cas = poleKalendaru[i][1][t][0]
                        cas.removeFirst()
                        cas.removeFirst()
                        cas.removeFirst()
                        let minuty=cas
                        print("cas z pole:\(hodiny):\(minuty)")
                        if (hour >= Int(hodiny)!) {//aktualni hodiny je vetsi nez cas na radku kalendare
                            if ((minute >= Int(minuty)!) || (hour>Int(hodiny)!)) {//aktualni minuty je vetsi nez cas na radku kalendare
                                poleZobrazenychteplotnaTopeni[i]=teplotaKalendar
                                
                                print("aktualni zvolena teplota dle kalendare je: \(teplotaKalendar) nastavena od \(hodiny):\(minuty) na modlu c:\(i)")
                            }
                        }
                    }
                    
                    //print("cas:\(cas)")
                    print("teplotaKalendar:\(teplotaKalendar)")
                }
                //if PondeliSpinaciCasyAteploty[i][0]<aktualnicas//cas
            }
            print("seznamPozadovanychTeplot na modulech v \(DenVtydnu): \(poleZobrazenychteplotnaTopeni)")
        }
        if DenVtydnu=="Streda"{
            for i in 0..<poleKalendaru.count {//tohle projde vsechny moduly
                //projde cele pole a naplni pole s teplotami
                //tohle vypise od kolika modulu ma informace o kalendari
                for t in 0..<poleKalendaru[i][2].count{//tohle projde teploty a cas u jendotlicych modulu
                    var cas = poleKalendaru[i][2][t][0]
                    let teplotaKalendar = poleKalendaru[i][2][t][1]
                    if cas.count>3{
                        cas.removeLast()
                        cas.removeLast()
                        cas.removeLast()
                        let hodiny=cas
                        cas = poleKalendaru[i][2][t][0]
                        cas.removeFirst()
                        cas.removeFirst()
                        cas.removeFirst()
                        let minuty=cas
                        print("cas z pole:\(hodiny):\(minuty)")
                        if (hour >= Int(hodiny)!) {//aktualni hodiny je vetsi nez cas na radku kalendare
                            if ((minute >= Int(minuty)!) || (hour>Int(hodiny)!)) {//aktualni minuty je vetsi nez cas na radku kalendare
                                poleZobrazenychteplotnaTopeni[i]=teplotaKalendar
                                
                                print("aktualni zvolena teplota dle kalendare je: \(teplotaKalendar) nastavena od \(hodiny):\(minuty) na modlu c:\(i)")
                            }
                        }
                    }
                    
                    //print("cas:\(cas)")
                    print("teplotaKalendar:\(teplotaKalendar)")
                }
                //if PondeliSpinaciCasyAteploty[i][0]<aktualnicas//cas
            }
            print("seznamPozadovanychTeplot na modulech v \(DenVtydnu): \(poleZobrazenychteplotnaTopeni)")
        }
        if DenVtydnu=="Ctvrtek"{
            for i in 0..<poleKalendaru.count {//tohle projde vsechny moduly
                //projde cele pole a naplni pole s teplotami
                //tohle vypise od kolika modulu ma informace o kalendari
                for t in 0..<poleKalendaru[i][3].count{//tohle projde teploty a cas u jendotlicych modulu
                    var cas = poleKalendaru[i][3][t][0]
                    let teplotaKalendar = poleKalendaru[i][3][t][1]
                    if cas.count>3{
                        cas.removeLast()
                        cas.removeLast()
                        cas.removeLast()
                        let hodiny=cas
                        cas = poleKalendaru[i][3][t][0]
                        cas.removeFirst()
                        cas.removeFirst()
                        cas.removeFirst()
                        let minuty=cas
                        print("cas z pole:\(hodiny):\(minuty)")
                        if (hour >= Int(hodiny)!) {//aktualni hodiny je vetsi nez cas na radku kalendare
                            if ((minute >= Int(minuty)!) || (hour>Int(hodiny)!)) {//aktualni minuty je vetsi nez cas na radku kalendare
                                poleZobrazenychteplotnaTopeni[i]=teplotaKalendar
                                
                                print("aktualni zvolena teplota dle kalendare je: \(teplotaKalendar) nastavena od \(hodiny):\(minuty) na modlu c:\(i)")
                            }
                        }
                    }
                    
                    //print("cas:\(cas)")
                    print("teplotaKalendar:\(teplotaKalendar)")
                }
                //if PondeliSpinaciCasyAteploty[i][0]<aktualnicas//cas
            }
            print("seznamPozadovanychTeplot na modulech v \(DenVtydnu): \(poleZobrazenychteplotnaTopeni)")
        }
        if DenVtydnu=="Patek"{//funkcni vycitani z pole
            
            for i in 0..<poleKalendaru.count {//tohle projde vsechny moduly
                //projde cele pole a naplni pole s teplotami
                //tohle vypise od kolika modulu ma informace o kalendari
                for t in 0..<poleKalendaru[i][4].count{//tohle projde teploty a cas u jendotlicych modulu
                    var cas = poleKalendaru[i][4][t][0]
                    let teplotaKalendar = poleKalendaru[i][4][t][1]
                    if cas.count>3{
                        cas.removeLast()
                        cas.removeLast()
                        cas.removeLast()
                        let hodiny=cas
                        cas = poleKalendaru[i][4][t][0]
                        cas.removeFirst()
                        cas.removeFirst()
                        cas.removeFirst()
                        let minuty=cas
                        print("cas z pole:\(hodiny):\(minuty)")
                        if (hour >= Int(hodiny)!) {//aktualni hodiny je vetsi nez cas na radku kalendare
                            if ((minute >= Int(minuty)!) || (hour>Int(hodiny)!)) {//aktualni minuty je vetsi nez cas na radku kalendare
                                poleZobrazenychteplotnaTopeni[i]=teplotaKalendar
                                
                                print("aktualni zvolena teplota dle kalendare je: \(teplotaKalendar) nastavena od \(hodiny):\(minuty) na modlu c:\(i)")
                            }
                        }
                    }
                    
                    //print("cas:\(cas)")
                    print("teplotaKalendar:\(teplotaKalendar)")
                }
                //if PondeliSpinaciCasyAteploty[i][0]<aktualnicas//cas
            }
            print("seznamPozadovanychTeplot na modulech v \(DenVtydnu): \(poleZobrazenychteplotnaTopeni)")
            
        }
        if DenVtydnu=="Sobota"{
            for i in 0..<poleKalendaru.count {//tohle projde vsechny moduly
                //projde cele pole a naplni pole s teplotami
                //tohle vypise od kolika modulu ma informace o kalendari
                for t in 0..<poleKalendaru[i][5].count{//tohle projde teploty a cas u jendotlicych modulu
                    var cas = poleKalendaru[i][5][t][0]
                    let teplotaKalendar = poleKalendaru[i][5][t][1]
                    if cas.count>3{
                        cas.removeLast()
                        cas.removeLast()
                        cas.removeLast()
                        let hodiny=cas
                        cas = poleKalendaru[i][5][t][0]
                        cas.removeFirst()
                        cas.removeFirst()
                        cas.removeFirst()
                        let minuty=cas
                        print("cas z pole:\(hodiny):\(minuty)")
                        if (hour >= Int(hodiny)!) {//aktualni hodiny je vetsi nez cas na radku kalendare
                            if ((minute >= Int(minuty)!) || (hour>Int(hodiny)!)) {//aktualni minuty je vetsi nez cas na radku kalendare
                                poleZobrazenychteplotnaTopeni[i]=teplotaKalendar
                                
                                print("aktualni zvolena teplota dle kalendare je: \(teplotaKalendar) nastavena od \(hodiny):\(minuty) na modlu c:\(i)")
                            }
                        }
                    }
                    
                    //print("cas:\(cas)")
                    print("teplotaKalendar:\(teplotaKalendar)")
                }
                //if PondeliSpinaciCasyAteploty[i][0]<aktualnicas//cas
            }
            print("seznamPozadovanychTeplot na modulech v \(DenVtydnu): \(poleZobrazenychteplotnaTopeni)")
        }
        if DenVtydnu=="Nedele"{
            for i in 0..<poleKalendaru.count {//tohle projde vsechny moduly
                //projde cele pole a naplni pole s teplotami
                //tohle vypise od kolika modulu ma informace o kalendari
                for t in 0..<poleKalendaru[i][6].count{//tohle projde teploty a cas u jendotlicych modulu
                    var cas = poleKalendaru[i][6][t][0]
                    let teplotaKalendar = poleKalendaru[i][6][t][1]
                    if cas.count>3{
                        cas.removeLast()
                        cas.removeLast()
                        cas.removeLast()
                        let hodiny=cas
                        cas = poleKalendaru[i][6][t][0]
                        cas.removeFirst()
                        cas.removeFirst()
                        cas.removeFirst()
                        let minuty=cas
                        print("cas z pole:\(hodiny):\(minuty)")
                        if (hour >= Int(hodiny)!) {//aktualni hodiny je vetsi nez cas na radku kalendare
                            if ((minute >= Int(minuty)!) || (hour>Int(hodiny)!)) {//aktualni minuty je vetsi nez cas na radku kalendare
                                poleZobrazenychteplotnaTopeni[i]=teplotaKalendar
                                
                                print("aktualni zvolena teplota dle kalendare je: \(teplotaKalendar) nastavena od \(hodiny):\(minuty) na modlu c:\(i)")
                            }
                        }
                    }
                    
                    //print("cas:\(cas)")
                    print("teplotaKalendar:\(teplotaKalendar)")
                }
                //if PondeliSpinaciCasyAteploty[i][0]<aktualnicas//cas
            }
            print("seznamPozadovanychTeplot na modulech v \(DenVtydnu): \(poleZobrazenychteplotnaTopeni)")
        }
    }
    //--------------------------------------------------------
    // MARK: searchServices --------------------------------
    //--------------------------------------------------------
    var services = [NetService]()
    // Local service browser
    var browser = NetServiceBrowser()
    
    // Instance of the service that we're looking for
    var service: NetService?
    
    
    
    
    private func startDiscovery() {
        // Make sure to reset the last known service if we want to run this a few times
        service = nil
        
        // Start the discovery
        browser.stop()
        browser.searchForServices(ofType: "_emtron-device-info._tcp", inDomain: "local.")//bylo ""
        service?.resolve(withTimeout:-1)
        print("startDiscovery")
    }
    
    // MARK: Service discovery
    
    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        print("Search about to begin")
    }
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {
        print("nic nenasel")
    }
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        print("Resolve error:", sender, errorDict)
        if sender.name.hasPrefix("EMTRON")
        {
            print("ubehnul timeout")
            if sender.name.contains("EMTRON-CZ-2-RELAYS-MODULE"){
                // pokud se modul neozve do timeoutu tak ho prohlasi za offline
                citacProDiscovery=0
                if seznamMACZarizeni.contains(sender.name)
                {
                    seznamOnlineZarizeni[seznamMACZarizeni.firstIndex(of: sender.name)!]="OFFline"
                    seznamOnlineZarizeni[seznamMACZarizeni.firstIndex(of: sender.name)!+1]="OFFline"
                    print("Nastavuji na OFFLINE\(sender.name)")
                    
                }
            }
            browser.stop()
            self.collectionView.reloadData()
        }
    }
    
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        print("Search stopped")
        removeActivityIndicator()
    }
    
    func netServiceBrowser(netServiceBrowser: NetServiceBrowser,
        didNotSearch errorInfo: [NSObject : AnyObject]) {
            print("nic nenasel")
        browser.stop()
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind svc: NetService, moreComing: Bool) {
        print("Discovered the service")
        print("- name:", svc.name)
        print("- type", svc.type)
        print("- domain:", svc.domain)
        self.services.append(svc)
        
        service = svc
        service?.delegate = self
        service?.resolve(withTimeout: -1)
        
        
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        print("Resolved service \(sender)")
        citacProDiscovery=0
        if sender.name.hasPrefix("EMTRON-CZ")
        {
            // Find the IPV4 address
            if let serviceIp = resolveIPv4(addresses: sender.addresses!) {
                print("Found \(sender.name) with IPV4:", serviceIp)
                if seznamMACZarizeni.contains(sender.name)
                {
                    
                    if sender.name.contains("EMTRON-CZ-2-RELAYS-MODULE"){
                        //pokud je modul se 2 rele musi aktualizovat IP adresu u obou
                        print("Nasel 2 RELAYS MODULE zarizeni")
                        indexKdeJeVpoliZarizeni = seznamMACZarizeni.firstIndex(of: sender.name)!
                        seznamOnlineZarizeni[indexKdeJeVpoliZarizeni]="ONline"
                        seznamIPZarizeni[indexKdeJeVpoliZarizeni]=serviceIp
                        seznamOnlineZarizeni[indexKdeJeVpoliZarizeni+1]="ONline"
                        seznamIPZarizeni[indexKdeJeVpoliZarizeni+1]=serviceIp
                        
                        if seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].contains("NoRespone"){
                            //print("obrazek obsahuje NoRespone")
                            let upravenyString = seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].replacingOccurrences(of: "NoRespone", with: "ON")
                            seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni]=upravenyString
                            
                        }
                        if seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni+1].contains("NoRespone"){
                            //print("obrazek obsahuje NoRespone")
                            let upravenyString = seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni+1].replacingOccurrences(of: "NoRespone", with: "ON")
                            seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni+1]=upravenyString
                            
                        }
                        
                        //print("aktualizuji IP adresu 2 zarizeni \(sender.name) na IP:\(serviceIp)")
                        
                        if let data = sender.txtRecordData() {
                            
                            
                            if data.count<100 {return}//ochrana kdyz to nenacte txt record data
                            //print(data)
                            let dict = NetService.dictionary(fromTXTRecord: data)
                            print("vytvoril dict z TXT")
                            
                            if dict.keys.contains("FWVERSION"){
                                seznamVerziFirmwaru[indexKdeJeVpoliZarizeni] = String(data: dict["FWVERSION"]!, encoding: String.Encoding.utf8)!
                                seznamVerziFirmwaru[indexKdeJeVpoliZarizeni+1] = String(data: dict["FWVERSION"]!, encoding: String.Encoding.utf8)!
                            }
                            
                            if dict.keys.contains("TEMPACT1"){
                                //var teplota1:Float = String(data: dict["TEMPACT1"]!, encoding: String.Encoding.utf8).
                                //teplota1
                                seznamMerenychTeplot[indexKdeJeVpoliZarizeni] = String(data: dict["TEMPACT1"]!, encoding: String.Encoding.utf8)!//pro prvni rele
                                seznamMerenychTeplot[indexKdeJeVpoliZarizeni+1] = String(data: dict["TEMPACT1"]!, encoding: String.Encoding.utf8)!
                            }
                            if dict.keys.contains("TEMPPOZ1"){
                                seznamPozadovanychTeplot[indexKdeJeVpoliZarizeni] = String(data: dict["TEMPPOZ1"]!, encoding: String.Encoding.utf8)!//tady se musi smazat posledni nula
                                seznamPozadovanychTeplot[indexKdeJeVpoliZarizeni]=String(seznamPozadovanychTeplot[indexKdeJeVpoliZarizeni].dropLast())
                            }
                            if dict.keys.contains("TEMPPOZ2"){
                                seznamPozadovanychTeplot[indexKdeJeVpoliZarizeni+1] = String(data: dict["TEMPPOZ2"]!, encoding: String.Encoding.utf8)!
                                seznamPozadovanychTeplot[indexKdeJeVpoliZarizeni+1] =  String(seznamPozadovanychTeplot[indexKdeJeVpoliZarizeni+1].dropLast())
                            }
                            if dict.keys.contains("LOCATION1"){
                                seznamUmisteniZarizeni[indexKdeJeVpoliZarizeni] = String(data: dict["LOCATION1"]!, encoding: String.Encoding.utf8)!
                            }
                            
                            if dict.keys.contains("LOCATION2"){
                                seznamUmisteniZarizeni[indexKdeJeVpoliZarizeni+1] = String(data: dict["LOCATION2"]!, encoding: String.Encoding.utf8)!
                            }
                            
                            if dict.keys.contains("NAME1"){
                                seznamNazvuZarizeni[indexKdeJeVpoliZarizeni] = String(data: dict["NAME1"]!, encoding: String.Encoding.utf8)!
                            }
                            
                            if dict.keys.contains("NAME2"){
                                seznamNazvuZarizeni[indexKdeJeVpoliZarizeni+1] = String(data: dict["NAME2"]!, encoding: String.Encoding.utf8)!
                            }
                            
                            
                            
                            if dict.keys.contains("RELAY1"){
                                seznamProvoznichRezimu[indexKdeJeVpoliZarizeni] = String(data: dict["RELAY1"]!, encoding: String.Encoding.utf8)!
                                print("ProvozniRezimRele1:\(seznamProvoznichRezimu[indexKdeJeVpoliZarizeni])")
                            }
                            if dict.keys.contains("RELAY2"){
                                seznamProvoznichRezimu[indexKdeJeVpoliZarizeni+1] = String(data: dict["RELAY2"]!, encoding: String.Encoding.utf8)!
                                print("ProvozniRezimRele2:\(seznamProvoznichRezimu[indexKdeJeVpoliZarizeni+1])")
                            }
                            
                            if (ochranyInterval==false){
                                if dict.keys.contains("RELAY1STATUS"){
                                    let rele1status = String(data: dict["RELAY1STATUS"]!, encoding: String.Encoding.utf8)!
                                    print("Text record (rele1status):", rele1status)
                                    if rele1status=="ON"{
                                        if seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].contains("OFF"){
                                            let upravenyString = seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].replacingOccurrences(of: "OFF", with: "ON")
                                            seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni]=upravenyString
                                        }
                                    }
                                    
                                    
                                    if rele1status=="OFF"{
                                        if seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].contains("ON"){
                                            let upravenyString = seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].replacingOccurrences(of: "ON", with: "OFF")
                                            seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni]=upravenyString
                                        }
                                        
                                    }
                                }
                                
                                if dict.keys.contains("RELAY2STATUS"){
                                    let rele2status = String(data: dict["RELAY2STATUS"]!, encoding: String.Encoding.utf8)!
                                    print("Text record (rele2status):", rele2status)
                                    indexKdeJeVpoliZarizeni=indexKdeJeVpoliZarizeni+1//aby to sahalo v poli na druhe rele protoze maji stejnou mac adresu
                                    if rele2status=="ON"{
                                        if seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].contains("OFF"){
                                            let upravenyString = seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].replacingOccurrences(of: "OFF", with: "ON")
                                            seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni]=upravenyString
                                        }
                                        
                                    }
                                    
                                    if rele2status=="OFF"{
                                        if seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].contains("ON"){
                                            let upravenyString = seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].replacingOccurrences(of: "ON", with: "OFF")
                                            seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni]=upravenyString
                                        }
                                        
                                    }
                                }
                            }//konwc if ochranyinterval
                            
                        }//tady koci txt
                        
                        
                        
                        if animaceHotova==true{
                            collectionView.reloadData()
                        }
                    }
                }
                
            } else {
                print("Did not find IPV4 address")
            }
            
        }
        sender.stop()
        //browser.stop()
        UserDefaults.standard.setValue(seznamNazvuZarizeni, forKey: "seznamNazvuZarizeni")
        UserDefaults.standard.setValue(seznamUmisteniZarizeni, forKey: "seznamUmisteniZarizeni")
        UserDefaults.standard.setValue(seznamObrazkuZarizeni, forKey: "seznamObrazkuZarizeni")
        collectionView.reloadData()
        removeActivityIndicator()
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        print("didNotSearch")
        print(errorDict)
        removeActivityIndicator()
    }
    
    
    func netServiceWillResolve(_ sender: NetService) {
        //print("netServiceWillResolve",sender)
    }
    
    // Find an IPv4 address from the service address data
    func resolveIPv4(addresses: [Data]) -> String? {
        var result: String?
        
        for addr in addresses {
            let data = addr as NSData
            var storage = sockaddr_storage()
            data.getBytes(&storage, length: MemoryLayout<sockaddr_storage>.size)
            
            if Int32(storage.ss_family) == AF_INET {
                let addr4 = withUnsafePointer(to: &storage) {
                    $0.withMemoryRebound(to: sockaddr_in.self, capacity: 1) {
                        $0.pointee
                    }
                }
                
                if let ip = String(cString: inet_ntoa(addr4.sin_addr), encoding: .ascii) {
                    result = ip
                    break
                }
            }
        }
        
        return result
    }
    
    //--------------------------------------------------------
    // MARK: viewDidDisappear --------------------------------
    //--------------------------------------------------------
    override func viewDidDisappear(_ animated: Bool) {
        
        timer.invalidate()
        super.viewDidDisappear(animated)
    }
    //--------------------------------------------------------
    // MARK: sendOverTCP --------------------------------
    //--------------------------------------------------------
    func sendOverTCP(message:String){
        do {
            print("IPadresaKekomuniaci\(hostAdress)")
            //ActivityIndicator("")
            let chatSocket = try Socket.create(family: .inet)
            //print("nejde vytvorit socket")
            print("vytvoril socket")
            //try chatSocket.setReadTimeout(value:1)
            //try chatSocket.setWriteTimeout(value: 1)
            try chatSocket.setBlocking(mode: false)
            //try chatSocket.connect(to: hostAdress, port: Int32(port))
            try chatSocket.connect(to: hostAdress, port: Int32(port), timeout: 5000, familyOnly: false)//bylo 500
            
            print("Connected to: \(chatSocket.remoteHostname) on port \(chatSocket.remotePort)")
            try chatSocket.setBlocking(mode: true)
            try chatSocket.write(from: message)
            print("odeslano")
            if (odeslanPrikazAktualizuj==false) {
                try readFromServer(chatSocket)
                
            }
            
            //sleep(1)  // Be nice to the server
            chatSocket.close()
            ochranyInterval=true
        }
        catch {
            guard let socketError = error as? Socket.Error else {
                print("Unexpected error ...")
                return
            }
            print("Error reported:\n \(socketError.description)")
            removeActivityIndicator()
            //sem dodelat aby se rovnou zapsal do pole jako offline
            //seznamOnlineZarizeni[indexVybranehoZarizeni]="OFFline"
            // create the alert
            let nadpis = "Connection ERROR"
            let messageBox = UIAlertController(title: nadpis, message: "Zarizeni nedpovida", preferredStyle: .alert)
            let AkceOK = UIAlertAction(title: "OK", style: .default){//pokud se stikne tlacitko OK
                (ACTION) in
                //self.performSegue(withIdentifier: "backToTheDeviceList", sender: self)
                seznamOnlineZarizeni[indexVybranehoZarizeni]="OFFline"
                print("nastavuji \(seznamNazvuZarizeni[indexVybranehoZarizeni]) na OFFline ")
                self.collectionView.reloadData()
            }
            
            messageBox.addAction(AkceOK)
            self.present(messageBox,animated: true)
            
            
        }
        //funkcevykonanakazdouvterinu()//vyhleda zmeny na MDNS
    }
    
    // This is very simple-minded. It blocks until there is input, and it then assumes that all the
    // relevant input has been read in one go.
    func readFromServer(_ chatSocket : Socket) throws {
        var readData = Data(capacity: chatSocket.readBufferSize)
        let bytesRead = try chatSocket.read(into: &readData)
        guard bytesRead > 0 else {
            print("Zero bytes read.")
            return
        }
        if let response = String(data: readData, encoding: .utf8) {
            dataKeZpracovani=response
            print(response)
            zpracujTCPdata()
        }
        else {
            print("Error decoding response ...")
            return
        }
        
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
    
    //--------------------------------------------------------
    // MARK: zpracujTCPdata --------------------------------
    //--------------------------------------------------------
    @objc private func zpracujTCPdata() {
        
        print("dosla notifikace ze jsou nova data z TCP")
        //aby to bralo jen data od IP adresy s kterou se komunikuje
        
        removeActivityIndicator()
        print("jupi data pro me")
        if dataKeZpracovani.contains("StatusR1=1")
        {
            
        }
        else if dataKeZpracovani.contains("StatusR1=0")
        {
            
        }
        if dataKeZpracovani.contains("StatusR2=1")
        {
            
        }
        else if dataKeZpracovani.contains("StatusR2=0")
        {
            
        }
        
        teplota=parsujData(prvniZnak: "@", druhyZnak: "#")
        
        dataKeZpracovani=""
        
    }
}//konec class


extension UICollectionView {
    func scrollToNearestVisibleCollectionViewCellProDveBunky() {
        self.decelerationRate = UIScrollView.DecelerationRate.fast
        let visibleCenterPositionOfScrollView = Float(self.contentOffset.x + (self.bounds.size.width / 2))
        var closestCellIndex = -1
        var closestDistance: Float = .greatestFiniteMagnitude
        for i in 0..<self.visibleCells.count {
            let cell = self.visibleCells[i]
            let cellWidth = cell.bounds.size.width
            let cellCenter = Float(cell.frame.origin.x + cellWidth / 2)
            
            // Now calculate closest cell
            let distance: Float = fabsf(visibleCenterPositionOfScrollView - cellCenter)
            print("distance :\(distance)")
            if distance < closestDistance {
                closestDistance = distance
                closestCellIndex = self.indexPath(for: cell)!.row
            }
        }
        print("closest index:\(closestCellIndex)")
        if closestCellIndex != -1 {
            self.scrollToItem(at: IndexPath(row: closestCellIndex, section: 0), at: .left, animated: true)
        }
    }
}
