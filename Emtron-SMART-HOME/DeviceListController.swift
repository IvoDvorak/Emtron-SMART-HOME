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
import UserNotifications


var hostAdress = "127.0.0.1"
let port = 23
var ProvozniRezimRele1=""
var ProvozniRezimRele2=""
var teplota = "20.0"
var merenaTeplota = ""
var PozadovanaTeplota = ""
var indexKdeJeVpoliZarizeni=0
var indexKdeJeZarizeniProMDNSaAWS=0
var nazevDomacnosti = "Emtron Smart Automation"
var odeslanPrikazAktualizuj = false;
var ochranyInterval=false
var citacProOchranyInterval=0
var probehloDiscovery=false
var refreshControl:UIRefreshControl!
var updatujCollectionView = true
var dict=[String: Any]()
//var dictMQTT=[String: Any]()
var verzeFWtermostatuNaServeru=""
var pocitadlo = 0
var PripojenaDobijecka = ""
var NapetiNaBaterie = 0

class DeviceListController: UIViewController,NetServiceBrowserDelegate,
                            NetServiceDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate,UNUserNotificationCenterDelegate{
    
    
    
    var nsb : NetServiceBrowser!
    var services = [NetService]()
    
    var casovacProAWS = 0
    
    @IBOutlet weak var labelNazevDomacnosti: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var uiviewProNazevDomacnosti: UIView!
    var citacProDiscovery = 0
    //let Items = ["Svetlo obyvak","Ventilator","Topeni","Zarovka"]
    //var Images = ["zarovkaON","ventilatorON","radiatorON","zarovkaOFF"]
    
    
    @IBAction func btnInfoClick(_ sender: Any) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NavodKpouzitiController")
        viewController.modalPresentationStyle = .pageSheet
        self.present(viewController, animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //setGradientBackground()
        super.viewWillAppear(animated)
        labelNazevDomacnosti.text=nazevDomacnosti
        print("willAppear")
        
    }
    
    @objc private func pullToRefresh(_ sender: Any) {
        print("pull to refresh")
        updatujCollectionView=false;
        citacProDiscovery=0;
        casovacProAWS=0;
        if (HledatPresMDNS==true){
            startDiscovery()
        }
        else {
            NotificationCenter.default.post(name:NSNotification.Name("HaloKdoJsteOnline"), object: nil)
            print("Hleda na AWS kdo je online")
            
        }
        refreshControl.endRefreshing()
        //reloadCollectionView()
        updatujCollectionView=true;
        //activityIndicatorView.stopAnimating()
        
    }
    
    let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    func ShowNotification(Title:String,Body:String,Badge:Int) {
        print("Show notification")
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = Title
        notificationContent.body = Body
        notificationContent.badge = NSNumber(value: Badge)//prida to jednicku na ikonu aplikace
        notificationContent.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                        repeats: false)
        let request = UNNotificationRequest(identifier: "EmtronAppNotification",
                                            content: notificationContent,
                                            trigger: trigger)
        
        userNotificationCenter.add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }
    
    func requestNotificationAuthorization() {
        //tohle si overi ze jsou zapnute notifikace
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        
        self.userNotificationCenter.requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print("Error: ", error)
            }
            else {
                print("Notifikace povoleny")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
        print("didReceive notification")
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
        print("willPresent notification")
    }
    
    // Local notifications
    func application(_ application: UIApplication, didReceive notification: UNNotification) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        print("click to notification")
    }
    
    
    
    //--------------------------------------------------------
    // MARK: viewDidLoad --------------------------------
    //--------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        vracimSeZnatsaveniTeploty=false;
        print("device list controller DidLoad")
        // Configure Refresh Control
        self.userNotificationCenter.delegate = self
        self.requestNotificationAuthorization()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        collectionView.alwaysBounceVertical = true
        collectionView.refreshControl = refreshControl // iOS 10+
        refreshControl.tintColor = UIColor.white
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(reloadCollectionView), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCollectionView), name: Notification.Name("reloadCollectionView"), object: nil)
        seznamCasuVmodulech.removeAll()
        for _ in 0..<seznamMACZarizeni.count{ 
            
            seznamCasuVmodulech.append("")
            
        }
        print("nacetl seznamy z pameti")
        
        //self.delegate = delegate
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        recognizer.minimumPressDuration = 0.75
        view.addGestureRecognizer(recognizer)
        uiviewProNazevDomacnosti.layer.cornerRadius=20
        
        NotificationCenter.default.addObserver(self, selector: #selector(zpracujDictionaryAWS), name: NSNotification.Name("zpracujDictionaryAWS"), object: nil)
        
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func reloadCollectionView() {//TODO:Zkontrolovat proc se tak casto vola opakovane
       
            print("notifikace reload collection view")
            //DispatchQueue.main.async {//zakomentoval jsme 29.12.2020
                self.collectionView.reloadData()
                animaceHotova=true
                
            //}
        
    }
    
    
    @objc func appMovedToForeground() {
        print("App moved to ForeGround!")
        performSelector(inBackground: #selector(testVerzeFirmwaru), with: nil)
        /*
         LoadingProgressHUD.set(cornerRadius: 5)
         LoadingProgressHUD.set(borderWidth: 2)
         LoadingProgressHUD.set(borderColor: UIColor.lightGray)
         LoadingProgressHUD.set(foregroundColor: UIColor.lightGray)
         LoadingProgressHUD.set(frontTextColor: UIColor.lightGray)
         LoadingProgressHUD.setFadeInAnimationDuration(fadeInAnimationDuration: 0.65)
         LoadingProgressHUD.setFadeOutAnimationDuration(fadeOutAnimationDuration: 0.5)
         LoadingProgressHUD.setHUD(backgroundColor: UIColor.darkGray)
         LoadingProgressHUD.set(defaultMaskType: .gradient)
         LoadingProgressHUD.setOffsetFromCenter(UIOffset(horizontal: 0, vertical: 0))
         //LoadingProgressHUD.setOffsetFromCenter(UIOffset(horizontal: 0, vertical: view.frame.height/4))
         LoadingProgressHUD.show(withStatus: "Loading...")
         LoadingProgressHUD.dismissWithDelay(2)*/
        seznamNotifikaci.removeAll()//aby kdyz se vrati aplikace do popredi to znovu ukazalo notifikace
        for index in 0..<seznamMACZarizeni.count{
            //po zapnuti jsou vsechny offline
            //print("index je:\(index)")
            seznamNotifikaci.append("")
            
        }
        ochranyInterval=false
        citacProOchranyInterval=0
        
        //seznamOnlineZarizeni.removeAll()
        for index in 0..<seznamMACZarizeni.count{
            
            if seznamMDNSvsAWS[index]=="MDNS"{
                seznamOnlineZarizeni[index]=("OFFline")
            }
            
        }
        if (HledatPresMDNS==true){
            startDiscovery()
        }
        else {
            
            NotificationCenter.default.post(name:NSNotification.Name("HaloKdoJsteOnline"), object: nil)
        }
        //removeActivityIndicator()
        //verzeFWnaServeru="2020011302"//jen testovani
        
    }
    
    @objc func testVerzeFirmwaru(){
        if let url = URL(string: "https://www.emdamo.eu/UPDATE/EMTRONCZ/KS001003-2-RELAYS-MODULE/KS001003version.txt") {
            do {
                let contents = try String(contentsOf: url)
                print(contents)
                verzeFWnaServeru=contents.replacingOccurrences(of: "VERSION:", with: "")//orizne pouze verzi
                print("verzeFWnaServeru:\(verzeFWnaServeru)")
                
            } catch {
                verzeFWnaServeru=""
                print("nenacetlo to verzi firmwaru ze serveru")
            }
        } else {
            verzeFWnaServeru=""
            print("nenacetlo to verzi firmwaru ze serveru")
        }
        
        if let url = URL(string: "https://www.emdamo.eu/UPDATE/EMTRONCZ/KS001005-THERMOSTAT/KS001005version.txt") {
            do {
                let contents = try String(contentsOf: url)
                print(contents)
                verzeFWTermostatunaServeru=contents.replacingOccurrences(of: "VERSION:", with: "")//orizne pouze verzi
                print("verzeFWTermostatunaServeru:\(verzeFWTermostatunaServeru)")
                
            } catch {
                verzeFWTermostatunaServeru=""
                print("nenacetlo to verzi firmwaru ze serveru")
            }
        } else {
            verzeFWTermostatunaServeru=""
            print("nenacetlo to verzi firmwaru ze serveru")
        }
        
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
            casovacProAWS=0
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
                    if seznamZparovanychZarizeni[indexVybranehoZarizeni]=="2" && (seznamProvoznichRezimu[indexVybranehoZarizeni] == "TERMOSTAT1"||seznamProvoznichRezimu[indexVybranehoZarizeni]=="TERMOSTAT2"
                                                                                    || seznamProvoznichRezimu[indexVybranehoZarizeni] == "KALENDAR1"||seznamProvoznichRezimu[indexVybranehoZarizeni]=="KALENDAR2")&&seznamOnlineZarizeni[indexVybranehoZarizeni]=="ONline"
                    {
                        //print("verzeFWnaServeru:\(verzeFWnaServeru)")
                        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
                        
                        let message  = "Je k dispozici aktualizace softwaru v bezdratovem termostatu, přejete si ji nainstalovat nebo pokračovat?"
                        var messageMutableString = NSMutableAttributedString()
                        messageMutableString = NSMutableAttributedString(string: message as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Aller", size: 18.0)!])
                        messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 60/255, green: 60/255, blue: 60/255, alpha: 1), range:NSRange(location:0,length:message.count))
                        alertController.setValue(messageMutableString, forKey: "attributedMessage")
                        
                        
                        let AKTUALIZOVATAction = UIAlertAction(title: "Aktualizovat", style: .default) { (action) in
                            print("Aktualizace firmware v termostatu")
                            //odeslanPrikazAktualizuj=true;
                            self.sendOverTCP(message: "THERMOSTAT_UPDATE\n")
                            seznamZparovanychZarizeni[indexKdeJeVpoliZarizeni]="1"
                        }
                        let POKRACOVATAction = UIAlertAction(title: "Pokračovat", style: .default) { (action) in
                            if DEBUGMSG{
                                print("Alert Click pokračovat")
                            }
                            //self.dismiss(animated: true, completion: nil)
                            
                            
                            if seznamObrazkuZarizeni[indexPath.row].contains("zarovka")||seznamObrazkuZarizeni[indexPath.row].contains("ventilator")||seznamObrazkuZarizeni[indexPath.row].contains("zasuvka"){
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
                        
                        alertController.view.tintColor = UIColor.init(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
                        //alertController.view.backgroundColor = UIColor.black
                        alertController.view.layer.cornerRadius = 40
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                    
                    
                    
                    if (seznamDostupnychAktualizaciVmodulech[indexVybranehoZarizeni]=="0" || seznamOnlineZarizeni[indexVybranehoZarizeni]=="OFFline"){
                        
                        print("Firmware je aktualni")
                        //self.sendOverTCP(message: "AKTUALIZUJ")
                        if seznamObrazkuZarizeni[indexPath.row].contains("Prvni zarizeni") || seznamObrazkuZarizeni[indexPath.row].contains("Druhe zarizeni"){
                            self.performSegue(withIdentifier: "showFirtsDeviceSetup", sender: Any?.self)
                        }
                        
                        if seznamObrazkuZarizeni[indexPath.row].contains("zarovka")||seznamObrazkuZarizeni[indexPath.row].contains("ventilator")||seznamObrazkuZarizeni[indexPath.row].contains("zasuvka"){
                            self.performSegue(withIdentifier: "showDeviceDetailZarovka", sender: Any?.self)
                        }
                        
                        if seznamObrazkuZarizeni[indexPath.row].contains("radiator"){
                            self.performSegue(withIdentifier: "showDeviceDetailTopeni", sender: Any?.self)
                        }
                    }
                    else {
                        
                        //print("verzeFWnaServeru:\(verzeFWnaServeru)")
                        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
                        
                        let message  = "Je k dispozici aktualizace softwaru v modulu, přejete si ji nainstalovat nebo pokračovat?"
                        var messageMutableString = NSMutableAttributedString()
                        messageMutableString = NSMutableAttributedString(string: message as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Aller", size: 18.0)!])
                        messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 60/255, green: 60/255, blue: 60/255, alpha: 1), range:NSRange(location:0,length:message.count))
                        alertController.setValue(messageMutableString, forKey: "attributedMessage")
                        
                        
                        let AKTUALIZOVATAction = UIAlertAction(title: "Aktualizovat", style: .default) { (action) in
                            seznamOnlineZarizeni[indexPath.item]="OFFline"
                            print("Aktualizace firmware")
                            //odeslanPrikazAktualizuj=true;
                            self.sendOverTCP(message: "AKTUALIZUJ\n")
                            seznamDostupnychAktualizaciVmodulech[indexVybranehoZarizeni]="0"
                            seznamOnlineZarizeni[indexVybranehoZarizeni]="OFFline"
                            if indexVybranehoZarizeni%2==0 {
                                //pokud je to modul sudy tz 0,2,4 tak jeste udela offline modul za nim
                                seznamDostupnychAktualizaciVmodulech[indexVybranehoZarizeni+1]="0"
                                seznamOnlineZarizeni[indexVybranehoZarizeni+1]="OFFline"
                            }
                            else {
                                seznamDostupnychAktualizaciVmodulech[indexVybranehoZarizeni-1]="0"
                                seznamOnlineZarizeni[indexVybranehoZarizeni-1]="OFFline"
                            }
                            //DispatchQueue.main.async {//zakomentoval jsme 29.12.2020
                            //    self.collectionView.reloadData()
                           //}
                            //odeslanPrikazAktualizuj=false;
                            print("Aktualizace firmware reload data")
                            //let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeviceListController")
                            //viewController.modalPresentationStyle = .fullScreen
                            //self.present(viewController, animated: true, completion: nil)
                        }
                        let POKRACOVATAction = UIAlertAction(title: "Pokračovat", style: .default) { (action) in
                            if DEBUGMSG{
                                print("Alert Click pokračovat")
                            }
                            //self.dismiss(animated: true, completion: nil)
                            
                            
                            if seznamObrazkuZarizeni[indexPath.row].contains("zarovka")||seznamObrazkuZarizeni[indexPath.row].contains("ventilator")||seznamObrazkuZarizeni[indexPath.row].contains("zasuvka"){
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
                        
                        alertController.view.tintColor = UIColor.init(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
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
            cell.UIViewOutlet.layer.cornerRadius = 20
            
            /*
             cell.UIViewOutlet.layer.shadowOffset = .zero
             cell.UIViewOutlet.layer.shadowOpacity = 1
             cell.UIViewOutlet.layer.shadowColor = UIColor.red.cgColor
             cell.UIViewOutlet.layer.shadowRadius = 3
             cell.UIViewOutlet.layer.shadowPath = UIBezierPath(roundedRect: cell.UIViewOutlet.bounds, cornerRadius: 20).cgPath
             */
            cell.UIImageOutlet.alpha=1
            cell.labelPlusko.alpha=0
            
            cell.labelNastavenaTeplota.alpha=0
            cell.labelNastavenaTeplota.layer.masksToBounds=true
            cell.labelNastavenaTeplota.layer.cornerRadius=5
            cell.labelNastavenaTeplota.alpha=0
            cell.outletSaktualniTeplotou.alpha=0
            cell.myLabel.alpha = 0
            cell.labelNazev.alpha = 0
            cell.labelNazevStred.alpha=1
            cell.labelUmisteniStred.alpha=1
            indexKdeJeVpoliZarizeni=indexPath.item
            cell.UIViewOutlet.backgroundColor=seznamBarevModulu[indexKdeJeVpoliZarizeni]
            cell.UIViewOutlet.layer.borderWidth = 0.5
            cell.UIViewOutlet.layer.borderColor = UIColor.green.cgColor
            if (seznamTimeru[indexKdeJeVpoliZarizeni]=="1"){
                cell.outletImageTimer.alpha=1//namaluje ikonu timeru v levem rohu
            }
            else{
                cell.outletImageTimer.alpha=0
            }
            if seznamProvoznichRezimu.count>0{
                
                if (seznamProvoznichRezimu[indexKdeJeVpoliZarizeni] == "TERMOSTAT1"||seznamProvoznichRezimu[indexKdeJeVpoliZarizeni]=="TERMOSTAT2")&&seznamOnlineZarizeni[indexKdeJeVpoliZarizeni]=="ONline"{
                    cell.imageProBezdratTerm.alpha=0
                    if seznamPripojenychTeplomeru[indexKdeJeVpoliZarizeni]=="Wire"{//pripojeny dratovy termostat
                        cell.imageRezimKalendare.image = UIImage(named: "teplomer")
                        cell.imageRezimKalendare.alpha=1
                        if seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].contains("OFF"){
                            seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni]="radiatorOFF"
                        }
                        if seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].contains("ON"){
                            seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni]="radiatorON"
                        }
                    }
                    if seznamPripojenychTeplomeru[indexKdeJeVpoliZarizeni]=="Wireless"{
                        if seznamMerenychTeplot[indexKdeJeVpoliZarizeni] != "-127.0"{
                            cell.imageRezimKalendare.image = UIImage(named: "teplomerPaired")
                        }
                        else {
                            cell.imageRezimKalendare.image = UIImage(named: "teplomerNOPaired")
                        }
                        
                        cell.imageRezimKalendare.alpha=1
                        if seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].contains("OFF"){
                            seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni]="radiatorOFF"
                        }
                        if seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].contains("ON"){
                            seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni]="radiatorON"
                        }
                        
                    }
                    
                }
                else{
                    cell.imageRezimKalendare.alpha=0
                }
                if (seznamProvoznichRezimu[indexKdeJeVpoliZarizeni] == "KALENDAR1"||seznamProvoznichRezimu[indexKdeJeVpoliZarizeni]=="KALENDAR2"||seznamProvoznichRezimu[indexKdeJeVpoliZarizeni]=="CASOVAC1"||seznamProvoznichRezimu[indexKdeJeVpoliZarizeni]=="CASOVAC2")&&seznamOnlineZarizeni[indexKdeJeVpoliZarizeni]=="ONline"{
                    cell.imageRezimKalendare.alpha=1
                    cell.imageRezimKalendare.image = UIImage(named: "Calendar")
                    if (seznamPripojenychTeplomeru[indexKdeJeVpoliZarizeni]=="Wireless")&&(seznamProvoznichRezimu[indexKdeJeVpoliZarizeni] == "KALENDAR1"||seznamProvoznichRezimu[indexKdeJeVpoliZarizeni]=="KALENDAR2"){
                        if (seznamMerenychTeplot[indexKdeJeVpoliZarizeni] != "-127.0"){
                            cell.imageProBezdratTerm.image = UIImage(named: "teplomerPaired")
                        }
                        else {
                            cell.imageProBezdratTerm.image = UIImage(named: "teplomerNOPaired")
                        }
                        cell.imageProBezdratTerm.alpha=1
                    }
                    else {
                        cell.imageProBezdratTerm.alpha=0
                    }
                }
                else {
                    cell.imageProBezdratTerm.alpha=0
                }
            }
            if seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].contains("radiator")&&seznamOnlineZarizeni[indexKdeJeVpoliZarizeni]=="ONline"&&(seznamPripojenychTeplomeru[indexKdeJeVpoliZarizeni]=="Wire" || seznamPripojenychTeplomeru[indexKdeJeVpoliZarizeni]=="Wireless"){
                if seznamMerenychTeplot[indexKdeJeVpoliZarizeni] != "-127.0"{
                    cell.outletSaktualniTeplotou.text=("\(seznamMerenychTeplot[indexKdeJeVpoliZarizeni])°C")
                    cell.outletSaktualniTeplotou.alpha=1
                    cell.myLabel.alpha = 1
                    cell.labelNazev.alpha = 1
                    cell.labelNazevStred.alpha=0
                    cell.labelUmisteniStred.alpha=0
                }
                
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
            
            
            
            if seznamOnlineZarizeni[indexKdeJeVpoliZarizeni]=="OFFline"{//zarizeni je offline musim namalovat jinou ikonu
                cell.UIViewOutlet.layer.borderWidth = 2.3
                cell.UIViewOutlet.layer.borderColor = UIColor.red.cgColor
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
            if seznamDostupnychAktualizaciVmodulech[indexKdeJeVpoliZarizeni]=="0" || seznamOnlineZarizeni[indexKdeJeVpoliZarizeni]=="OFFline"{
                cell.ImageFWupgradeAvailabel.alpha=0
                //print("verzeFWnaServeru:\(verzeFWnaServeru)")
                
            }
            if ((seznamDostupnychAktualizaciVmodulech[indexKdeJeVpoliZarizeni]=="1" && seznamOnlineZarizeni[indexKdeJeVpoliZarizeni]=="ONline")||(seznamZparovanychZarizeni[indexKdeJeVpoliZarizeni]=="2")&&(cell.imageRezimKalendare.alpha==1)){
                cell.ImageFWupgradeAvailabel.alpha=1
                print("firmware neni aktualni")
            }
            
            
            cell.myLabel.text = seznamUmisteniZarizeni[indexPath.item]
            cell.labelNazev.text = seznamNazvuZarizeni[indexPath.item]
            cell.labelUmisteniStred.text = seznamUmisteniZarizeni[indexPath.item]
            cell.labelNazevStred.text = seznamNazvuZarizeni[indexPath.item]
            
            
            
            cell.UIImageOutlet.image=UIImage(named: seznamObrazkuZarizeni[indexPath.item])
            
            
            
        }
        else{
            cell.myLabel.text = ""
            cell.labelNazev.text = ""
            cell.labelUmisteniStred.text = ""
            cell.labelNazevStred.text = ""
            cell.UIImageOutlet.alpha=0
            cell.outletImageTimer.alpha=0
            cell.labelPlusko.alpha=1
            cell.imageProBezdratTerm.alpha=0
            cell.imageRezimKalendare.alpha=0
            cell.outletSaktualniTeplotou.alpha=0
            cell.labelNastavenaTeplota.alpha=0
            cell.labelNazevStred.alpha=0
            cell.labelUmisteniStred.alpha=0
            cell.ImageFWupgradeAvailabel.alpha=0
            cell.UIViewOutlet.layer.borderWidth = 0
            cell.UIViewOutlet.layer.borderColor = UIColor.green.cgColor
        }
        //print("Maluju obrazek: \(seznamObrazkuZarizeni[indexPath.item]) na indexu: \(indexPath.item)")
        cell.UIViewOutlet.layer.cornerRadius = 20
        
        //cell.UIViewOutlet.borderColor = UIColor.blue.cgColor
        //cell.UIViewOutlet.borderWidth = 1
        return cell
    }
    
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("vybrana bunka:\(indexPath.item)")
        
        citacProDiscovery=0//aby nebezelo discovery hned po kliknuti
        casovacProAWS=0
        
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
                seznamTimeru[indexVybranehoZarizeni]="0"//rovnou se smaze ze bezi timer
                if (seznamProvoznichRezimu[indexVybranehoZarizeni] == "KALENDAR1"||seznamProvoznichRezimu[indexVybranehoZarizeni]=="KALENDAR2"||seznamProvoznichRezimu[indexVybranehoZarizeni]=="CASOVAC1"||seznamProvoznichRezimu[indexVybranehoZarizeni]=="CASOVAC2"){
                    let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
                    
                    let message  = "Zařízení je nastaveno dle rozvrhu kalendáře, opravdu si přejete kalendář deaktivovat a okmažitě změnit stav?"
                    var messageMutableString = NSMutableAttributedString()
                    messageMutableString = NSMutableAttributedString(string: message as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Aller", size: 18.0)!])
                    messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 60/255, green: 60/255, blue: 60/255, alpha: 1), range:NSRange(location:0,length:message.count))
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
                        
                        if seznamObrazkuZarizeni[indexPath.item]=="zasuvkaON"{
                            seznamObrazkuZarizeni[indexPath.item]="zasuvkaOFF"
                            
                        }
                        else if seznamObrazkuZarizeni[indexPath.item]=="zasuvkaOFF"{
                            seznamObrazkuZarizeni[indexPath.item]="zasuvkaON"
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
                            self.sendOverTCP(message:"R\(poradoveCisloRele[indexVybranehoZarizeni])ON\n")//melo by to poslat R1ON nebo R2ON
                            print("switch R\(poradoveCisloRele[indexVybranehoZarizeni]) ON")
                        }
                        if seznamObrazkuZarizeni[indexPath.item].contains("OFF"){
                            self.sendOverTCP(message:"R\(poradoveCisloRele[indexVybranehoZarizeni])OFF\n")//melo by to poslat R1OFF nebo R2OFF
                            print("switch R\(poradoveCisloRele[indexVybranehoZarizeni]) OFF")
                        }
                        seznamProvoznichRezimu[indexVybranehoZarizeni]="RELE"
                        if animaceHotova==true{
                            //DispatchQueue.main.async {//zakomentoval jsme 29.12.2020
                            self.collectionView.reloadData()
                       //}
                            
                        }
                    }
                    
                    let NEAction = UIAlertAction(title: "NE", style: .destructive) { (action) in
                        if DEBUGMSG{
                            print("Alert Click NE")
                        }
                        //self.dismiss(animated: true, completion: nil)
                    }
                    
                    alertController.addAction(NEAction)
                    alertController.addAction(ANOAction)
                    
                    
                    //alertController.view.tintColor = UIColor.init(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
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
                        
                        if seznamObrazkuZarizeni[indexPath.item]=="zasuvkaON"{
                            seznamObrazkuZarizeni[indexPath.item]="zasuvkaOFF"
                            
                        }
                        else if seznamObrazkuZarizeni[indexPath.item]=="zasuvkaOFF"{
                            seznamObrazkuZarizeni[indexPath.item]="zasuvkaON"
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
                            self.sendOverTCP(message:"R\(poradoveCisloRele[indexVybranehoZarizeni])ON\n")//melo by to poslat R1ON nebo R2ON
                            print("switch R\(poradoveCisloRele[indexVybranehoZarizeni]) ON")
                        }
                        if seznamObrazkuZarizeni[indexPath.item].contains("OFF"){
                            self.sendOverTCP(message:"R\(poradoveCisloRele[indexVybranehoZarizeni])OFF\n")//melo by to poslat R1OFF nebo R2OFF
                            print("switch R\(poradoveCisloRele[indexVybranehoZarizeni]) OFF")
                        }
                        seznamProvoznichRezimu[indexVybranehoZarizeni]="RELE"
                        if animaceHotova==true{
                            //DispatchQueue.main.async {//zakomentoval jsme 29.12.2020
                            self.collectionView.reloadData()
                       //}
                            
                        }
                    }
                    
                    let NEAction = UIAlertAction(title: "NE", style: .destructive) { (action) in
                        if DEBUGMSG{
                            print("Alert Click NE")
                        }
                        //self.dismiss(animated: true, completion: nil)
                    }
                    alertController.addAction(NEAction)
                    alertController.addAction(ANOAction)
                    
                    
                    //alertController.view.tintColor = UIColor.init(red: 255/255, green: 168/255, blue: 0, alpha: 1)
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
                    
                    if seznamObrazkuZarizeni[indexPath.item]=="zasuvkaON"{
                        seznamObrazkuZarizeni[indexPath.item]="zasuvkaOFF"
                        
                    }
                    else if seznamObrazkuZarizeni[indexPath.item]=="zasuvkaOFF"{
                        seznamObrazkuZarizeni[indexPath.item]="zasuvkaON"
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
                        self.sendOverTCP(message:"R\(poradoveCisloRele[indexVybranehoZarizeni])ON\n")//melo by to poslat R1ON nebo R2ON
                        print("switch R\(poradoveCisloRele[indexVybranehoZarizeni]) ON")
                    }
                    if seznamObrazkuZarizeni[indexPath.item].contains("OFF"){
                        self.sendOverTCP(message:"R\(poradoveCisloRele[indexVybranehoZarizeni])OFF\n")//melo by to poslat R1OFF nebo R2OFF
                        print("switch R\(poradoveCisloRele[indexVybranehoZarizeni]) OFF")
                    }
                    
                    //seznamProvoznichRezimu[indexVybranehoZarizeni]="RELE"
                    seznamTimeru[indexVybranehoZarizeni]="0"
                }
                //collectionView.reloadData()
            }//konec if online
        }//konec if coiunt
        else{
            print("stisknul plusko")
            timer.invalidate()
            print("timer.invalidate()")
            if probehloDiscovery==true{
                self.nsb.stop()
                self.services.removeAll()
            }
            probehloDiscovery=false
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            self.performSegue(withIdentifier: "addDeviceSegue", sender: Any?.self)
        }
        
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //let width  = (view.frame.width-45)/2//trojnasobek toho co je nastaveny jako mezera
        
        //return CGSize(width: width, height: width)
       // let width  = (view.frame.width-30)//-30
        //let height  = (view.frame.height-45)/5//5
        //return CGSize(width: width, height: height)
        
        let width  = collectionView.frame.width-30
        let height  = (collectionView.frame.height-60)/3//5
        return CGSize(width: width, height: height)
        
    }
    
    
    //--------------------------------------------------------
    // MARK: viewDidAppear --------------------------------
    //--------------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        probehloDiscovery=false
        print("DeviceListController viewDidAppear")
        if bylDetailController==false
        {
            if (HledatPresMDNS==true){
                startDiscovery()
            }
            else {
                //NotificationCenter.default.post(name:NSNotification.Name("HaloKdoJsteOnline"), object: nil)
            }
            //if (UIApplication.shared.applicationIconBadgeNumber == 1){
            //   print("pripojte nabijecku")
            //}
            
            /*for i in 0..<seznamNotifikaci.count {
             if seznamNotifikaci[i]=="CHARGING"{
             ShowNotification(Title: "Pripojena nabijecka", Body: "Baterie ve vasem bezdratovem termostatu se dobiji", Badge: 0)
             }
             if seznamNotifikaci[i]=="CHARGED"{
             ShowNotification(Title: "Odpojte nabijecku", Body: "Baterie ve vasem bezdratovem termostatu je uspesne dobita", Badge: 0)
             }
             if seznamNotifikaci[i]=="NOT CONNECTED"{
             if ((NapetiNaBaterie<1906)&&(NapetiNaBaterie>0)){
             //baterie dosahla mene nez 30%
             print("baterie dosahla mene nez 30%")
             ShowNotification(Title: "Pripojte nabijecku", Body: "Baterie ve vasem bezdratovem termostatu je vybita na mene nez 30%", Badge: 1)
             }
             }
             if seznamNotifikaci[i]=="LOW BATTERY"{
             ShowNotification(Title: "Pripojte nabijecku", Body: "Vas bezdratovy termostat se vypnul z duvodu uplneho vybiti baterie", Badge: 1)
             }
             }*/
            
        }
        else {
            bylDetailController=false
            citacProDiscovery=0
            ochranyInterval=false
            
            
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(funkcevykonanakazdouvterinu), userInfo: nil, repeats: true)
        timer.tolerance=0.4
        print("DidAppear DEVICELISTCONTROLLER")
        
    }
    
    
    
    @objc func funkcevykonanakazdouvterinu()
    {
        if (casovacProAWS<30){//30
            casovacProAWS=casovacProAWS+1
        }
        else{
            casovacProAWS=0
            NotificationCenter.default.post(name:NSNotification.Name("HaloKdoJsteOnline"), object: nil)
        }
        
        if (citacProDiscovery<9) {//bylo 5
            citacProDiscovery=citacProDiscovery+1
        }
        else{
            citacProDiscovery=0
            //print("Start discovery")
            if (ochranyInterval==false) {
                if (HledatPresMDNS==true){
                    startDiscovery()
                }
                
            }
            
            //calendar()
            
        }//konec else
        
        if ochranyInterval==true{
            if citacProOchranyInterval<7{
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
    
    private func startDiscovery() {
        print("listening for services...")
        if services.count==0{
            /*seznamOnlineZarizeni.removeAll()
             for _ in 0..<seznamMACZarizeni.count{
             //po zapnuti jsou vsechny offline
             //print("index je:\(index)")
             seznamOnlineZarizeni.append("OFFline")
             
             }*/
            //if animaceHotova==true{collectionView.reloadData()}
        }
        self.services.removeAll()
        self.nsb = NetServiceBrowser()
        self.nsb.delegate = self
        self.nsb.searchForServices(ofType:"_emtron-device-info._tcp", inDomain: "")
        probehloDiscovery=true
    }
    
    func updateInterface () {
        //prvne nastavim ve na offline a pak se uvidi
        if updatujCollectionView==true{
            if bylDetailController==false{
                //seznamOnlineZarizeni.removeAll()
                for index in 0..<seznamMACZarizeni.count{
                    //po zapnuti jsou vsechny offline
                    //print("index je:\(index)")
                    if (seznamMDNSvsAWS[index]=="MDNS"){
                        seznamMDNSvsAWS[index]="AWS"
                        seznamOnlineZarizeni[index]=("OFFline")
                    }
                    
                }
            }
            
            for service in self.services {
                if service.port == -1 {
                    print("service \(service.name) of type \(service.type)" +
                            " not yet resolved")
                    service.delegate = self
                    service.resolve(withTimeout:5)//10
                    //citacProDiscovery=0//zakomentoval jsem
                } else {
                    //print("service \(service.name) of type \(service.type)," +
                    //    "port \(service.port), addresses \(service.addresses)")
                    
                    if service.name.hasPrefix("EMTRON-CZ")
                    {
                        // Find the IPV4 address
                        if let serviceIp = resolveIPv4(addresses: service.addresses!) {
                            print("Found \(service.name) with IPV4:", serviceIp)
                            if seznamMACZarizeni.contains(service.name)
                            {
                                
                                if service.name.contains("EMTRON-CZ-2-RELAYS-MODULE"){
                                    //pokud je modul se 2 rele musi aktualizovat IP adresu u obou
                                    print("Nasel 2 RELAYS MODULE zarizeni")
                                    
                                    
                                    //print("aktualizuji IP adresu 2 zarizeni \(sender.name) na IP:\(serviceIp)")
                                    
                                    if let data = service.txtRecordData() {
                                        
                                        
                                        if data.count<100 {return}//ochrana kdyz to nenacte txt record data
                                        //print(data)
                                        dict = NetService.dictionary(fromTXTRecord: data)
                                        print("vytvoril dict z TXT")
                                        
                                        indexKdeJeZarizeniProMDNSaAWS = seznamMACZarizeni.firstIndex(of: service.name)!
                                        seznamOnlineZarizeni[indexKdeJeZarizeniProMDNSaAWS]="ONline"
                                        seznamIPZarizeni[indexKdeJeZarizeniProMDNSaAWS]=serviceIp
                                        seznamOnlineZarizeni[indexKdeJeZarizeniProMDNSaAWS+1]="ONline"
                                        seznamIPZarizeni[indexKdeJeZarizeniProMDNSaAWS+1]=serviceIp
                                        seznamMDNSvsAWS[indexKdeJeZarizeniProMDNSaAWS]="MDNS"
                                        seznamMDNSvsAWS[indexKdeJeZarizeniProMDNSaAWS+1]="MDNS"
                                        zpracujDictionaryMDNS();
                                    }//tady koci txt
                                    
                                    
                                    
                                    if animaceHotova==true{
                                        //DispatchQueue.main.async { //zakomentoval jsem 29.12.2020
                                            self.collectionView.reloadData()
                                        //}
                                    }
                                }
                            }
                            
                        } else {
                            print("Did not find IPV4 address")
                        }
                        
                    }
                    
                    
                }
            }
            
        }
    }
    
    @objc func zpracujDictionaryAWS(_ notification: NSNotification){
        if animaceHotova==true{
            DispatchQueue.main.async {//zakomentoval jsem 29.12.2020
                self.collectionView.reloadData()
            }
        }

    }//konec funkce
    @objc func zpracujDictionaryMDNS(){
        //LoadingProgressHUD.dismiss()
        print("zavolana funkce zpracujDictionaryMDNS")
        if seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].contains("NoRespone"){
            //print("obrazek obsahuje NoRespone")
            let upravenyString = seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].replacingOccurrences(of: "NoRespone", with: "ON")
            seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS]=upravenyString
            
        }
        if seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].contains("NoRespone"){
            //print("obrazek obsahuje NoRespone")
            let upravenyString = seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].replacingOccurrences(of: "NoRespone", with: "ON")
            seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1]=upravenyString
            
        }
        
        
        if dict.keys.contains("FWVERSION"){
            seznamVerziFirmwaru[indexKdeJeZarizeniProMDNSaAWS] = String(data: dict["FWVERSION"]! as! Data, encoding: String.Encoding.utf8)!
            seznamVerziFirmwaru[indexKdeJeZarizeniProMDNSaAWS+1] = String(data: dict["FWVERSION"]! as! Data, encoding: String.Encoding.utf8)!
            
            if seznamVerziFirmwaru[indexKdeJeZarizeniProMDNSaAWS] != verzeFWnaServeru{
                seznamDostupnychAktualizaciVmodulech[indexKdeJeZarizeniProMDNSaAWS] = "1"}
            else {
                seznamDostupnychAktualizaciVmodulech[indexKdeJeZarizeniProMDNSaAWS] = "0"
            }
            if seznamVerziFirmwaru[indexKdeJeZarizeniProMDNSaAWS+1] != verzeFWnaServeru{
                seznamDostupnychAktualizaciVmodulech[indexKdeJeZarizeniProMDNSaAWS+1] = "1"}
            else {
                seznamDostupnychAktualizaciVmodulech[indexKdeJeZarizeniProMDNSaAWS+1] = "0"
            }
        }
        
        if dict.keys.contains("HOMEKIT_PASSW"){
            seznamKoduHomekitu [indexKdeJeZarizeniProMDNSaAWS] = String(data: dict["HOMEKIT_PASSW"]! as! Data, encoding: String.Encoding.utf8)!
            seznamKoduHomekitu [indexKdeJeZarizeniProMDNSaAWS] = seznamKoduHomekitu [indexKdeJeZarizeniProMDNSaAWS].replacingOccurrences(of: "-", with: "")
            
            seznamKoduHomekitu[indexKdeJeZarizeniProMDNSaAWS+1] = String(data: dict["HOMEKIT_PASSW"]! as! Data, encoding: String.Encoding.utf8)!
            seznamKoduHomekitu [indexKdeJeZarizeniProMDNSaAWS+1] = seznamKoduHomekitu [indexKdeJeZarizeniProMDNSaAWS+1].replacingOccurrences(of: "-", with: "")
            UserDefaults.standard.setValue(seznamKoduHomekitu, forKey: "seznamKoduHomekitu")
        }
        
        if dict.keys.contains("HomekitPaired"){
            seznamZparovanychShomekitem [indexKdeJeZarizeniProMDNSaAWS] = String(data: dict["HomekitPaired"]! as! Data, encoding: String.Encoding.utf8)!
            seznamZparovanychShomekitem[indexKdeJeZarizeniProMDNSaAWS+1] = String(data: dict["HomekitPaired"]! as! Data, encoding: String.Encoding.utf8)!
            UserDefaults.standard.setValue(seznamZparovanychShomekitem, forKey: "seznamZparovanychShomekitem")
        }
        
        if dict.keys.contains("RSSI"){
            seznamRSSI[indexKdeJeZarizeniProMDNSaAWS] = String(data: dict["RSSI"]! as! Data, encoding: String.Encoding.utf8)!
            seznamRSSI[indexKdeJeZarizeniProMDNSaAWS+1] = String(data: dict["RSSI"]! as! Data, encoding: String.Encoding.utf8)!
        }
        
        if dict.keys.contains("SSID"){
            seznamSSID[indexKdeJeZarizeniProMDNSaAWS] = String(data: dict["SSID"]! as! Data, encoding: String.Encoding.utf8)!
            seznamSSID[indexKdeJeZarizeniProMDNSaAWS+1] = String(data: dict["SSID"]! as! Data, encoding: String.Encoding.utf8)!
        }
        
        if dict.keys.contains("Hystereze"){
            dataKeZpracovani = String(data: dict["Hystereze"]! as! Data, encoding: String.Encoding.utf8)!
            seznamKladnaHystereze[indexKdeJeZarizeniProMDNSaAWS]=parsujData(prvniZnak: "!", druhyZnak: "@")
            seznamKladnaHystereze[indexKdeJeZarizeniProMDNSaAWS+1]=parsujData(prvniZnak: "@", druhyZnak: "#")
            seznamZapornaHystereze[indexKdeJeZarizeniProMDNSaAWS]=parsujData(prvniZnak: "#", druhyZnak: "$")
            seznamZapornaHystereze[indexKdeJeZarizeniProMDNSaAWS+1]=parsujData(prvniZnak: "$", druhyZnak: "%")
            seznamTopoimChladim[indexKdeJeZarizeniProMDNSaAWS]=parsujData(prvniZnak: "%", druhyZnak: "^")
            seznamTopoimChladim[indexKdeJeZarizeniProMDNSaAWS]=parsujData(prvniZnak: "^", druhyZnak: "&")
        }
        
        if dict.keys.contains("HOMEKIT_QRcode"){
            seznamQRkodu[indexKdeJeZarizeniProMDNSaAWS] = String(data: dict["HOMEKIT_QRcode"]! as! Data, encoding: String.Encoding.utf8)!
            seznamQRkodu[indexKdeJeZarizeniProMDNSaAWS+1] = String(data: dict["HOMEKIT_QRcode"]! as! Data, encoding: String.Encoding.utf8)!
            UserDefaults.standard.setValue(seznamQRkodu, forKey: "seznamQRkodu")
        }
        
        /*if dict.keys.contains("UPDATABLE"){
         
         seznamDostupnychAktualizaciVmodulech[indexKdeJeZarizeniProMDNSaAWS] = String(data: dict["UPDATABLE"]! as! Data, encoding: String.Encoding.utf8)!
         seznamDostupnychAktualizaciVmodulech[indexKdeJeZarizeniProMDNSaAWS+1] = String(data: dict["UPDATABLE"]! as! Data, encoding: String.Encoding.utf8)!
         }
         */
        if dict.keys.contains("TEMPACT1"){
            //var teplota1:Float = String(data: dict["TEMPACT1"]!, encoding: String.Encoding.utf8).
            //teplota1
            seznamMerenychTeplot[indexKdeJeZarizeniProMDNSaAWS] = String(data: dict["TEMPACT1"]! as! Data, encoding: String.Encoding.utf8)!//pro prvni rele
            
        }
        
        if dict.keys.contains("TEMPACT2"){
            //var teplota1:Float = String(data: dict["TEMPACT1"]!, encoding: String.Encoding.utf8).
            //teplota1
            
            seznamMerenychTeplot[indexKdeJeZarizeniProMDNSaAWS+1] = String(data: dict["TEMPACT2"]! as! Data, encoding: String.Encoding.utf8)!
        }
        
        if dict.keys.contains("ICONE1"){
            if (String(data: dict["ICONE1"]! as! Data, encoding: String.Encoding.utf8)!) != "" && (String(data: dict["ICONE1"]! as! Data, encoding: String.Encoding.utf8)!) != "NONE"{
            //var teplota1:Float = String(data: dict["TEMPACT1"]!, encoding: String.Encoding.utf8).
            //teplota1
            // let Images = ["zarovka","ventilator","radiator","zasuvka"]
            
            if seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].contains("zarovka")||seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].contains("ventilator")||seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].contains("radiator")||seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].contains("zasuvka")||seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].contains("Prvni zarizeni"){
                
                if seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].contains("NoRespone"){
                    seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS] = "\(String(data: dict["ICONE1"]! as! Data, encoding: String.Encoding.utf8)!)NoRespone"
                }
                else if seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].contains("ON"){
                    seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS] = "\(String(data: dict["ICONE1"]! as! Data, encoding: String.Encoding.utf8)!)ON"
                }
                else if seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].contains("OFF"){
                    seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS] = "\(String(data: dict["ICONE1"]! as! Data, encoding: String.Encoding.utf8)!)OFF"
                }
                else {
                    seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS] = "\(String(data: dict["ICONE1"]! as! Data, encoding: String.Encoding.utf8)!)"
                }
                
            }
            else {
                print("skace do else prvni zarizeni ikona")
                seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS] = "Prvni zarizeni"
            }
        }
    }
        
        if dict.keys.contains("ICONE2"){
            if (String(data: dict["ICONE2"]! as! Data, encoding: String.Encoding.utf8)!) != "" && (String(data: dict["ICONE2"]! as! Data, encoding: String.Encoding.utf8)!) != "NONE"{
            //var teplota1:Float = String(data: dict["TEMPACT1"]!, encoding: String.Encoding.utf8).
            //teplota1
            if seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].contains("zarovka")||seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].contains("ventilator")||seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].contains("radiator")||seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].contains("zasuvka")||seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].contains("Druhe zarizeni"){
                if seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].contains("NoRespone"){
                    seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1] = "\(String(data: dict["ICONE2"]! as! Data, encoding: String.Encoding.utf8)!)NoRespone"
                }
                else if seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].contains("ON"){
                    seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1] = "\(String(data: dict["ICONE2"]! as! Data, encoding: String.Encoding.utf8)!)ON"
                }
                else if seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].contains("OFF"){
                    seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1] = "\(String(data: dict["ICONE2"]! as! Data, encoding: String.Encoding.utf8)!)OFF"
                }
                else {
                    seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1] = "\(String(data: dict["ICONE2"]! as! Data, encoding: String.Encoding.utf8)!)"
                }
            }
            else {
                seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1] = "Druhe zarizeni"
                print("skace do else prvni zarizeni ikona")
            }
        }
    }
        if dict.keys.contains("TEMPPOZ1"){
            seznamPozadovanychTeplot[indexKdeJeZarizeniProMDNSaAWS] = String(data: dict["TEMPPOZ1"]! as! Data, encoding: String.Encoding.utf8)!//tady se musi smazat posledni nula
            seznamPozadovanychTeplot[indexKdeJeZarizeniProMDNSaAWS]=String(seznamPozadovanychTeplot[indexKdeJeZarizeniProMDNSaAWS].dropLast())
        }
        if dict.keys.contains("TEMPPOZ2"){
            seznamPozadovanychTeplot[indexKdeJeZarizeniProMDNSaAWS+1] = String(data: dict["TEMPPOZ2"]! as! Data, encoding: String.Encoding.utf8)!
            seznamPozadovanychTeplot[indexKdeJeZarizeniProMDNSaAWS+1] =  String(seznamPozadovanychTeplot[indexKdeJeZarizeniProMDNSaAWS+1].dropLast())
        }
        if dict.keys.contains("LOCATION1"){
            seznamUmisteniZarizeni[indexKdeJeZarizeniProMDNSaAWS] = String(data: dict["LOCATION1"]! as! Data, encoding: String.Encoding.utf8)!
        }
        
        if dict.keys.contains("LOCATION2"){
            seznamUmisteniZarizeni[indexKdeJeZarizeniProMDNSaAWS+1] = String(data: dict["LOCATION2"]! as! Data, encoding: String.Encoding.utf8)!
        }
        
        if dict.keys.contains("PAIRED"){
            seznamZparovanychZarizeni[indexKdeJeZarizeniProMDNSaAWS+1] = String(data: dict["PAIRED"]! as! Data, encoding: String.Encoding.utf8)!
            seznamZparovanychZarizeni[indexKdeJeZarizeniProMDNSaAWS] = String(data: dict["PAIRED"]! as! Data, encoding: String.Encoding.utf8)!
            
            if dict.keys.contains("FWtermostat"){
                let verzeFWtermostatuzMDNS = String(data: dict["FWtermostat"]! as! Data, encoding: String.Encoding.utf8)!
                print("verzeFWtermostatuzMDNS:\(verzeFWtermostatuzMDNS)")
                print("verzeFWTermostatunaServeru:\(verzeFWTermostatunaServeru)")
                if((verzeFWtermostatuzMDNS != verzeFWTermostatunaServeru)&&(verzeFWtermostatuzMDNS != "0")&&(verzeFWtermostatuzMDNS != "")){
                    seznamZparovanychZarizeni[indexKdeJeZarizeniProMDNSaAWS] = "2"
                    seznamZparovanychZarizeni[indexKdeJeZarizeniProMDNSaAWS+1] = "2"
                }
            }
        }
        
        if dict.keys.contains("TempSensorRelayOne"){
            seznamPripojenychTeplomeru[indexKdeJeZarizeniProMDNSaAWS] = String(data: dict["TempSensorRelayOne"]! as! Data, encoding: String.Encoding.utf8)!
        }
        
        if dict.keys.contains("TempSensorRelayTwo"){
            seznamPripojenychTeplomeru[indexKdeJeZarizeniProMDNSaAWS+1] = String(data: dict["TempSensorRelayTwo"]! as! Data, encoding: String.Encoding.utf8)!
        }
        
        if dict.keys.contains("NAME1"){
            seznamNazvuZarizeni[indexKdeJeZarizeniProMDNSaAWS] = String(data: dict["NAME1"]! as! Data, encoding: String.Encoding.utf8)!
        }
        
        if dict.keys.contains("NAME2"){
            seznamNazvuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1] = String(data: dict["NAME2"]! as! Data, encoding: String.Encoding.utf8)!
        }
        
        if dict.keys.contains("TIME"){
            seznamCasuVmodulech[indexKdeJeZarizeniProMDNSaAWS+1] = String(data: dict["TIME"]! as! Data, encoding: String.Encoding.utf8)!
            seznamCasuVmodulech[indexKdeJeZarizeniProMDNSaAWS] = String(data: dict["TIME"]! as! Data, encoding: String.Encoding.utf8)!
        }
        
        if dict.keys.contains("RELAY1"){
            seznamProvoznichRezimu[indexKdeJeZarizeniProMDNSaAWS] = String(data: dict["RELAY1"]! as! Data, encoding: String.Encoding.utf8)!
            print("ProvozniRezimRele1:\(seznamProvoznichRezimu[indexKdeJeZarizeniProMDNSaAWS])")
        }
        if dict.keys.contains("TimerOne"){
            seznamTimeru[indexKdeJeZarizeniProMDNSaAWS] = String(data: dict["TimerOne"]! as! Data, encoding: String.Encoding.utf8)!
            
        }
        if dict.keys.contains("TimerTwo"){
            seznamTimeru[indexKdeJeZarizeniProMDNSaAWS+1] = String(data: dict["TimerTwo"]! as! Data, encoding: String.Encoding.utf8)!
            
        }
        if dict.keys.contains("RELAY2"){
            seznamProvoznichRezimu[indexKdeJeZarizeniProMDNSaAWS+1] = String(data: dict["RELAY2"]! as! Data, encoding: String.Encoding.utf8)!
            print("ProvozniRezimRele2:\(seznamProvoznichRezimu[indexKdeJeZarizeniProMDNSaAWS+1])")
        }
        if dict.keys.contains("BATTERY"){
            NapetiNaBaterie = Int(String(data: dict["BATTERY"]! as! Data, encoding: String.Encoding.utf8)!) ?? 0
            
        }
        if dict.keys.contains("CHARGER"){
            PripojenaDobijecka = String(data: dict["CHARGER"]! as! Data, encoding: String.Encoding.utf8)!
            if (PripojenaDobijecka=="CHARGING"){
                //baterie se nabiji
                print("baterie se nabiji")
                
                if seznamPripojenychTeplomeru[indexKdeJeZarizeniProMDNSaAWS]=="Wireless"{
                    if seznamNotifikaci[indexKdeJeZarizeniProMDNSaAWS] != "CHARGING"{
                        ShowNotification(Title: "Připojena nabíječka", Body: "Baterie ve Vašem bezdrátovém termostatu se dobíjí.", Badge: 0)
                        seznamNotifikaci[indexKdeJeZarizeniProMDNSaAWS]="CHARGING"
                    }
                    
                }
                if seznamPripojenychTeplomeru[indexKdeJeZarizeniProMDNSaAWS+1]=="Wireless"{
                    if seznamNotifikaci[indexKdeJeZarizeniProMDNSaAWS+1] != "CHARGING"{
                        ShowNotification(Title: "Připojena nabíječka", Body: "Baterie ve Vašem bezdrátovém termostatu se dobíjí.", Badge: 0)
                        seznamNotifikaci[indexKdeJeZarizeniProMDNSaAWS+1]="CHARGING"
                    }
                }
            }
            
            else if (PripojenaDobijecka=="CHARGED"){
                //baterie nabita
                print("baterie nabita")
                if seznamPripojenychTeplomeru[indexKdeJeZarizeniProMDNSaAWS]=="Wireless"{
                    if seznamNotifikaci[indexKdeJeZarizeniProMDNSaAWS] != "CHARGED"{
                        ShowNotification(Title: "Odpojte nabíječku", Body: "Baterie ve Vašem bezdrátovém termostatu je úspěšně dobita.", Badge: 0)
                        seznamNotifikaci[indexKdeJeZarizeniProMDNSaAWS]="CHARGED"
                    }
                    
                }
                if seznamPripojenychTeplomeru[indexKdeJeZarizeniProMDNSaAWS+1]=="Wireless"{
                    if seznamNotifikaci[indexKdeJeZarizeniProMDNSaAWS+1] != "CHARGED"{
                        ShowNotification(Title: "Odpojte nabíječku", Body: "Baterie ve Vašem bezdrátovém termostatu je úspěšně dobita.", Badge: 0)
                        seznamNotifikaci[indexKdeJeZarizeniProMDNSaAWS+1]="CHARGED"
                    }
                }
            }
            else if (PripojenaDobijecka=="NOT CONNECTED"){
                //nabijecka neni pripojena
                print("nabijecka neni pripojena")
                if seznamPripojenychTeplomeru[indexKdeJeZarizeniProMDNSaAWS]=="Wireless"{
                    if seznamNotifikaci[indexKdeJeZarizeniProMDNSaAWS] != "NOT CONNECTED"{
                        if ((NapetiNaBaterie<1906)&&(NapetiNaBaterie>0)){
                            //baterie dosahla mene nez 30%
                            print("baterie dosahla mene nez 30%")
                            ShowNotification(Title: "Připojte nabíječku", Body: "Baterie ve Vašem bezdrátovém termostatu je nabita na méně než 30%.", Badge: 1)
                            seznamNotifikaci[indexKdeJeZarizeniProMDNSaAWS]="NOT CONNECTED"
                        }
                    }
                }
                if seznamPripojenychTeplomeru[indexKdeJeZarizeniProMDNSaAWS+1]=="Wireless"{
                    if seznamNotifikaci[indexKdeJeZarizeniProMDNSaAWS+1] != "NOT CONNECTED"{
                        if ((NapetiNaBaterie<1906)&&(NapetiNaBaterie>0)){
                            //baterie dosahla mene nez 30%
                            print("baterie dosahla mene nez 30%")
                            ShowNotification(Title: "Připojte nabíječku", Body: "Baterie ve Vašem bezdrátovém termostatu je nabita na méně než 30%.", Badge: 1)
                            seznamNotifikaci[indexKdeJeZarizeniProMDNSaAWS+1]="NOT CONNECTED"
                        }
                    }
                }
            }
            
            else if (PripojenaDobijecka=="LOW BATTERY"){
                //baterka je uplne vybita
                print("baterka je uplne vybita")
                if seznamPripojenychTeplomeru[indexKdeJeZarizeniProMDNSaAWS]=="Wireless"{
                    if seznamNotifikaci[indexKdeJeZarizeniProMDNSaAWS] != "LOW BATTERY"{
                        ShowNotification(Title: "Připojte nabíječku!", Body: "Váš bezdrátový termostat se vypnul z důvodu úplného vybití baterie.", Badge: 1)
                        seznamNotifikaci[indexKdeJeZarizeniProMDNSaAWS]="LOW BATTERY"
                    }
                }
                if seznamPripojenychTeplomeru[indexKdeJeZarizeniProMDNSaAWS+1]=="Wireless"{
                    if seznamNotifikaci[indexKdeJeZarizeniProMDNSaAWS+1] != "LOW BATTERY"{
                        ShowNotification(Title: "Připojte nabíječku!", Body: "Váš bezdrátový termostat se vypnul z důvodu úplného vybití baterie.", Badge: 1)
                        seznamNotifikaci[indexKdeJeZarizeniProMDNSaAWS+1]="LOW BATTERY"
                    }
                }
            }
            
        }
        
        
        
        
        
        if (ochranyInterval==false){
            if dict.keys.contains("RELAY1STATUS"){
                let rele1status = String(data: dict["RELAY1STATUS"]! as! Data, encoding: String.Encoding.utf8)!
                print("Text record (rele1status MDNS):", rele1status)
                if seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS] != "Prvni zarizeni" && (seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].contains("zarovka")||seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].contains("ventilator")||seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].contains("radiator")||seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].contains("zasuvka")){
                if rele1status=="ON"{
                    if seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].contains("OFF"){
                        let upravenyString = seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].replacingOccurrences(of: "OFF", with: "ON")
                        seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS]=upravenyString
                    }
                }
                
                
                if rele1status=="OFF"{
                    if seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].contains("ON"){
                        let upravenyString = seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].replacingOccurrences(of: "ON", with: "OFF")
                        seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS]=upravenyString
                    }
                    
                }
                }
            }
            
            if dict.keys.contains("RELAY2STATUS"){
                let rele2status = String(data: dict["RELAY2STATUS"]! as! Data, encoding: String.Encoding.utf8)!
                print("Text record (rele2status MDNS):", rele2status)
                //indexKdeJeZarizeniProMDNSaAWS=indexKdeJeZarizeniProMDNSaAWS+1//aby to sahalo v poli na druhe rele protoze maji stejnou mac adresu
                if seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1] != "Druhe zarizeni" && (seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].contains("zarovka")||seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].contains("ventilator")||seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].contains("radiator")||seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].contains("zasuvka")){
                if rele2status=="ON"{
                    if seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].contains("OFF"){
                        let upravenyString = seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].replacingOccurrences(of: "OFF", with: "ON")
                        seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1]=upravenyString
                    }
                    
                }
                
                if rele2status=="OFF"{
                    if seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].contains("ON"){
                        let upravenyString = seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].replacingOccurrences(of: "ON", with: "OFF")
                        seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1]=upravenyString
                    }
                    
                }
                }
            }
        }//konec if ochranyinterval
        print("zpracoval cely dict")
        dict.removeAll()
    }
    
    
    
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        self.updateInterface()
    }
    
    func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didFind aNetService: NetService, moreComing: Bool) {
        print("adding a service")
        self.services.append(aNetService)
        if !moreComing {
            self.updateInterface()
        }
    }
    
    func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didRemove aNetService: NetService, moreComing: Bool) {
        if let ix = self.services.firstIndex(of:aNetService) {
            self.services.remove(at:ix)
            print("removing a service")
        }
        if !moreComing {
            self.updateInterface()
        }
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
    override func viewWillDisappear(_ animated: Bool) {
        
        timer.invalidate()
        print("timer.invalidate() v viewWillDisappear")
        if probehloDiscovery==true{
            self.nsb.stop()
            self.services.removeAll()
        }
        probehloDiscovery=false
        super.viewWillDisappear(animated)
    }
    
    //--------------------------------------------------------
    // MARK: sendOverTCP --------------------------------
    //--------------------------------------------------------
    func sendOverTCP(message:String){
        //DispatchQueue.global(qos: .userInitiated).async {//nove vlakno
        if seznamMDNSvsAWS[indexVybranehoZarizeni]=="MDNS"{
            DispatchQueue.global().async {
                do {
                    print("IPadresaKekomuniaci:\(hostAdress)")
                    //ActivityIndicator("")
                    let chatSocket = try Socket.create(family: .inet6)
                    //print("nejde vytvorit socket")
                    print("vytvoril socket")
                    //try chatSocket.setReadTimeout(value:1)
                    //try chatSocket.setWriteTimeout(value: 1)
                    try chatSocket.setBlocking(mode: false)
                    //try chatSocket.connect(to: hostAdress, port: Int32(port))
                    try chatSocket.connect(to: hostAdress, port: Int32(port), timeout: 2500, familyOnly: false)//bylo 500
                    
                    print("Connected to: \(chatSocket.remoteHostname) on port \(chatSocket.remotePort)")
                    try chatSocket.setBlocking(mode: true)
                    try chatSocket.write(from: message)
                    print("odeslano")
                    // if (odeslanPrikazAktualizuj==false) {
                    //    try self.readFromServer(chatSocket)
                    //
                    //}
                    
                    //sleep(1)  // Be nice to the server
                    chatSocket.close()
                    print("chat socket close")
                    ochranyInterval=true
                    //print("za ochrany interval")
                }
                catch {
                    guard let socketError = error as? Socket.Error else {
                        print("Unexpected error ...")
                        return
                    }
                    print("Error reported:\n \(socketError.description)")
                    //removeActivityIndicator()
                    
                    //sem dodelat aby se rovnou zapsal do pole jako offline
                    //seznamOnlineZarizeni[indexVybranehoZarizeni]="OFFline"
                    // create the alert
                    DispatchQueue.main.async {
                        let nadpis = "Connection ERROR"
                        let messageBox = UIAlertController(title: nadpis, message: "Zarizeni nedpovida", preferredStyle: .alert)
                        let AkceOK = UIAlertAction(title: "OK", style: .default){//pokud se stikne tlacitko OK
                            (ACTION) in
                            //self.performSegue(withIdentifier: "backToTheDeviceList", sender: self)
                            seznamOnlineZarizeni[indexVybranehoZarizeni]="OFFline"
                            print("nastavuji \(seznamNazvuZarizeni[indexVybranehoZarizeni]) na OFFline ")
                            DispatchQueue.main.async {//zakomentoval jsme 29.12.2020
                                self.collectionView.reloadData()
                           }
                        }
                        
                        messageBox.addAction(AkceOK)
                        self.present(messageBox,animated: true)
                    }
                    
                }
                
            }//konec novz thread
        }//konec mdns
        else if seznamMDNSvsAWS[indexVybranehoZarizeni]=="AWS"{
            DispatchQueue.global().async {
                do {
                    ochranyInterval=false
                    AWSmessage="{\"message\": \"\(message)\"}"
                    AWStopic="\(seznamTopicu[indexVybranehoZarizeni/2] as String)dataProModul"
                    NotificationCenter.default.post(name:NSNotification.Name("AWSprikaz"), object: nil)
                    self.casovacProAWS=0;
                    //self.reloadCollectionView()
                }
            }
        }
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
            //zpracujTCPdata()
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
