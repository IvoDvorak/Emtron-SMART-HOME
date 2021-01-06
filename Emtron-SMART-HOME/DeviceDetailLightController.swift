//
//  DeviceDetailLightController.swift
//  Emtron-SMART-HOME
//
//  Created by Ivo Dvorak on 24/10/2019.
//  Copyright © 2019 Ivo Dvorak. All rights reserved.
//

import UIKit
import Foundation
import Socket
import AudioToolbox

var bylDetailController = false
var uzDoslaData = false;

class DeviceDetailLightControlller: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource {
    
    let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    
    @IBAction func btnSetupClick(_ sender: Any) {
        if seznamOnlineZarizeni[indexVybranehoZarizeni]=="ONline"{
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeviceSetupController")
            viewController.modalPresentationStyle = .pageSheet
            self.present(viewController, animated: true, completion: nil)
        }
    }
    var pickerData: [String] = [String]()
    let blurView = UIVisualEffectView()
    
    @IBOutlet weak var outletPickerZadavaniCasu: UIPickerView!
    @IBOutlet weak var outletBtnLongPress: UIButton!
    @IBAction func btnCalendarClick(_ sender: Any) {
        
        if seznamOnlineZarizeni[indexVybranehoZarizeni]=="ONline"{
            uzDoslaData=false
            odkudBylSpustenKalendar="Svetlo"
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TemperatureCalendarController")
            viewController.modalPresentationStyle = .pageSheet
            self.present(viewController, animated: true, completion: nil)
        }
        else
        {
            print("Zarizeni je OFFline")
        }
    }
    
    @IBOutlet weak var outletViewProPicker: UIView!
    
    
    @IBAction func btnOKtimeClick(_ sender: UIButton) {
        if seznamObrazkuZarizeni[indexVybranehoZarizeni].contains("ON"){
            self.sendOverTCP(message:"T\(poradoveCisloRele[indexVybranehoZarizeni])OFF:\(pickerData[ outletPickerZadavaniCasu.selectedRow(inComponent: 0)])t\n")//melo by to poslat R1ON nebo R2ON
            print("switch R\(poradoveCisloRele[indexVybranehoZarizeni]) OFF za cas:\(pickerData[ outletPickerZadavaniCasu.selectedRow(inComponent: 0)]) min")
        }
        if seznamObrazkuZarizeni[indexVybranehoZarizeni].contains("OFF"){
            self.sendOverTCP(message:"T\(poradoveCisloRele[indexVybranehoZarizeni])ON:\(pickerData[ outletPickerZadavaniCasu.selectedRow(inComponent: 0)])t\n")//melo by to poslat R1OFF nebo R2OFF
            print("switch R\(poradoveCisloRele[indexVybranehoZarizeni]) OFN za cas:\(pickerData[ outletPickerZadavaniCasu.selectedRow(inComponent: 0)]) min")
        }
        seznamTimeru[indexVybranehoZarizeni]="1"
        self.performSegue(withIdentifier: "backToDeviceListFromLightDSegue", sender: self)
        
    }
    
    
    
    
    
    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizer.State.began {
            print("Long Press")
            if seznamOnlineZarizeni[indexVybranehoZarizeni]=="ONline"{
                if seznamObrazkuZarizeni[indexVybranehoZarizeni].contains("OFF"){
                    outletLabelChange.text="Turn ON for:"
                }
                else{
                    outletLabelChange.text="Turn OFF for:"
                }
                //let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
                //et blurEffectView = UIVisualEffectView(effect: blurEffect)
                //blurEffectView.frame = view.bounds
                //blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                //view.addSubview(blurEffectView)
                
                //let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
                //let blurEffectView = UIVisualEffectView(effect: blurEffect)
                //blurEffectView.frame = self.view.frame
                
                //self.view.insertSubview(blurEffectView, at: 0)
                
                
                // Make its frame equal the main view frame so that every pixel is under blurred
                blurView.frame = view.frame
                // Choose the style of the blur effect to regular.
                // You can choose dark, light, or extraLight if you wants
                blurView.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
                // Now add the blur view to the main view
                view.addSubview(blurView)
                
                
                outletViewProPicker.alpha=1;
                view.addSubview(outletViewProPicker)
                //self.view.bringSubviewToFront(outletViewProPicker)
            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        let touch = touches.first
        guard let location = touch?.location(in: self.view) else { return }
        if !outletViewProPicker.frame.contains(location) {
            print("Tapped outside the view AA")
            outletViewProPicker.alpha=0
            blurView.removeFromSuperview()
        } else {
            print("Tapped inside the view AA")
        }
        
        
    }
    
    
    
    
    func addLongPressGesture(){
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
        longPress.minimumPressDuration = 1.2
        self.outletBtnLongPress.addGestureRecognizer(longPress)
    }
    
    @IBAction func btnClickToImage(_ sender: Any) {
        print("click to image")
        if seznamOnlineZarizeni[indexVybranehoZarizeni]=="ONline"{//aby to klikalo jen kdyz to je online
            //AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            /*
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: [],
                           animations: {
                            self.DeviceImage.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                            
            },
                           completion: { finished in
                            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: .curveEaseInOut,
                                           animations: {
                                            self.DeviceImage.transform = CGAffineTransform(scaleX: 1, y: 1)
                            },
                                           completion: { (finished: Bool) in
 */
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
                                                    if seznamObrazkuZarizeni[indexVybranehoZarizeni]=="zarovkaON"{
                                                        seznamObrazkuZarizeni[indexVybranehoZarizeni]="zarovkaOFF"
                                                        
                                                    }
                                                    else if seznamObrazkuZarizeni[indexVybranehoZarizeni]=="zarovkaOFF"{
                                                        seznamObrazkuZarizeni[indexVybranehoZarizeni]="zarovkaON"
                                                    }
                                                    
                                                    if seznamObrazkuZarizeni[indexVybranehoZarizeni]=="zasuvkaON"{
                                                        seznamObrazkuZarizeni[indexVybranehoZarizeni]="zasuvkaOFF"
                                                        
                                                    }
                                                    else if seznamObrazkuZarizeni[indexVybranehoZarizeni]=="zasuvkaOFF"{
                                                        seznamObrazkuZarizeni[indexVybranehoZarizeni]="zasuvkaON"
                                                    }
                                                    
                                                    if seznamObrazkuZarizeni[indexVybranehoZarizeni]=="ventilatorON"{
                                                        seznamObrazkuZarizeni[indexVybranehoZarizeni]="ventilatorOFF"
                                                    }
                                                    else if seznamObrazkuZarizeni[indexVybranehoZarizeni]=="ventilatorOFF"{
                                                        seznamObrazkuZarizeni[indexVybranehoZarizeni]="ventilatorON"
                                                    }
                                                    
                                                    
                                                    if seznamObrazkuZarizeni[indexVybranehoZarizeni]=="radiatorON"{
                                                        seznamObrazkuZarizeni[indexVybranehoZarizeni]="radiatorOFF"
                                                    }
                                                    else if seznamObrazkuZarizeni[indexVybranehoZarizeni]=="radiatorOFF"{
                                                        seznamObrazkuZarizeni[indexVybranehoZarizeni]="radiatorON"
                                                    }
                                                    
                                                    if seznamObrazkuZarizeni[indexVybranehoZarizeni].contains("ON"){
                                                        self.sendOverTCP(message:"R\(poradoveCisloRele[indexVybranehoZarizeni])ON\n")//melo by to poslat R1ON nebo R2ON
                                                        print("switch R\(poradoveCisloRele[indexVybranehoZarizeni]) ON")
                                                    }
                                                    if seznamObrazkuZarizeni[indexVybranehoZarizeni].contains("OFF"){
                                                        self.sendOverTCP(message:"R\(poradoveCisloRele[indexVybranehoZarizeni])OFF\n")//melo by to poslat R1OFF nebo R2OFF
                                                        print("switch R\(poradoveCisloRele[indexVybranehoZarizeni]) OFF")
                                                    }
                                                    self.DeviceImage.image=UIImage(named:seznamObrazkuZarizeni[indexVybranehoZarizeni])
                                                    seznamProvoznichRezimu[indexVybranehoZarizeni]="RELE"
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
                                                    if seznamObrazkuZarizeni[indexVybranehoZarizeni]=="zarovkaON"{
                                                        seznamObrazkuZarizeni[indexVybranehoZarizeni]="zarovkaOFF"
                                                        
                                                    }
                                                    else if seznamObrazkuZarizeni[indexVybranehoZarizeni]=="zarovkaOFF"{
                                                        seznamObrazkuZarizeni[indexVybranehoZarizeni]="zarovkaON"
                                                    }
                                                    
                                                    if seznamObrazkuZarizeni[indexVybranehoZarizeni]=="zasuvkaON"{
                                                        seznamObrazkuZarizeni[indexVybranehoZarizeni]="zasuvkaOFF"
                                                        
                                                    }
                                                    else if seznamObrazkuZarizeni[indexVybranehoZarizeni]=="zasuvkaOFF"{
                                                        seznamObrazkuZarizeni[indexVybranehoZarizeni]="zasuvkaON"
                                                    }
                                                    
                                                    if seznamObrazkuZarizeni[indexVybranehoZarizeni]=="ventilatorON"{
                                                        seznamObrazkuZarizeni[indexVybranehoZarizeni]="ventilatorOFF"
                                                    }
                                                    else if seznamObrazkuZarizeni[indexVybranehoZarizeni]=="ventilatorOFF"{
                                                        seznamObrazkuZarizeni[indexVybranehoZarizeni]="ventilatorON"
                                                    }
                                                    
                                                    
                                                    if seznamObrazkuZarizeni[indexVybranehoZarizeni]=="radiatorON"{
                                                        seznamObrazkuZarizeni[indexVybranehoZarizeni]="radiatorOFF"
                                                    }
                                                    else if seznamObrazkuZarizeni[indexVybranehoZarizeni]=="radiatorOFF"{
                                                        seznamObrazkuZarizeni[indexVybranehoZarizeni]="radiatorON"
                                                    }
                                                    
                                                    if seznamObrazkuZarizeni[indexVybranehoZarizeni].contains("ON"){
                                                        self.sendOverTCP(message:"R\(poradoveCisloRele[indexVybranehoZarizeni])ON\n")//melo by to poslat R1ON nebo R2ON
                                                        print("switch R\(poradoveCisloRele[indexVybranehoZarizeni]) ON")
                                                    }
                                                    if seznamObrazkuZarizeni[indexVybranehoZarizeni].contains("OFF"){
                                                        self.sendOverTCP(message:"R\(poradoveCisloRele[indexVybranehoZarizeni])OFF\n")//melo by to poslat R1OFF nebo R2OFF
                                                        print("switch R\(poradoveCisloRele[indexVybranehoZarizeni]) OFF")
                                                    }
                                                    self.DeviceImage.image=UIImage(named:seznamObrazkuZarizeni[indexVybranehoZarizeni])
                                                    seznamProvoznichRezimu[indexVybranehoZarizeni]="RELE"
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
                                                
                                                if seznamObrazkuZarizeni[indexVybranehoZarizeni]=="zarovkaON"{
                                                    seznamObrazkuZarizeni[indexVybranehoZarizeni]="zarovkaOFF"
                                                    
                                                }
                                                else if seznamObrazkuZarizeni[indexVybranehoZarizeni]=="zarovkaOFF"{
                                                    seznamObrazkuZarizeni[indexVybranehoZarizeni]="zarovkaON"
                                                }
                                                
                                                if seznamObrazkuZarizeni[indexVybranehoZarizeni]=="zasuvkaON"{
                                                    seznamObrazkuZarizeni[indexVybranehoZarizeni]="zasuvkaOFF"
                                                    
                                                }
                                                else if seznamObrazkuZarizeni[indexVybranehoZarizeni]=="zasuvkaOFF"{
                                                    seznamObrazkuZarizeni[indexVybranehoZarizeni]="zasuvkaON"
                                                }
                                                
                                                if seznamObrazkuZarizeni[indexVybranehoZarizeni]=="ventilatorON"{
                                                    seznamObrazkuZarizeni[indexVybranehoZarizeni]="ventilatorOFF"
                                                }
                                                else if seznamObrazkuZarizeni[indexVybranehoZarizeni]=="ventilatorOFF"{
                                                    seznamObrazkuZarizeni[indexVybranehoZarizeni]="ventilatorON"
                                                }
                                                
                                                
                                                if seznamObrazkuZarizeni[indexVybranehoZarizeni]=="radiatorON"{
                                                    seznamObrazkuZarizeni[indexVybranehoZarizeni]="radiatorOFF"
                                                }
                                                else if seznamObrazkuZarizeni[indexVybranehoZarizeni]=="radiatorOFF"{
                                                    seznamObrazkuZarizeni[indexVybranehoZarizeni]="radiatorON"
                                                }
                                                
                                                if seznamObrazkuZarizeni[indexVybranehoZarizeni].contains("ON"){
                                                    self.sendOverTCP(message:"R\(poradoveCisloRele[indexVybranehoZarizeni])ON\n")//melo by to poslat R1ON nebo R2ON
                                                    print("switch R\(poradoveCisloRele[indexVybranehoZarizeni]) ON")
                                                }
                                                if seznamObrazkuZarizeni[indexVybranehoZarizeni].contains("OFF"){
                                                    self.sendOverTCP(message:"R\(poradoveCisloRele[indexVybranehoZarizeni])OFF\n")//melo by to poslat R1OFF nebo R2OFF
                                                    print("switch R\(poradoveCisloRele[indexVybranehoZarizeni]) OFF")
                                                }
                                                outletBtnLongPress.setImage(UIImage(named: seznamObrazkuZarizeni[indexVybranehoZarizeni]), for: .normal)
                                            }
                                            
                                            
                           
            
        }//konec if online
        
    }
    
    @IBOutlet weak var LabelNazev: UILabel!
    
    @IBOutlet weak var LabelUmisteni: UILabel!
    @IBOutlet weak var DeviceImage: UIImageView!
    
    @IBOutlet weak var outletLabelChange: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationFeedbackGenerator.prepare()
        outletBtnLongPress.imageView!.contentMode = .scaleAspectFit
        outletBtnLongPress.contentVerticalAlignment = .fill
        outletBtnLongPress.contentHorizontalAlignment = .fill
        outletBtnLongPress.startAnimatingPressActions()
        pickerData = ["1", "2", "3","5", "10", "15", "20","25", "30", "35", "40","45","60","90","120"]
        addLongPressGesture()
        outletBtnLongPress.setImage(UIImage(named: seznamObrazkuZarizeni[indexVybranehoZarizeni]), for: .normal)
        //outletBtnLongPress.bac
        LabelNazev.text=seznamNazvuZarizeni[indexVybranehoZarizeni]
        LabelUmisteni.text=seznamUmisteniZarizeni[indexVybranehoZarizeni]
        outletPickerZadavaniCasu.setValue(UIColor.white, forKey: "textColor")
        outletViewProPicker.layer.cornerRadius=20
        
        
        //setGradientBackground()
        //bylDetailController=true
        
        
        
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
           // This method is triggered whenever the user makes a change to the picker selection.
           // The parameter named row and component represents what was selected.
        notificationFeedbackGenerator.notificationOccurred(.success)
       }
    //
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {//POCET VALCU V PICKERU
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {//POCET HODNOT V PICKERU
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(pickerData[row]) min"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //setGradientBackground()
        super.viewWillAppear(animated)
        let date = Date()
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        if seznamOnlineZarizeni[indexVybranehoZarizeni]=="ONline"{
            sendOverTCP(message: "Hour:\(hour)Minute:\(minute)@\n")
            print("odesilam aktualni cas do modulu")
        }
        outletPickerZadavaniCasu.selectRow(3, inComponent: 0, animated: false)
    }
    override func viewWillAppear(_ animated: Bool) {
        //setGradientBackground()
        super.viewWillAppear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
                    try self.readFromServer(chatSocket)
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
                            //self.collectionView.reloadData()
                        }
                        
                        messageBox.addAction(AkceOK)
                        self.present(messageBox,animated: true)
                    }
                    
                }
                
            }//konec novz thread
        }//konec mdns
        else if seznamMDNSvsAWS[indexVybranehoZarizeni]=="AWS"{
                AWSmessage="{\"message\": \"\(message)\"}"
                AWStopic="\(seznamTopicu[indexVybranehoZarizeni/2] as String)dataProModul"
                NotificationCenter.default.post(name:NSNotification.Name("AWSprikaz"), object: nil)
            
        }
    }
    
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
    
    @objc private func zpracujTCPdata() {
        
        print("dosla notifikace ze jsou nova data z TCP")
        //aby to bralo jen data od IP adresy s kterou se komunikuje
        
        
        
        if dataKeZpracovani.contains("CasAktualizovan")
        {
            DispatchQueue.main.async{
            print("cas v modulu byl aktualizovan")
            //tady nekde vypsat message ze se aktualizoval cas v modulu
            let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
            let message  = "V modulu byl aktualizovan cas"
            var messageMutableString = NSMutableAttributedString()
            messageMutableString = NSMutableAttributedString(string: message as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Aller", size: 18.0)!])
            messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 60/255, green: 60/255, blue: 60/255, alpha: 1), range:NSRange(location:0,length:message.count))
            alertController.setValue(messageMutableString, forKey: "attributedMessage")
            
            
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                if DEBUGMSG{
                    print("Alert Click OK")
                }
                
            }
            
            
            alertController.addAction(okAction)
            
            
            alertController.view.tintColor = UIColor.init(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
            //alertController.view.backgroundColor = UIColor.black
            alertController.view.layer.cornerRadius = 40
            
                self.present(alertController, animated: true, completion: nil)
            
        }
        
        dataKeZpracovani=""
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        probehloDiscovery=false
        super.viewWillDisappear(animated)
    }
}

extension UIButton {
    
    func startAnimatingPressActions() {
        addTarget(self, action: #selector(animateDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(animateUp), for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside])
    }
    
    @objc private func animateDown(sender: UIButton) {
        animate(sender, transform: CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8))
    }
    
    @objc private func animateUp(sender: UIButton) {
        animate(sender, transform: .identity)
    }
    
    private func animate(_ button: UIButton, transform: CGAffineTransform) {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 5,
                       options: [.curveEaseInOut],
                       animations: {
                        button.transform = transform
            }, completion: nil)
    }
    
}
