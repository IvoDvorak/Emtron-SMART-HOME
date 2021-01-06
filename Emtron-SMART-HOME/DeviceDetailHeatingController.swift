//
//  DeviceDetailHeatingController.swift
//  Emtron-SMART-HOME
//
//  Created by Ivo Dvorak on 24/10/2019.
//  Copyright © 2019 Ivo Dvorak. All rights reserved.
//

import UIKit
import Foundation
import Socket

//import AWSMobileClient

var odkudBylSpustenKalendar=""
var pozadovanaHysterezeTCP = 0.25
var ClientID=""
class DeviceDetailHeatingController: UIViewController {
    
    //let credentials = AWSCognitoCredentialsProvider(regionType:.USWest2, identityPoolId: "us-west-2:a0beab9c-5291-4823-b59a-eb04e7478a79")
    
    //let configuration = AWSServiceConfiguration(region:.USWest2, credentialsProvider: credentials)
    
    
    
    
    
    
    
    
    
    @IBAction func pingButtonClick(_ sender: Any) {
        sendOverTCP(message: "PING\n")
    }
    
    @IBAction func btnSetupClick(_ sender: Any) {
        if seznamOnlineZarizeni[indexVybranehoZarizeni]=="ONline"{
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeviceSetupController")
            viewController.modalPresentationStyle = .pageSheet
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnCalendarClick(_ sender: Any) {
        if seznamOnlineZarizeni[indexVybranehoZarizeni]=="ONline"{
            odkudBylSpustenKalendar="Topeni"
            uzDoslaData=false
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TemperatureCalendarController")
            viewController.modalPresentationStyle = .pageSheet
            self.present(viewController, animated: true, completion: nil)
            
            // self.performSegue(withIdentifier: "segueTemperatureController", sender: Any?.self)
        }
        else
        {
            print("Zarizeni je OFFline")
        }
        
    }
    
    
    
    @IBOutlet weak var viewPpodTeplotouOutlet: UIView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var DeviceImage: UIImageView!
    
    @IBOutlet weak var labelAktualniTeplota: UILabel!
    @IBOutlet weak var textFieldSteplotou: UITextField!
    
    @IBOutlet weak var LabelNazev: UILabel!
    
    @IBOutlet weak var LabelUmisteni: UILabel!
    
    
    @IBOutlet weak var labelMinimalniTeplota: UILabel!
    
    @IBOutlet weak var labelMaximalniTeplota: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSlider(slider: slider)
        minimalniTeplota=Int(seznamMinimalnichTeplot[indexVybranehoZarizeni]) ?? 0
        maximalniTeplota=Int(seznamMaximalnichTeplot[indexVybranehoZarizeni]) ?? 40
        slider.minimumValue=Float(minimalniTeplota)
        slider.maximumValue=Float(maximalniTeplota)
        DeviceImage.image=UIImage(named:seznamObrazkuZarizeni[indexVybranehoZarizeni])
        
        //hideKeyboardWhenTappedAround()
        
        textFieldSteplotou.text=("\(seznamPozadovanychTeplot[indexVybranehoZarizeni])°C")
        LabelNazev.text=seznamNazvuZarizeni[indexVybranehoZarizeni]
        LabelUmisteni.text=seznamUmisteniZarizeni[indexVybranehoZarizeni]
        if seznamOnlineZarizeni[indexVybranehoZarizeni]=="ONline"{
            if seznamMerenychTeplot[indexVybranehoZarizeni] != "-127.0"{
                labelAktualniTeplota.text = "\(seznamMerenychTeplot[indexVybranehoZarizeni])°C"
                
            }
            else{
                labelAktualniTeplota.text="Sensor error"
            }
            viewPpodTeplotouOutlet.layer.cornerRadius=20
            viewPpodTeplotouOutlet.alpha=1//0.75
        }
        else{
            labelAktualniTeplota.text=""
            viewPpodTeplotouOutlet.alpha=0
        }
        slider.value=Float(seznamPozadovanychTeplot[indexVybranehoZarizeni])!
        labelMinimalniTeplota.text=("\(minimalniTeplota)°C")
        labelMaximalniTeplota.text=("\(maximalniTeplota)°C")
        
        
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        //setGradientBackground()
        super.viewWillAppear(animated)
        let date = Date()
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        if seznamOnlineZarizeni[indexVybranehoZarizeni]=="ONline"{
            sendOverTCP(message: "Hour:\(hour)Minute:\(minute)@\n")
        }
        
    }
    
    @IBAction func btnTrvaleNastavitClick(_ sender: Any) {
        
        //.replacingOccurrences(of: "NoRespone", with: "ON")
        if seznamProvoznichRezimu[indexVybranehoZarizeni].contains("KALENDAR"){
            let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
            
            let message  = "Zařízení je nastaveno dle rozvrhu kalendáře, přejete si změnit teplotu trvale nebo do dalšího časového úseku kalendáře?"
            var messageMutableString = NSMutableAttributedString()
            messageMutableString = NSMutableAttributedString(string: message as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Aller", size: 18.0)!])
            messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 60/255, green: 60/255, blue: 60/255, alpha: 1), range:NSRange(location:0,length:message.count))
            alertController.setValue(messageMutableString, forKey: "attributedMessage")
            
            
            let DocasneAction = UIAlertAction(title: "Dočasně", style: .default) { (action) in
                if DEBUGMSG{
                    print("Alert Click DocasneAction")
                }
                let pozadovanaTeplotaTCP = String(self.textFieldSteplotou.text ?? "15.0")
                
                self.sendOverTCP(message: "BOOST\(poradoveCisloRele[indexVybranehoZarizeni]):\(pozadovanaTeplotaTCP)C\n")
                seznamPozadovanychTeplot[indexVybranehoZarizeni]=String(self.textFieldSteplotou.text?.replacingOccurrences(of: "°C", with: "") ?? "15.0")//tady se musi vyhodit stppme celsia
                UserDefaults.standard.setValue(seznamPozadovanychTeplot, forKey: "seznamPozadovanychTeplot")
                print("pozadovana teplota slicer \(self.slider.value)")
                print("pozadovana teplota textfield \(self.textFieldSteplotou.text)")
                print("pozadovana teplota v poli je \(seznamPozadovanychTeplot[indexVybranehoZarizeni])")
                //textFieldSteplotou.text=seznamPozadovanychTeplot[indexVybranehoZarizeni]
                let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeviceListController")
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true, completion: nil)
            }
            
            let TrvaleAction = UIAlertAction(title: "Trvale", style: .destructive) { (action) in
                if DEBUGMSG{
                    print("Alert Click TrvaleAction")
                    //nastavTeplotu()
                }
                //AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.nastavTeplotu()
                seznamPozadovanychTeplot[indexVybranehoZarizeni]=String(self.textFieldSteplotou.text?.replacingOccurrences(of: "°C", with: "") ?? "15.0")//tady se musi vyhodit stppme celsia
                UserDefaults.standard.setValue(seznamPozadovanychTeplot, forKey: "seznamPozadovanychTeplot")
                print("pozadovana teplota slicer \(self.slider.value)")
                print("pozadovana teplota textfield \(self.textFieldSteplotou.text)")
                print("pozadovana teplota v poli je \(seznamPozadovanychTeplot[indexVybranehoZarizeni])")
                //textFieldSteplotou.text=seznamPozadovanychTeplot[indexVybranehoZarizeni]
                let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeviceListController")
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true, completion: nil)
            }
            
            alertController.addAction(DocasneAction)
            alertController.addAction(TrvaleAction)
            
            
            //alertController.view.tintColor = UIColor.init(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
            //alertController.view.backgroundColor = UIColor.black
            alertController.view.layer.cornerRadius = 40
            
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            nastavTeplotu()
            seznamPozadovanychTeplot[indexVybranehoZarizeni]=String(textFieldSteplotou.text?.replacingOccurrences(of: "°C", with: "") ?? "15.0")//tady se musi vyhodit stppme celsia
            UserDefaults.standard.setValue(seznamPozadovanychTeplot, forKey: "seznamPozadovanychTeplot")
            print("pozadovana teplota slicer \(slider.value)")
            print("pozadovana teplota textfield \(textFieldSteplotou.text)")
            print("pozadovana teplota v poli je \(seznamPozadovanychTeplot[indexVybranehoZarizeni])")
            //textFieldSteplotou.text=seznamPozadovanychTeplot[indexVybranehoZarizeni]
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeviceListController")
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true, completion: nil)
        }
        
    }
    @IBAction func KonecZmenyTeplotyNaSlideru(_ sender: Any) {
        print("uz se nemeni hodnota na slideru")
        //nastavTeplotu()
        
    }
    @IBAction func ZmenaHodnotyNaSlideru(_ sender: Any) {
        //let celociselnaHodnota = (Int((slider.value)*5))
        //print("celocislena hodnota: \(celociselnaHodnota)")
        //let pocetKrokuNaSlideru=(maximalniTeplota-minimalniTeplota)*2//Int(slider.value*100)
        
        let teplotaNaPulStupne = roundf((roundf(slider.value*10)/10)/0.5)*0.5
        textFieldSteplotou.text="\(teplotaNaPulStupne)°C"
        print("Slider value:\(roundf(slider.value))")
        let pocetKrokuNaSlideru:Float=220/(Float(maximalniTeplota)-Float(minimalniTeplota))
        print("pocetKrokuNaSlideru:\(pocetKrokuNaSlideru)")
        let posunvBarve = ((roundf(slider.value))*pocetKrokuNaSlideru)
        print("posunvBarve:\(posunvBarve)")
        textFieldSteplotou.textColor=UIColor.init(red: (220/255), green: (220/255), blue: (220/255), alpha: 1)
    }
    
    func nastavTeplotu(){
        let pozadovanaTeplotaTCP = String(textFieldSteplotou.text ?? "15.0")
        
        sendOverTCP(message: "TERM\(poradoveCisloRele[indexVybranehoZarizeni]):\(pozadovanaTeplotaTCP)C\n")
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        print("dismissKeyboard")
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //setGradientBackground()
        super.viewWillAppear(animated)
        print("will appear")
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
        }
        dataKeZpracovani=""
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        probehloDiscovery=false
        super.viewWillDisappear(animated)
    }
    
    func ZobrazAlertMessage(message:String)
    {
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        let message  = message
        var messageMutableString = NSMutableAttributedString()
        messageMutableString = NSMutableAttributedString(string: message as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Aller", size: 18.0)!])
        messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 1), range:NSRange(location:0,length:message.count))
        alertController.setValue(messageMutableString, forKey: "attributedMessage")
        
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            if DEBUGMSG{
                print("Alert Click OK")
            }
            //self.dismiss(animated: true, completion: nil)
        }
        
        
        alertController.addAction(okAction)
        
        
        alertController.view.tintColor = UIColor.init(red: 255/255, green: 168/255, blue: 0, alpha: 1)
        //alertController.view.backgroundColor = UIColor.black
        alertController.view.layer.cornerRadius = 40
        
        present(alertController, animated: true, completion: nil)
        slider.value = 20.0
        textFieldSteplotou.text = "20.0°C"
    }
    
    
    @IBAction func konecEditaceText(_ sender: Any) {
        var num = Float(textFieldSteplotou.text ?? "20.0");
        if num == nil{
            num = 20.0
            ZobrazAlertMessage(message: "Neplatne zadani")
        }
        else{
            let teplota = Float(num!)
            print("Nastavena teplota \(teplota)")
            let spodniMez = Float(minimalniTeplota)
            let HorniMez = Float(maximalniTeplota)
            if teplota >= spodniMez && teplota <= HorniMez{
                print("Valid Integer")
                slider.value = teplota
            }
            else {
                print("Not Valid Integer")
                ZobrazAlertMessage(message: "Rozsah teplot je \(minimalniTeplota)-\(maximalniTeplota)°C")
                
            }
            
        }
        
        
        nastavTeplotu()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setSlider(slider:UISlider) {
        let tgl = CAGradientLayer()
        let frame = CGRect(x: 0.0, y: 0.0, width: slider.frame.width-5, height: 22.0 )
        tgl.frame = frame
        
        tgl.colors = [UIColor.blue.cgColor, UIColor.green.cgColor, UIColor.red.cgColor]
        
        tgl.borderWidth = 0.0
        tgl.borderColor = UIColor.gray.cgColor
        //tgl.borderColor = UIColor(red: 255.0/255.0, green: 191.0/255.0, blue: 58.0/255.0, alpha: 1.0).cgColor
        tgl.cornerRadius = 5.0
        tgl.masksToBounds=true
        
        tgl.endPoint = CGPoint(x: 1.0, y:  1.0)
        tgl.startPoint = CGPoint(x: 0.0, y:  1.0)//bylo 1.0
        
        UIGraphicsBeginImageContextWithOptions(tgl.frame.size, false, 0.0)
        tgl.render(in: UIGraphicsGetCurrentContext()!)
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        slider.setMaximumTrackImage(backgroundImage?.resizableImage(withCapInsets:.zero),  for: .normal)
        slider.setMinimumTrackImage(backgroundImage?.resizableImage(withCapInsets:.zero),  for: .normal)
        
        let layerFrame = CGRect(x: 0, y: 0, width: 15.0, height: 45.0)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = CGPath(rect: layerFrame, transform: nil)
        //shapeLayer.fillColor = UIColor(red: 255.0/255.0, green: 191.0/255.0, blue: 58.0/255.0, alpha: 1.0).cgColor
        shapeLayer.fillColor = UIColor.gray.cgColor
        shapeLayer.cornerRadius=4
        
        let thumb = CALayer.init()
        thumb.cornerRadius=4
        //layerFrame.l
        thumb.frame = layerFrame
        
        thumb.addSublayer(shapeLayer)
        thumb.cornerRadius = 4
        thumb.masksToBounds=true
        
        UIGraphicsBeginImageContextWithOptions(thumb.frame.size, false, 0.0)
        
        thumb.render(in: UIGraphicsGetCurrentContext()!)
        let thumbImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        slider.setThumbImage(thumbImage, for: .normal)
        slider.setThumbImage(thumbImage, for: .highlighted)
    }
}

extension UIView {
    func colorOfPoint(point: CGPoint) -> UIColor {
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        var pixelData: [UInt8] = [0, 0, 0, 0]
        
        let context = CGContext(data: &pixelData, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context!.translateBy(x: -point.x, y: -point.y)
        
        self.layer.render(in: context!)
        
        let red: CGFloat = CGFloat(pixelData[0]) / CGFloat(255.0)
        let green: CGFloat = CGFloat(pixelData[1]) / CGFloat(255.0)
        let blue: CGFloat = CGFloat(pixelData[2]) / CGFloat(255.0)
        let alpha: CGFloat = CGFloat(pixelData[3]) / CGFloat(255.0)
        
        let color: UIColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        
        return color
    }
}
