//
//  WelcomeController.swift
//  Control center
//
//  Created by Ivo Dvorak on 10/07/2019.
//  Copyright © 2019 Ivo Dvorak. All rights reserved.
//

import UIKit
import Foundation
import AudioToolbox
import Reachability
import Network
import AWSIoT
import AWSCore
import iProgressHUD


let DEBUGMSG=true//kdyz je true tak pise debug na vystup

var reachability:Reachability?

var activityIndicator = UIActivityIndicatorView(style: .large)
var strLabel = UILabel()
let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
let blurEffectView = UIVisualEffectView(effect: blurEffect)
var seznamNazvuZarizeni = [String]()
var seznamMACZarizeni = [String]()
var seznamOnlineZarizeni = [String]()
var seznamIPZarizeni = [String]()
var seznamUmisteniZarizeni = [String]()
var seznamObrazkuZarizeni = [String]()
var poradoveCisloRele = [String]()
var seznamMerenychTeplot = [String]()
var seznamPozadovanychTeplot = [String]()
var seznamProvoznichRezimu = [String]()
var seznamVerziFirmwaru = [String]()
var seznamZparovanychZarizeni = [String]()
var seznamPripojenychTeplomeru = [String]()
var seznamCasuVmodulech = [String]()
var seznamTopicu = [String]()
var seznamDostupnychAktualizaciVmodulech = [String]()
var seznamZparovanychShomekitem = [String]()
var seznamQRkodu = [String]()
var seznamKoduHomekitu = [String]()
var seznamBarevModulu = [UIColor]()
var seznamHysterezi = [String]()
var seznamTimeru = [String]()
var seznamRSSI = [String]()
var seznamSSID = [String]()
var seznamTopoimChladim = [String]()
var seznamMinimalnichTeplot = [String]()
var seznamMaximalnichTeplot = [String]()
var seznamKladnaHystereze = [String]()
var seznamZapornaHystereze = [String]()
var spustenWelcomeController = false
var seznamZarizeniDleIpAdres = [String]()
var seznamMDNSvsAWS = [String]()
var verzeFWnaServeru = "000000"
var verzeFWTermostatunaServeru = "000000"
var Colours = [UIColor]()
var minimalniTeplota = 0
var maximalniTeplota = 40
var seznamNotifikaci = [String]()
var seznamNavoduNaYoutube = [String]()
var seznamTextuNavodu = [String]()
var ConnectedToAWS=false
var HledatPresMDNS=false
var AWSmessage=""
var AWStopic=""
var uzProbehlaCelaFunkce = true;




class WelcomeController: UIViewController,UNUserNotificationCenterDelegate {
    
    
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
    
    
    @IBAction func btnInfoClick(_ sender: Any) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NavodKpouzitiController")
        viewController.modalPresentationStyle = .pageSheet
        self.present(viewController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var btnAddDeviceOutlet: UIButton!
    
    @IBAction func btnAddDeviceClick(_ sender: Any) {
        //sem dopsat hlasku o nutnosti zapnuteho BLE
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        if DEBUGMSG{
            print("DBGMSG:Click na Addbutton")
        }
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        let message  = "Ujistěte se, že máte zapnuté Bluethoot a jste připojeni na domácí wifi síť"
        var messageMutableString = NSMutableAttributedString()
        messageMutableString = NSMutableAttributedString(string: message as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Aller", size: 18.0)!])
        messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 60/255, green: 60/255, blue: 60/255, alpha: 1), range:NSRange(location:0,length:message.count))
        alertController.setValue(messageMutableString, forKey: "attributedMessage")
        
        
        let okAction = UIAlertAction(title: "Ano", style: .default) { (action) in
            if DEBUGMSG{
                print("Alert Click OK")
            }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.performSegue(withIdentifier: "showNavodOne", sender: Any?.self)
        }
        
        
        alertController.addAction(okAction)
        
        
        alertController.view.tintColor = UIColor.init(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        
        //alertController.view.backgroundColor = UIColor.black
        alertController.view.layer.cornerRadius = 40
        
        present(alertController, animated: true, completion: nil)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //setGradientBackground()
        spustenWelcomeController=true
        super.viewWillAppear(animated)
    }
    
    
    
    let reachability = try! Reachability()
    //--------------------------------------------------------
    // MARK: viewDidLoad --------------------------------
    //--------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        uzDoslaData=false
        if UserDefaults.standard.object(forKey: "JizByloSpusteno")as? String ?? ""=="ANO"{//ma tam byt ANO
            if DEBUGMSG{
                print("DBGMSG:UZ BYLO SPUSTENO")
            }
            
            if UserDefaults.standard.object(forKey: "seznamMACZarizeni") != nil{
                seznamMACZarizeni = UserDefaults.standard.object(forKey: "seznamMACZarizeni") as! [String]
            }
            
            if UserDefaults.standard.object(forKey: "seznamNazvuZarizeni") != nil{
                seznamNazvuZarizeni = UserDefaults.standard.object(forKey: "seznamNazvuZarizeni") as! [String]
            }
            
            if UserDefaults.standard.object(forKey: "seznamPozadovanychTeplot") != nil{
                seznamPozadovanychTeplot = UserDefaults.standard.object(forKey: "seznamPozadovanychTeplot") as! [String]
            }
            
            if UserDefaults.standard.object(forKey: "seznamProvoznichRezimu") != nil{
                seznamProvoznichRezimu = UserDefaults.standard.object(forKey: "seznamProvoznichRezimu") as! [String]
            }
            
            //if UserDefaults.standard.object(forKey: "seznamVerziFirmwaru") != nil{
            //seznamVerziFirmwaru = UserDefaults.standard.object(forKey: "seznamVerziFirmwaru") as! [String]
            //}
            
            if UserDefaults.standard.object(forKey: "poleZobrazenychteplotnaTopeni") != nil{
                poleZobrazenychteplotnaTopeni = UserDefaults.standard.object(forKey: "poleZobrazenychteplotnaTopeni") as! [String]
            }
            
            //if UserDefaults.standard.object(forKey: "poleKalendaru") != nil{
            //    poleKalendaru = UserDefaults.standard.object(forKey: "poleKalendaru") as! [[[[String]]]]
            //}
            
            
            if UserDefaults.standard.object(forKey: "PondeliSpinaciCasyAteploty") != nil{
                PondeliSpinaciCasyAteploty = UserDefaults.standard.object(forKey: "PondeliSpinaciCasyAteploty") as! [[String]]
            }
            if UserDefaults.standard.object(forKey: "seznamMaximalnichTeplot") != nil{
                seznamMaximalnichTeplot = UserDefaults.standard.object(forKey: "seznamMaximalnichTeplot") as! [String]
            }
            if UserDefaults.standard.object(forKey: "seznamMinimalnichTeplot") != nil{
                seznamMinimalnichTeplot = UserDefaults.standard.object(forKey: "seznamMinimalnichTeplot") as! [String]
            }
            
            if UserDefaults.standard.object(forKey: "UterySpinaciCasyAteploty") != nil{
                UterySpinaciCasyAteploty = UserDefaults.standard.object(forKey: "UterySpinaciCasyAteploty") as! [[String]]
            }
            
            if UserDefaults.standard.object(forKey: "StredaSpinaciCasyAteploty") != nil{
                StredaSpinaciCasyAteploty = UserDefaults.standard.object(forKey: "StredaSpinaciCasyAteploty") as! [[String]]
            }
            
            if UserDefaults.standard.object(forKey: "CtvrtekSpinaciCasyAteploty") != nil{
                CtvrtekSpinaciCasyAteploty = UserDefaults.standard.object(forKey: "CtvrtekSpinaciCasyAteploty") as! [[String]]
            }
            
            if UserDefaults.standard.object(forKey: "PatekSpinaciCasyAteploty") != nil{
                PatekSpinaciCasyAteploty = UserDefaults.standard.object(forKey: "PatekSpinaciCasyAteploty") as! [[String]]
            }
            
            if UserDefaults.standard.object(forKey: "SobotaSpinaciCasyAteploty") != nil{
                SobotaSpinaciCasyAteploty = UserDefaults.standard.object(forKey: "SobotaSpinaciCasyAteploty") as! [[String]]
            }
            
            if UserDefaults.standard.object(forKey: "NedeleSpinaciCasyAteploty") != nil{
                NedeleSpinaciCasyAteploty = UserDefaults.standard.object(forKey: "NedeleSpinaciCasyAteploty") as! [[String]]
            }
            
            if UserDefaults.standard.object(forKey: "PondeliSpinaciCasy") != nil{
                PondeliSpinaciCasy = UserDefaults.standard.object(forKey: "PondeliSpinaciCasy") as! [[String]]
            }
            
            if UserDefaults.standard.object(forKey: "UterySpinaciCasy") != nil{
                UterySpinaciCasy = UserDefaults.standard.object(forKey: "UterySpinaciCasy") as! [[String]]
            }
            
            if UserDefaults.standard.object(forKey: "StredaSpinaciCasy") != nil{
                StredaSpinaciCasy = UserDefaults.standard.object(forKey: "StredaSpinaciCasy") as! [[String]]
            }
            
            if UserDefaults.standard.object(forKey: "CtvrtekSpinaciCasy") != nil{
                CtvrtekSpinaciCasy = UserDefaults.standard.object(forKey: "CtvrtekSpinaciCasy") as! [[String]]
            }
            
            if UserDefaults.standard.object(forKey: "PatekSpinaciCasy") != nil{
                PatekSpinaciCasy = UserDefaults.standard.object(forKey: "PatekSpinaciCasy") as! [[String]]
            }
            
            if UserDefaults.standard.object(forKey: "SobotaSpinaciCasy") != nil{
                SobotaSpinaciCasy = UserDefaults.standard.object(forKey: "SobotaSpinaciCasy") as! [[String]]
            }
            
            if UserDefaults.standard.object(forKey: "NedeleSpinaciCasy") != nil{
                NedeleSpinaciCasy = UserDefaults.standard.object(forKey: "NedeleSpinaciCasy") as! [[String]]
            }
            
            
            if UserDefaults.standard.object(forKey: "minimalniTeplota") != nil{
                minimalniTeplota = UserDefaults.standard.object(forKey: "minimalniTeplota") as! Int
            }
            
            if UserDefaults.standard.object(forKey: "maximalniTeplota") != nil{
                maximalniTeplota = UserDefaults.standard.object(forKey: "maximalniTeplota") as! Int
            }
            
            
            if UserDefaults.standard.object(forKey: "seznamMerenychTeplot") != nil{
                seznamMerenychTeplot = UserDefaults.standard.object(forKey: "seznamMerenychTeplot") as! [String]
            }
            
            if UserDefaults.standard.object(forKey: "seznamIPZarizeni") != nil{
                seznamIPZarizeni = UserDefaults.standard.object(forKey: "seznamIPZarizeni") as! [String]
            }
            
            if UserDefaults.standard.object(forKey: "seznamUmisteniZarizeni") != nil{
                seznamUmisteniZarizeni = UserDefaults.standard.object(forKey: "seznamUmisteniZarizeni") as! [String]
            }
            
            if UserDefaults.standard.object(forKey: "seznamObrazkuZarizeni") != nil{
                seznamObrazkuZarizeni = UserDefaults.standard.object(forKey: "seznamObrazkuZarizeni") as! [String]
            }
            
            if UserDefaults.standard.object(forKey: "poradoveCisloRele") != nil{
                poradoveCisloRele = UserDefaults.standard.object(forKey: "poradoveCisloRele") as! [String]
            }
            
            if UserDefaults.standard.object(forKey: "nazevDomacnosti") != nil{
                nazevDomacnosti = UserDefaults.standard.object(forKey: "nazevDomacnosti") as! String
            }
            
            
            seznamTopicu.removeAll()
            
            for indexPole in 0..<seznamMACZarizeni.count/2{
                //napni to topicama k teryma se ma kominikovat
                var MACadress = seznamMACZarizeni[indexPole*2].replacingOccurrences(of: "EMTRON-CZ-2-RELAYS-MODULE{", with: "")
                MACadress = MACadress.replacingOccurrences(of: "}", with: "/")
                seznamTopicu.append(MACadress)
                
            }
            
            seznamMDNSvsAWS.removeAll()
            for index in 0..<seznamMACZarizeni.count{
                //po zapnuti jsou vsechny offline
                //print("index je:\(index)")
                seznamMDNSvsAWS.append("AWS")
                
            }
            
            seznamOnlineZarizeni.removeAll()
            for index in 0..<seznamMACZarizeni.count{
                //po zapnuti jsou vsechny offline
                //print("index je:\(index)")
                seznamOnlineZarizeni.append("OFFline")
                
            }
            
            seznamZparovanychZarizeni.removeAll()
            for index in 0..<seznamMACZarizeni.count{
                //po zapnuti jsou vsechny offline
                //print("index je:\(index)")
                seznamZparovanychZarizeni.append("0")
                
            }
            
            if seznamMinimalnichTeplot.count==0{
                for index in 0..<seznamMACZarizeni.count{
                    //po zapnuti jsou vsechny offline
                    //print("index je:\(index)")
                    seznamMinimalnichTeplot.append("0")
                    
                }
            }
            if seznamMaximalnichTeplot.count==0{
                for index in 0..<seznamMACZarizeni.count{
                    //po zapnuti jsou vsechny offline
                    //print("index je:\(index)")
                    seznamMaximalnichTeplot.append("40")
                    
                }
            }
            
            
            seznamPripojenychTeplomeru.removeAll()
            for index in 0..<seznamMACZarizeni.count{
                //po zapnuti jsou vsechny offline
                //print("index je:\(index)")
                seznamPripojenychTeplomeru.append("")
                
            }
            
            seznamTimeru.removeAll()
            for index in 0..<seznamMACZarizeni.count{
                //po zapnuti jsou vsechny offline
                //print("index je:\(index)")
                seznamTimeru.append("0")
                
            }
            
            if UserDefaults.standard.object(forKey: "seznamZparovanychShomekitem") != nil{
                seznamZparovanychShomekitem = UserDefaults.standard.object(forKey: "seznamZparovanychShomekitem") as! [String]
                
            }
            if UserDefaults.standard.object(forKey: "seznamQRkodu") != nil{
                seznamQRkodu = UserDefaults.standard.object(forKey: "seznamQRkodu") as! [String]
            }
            
            if UserDefaults.standard.object(forKey: "seznamKoduHomekitu") != nil{
                seznamKoduHomekitu = UserDefaults.standard.object(forKey: "seznamKoduHomekitu") as! [String]
            }
            if seznamZparovanychShomekitem.count != seznamMACZarizeni.count{
                seznamZparovanychShomekitem.removeAll()
                for index in 0..<seznamMACZarizeni.count{
                    //po zapnuti jsou vsechny offline
                    //print("index je:\(index)")
                    seznamZparovanychShomekitem.append("")
                    
                }
            }
            if seznamQRkodu.count != seznamMACZarizeni.count{
                
                seznamQRkodu.removeAll()
                for index in 0..<seznamMACZarizeni.count{
                    //po zapnuti jsou vsechny offline
                    //print("index je:\(index)")
                    seznamQRkodu.append("")
                    
                }
            }
            if seznamKoduHomekitu.count != seznamMACZarizeni.count{
                seznamKoduHomekitu.removeAll()
                for index in 0..<seznamMACZarizeni.count{
                    //po zapnuti jsou vsechny offline
                    //print("index je:\(index)")
                    seznamKoduHomekitu.append("")
                    
                }
            }
            
            
            if UserDefaults.standard.object(forKey: "seznamKladnaHystereze") != nil{
                seznamKladnaHystereze = UserDefaults.standard.object(forKey: "seznamKladnaHystereze") as! [String]
            }
            if seznamKladnaHystereze.count != seznamMACZarizeni.count{
                seznamKladnaHystereze.removeAll()
                for index in 0..<seznamMACZarizeni.count{
                    //po zapnuti jsou vsechny offline
                    //print("index je:\(index)")
                    seznamKladnaHystereze.append("0.5")
                    
                }
            }
            
            if UserDefaults.standard.object(forKey: "seznamZapornaHystereze") != nil{
                seznamZapornaHystereze = UserDefaults.standard.object(forKey: "seznamZapornaHystereze") as! [String]
            }
            if seznamZapornaHystereze.count != seznamMACZarizeni.count{
                seznamZapornaHystereze.removeAll()
                for index in 0..<seznamMACZarizeni.count{
                    //po zapnuti jsou vsechny offline
                    //print("index je:\(index)")
                    seznamZapornaHystereze.append("0.5")
                    
                }
            }
            
            if UserDefaults.standard.object(forKey: "seznamTopoimChladim") != nil{
                seznamTopoimChladim = UserDefaults.standard.object(forKey: "seznamTopoimChladim") as! [String]
            }
            if seznamTopoimChladim.count != seznamMACZarizeni.count{
                seznamTopoimChladim.removeAll()
                for index in 0..<seznamMACZarizeni.count{
                    //po zapnuti jsou vsechny offline
                    //print("index je:\(index)")
                    seznamTopoimChladim.append("Topim")
                    
                }
            }
            
            seznamHysterezi.removeAll()
            for index in 0..<seznamMACZarizeni.count{
                //po zapnuti jsou vsechny offline
                //print("index je:\(index)")
                seznamHysterezi.append("")
                
            }
            
            seznamNotifikaci.removeAll()
            for index in 0..<seznamMACZarizeni.count{
                //po zapnuti jsou vsechny offline
                //print("index je:\(index)")
                seznamNotifikaci.append("")
                
            }
            
            seznamRSSI.removeAll()
            for _ in 0..<seznamMACZarizeni.count{
                //po zapnuti jsou vsechny offline
                //print("index je:\(index)")
                seznamRSSI.append("")
                
            }
            seznamSSID.removeAll()
            for _ in 0..<seznamMACZarizeni.count{
                //po zapnuti jsou vsechny offline
                //print("index je:\(index)")
                seznamSSID.append("")
                
            }
            if UserDefaults.standard.object(forKey: "seznamBarevModulu") != nil{
                seznamBarevModulu = UserDefaults.standard.object(forKey: "seznamBarevModulu") as! [UIColor]
            }
            if seznamBarevModulu.count != seznamMACZarizeni.count{
                seznamBarevModulu.removeAll()
                for _ in 0..<seznamMACZarizeni.count{
                    //po zapnuti jsou vsechny offline
                    //print("index je:\(index)")
                    seznamBarevModulu.append(UIColor.init(red: 90/255, green: 90/255, blue: 90/255, alpha: 1))//nastavi se seda barva
                }
            }
            seznamVerziFirmwaru.removeAll()
            for _ in 0..<seznamMACZarizeni.count{
                //po zapnuti jsou vsechny offline
                //print("index je:\(index)")
                seznamVerziFirmwaru.append(verzeFWnaServeru)
                
            }
            
            seznamDostupnychAktualizaciVmodulech.removeAll()
            for _ in 0..<seznamMACZarizeni.count{
                //po zapnuti jsou vsechny offline
                //print("index je:\(index)")
                seznamDostupnychAktualizaciVmodulech.append("0")
                
            }
            
            seznamCasuVmodulech.removeAll()
            for _ in 0..<seznamMACZarizeni.count{
                //po zapnuti jsou vsechny offline
                //print("index je:\(index)")
                seznamCasuVmodulech.append("")
                
            }
            
            
        }
        /*
         for index in 0..<seznamMACZarizeni.count{
         //po zapnuti jsou vsechny offline
         //print("index je:\(index)")
         seznamMDNSvsAWS.append("OFFline")
         }*/
        
        //XOffset=(view.bounds.size.height / 3)*2
        //declare this property where it won't go out of scope relative to your listener
        let iprogress: iProgressHUD = iProgressHUD()
        // Attach iProgressHUD to views
        //iProgressHUD.sharedInstance().attachProgress(toView: self.view)
        // Show iProgressHUD directly from view
        iprogress.modalColor = .clear
        iprogress.boxColor = .clear
        iprogress.isBlurModal=false
        iprogress.boxSize=25
        iprogress.isTouchDismiss = false
        iprogress.indicatorStyle = .pacman
        iprogress.YOffset=(view.bounds.size.height / 3)*2
        iprogress.attachProgress(toView: self.view)
        view.updateCaption(text: "Connecting...")
        view.showProgress()
        
        Colours.append(UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1))
        Colours.append(UIColor(red: 100/255, green: 50/255, blue: 50/255, alpha: 1))
        Colours.append(UIColor(red: 150/255, green: 50/255, blue: 50/255, alpha: 1))
        Colours.append(UIColor(red: 50/255, green: 100/255, blue: 50/255, alpha: 1))
        Colours.append(UIColor(red: 50/255, green: 150/255, blue: 50/255, alpha: 1))
        Colours.append(UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1))
        Colours.append(UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1))
        Colours.append(UIColor(red: 50/255, green: 50/255, blue: 100/255, alpha: 1))
        Colours.append(UIColor(red: 50/255, green: 50/255, blue: 150/255, alpha: 1))
        
        Colours.append(.white)
        Colours.append(.green)
        Colours.append(.gray)
        Colours.append(.yellow)
        Colours.append(.orange)
        Colours.append(.red)
        Colours.append(.darkGray)
        Colours.append(.purple)
        Colours.append(.magenta)
        //declare this inside of viewWillAppear
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
        btnAddDeviceOutlet.setBackgroundImage(UIImage(named: "AddDevice"), for: UIControl.State.normal)
        btnAddDeviceOutlet.isHidden=true//zkryje tlacitko na pridani zarizeni
        //if DEBUGMSG{
        print("Dobrý den z aplikace EMTRON SMART HOME")
        //}
        //declare this property where it won't go out of scope relative to your listener
        verzeFWnaServeru=""
        performSelector(inBackground: #selector(testVerzeFirmwaru), with: nil)
        performSelector(inBackground: #selector(NactiNavodyzYouTube), with: nil)
        
        //let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USWest2, identityPoolId: "us-west-2:a0beab9c-5291-4823-b59a-eb04e7478a79")
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .EUWest2, identityPoolId: "eu-west-2:4bd878da-aa44-4505-a750-0287df17b758")
        let configuration = AWSServiceConfiguration(region: .EUWest2, credentialsProvider: credentialsProvider)
        
        // Initialising AWS IoT And IoT DataManager
        AWSIoT.register(with: configuration!, forKey: "kAWSIoT")  // Same configuration var as above
        
        let iotEndPoint = AWSEndpoint(urlString: "wss://af2xn8zfxtv6i-ats.iot.eu-west-2.amazonaws.com/mqtt") // Access from AWS IoT Core --> Settings
        let iotDataConfiguration = AWSServiceConfiguration(region: .EUWest2,     // Use AWS typedef .Region
                                                           endpoint: iotEndPoint,
                                                           credentialsProvider: credentialsProvider)  // credentials is the same var as created above
        /*
         let iotEndPoint = AWSEndpoint(urlString: "wss://af2xn8zfxtv6i-ats.iot.us-west-2.amazonaws.com/mqtt") // Access from AWS IoT Core --> Settings
         let iotDataConfiguration = AWSServiceConfiguration(region: .USWest2,     // Use AWS typedef .Region
         endpoint: iotEndPoint,
         credentialsProvider: credentialsProvider)  // credentials is the same var as created above
         */
        AWSIoTDataManager.register(with: iotDataConfiguration!, forKey: "kDataManager")
        
        
        // Access the AWSDataManager instance as follows:
        let dataManager = AWSIoTDataManager(forKey: "kDataManager")
        //var ClientID=""
        
        getAWSClientID()
        connectToAWSIoT(clientId: ClientID)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HaloKdoJsteOnline), name: NSNotification.Name("HaloKdoJsteOnline"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AWSprikaz), name: NSNotification.Name("AWSprikaz"), object: nil)
    }
    
    func getAWSClientID() {
        // Depending on your scope you may still have access to the original credentials var
        //let credentials =  AWSCognitoCredentialsProvider(regionType: .USWest2, identityPoolId: "us-west-2:a0beab9c-5291-4823-b59a-eb04e7478a79")
        let credentials =  AWSCognitoCredentialsProvider(regionType: .EUWest2, identityPoolId: "eu-west-2:4bd878da-aa44-4505-a750-0287df17b758")
        credentials.getIdentityId().continueWith(block: { (task:AWSTask<NSString>) -> Any? in
            if let error = task.error as NSError? {
                print("Failed to get client ID => \(error)")
                //completion(nil, error)
                return nil  // Required by AWSTask closure
            }
            
            let clientId = task.result! as String
            print("Got client ID => \(clientId)")
            ClientID=clientId
            //completion(clientId, nil)
            return nil // Required by AWSTask closure
        })
    }
    
    
    @objc private func HaloKdoJsteOnline(){
        print("zacatek funkce HaloKdoJsteOnline")
        for index in 0..<seznamMACZarizeni.count{
            print("Nastavuju vse na OFFLINE v HaloKdoJsteOnline")
            if seznamMDNSvsAWS[index]=="AWS"{
                seznamOnlineZarizeni[index]=("OFFline")
            }
            
        }
        
        if uzProbehlaCelaFunkce == true{
            uzProbehlaCelaFunkce=false
            DispatchQueue.global(qos: .background).async {
                
                for index in 0..<seznamTopicu.count{
                    self.publishMessage(message: "{\"message\": \"PosliData\"}", topic: "\(seznamTopicu[index] as String)dataProModul")//posle vsem sparovanym modulum at se mu ozvou
                    usleep(100000)
                }
                uzProbehlaCelaFunkce=true
                print("konec funkce HaloKdoJsteOnline")
                NotificationCenter.default.post(name:NSNotification.Name("zpracujDictionaryAWS"), object: nil)
            }
            
        }
        
    }
    
    @objc func AWSprikaz() {
        print("message:\(AWSmessage) topic:\(AWStopic)")
        let dataManager = AWSIoTDataManager(forKey: "kDataManager")
        dataManager.publishString(AWSmessage, onTopic: AWStopic, qoS: .messageDeliveryAttemptedAtLeastOnce) // Set QoS as needed
    }
    
    func connectToAWSIoT(clientId: String!) {
        
        func mqttEventCallback(_ status: AWSIoTMQTTStatus ) {
            switch status {
            case .connecting: print("Connecting to AWS IoT")
            case .connected:
                print("Connected to AWS IoT")
                // Register subscriptions here
                // Publish a boot message if required
                registerSubscriptions()
                //HaloKdoJsteOnline()
                ConnectedToAWS=true
            //ProgressHUD.showSuccess()
            case .connectionError: print("AWS IoT connection error")
            //LoadingProgressHUD.dismiss()
            //LoadingProgressHUD.resetOffsetFromCenter()
            //LoadingProgressHUD.showInfowithStatus("Connection ERROR")
            //LoadingProgressHUD.setHUD(backgroundColor: UIColor.white)
            //LoadingProgressHUD.set(borderColor: UIColor.systemRed)
            //LoadingProgressHUD.set(foregroundColor: UIColor.darkGray)
            //LoadingProgressHUD.set(frontTextColor: UIColor.darkGray)
            
            case .connectionRefused: print("AWS IoT connection refused")
            case .protocolError: print("AWS IoT protocol error")
            case .disconnected: print("AWS IoT disconnected")
            case .unknown: print("AWS IoT unknown state")
            default: print("Error - unknown MQTT state")
            }
        }
        
        // Ensure connection gets performed background thread (so as not to block the UI)
        DispatchQueue.global(qos: .background).async {
            do {
                print("Attempting to connect to IoT device gateway with ID = \(clientId)")
                let dataManager = AWSIoTDataManager(forKey: "kDataManager")
                dataManager.connectUsingWebSocket(withClientId: clientId,
                                                  cleanSession: true,
                                                  statusCallback: mqttEventCallback)
                
            } catch {
                print("Error, failed to connect to device gateway => \(error)")
            }
        }
    }
    
    func registerSubscriptions() {
        
        func messageReceived(payload: Data) {
            //LoadingProgressHUD.dismiss()
            let dictMQTT = jsonDataToDict(jsonData: payload)
            print("Message received: \(dictMQTT)")
            
            if let macovka = dictMQTT["MAC"] as? String{
                pocitadlo=pocitadlo+1
                print("POCITADLOSTART\(pocitadlo)")
                if (seznamMACZarizeni.contains("EMTRON-CZ-2-RELAYS-MODULE{\(macovka)}")) {
                    indexKdeJeZarizeniProMDNSaAWS = seznamMACZarizeni.firstIndex(of: "EMTRON-CZ-2-RELAYS-MODULE{\(macovka)}")!
                    seznamOnlineZarizeni[indexKdeJeZarizeniProMDNSaAWS]="ONline"
                    seznamOnlineZarizeni[indexKdeJeZarizeniProMDNSaAWS+1]="ONline"
                    if seznamMDNSvsAWS[indexKdeJeZarizeniProMDNSaAWS] != "MDNS"{
                        seznamMDNSvsAWS[indexKdeJeZarizeniProMDNSaAWS]="AWS"
                    }
                    if seznamMDNSvsAWS[indexKdeJeZarizeniProMDNSaAWS+1] != "MDNS"{
                        seznamMDNSvsAWS[indexKdeJeZarizeniProMDNSaAWS+1]="AWS"
                    }
                    
                    
                    
                    
                    
                    print("zavolana funkce zpracujDictionary MQTT")
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
                    
                    
                    
                    if dictMQTT.keys.contains("IPadress"){
                        seznamIPZarizeni[indexKdeJeZarizeniProMDNSaAWS]=dictMQTT["IPadress"] as! String
                        seznamIPZarizeni[indexKdeJeZarizeniProMDNSaAWS+1]=dictMQTT["IPadress"] as! String
                    }
                    if dictMQTT.keys.contains("FWVERSION"){
                        seznamVerziFirmwaru[indexKdeJeZarizeniProMDNSaAWS] = dictMQTT["FWVERSION"] as! String
                        seznamVerziFirmwaru[indexKdeJeZarizeniProMDNSaAWS+1] = dictMQTT["FWVERSION"] as! String
                        
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
                    
                    if dictMQTT.keys.contains("HOMEKIT_PASSW"){
                        seznamKoduHomekitu [indexKdeJeZarizeniProMDNSaAWS] = dictMQTT["HOMEKIT_PASSW"] as! String
                        seznamKoduHomekitu [indexKdeJeZarizeniProMDNSaAWS] = seznamKoduHomekitu [indexKdeJeZarizeniProMDNSaAWS].replacingOccurrences(of: "-", with: "")
                        
                        seznamKoduHomekitu[indexKdeJeZarizeniProMDNSaAWS+1] = dictMQTT["HOMEKIT_PASSW"]! as! String
                        seznamKoduHomekitu [indexKdeJeZarizeniProMDNSaAWS+1] = seznamKoduHomekitu [indexKdeJeZarizeniProMDNSaAWS+1].replacingOccurrences(of: "-", with: "")
                        UserDefaults.standard.setValue(seznamKoduHomekitu, forKey: "seznamKoduHomekitu")
                    }
                    
                    if dictMQTT.keys.contains("HomekitPaired"){
                        seznamZparovanychShomekitem [indexKdeJeZarizeniProMDNSaAWS] = dictMQTT["HomekitPaired"] as! String
                        seznamZparovanychShomekitem[indexKdeJeZarizeniProMDNSaAWS+1] = dictMQTT["HomekitPaired"] as! String
                        UserDefaults.standard.setValue(seznamZparovanychShomekitem, forKey: "seznamZparovanychShomekitem")
                    }
                    
                    if dictMQTT.keys.contains("RSSI"){
                        seznamRSSI[indexKdeJeZarizeniProMDNSaAWS] = dictMQTT["RSSI"] as! String
                        seznamRSSI[indexKdeJeZarizeniProMDNSaAWS+1] = dictMQTT["RSSI"] as! String
                    }
                    
                    if dictMQTT.keys.contains("SSID"){
                        seznamSSID[indexKdeJeZarizeniProMDNSaAWS] = dictMQTT["SSID"] as! String
                        seznamSSID[indexKdeJeZarizeniProMDNSaAWS+1] = dictMQTT["SSID"] as! String
                    }
                    
                    if dictMQTT.keys.contains("Hystereze"){
                        dataKeZpracovani = dictMQTT["Hystereze"] as! String
                        seznamKladnaHystereze[indexKdeJeZarizeniProMDNSaAWS]=parsujData(prvniZnak: "!", druhyZnak: "@")
                        seznamKladnaHystereze[indexKdeJeZarizeniProMDNSaAWS+1]=parsujData(prvniZnak: "@", druhyZnak: "#")
                        seznamZapornaHystereze[indexKdeJeZarizeniProMDNSaAWS]=parsujData(prvniZnak: "#", druhyZnak: "$")
                        seznamZapornaHystereze[indexKdeJeZarizeniProMDNSaAWS+1]=parsujData(prvniZnak: "$", druhyZnak: "%")
                        seznamTopoimChladim[indexKdeJeZarizeniProMDNSaAWS]=parsujData(prvniZnak: "%", druhyZnak: "^")
                        seznamTopoimChladim[indexKdeJeZarizeniProMDNSaAWS]=parsujData(prvniZnak: "^", druhyZnak: "&")
                    }
                    
                    if dictMQTT.keys.contains("HOMEKIT_QRcode"){
                        seznamQRkodu[indexKdeJeZarizeniProMDNSaAWS] = dictMQTT["HOMEKIT_QRcode"] as! String
                        seznamQRkodu[indexKdeJeZarizeniProMDNSaAWS+1] = dictMQTT["HOMEKIT_QRcode"] as! String
                        UserDefaults.standard.setValue(seznamQRkodu, forKey: "seznamQRkodu")
                    }
                    
                    
                    
                    if dictMQTT.keys.contains("TEMPACT1"){
                        //var teplota1:Float = String(data: dict["TEMPACT1"]!, encoding: String.Encoding.utf8).
                        //teplota1
                        seznamMerenychTeplot[indexKdeJeZarizeniProMDNSaAWS] = dictMQTT["TEMPACT1"] as! String
                        
                    }
                    
                    if dictMQTT.keys.contains("TEMPACT2"){
                        //var teplota1:Float = String(data: dict["TEMPACT1"]!, encoding: String.Encoding.utf8).
                        //teplota1
                        
                        seznamMerenychTeplot[indexKdeJeZarizeniProMDNSaAWS+1] = dictMQTT["TEMPACT2"] as! String
                    }
                    
                    if dictMQTT.keys.contains("ICONE1"){
                        if (dictMQTT["ICONE1"] as! String) != ""{
                        //var teplota1:Float = String(data: dict["TEMPACT1"]!, encoding: String.Encoding.utf8).
                        //teplota1
                        if seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].contains("zarovka")||seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].contains("ventilator")||seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].contains("radiator")||seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].contains("zasuvka")||seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].contains("Prvni zarizeni"){
                            if seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].contains("NoRespone"){
                                seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS] = "\(dictMQTT["ICONE1"] as! String)NoRespone"
                            }
                            else if seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].contains("ON"){
                                seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS] = "\(dictMQTT["ICONE1"] as! String)ON"
                            }
                            else if seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].contains("OFF"){
                                seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS] = "\(dictMQTT["ICONE1"] as! String)OFF"
                            }
                            else{
                                seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS] = "\(dictMQTT["ICONE1"] as! String)"
                            }
                        }
                        else {
                            seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS] = "Prvni zarizeni"
                        }
                    }
                    }
                    
                    if dictMQTT.keys.contains("ICONE2"){
                        if (dictMQTT["ICONE2"] as! String) != ""{
                        if seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].contains("zarovka")||seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].contains("ventilator")||seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].contains("radiator")||seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].contains("zasuvka")||seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].contains("Druhe zarizeni"){
                            if seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].contains("NoRespone"){
                                seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1] = "\(dictMQTT["ICONE2"] as! String)NoRespone"
                            }
                            else if seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].contains("ON"){
                                seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1] = "\(dictMQTT["ICONE2"] as! String)ON"
                            }
                            else if seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].contains("OFF"){
                                seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1] = "\(dictMQTT["ICONE2"] as! String)OFF"
                            }
                            else{
                                seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1] = "\(dictMQTT["ICONE2"] as! String)"
                            }
                        }
                        else {
                            seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1] = "Druhe zarizeni"
                        }
                        
                    }
                }
                    
                    if dictMQTT.keys.contains("TEMPPOZ1"){
                        seznamPozadovanychTeplot[indexKdeJeZarizeniProMDNSaAWS] = dictMQTT["TEMPPOZ1"] as! String
                        seznamPozadovanychTeplot[indexKdeJeZarizeniProMDNSaAWS]=String(seznamPozadovanychTeplot[indexKdeJeZarizeniProMDNSaAWS].dropLast())
                    }
                    if dictMQTT.keys.contains("TEMPPOZ2"){
                        seznamPozadovanychTeplot[indexKdeJeZarizeniProMDNSaAWS+1] = dictMQTT["TEMPPOZ2"] as! String
                        seznamPozadovanychTeplot[indexKdeJeZarizeniProMDNSaAWS+1] =  String(seznamPozadovanychTeplot[indexKdeJeZarizeniProMDNSaAWS+1].dropLast())
                    }
                    if dictMQTT.keys.contains("LOCATION1"){
                        seznamUmisteniZarizeni[indexKdeJeZarizeniProMDNSaAWS] = dictMQTT["LOCATION1"] as! String
                        if seznamUmisteniZarizeni[indexKdeJeZarizeniProMDNSaAWS]==""
                        {
                            seznamUmisteniZarizeni[indexKdeJeZarizeniProMDNSaAWS]="unknow1"
                        }
                    }
                    
                    if dictMQTT.keys.contains("LOCATION2"){
                        seznamUmisteniZarizeni[indexKdeJeZarizeniProMDNSaAWS+1] = dictMQTT["LOCATION2"] as! String
                        if seznamUmisteniZarizeni[indexKdeJeZarizeniProMDNSaAWS+1]==""
                        {
                            seznamUmisteniZarizeni[indexKdeJeZarizeniProMDNSaAWS+1]="unknow2"
                        }
                    }
                    
                    if dictMQTT.keys.contains("PAIRED"){
                        seznamZparovanychZarizeni[indexKdeJeZarizeniProMDNSaAWS+1] = dictMQTT["PAIRED"] as! String
                        seznamZparovanychZarizeni[indexKdeJeZarizeniProMDNSaAWS] = dictMQTT["PAIRED"] as! String
                        
                        if dictMQTT.keys.contains("FWtermostat"){
                            let verzeFWtermostatuZMQTT = dictMQTT["FWtermostat"] as! String
                            //print("verzeFWtermostatuZMQTT:\(verzeFWtermostatuZMQTT)")
                            //print("verzeFWTermostatunaServeru:\(verzeFWTermostatunaServeru)")
                            if((verzeFWtermostatuZMQTT != verzeFWTermostatunaServeru)&&(verzeFWtermostatuZMQTT != "0")&&(verzeFWtermostatuZMQTT != "")){
                                seznamZparovanychZarizeni[indexKdeJeZarizeniProMDNSaAWS] = "2"
                                seznamZparovanychZarizeni[indexKdeJeZarizeniProMDNSaAWS+1] = "2"
                            }
                            
                        }
                        
                    }
                    
                    if dictMQTT.keys.contains("TempSensorRelayOne"){
                        seznamPripojenychTeplomeru[indexKdeJeZarizeniProMDNSaAWS] = dictMQTT["TempSensorRelayOne"] as! String
                    }
                    
                    if dictMQTT.keys.contains("TempSensorRelayTwo"){
                        seznamPripojenychTeplomeru[indexKdeJeZarizeniProMDNSaAWS+1] = dictMQTT["TempSensorRelayTwo"] as! String
                    }
                    
                    if dictMQTT.keys.contains("NAME1"){
                        seznamNazvuZarizeni[indexKdeJeZarizeniProMDNSaAWS] = dictMQTT["NAME1"] as! String
                    }
                    
                    if dictMQTT.keys.contains("NAME2"){
                        seznamNazvuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1] = dictMQTT["NAME2"] as! String
                    }
                    
                    if dictMQTT.keys.contains("TIME"){
                        seznamCasuVmodulech[indexKdeJeZarizeniProMDNSaAWS+1] = dictMQTT["TIME"] as! String
                        seznamCasuVmodulech[indexKdeJeZarizeniProMDNSaAWS] = dictMQTT["TIME"] as! String
                    }
                    
                    if dictMQTT.keys.contains("RELAY1"){
                        seznamProvoznichRezimu[indexKdeJeZarizeniProMDNSaAWS] = dictMQTT["RELAY1"] as! String
                        print("ProvozniRezimRele1:\(seznamProvoznichRezimu[indexKdeJeZarizeniProMDNSaAWS])")
                    }
                    if dictMQTT.keys.contains("TimerOne"){
                        seznamTimeru[indexKdeJeZarizeniProMDNSaAWS] = dictMQTT["TimerOne"] as! String
                        
                    }
                    if dictMQTT.keys.contains("TimerTwo"){
                        seznamTimeru[indexKdeJeZarizeniProMDNSaAWS+1] = dictMQTT["TimerTwo"] as! String
                        
                    }
                    if dictMQTT.keys.contains("RELAY2"){
                        seznamProvoznichRezimu[indexKdeJeZarizeniProMDNSaAWS+1] = dictMQTT["RELAY2"] as! String
                        print("ProvozniRezimRele2:\(seznamProvoznichRezimu[indexKdeJeZarizeniProMDNSaAWS+1])")
                    }
                    if dictMQTT.keys.contains("BATTERY"){
                        NapetiNaBaterie = Int(dictMQTT["BATTERY"] as! String) ?? 0
                        
                    }
                    if dictMQTT.keys.contains("CHARGER"){
                        PripojenaDobijecka = dictMQTT["CHARGER"] as! String
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
                        if dictMQTT.keys.contains("RELAY1STATUS"){
                            let rele1status = dictMQTT["RELAY1STATUS"]as! String
                            print("Text record (rele1status MQTT):", rele1status)
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
                        
                        if dictMQTT.keys.contains("RELAY2STATUS"){
                            let rele2status = dictMQTT["RELAY2STATUS"]as! String
                            print("Text record (rele2status MQTT):", rele2status)
                            //indexKdeJeZarizeniProMDNSaAWS=indexKdeJeZarizeniProMDNSaAWS+1//aby to sahalo v poli na druhe rele protoze maji stejnou mac adresu
                            if seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1] != "Druhe zarizeni" && (seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].contains("zarovka")||seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].contains("ventilator")||seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].contains("radiator")||seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS+1].contains("zasuvka")){
                            if rele2status=="ON"{//UPRAVENO 1.12.2020
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
                    
                }
                print("zpracoval cely dictMQTT")
                if uzProbehlaCelaFunkce{
                    NotificationCenter.default.post(name:NSNotification.Name("zpracujDictionaryAWS"), object: nil)
                }
            }
            pocitadlo=pocitadlo-1
            print("POCITADLOEND\(pocitadlo)")
            
            
            
            
            
            if let prikaz = dictMQTT["PRIKAZ"] as? String{
                print("dosel prikaz:\(prikaz)")
                dataKeZpracovani=prikaz
                NotificationCenter.default.post(name:NSNotification.Name("zpracujTCPdata"), object: nil)
            }
            
            
            
        }//konec message receive callback
        
        /*
         {
         //LoadingProgressHUD.dismiss()
         let dictMQTT = jsonDataToDict(jsonData: payload)
         print("Message received: \(dictMQTT)")
         if let macovka = dictMQTT["MAC"] as? String{
         print("Odesilam notifikaci zpracujDictionaryAWS")
         NotificationCenter.default.post(name:NSNotification.Name("zpracujDictionaryAWS"), object: dictMQTT)
         
         }
         
         
         if let prikaz = dictMQTT["PRIKAZ"] as? String{
         print("dosel prikaz:\(prikaz)")
         dataKeZpracovani=prikaz
         NotificationCenter.default.post(name:NSNotification.Name("zpracujTCPdata"), object: nil)
         }
         
         
         
         }
         */
        //let topicArray = ["C44F33798815/"]
        let dataManager = AWSIoTDataManager(forKey: "kDataManager")
        
        for topic in seznamTopicu {
            print("Registering subscription to => \(topic)")
            dataManager.subscribe(toTopic: topic,
                                  qoS: .messageDeliveryAttemptedAtMostOnce,  // Set according to use case
                                  messageCallback: messageReceived)
            print("Registering subscription to => \(topic)dataProAplikaci")
            dataManager.subscribe(toTopic: "\(topic)dataProAplikaci",
                                  qoS: .messageDeliveryAttemptedAtMostOnce,  // Set according to use case
                                  messageCallback: messageReceived)
        }
        HaloKdoJsteOnline()
    }
    
    func publishMessage(message: String!, topic: String!) {
        print("message:\(message as String) topic:\(topic as String)")
        let dataManager = AWSIoTDataManager(forKey: "kDataManager")
        dataManager.publishString(message, onTopic: topic, qoS: .messageDeliveryAttemptedAtMostOnce) // Set QoS as needed
    }
    
    func jsonDataToDict(jsonData: Data?) -> Dictionary <String, Any> {
        // Converts data to dictionary or nil if error
        do {
            let jsonDict = try JSONSerialization.jsonObject(with: jsonData!, options: [])
            let convertedDict = jsonDict as! [String: Any]
            return convertedDict
        } catch {
            // Couldn't get JSON
            print(error.localizedDescription)
            return [:]
        }
    }
    
    
    @objc func testVerzeFirmwaru(){
        if let url = URL(string: "https://www.emdamo.eu/UPDATE/EMTRONCZ/KS001003-2-RELAYS-MODULE_16MB/KS001003version.txt") {
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
    
    
    @objc func NactiNavodyzYouTube(){
        if let url = URL(string: "https://www.emdamo.eu/UPDATE/EMTRONCZ/EMTRON-SMART-HOME-APK/YouTubeList.txt") {
            do {
                
                var contents = ""
                contents = try String(contentsOf: url,encoding: .utf8)
                print(contents)
                //print("delka Stringu : \(contents.count)")
                contents=contents.replacingOccurrences(of: "\r", with: "")
                if contents.contains("END"){
                    contents=contents.replacingOccurrences(of: "END", with: "")
                    seznamNavoduNaYoutube = contents.components(separatedBy: .newlines)
                    seznamNavoduNaYoutube.removeLast()
                    print(seznamNavoduNaYoutube)
                }
                
            } catch {
                //verzeFWnaServeru=""
                print("nenacetlo to navody ze serveru")
            }
            print("Probehlo nacteni navodu z webu")
        } else {
            //verzeFWnaServeru=""
            print("nenacetlo to navody ze serveru")
        }
        
    }
    
    //--------------------------------------------------------
    // MARK: parsujData --------------------------------
    //--------------------------------------------------------
    public func parsujNavody(prvniZnak:Character,druhyZnak:Character) -> String
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
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
            HledatPresMDNS=true
        case .cellular:
            print("Reachable via Cellular")
            HledatPresMDNS=false
        /*
         seznamMDNSvsAWS.removeAll()
         for index in 0..<seznamMACZarizeni.count{
         //po zapnuti jsou vsechny offline
         //print("index je:\(index)")
         seznamMDNSvsAWS.append("OFFline")
         }*/
        case .unavailable:
            print("Network not reachable")
            ZobrazAlertMessage(message: "Připojte se prosím k internetu.")
        case .none:
            print("none")
            ZobrazAlertMessage(message: "Připojte se prosím k internetu.")
        }
    }
    
    func ZobrazAlertMessage(message:String)
    {
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        let message  = message
        var messageMutableString = NSMutableAttributedString()
        messageMutableString = NSMutableAttributedString(string: message as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Aller", size: 18.0)!])
        messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 60/255, green: 60/255, blue: 60/255, alpha: 1), range:NSRange(location:0,length:message.count))
        alertController.setValue(messageMutableString, forKey: "attributedMessage")
        
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            if DEBUGMSG{
                print("Alert Click OK")
                
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                }
            }
            self.dismiss(animated: true, completion: nil)
            if UserDefaults.standard.object(forKey: "JizByloSpusteno")as? String ?? ""=="ANO"{
                self.btnAddDeviceOutlet.isHidden=true//zkryje tlacitko na pridani zarizeni
                self.performSegue(withIdentifier: "showDeviceListFromWelcome", sender: Any?.self)
            }
            else{
                //btnAddDeviceOutlet.alpha=0
                self.btnAddDeviceOutlet.isHidden=false
                self.btnAddDeviceOutlet.flash()
            }
        }
        
        
        alertController.addAction(okAction)
        
        
        alertController.view.tintColor = UIColor.init(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        //alertController.view.backgroundColor = UIColor.black
        alertController.view.layer.cornerRadius = 40
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //declare this property where it won't go out of scope relative to your listener
        //ActivityIndicator("Connecting...")
        //let reachability = try! Reachability.self
        
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
            HledatPresMDNS=true
        case .cellular:
            print("Reachable via Cellular")
            HledatPresMDNS=false
            
            
        case .unavailable:
            print("Network not reachable")
            ZobrazAlertMessage(message: "Připojte se prosím k internetu.")
        case .none:
            print("none")
            ZobrazAlertMessage(message: "Připojte se prosím k internetu.")
        }
        
        if UserDefaults.standard.object(forKey: "JizByloSpusteno")as? String ?? ""=="ANO"{//ma tam byt ANO
            
            btnAddDeviceOutlet.isHidden=true//zkryje tlacitko na pridani zarizeni
            
            while(ConnectedToAWS==false){
                sleep(1)//aby to hned nezmizelo
            }
            
            sleep(2)
            self.performSegue(withIdentifier: "showDeviceListFromWelcome", sender: Any?.self)
        }
        else{
            if DEBUGMSG{
                print("DBGMSG:PRVNI START APLIKACE")
            }
            //btnAddDeviceOutlet.alpha=0
            view.dismissProgress()
            btnAddDeviceOutlet.isHidden=false
            btnAddDeviceOutlet.flash()
        }
        sleep(2)//aby to hned nezmizelo
    }
    
    
    //--------------------------------------------------------
    // MARK: viewDidDisappear --------------------------------
    //--------------------------------------------------------
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //LoadingProgressHUD.dismiss()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
}

//--------------------------------------------------------
// MARK: SPINNER --------------------------------
//--------------------------------------------------------


extension UIViewController {
    func setGradientBackground() {
        //let colorBottom =  UIColor(red: 220.0/255.0, green: 220.0/255.0, blue: 220.0/255.0, alpha: 1.0).cgColor
        //let colorTop = UIColor(red: 150.0/255.0, green: 214.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        
        let colorBottom =  UIColor(red: 49.0/255.0, green: 49.0/255.0, blue: 49.0/255.0, alpha: 1.0).cgColor
        let colorTop = UIColor(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 1.0).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func createSpinnerView() {
        let child = SpinnerViewController()
        
        // add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        
        // wait two seconds to simulate some work happening
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // then remove the spinner view controller
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
    
    func removeBlur(){
        blurEffectView.removeFromSuperview()
        
    }
    
    func showBlur() {
        
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        //let viewAnimation = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        
    }
    
    func removeActivityIndicator(){
        blurEffectView.removeFromSuperview()
        strLabel.removeFromSuperview()
        activityIndicator.removeFromSuperview()
        effectView.removeFromSuperview()
        AktivniIndikator=false;
    }
    
    func ActivityIndicator(_ title: String) {
        blurEffectView.removeFromSuperview()
        strLabel.removeFromSuperview()
        activityIndicator.removeFromSuperview()
        effectView.removeFromSuperview()
        
        
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 60))
        strLabel.text = title
        strLabel.font = UIFont.boldSystemFont(ofSize: 24)
        strLabel.textColor = UIColor.lightText
        strLabel.textAlignment = .center
        strLabel.baselineAdjustment = .alignCenters
        strLabel.numberOfLines = 0
        
        effectView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.midY - strLabel.frame.height/2 , width: 120, height: 60)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        effectView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        
        activityIndicator = UIActivityIndicatorView(style:.large)
        activityIndicator.color = UIColor(white: 0.9, alpha: 0.7)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        activityIndicator.startAnimating()
        
        view.addSubview(blurEffectView)
        effectView.contentView.addSubview(activityIndicator)
        effectView.contentView.addSubview(strLabel)
        view.addSubview(effectView)
        AktivniIndikator=true;
    }
    
    
}
//--------------------------------------------------------
// MARK: EFECTS ON BUTTONS --------------------------------
//--------------------------------------------------------
extension UIButton {
    
    func pulsate() {
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.2
        pulse.fromValue = 0.95
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 2
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        
        layer.add(pulse, forKey: "pulse")
    }
    
    func flash() {
        
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.2
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 2
        
        layer.add(flash, forKey: nil)
    }
    
    
    func shake() {
        
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.05
        shake.repeatCount = 2
        shake.autoreverses = true
        
        let fromPoint = CGPoint(x: center.x - 5, y: center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        
        let toPoint = CGPoint(x: center.x + 5, y: center.y)
        let toValue = NSValue(cgPoint: toPoint)
        
        shake.fromValue = fromValue
        shake.toValue = toValue
        
        layer.add(shake, forKey: "position")
    }
}

class SpinnerViewController: UIViewController {
    var spinner = UIActivityIndicatorView(style: .whiteLarge)
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
