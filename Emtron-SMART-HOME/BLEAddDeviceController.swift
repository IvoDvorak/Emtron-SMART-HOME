//
//  AddDeviceController.swift
//  Control center
//
//  Created by Ivo Dvorak on 10/07/2019.
//  Copyright © 2019 Ivo Dvorak. All rights reserved.
//
import Foundation
import UIKit
import CoreBluetooth
import AudioToolbox
import iProgressHUD

var aktualniJmenoZarizeni = ""
var aktualniMacAdressa = ""
var citacProWifiPripojeni = 0
var kBLEService_UUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
//let kBLEService_UUID = "bc3c0bb3-07ab-4d12-d66c-21b185e0ce6b"
var kBLE_Characteristic_uuid_Tx = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
var kBLE_Characteristic_uuid_Rx = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

var BLEService_UUID = CBUUID(string: kBLEService_UUID)
var BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx)//(Property = Write without response)
var BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx)// (Property = Read/Notify)

var txCharacteristic : CBCharacteristic?
var rxCharacteristic : CBCharacteristic?
var blePeripheral : CBPeripheral?
var characteristicASCIIValue = NSString()
var SerialNumber:String = "Emtron2RelaysModule"
var spojenoBluetooth:Bool = false
var indikaceIkonaBluetooth:Bool = false
var dataZuartu:String = ""
var uartData = ""
var data = NSMutableData()
var verzeSWvModulu=""
var byloScanovano = false
var vypniTimer=false
var obdrzelJsempoZdrav:Bool=false
var BLEzpravaOdeslana=false
var autoReconnect = true


class BLEAddDeviceCOntroller: UIViewController,CBCentralManagerDelegate,CBPeripheralDelegate,UIPickerViewDelegate, UIPickerViewDataSource{
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
           return .lightContent
       }
    
    
               func numberOfComponents(in pickerView: UIPickerView) -> Int {//POCET VALCU V PICKERU
                   return 1
               }
               
               func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {//POCET HODNOT V PICKERU
                   return seznamMACZarizeni.count
               }
               
               func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
                let attributedString = NSAttributedString(string: "\(seznamNazvuZarizeni[row]), \(seznamUmisteniZarizeni[row])", attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGray])
                return attributedString//tohle nastavi data na pickeru na bilou barvu
                //102 102 102
                }
    
    var citacProBluetoothTimeout = 0
    var timerProOnlineTikej=false
    //var indexZpickeru
    
    @IBOutlet weak var outletLabelZvolte: UILabel!
    @IBOutlet weak var LabelWifi1: UILabel!
    
    @IBOutlet weak var LabelWifi2: UILabel!
    
    @IBOutlet weak var LabelWifi3: UILabel!
    
    @IBOutlet weak var LabelWifi4: UILabel!
    
    
    @IBOutlet weak var RSSIwifi4: UIImageView!
    
    @IBOutlet weak var RSSIwifi3: UIImageView!
    
    @IBOutlet weak var RSSIwifi2: UIImageView!
    
    @IBOutlet weak var RSSIwifi1: UIImageView!
    
    //@IBOutlet weak var LogoBluetooth: UIImageView!
    
    
    @IBOutlet weak var outletPickerSeSeznamem: UIPickerView!
    
    @IBOutlet weak var pozadiView: UIView!
    
    
    
    @IBAction func buttonConnectWifi1(_ sender: Any) {
        if volbaZarizeni=="modul"{
        if LabelWifi1.text != "----"{
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        let nadpis = "Zadejte heslo k WIFi \(LabelWifi1.text!) a mail adresu pro zasílání reportu:"
            var mailTextField: UITextField?
            var passwordTextField: UITextField?
        let messageBox = UIAlertController(title: nadpis, message: "", preferredStyle: .alert)
            //let messageBox2 = UIAlertController(title: nadpis, message: "Zadejte vaši emailovou adresu \(LabelWifi1.text!)", preferredStyle: .alert)
        let AkceOK = UIAlertAction(title: "OK", style: .default){//pokud se stikne tlacitko OK
            (ACTION) in
            
            let configData = "Wifi CONFIG:SSID:\(self.LabelWifi1.text!)PASSW:\(passwordTextField?.text ?? "")MAIL:\(mailTextField?.text ?? "")END"
            self.writeValue(data: configData)
            print("configData:\(configData)")
            //self.ActivityIndicator("Connecting to \(self.LabelWifi1.text!)")
            autoReconnect=false
            while(BLEzpravaOdeslana){}
            print("Odeslane nastaveni do modulu")
            if volbaZarizeni=="modul"{
            self.performSegue(withIdentifier: "testConnection", sender: Any?.self)
            }
            
        }
        let AkceZpet = UIAlertAction(title: "BACK", style: .default){//kliknuti na tlacitko BACK
            (ACTION) in
          //Stisk BACK
        }
        messageBox.addTextField {//tohle zobrazi text pole na zadani serioveho cisla
        (txtUsername) -> Void in
        passwordTextField = txtUsername
        passwordTextField!.placeholder = "<Your password here>"
        }
            
        messageBox.addTextField {//tohle zobrazi text pole na zadani serioveho cisla
        (txtMailname) -> Void in
        mailTextField = txtMailname
        mailTextField!.placeholder = "<Your email address here>"
        }
        
        messageBox.addAction(AkceZpet)
        messageBox.addAction(AkceOK)
        self.present(messageBox,animated: true)
        }
        
    }
    if volbaZarizeni=="termostat"{
    
        if LabelWifi1.text != "----"{
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        let nadpis = "Zadejte heslo k WIFi \(LabelWifi1.text!)"
            //var mailTextField: UITextField?
            var passwordTextField: UITextField?
        let messageBox = UIAlertController(title: nadpis, message: "", preferredStyle: .alert)
            //let messageBox2 = UIAlertController(title: nadpis, message: "Zadejte vaši emailovou adresu \(LabelWifi1.text!)", preferredStyle: .alert)
        let AkceOK = UIAlertAction(title: "OK", style: .default){//pokud se stikne tlacitko OK
            (ACTION) in
            
            let configData = "Wifi CONFIG:SSID:\(self.LabelWifi1.text!)PASSW:\(passwordTextField?.text ?? "")MAC:\(seznamMACZarizeni[self.outletPickerSeSeznamem.selectedRow(inComponent: 0)])IP:\(seznamIPZarizeni[self.outletPickerSeSeznamem.selectedRow(inComponent: 0)])NUM:\(self.outletPickerSeSeznamem.selectedRow(inComponent:0)%2)END"
            self.writeValue(data: configData)
            print("configData:\(configData)")
            //self.ActivityIndicator("Connecting to \(self.LabelWifi1.text!)")
            autoReconnect=false
            while(BLEzpravaOdeslana){}
            print("Odeslane nastaveni do modulu")
           
            self.performSegue(withIdentifier: "showDeviceListTermostat", sender: Any?.self)//tady ho rvonou poslat do hlavni obrazovky
            
        }
        let AkceZpet = UIAlertAction(title: "BACK", style: .default){//kliknuti na tlacitko BACK
            (ACTION) in
          //Stisk BACK
        }
        messageBox.addTextField {//tohle zobrazi text pole na zadani serioveho cisla
        (txtUsername) -> Void in
        passwordTextField = txtUsername
        passwordTextField!.placeholder = "<Your password here>"
        }
            
        
        messageBox.addAction(AkceZpet)
        messageBox.addAction(AkceOK)
        self.present(messageBox,animated: true)
        }
        
    }
    
    }
    
    
    
    @IBAction func buttonConnectWifi2(_ sender: Any) {
        if volbaZarizeni=="modul"{
        if LabelWifi2.text != "----"{
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        let nadpis = "Zadejte heslo k WIFi \(LabelWifi2.text!) a mail adresu pro zasílání reportu:"
            var mailTextField: UITextField?
            var passwordTextField: UITextField?
        let messageBox = UIAlertController(title: nadpis, message: "", preferredStyle: .alert)
            //let messageBox2 = UIAlertController(title: nadpis, message: "Zadejte vaši emailovou adresu \(LabelWifi1.text!)", preferredStyle: .alert)
        let AkceOK = UIAlertAction(title: "OK", style: .default){//pokud se stikne tlacitko OK
            (ACTION) in
            
            let configData = "Wifi CONFIG:SSID:\(self.LabelWifi2.text!)PASSW:\(passwordTextField?.text ?? "")MAIL:\(mailTextField?.text ?? "")END"
            self.writeValue(data: configData)
            print("configData:\(configData)")
            //self.ActivityIndicator("Connecting to \(self.LabelWifi1.text!)")
            autoReconnect=false
            while(BLEzpravaOdeslana){}
            print("Odeslane nastaveni do modulu")
            
            self.performSegue(withIdentifier: "testConnection", sender: Any?.self)
            
            
        }
        let AkceZpet = UIAlertAction(title: "BACK", style: .default){//kliknuti na tlacitko BACK
            (ACTION) in
          //Stisk BACK
        }
        messageBox.addTextField {//tohle zobrazi text pole na zadani serioveho cisla
        (txtUsername) -> Void in
        passwordTextField = txtUsername
        passwordTextField!.placeholder = "<Your password here>"
        }
            
        messageBox.addTextField {//tohle zobrazi text pole na zadani serioveho cisla
        (txtMailname) -> Void in
        mailTextField = txtMailname
        mailTextField!.placeholder = "<Your email address here>"
        }
        
        messageBox.addAction(AkceZpet)
        messageBox.addAction(AkceOK)
        self.present(messageBox,animated: true)
        }
        
    }
    if volbaZarizeni=="termostat"{
    
        if LabelWifi2.text != "----"{
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        let nadpis = "Zadejte heslo k WIFi \(LabelWifi2.text!)"
            //var mailTextField: UITextField?
            var passwordTextField: UITextField?
        let messageBox = UIAlertController(title: nadpis, message: "", preferredStyle: .alert)
            //let messageBox2 = UIAlertController(title: nadpis, message: "Zadejte vaši emailovou adresu \(LabelWifi1.text!)", preferredStyle: .alert)
        let AkceOK = UIAlertAction(title: "OK", style: .default){//pokud se stikne tlacitko OK
            (ACTION) in
            
            let configData = "Wifi CONFIG:SSID:\(self.LabelWifi2.text!)PASSW:\(passwordTextField?.text ?? "")MAC:\(seznamMACZarizeni[self.outletPickerSeSeznamem.selectedRow(inComponent: 0)])IP:\(seznamIPZarizeni[self.outletPickerSeSeznamem.selectedRow(inComponent: 0)])NUM:\(self.outletPickerSeSeznamem.selectedRow(inComponent:0)%2)END"
            self.writeValue(data: configData)
            print("configData:\(configData)")
            autoReconnect=false
            while(BLEzpravaOdeslana){}
            print("Odeslane nastaveni do modulu")
            
            self.performSegue(withIdentifier: "showDeviceListTermostat", sender: Any?.self)
            
        }
        let AkceZpet = UIAlertAction(title: "BACK", style: .default){//kliknuti na tlacitko BACK
            (ACTION) in
          //Stisk BACK
        }
        messageBox.addTextField {//tohle zobrazi text pole na zadani serioveho cisla
        (txtUsername) -> Void in
        passwordTextField = txtUsername
        passwordTextField!.placeholder = "<Your password here>"
        }
            
        
        messageBox.addAction(AkceZpet)
        messageBox.addAction(AkceOK)
        self.present(messageBox,animated: true)
        }
        
    }
    
    }
    @IBAction func buttonConnectWifi3(_ sender: Any) {
        if volbaZarizeni=="modul"{
        if LabelWifi3.text != "----"{
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        let nadpis = "Zadejte heslo k WIFi \(LabelWifi3.text!) a mail adresu pro zasílání reportu:"
            var mailTextField: UITextField?
            var passwordTextField: UITextField?
        let messageBox = UIAlertController(title: nadpis, message: "", preferredStyle: .alert)
            //let messageBox2 = UIAlertController(title: nadpis, message: "Zadejte vaši emailovou adresu \(LabelWifi1.text!)", preferredStyle: .alert)
        let AkceOK = UIAlertAction(title: "OK", style: .default){//pokud se stikne tlacitko OK
            (ACTION) in
            
            let configData = "Wifi CONFIG:SSID:\(self.LabelWifi3.text!)PASSW:\(passwordTextField?.text ?? "")MAIL:\(mailTextField?.text ?? "")END"
            self.writeValue(data: configData)
            print("configData:\(configData)")
            //self.ActivityIndicator("Connecting to \(self.LabelWifi1.text!)")
            autoReconnect=false
            while(BLEzpravaOdeslana){}
            print("Odeslane nastaveni do modulu")
            
            self.performSegue(withIdentifier: "testConnection", sender: Any?.self)
            
        }
        let AkceZpet = UIAlertAction(title: "BACK", style: .default){//kliknuti na tlacitko BACK
            (ACTION) in
          //Stisk BACK
        }
        messageBox.addTextField {//tohle zobrazi text pole na zadani serioveho cisla
        (txtUsername) -> Void in
        passwordTextField = txtUsername
        passwordTextField!.placeholder = "<Your password here>"
        }
            
        messageBox.addTextField {//tohle zobrazi text pole na zadani serioveho cisla
        (txtMailname) -> Void in
        mailTextField = txtMailname
        mailTextField!.placeholder = "<Your email address here>"
        }
        
        messageBox.addAction(AkceZpet)
        messageBox.addAction(AkceOK)
        self.present(messageBox,animated: true)
        }
        
    }
    if volbaZarizeni=="termostat"{
    
        if LabelWifi3.text != "----"{
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        let nadpis = "Zadejte heslo k WIFi \(LabelWifi3.text!)"
            //var mailTextField: UITextField?
            var passwordTextField: UITextField?
        let messageBox = UIAlertController(title: nadpis, message: "", preferredStyle: .alert)
            //let messageBox2 = UIAlertController(title: nadpis, message: "Zadejte vaši emailovou adresu \(LabelWifi1.text!)", preferredStyle: .alert)
        let AkceOK = UIAlertAction(title: "OK", style: .default){//pokud se stikne tlacitko OK
            (ACTION) in
            
            let configData = "Wifi CONFIG:SSID:\(self.LabelWifi3.text!)PASSW:\(passwordTextField?.text ?? "")MAC:\(seznamMACZarizeni[self.outletPickerSeSeznamem.selectedRow(inComponent: 0)])IP:\(seznamIPZarizeni[self.outletPickerSeSeznamem.selectedRow(inComponent: 0)])NUM:\(self.outletPickerSeSeznamem.selectedRow(inComponent:0)%2)END"
            self.writeValue(data:configData )
            print("configData:\(configData)")
            autoReconnect=false
            while(BLEzpravaOdeslana){}
            print("Odeslane nastaveni do modulu")
            
            self.performSegue(withIdentifier: "showDeviceListTermostat", sender: Any?.self)
            
        }
        let AkceZpet = UIAlertAction(title: "BACK", style: .default){//kliknuti na tlacitko BACK
            (ACTION) in
          //Stisk BACK
        }
        messageBox.addTextField {//tohle zobrazi text pole na zadani serioveho cisla
        (txtUsername) -> Void in
        passwordTextField = txtUsername
        passwordTextField!.placeholder = "<Your password here>"
        }
            
        
        messageBox.addAction(AkceZpet)
        messageBox.addAction(AkceOK)
        self.present(messageBox,animated: true)
        }
        
    }
    
    }
    @IBAction func buttonConnectWifi4(_ sender: Any) {
        if volbaZarizeni=="modul"{
        if LabelWifi4.text != "----"{
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        let nadpis = "Zadejte heslo k WIFi \(LabelWifi4.text!) a mail adresu pro zasílání reportu:"
            var mailTextField: UITextField?
            var passwordTextField: UITextField?
        let messageBox = UIAlertController(title: nadpis, message: "", preferredStyle: .alert)
            //let messageBox2 = UIAlertController(title: nadpis, message: "Zadejte vaši emailovou adresu \(LabelWifi1.text!)", preferredStyle: .alert)
        let AkceOK = UIAlertAction(title: "OK", style: .default){//pokud se stikne tlacitko OK
            (ACTION) in
            
            let configData = "Wifi CONFIG:SSID:\(self.LabelWifi4.text!)PASSW:\(passwordTextField?.text ?? "")MAIL:\(mailTextField?.text ?? "")END"
            self.writeValue(data: configData)
            print("configData:\(configData)")
            //self.ActivityIndicator("Connecting to \(self.LabelWifi1.text!)")
            autoReconnect=false
            while(BLEzpravaOdeslana){}
            print("Odeslane nastaveni do modulu")
            
            self.performSegue(withIdentifier: "testConnection", sender: Any?.self)
            
        }
        let AkceZpet = UIAlertAction(title: "BACK", style: .default){//kliknuti na tlacitko BACK
            (ACTION) in
          //Stisk BACK
        }
        messageBox.addTextField {//tohle zobrazi text pole na zadani serioveho cisla
        (txtUsername) -> Void in
        passwordTextField = txtUsername
        passwordTextField!.placeholder = "<Your password here>"
        }
            
        messageBox.addTextField {//tohle zobrazi text pole na zadani serioveho cisla
        (txtMailname) -> Void in
        mailTextField = txtMailname
        mailTextField!.placeholder = "<Your email address here>"
        }
        
        messageBox.addAction(AkceZpet)
        messageBox.addAction(AkceOK)
        self.present(messageBox,animated: true)
        }
        
    }
    if volbaZarizeni=="termostat"{
    
        if LabelWifi4.text != "----"{
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        let nadpis = "Zadejte heslo k WIFi \(LabelWifi4.text!)"
            //var mailTextField: UITextField?
            var passwordTextField: UITextField?
        let messageBox = UIAlertController(title: nadpis, message: "", preferredStyle: .alert)
            //let messageBox2 = UIAlertController(title: nadpis, message: "Zadejte vaši emailovou adresu \(LabelWifi1.text!)", preferredStyle: .alert)
        let AkceOK = UIAlertAction(title: "OK", style: .default){//pokud se stikne tlacitko OK
            (ACTION) in
            
            let configData = "Wifi CONFIG:SSID:\(self.LabelWifi4.text!)PASSW:\(passwordTextField?.text ?? "")MAC:\(seznamMACZarizeni[self.outletPickerSeSeznamem.selectedRow(inComponent: 0)])IP:\(seznamIPZarizeni[self.outletPickerSeSeznamem.selectedRow(inComponent: 0)])NUM:\(self.outletPickerSeSeznamem.selectedRow(inComponent:0)%2)END"
            self.writeValue(data: configData)
            print("configData:\(configData)")
            autoReconnect=false
            while(BLEzpravaOdeslana){}
            print("Odeslane nastaveni do modulu")
            
            self.performSegue(withIdentifier: "showDeviceListTermostat", sender: Any?.self)
            
        }
        let AkceZpet = UIAlertAction(title: "BACK", style: .default){//kliknuti na tlacitko BACK
            (ACTION) in
          //Stisk BACK
        }
        messageBox.addTextField {//tohle zobrazi text pole na zadani serioveho cisla
        (txtUsername) -> Void in
        passwordTextField = txtUsername
        passwordTextField!.placeholder = "<Your password here>"
        }
            
        
        messageBox.addAction(AkceZpet)
        messageBox.addAction(AkceOK)
        self.present(messageBox,animated: true)
        }
        
    }
    
    }
    
    @IBAction func buttonConnectToSecretWifi(_ sender: Any) {
       if volbaZarizeni=="modul"{
        let nadpis = "Zadejte Nazev a heslo WIFi:"
        let messageBox = UIAlertController(title: nadpis, message: "Zadejte nazev a heslo Vasi WiFI site", preferredStyle: .alert)
        let AkceOK = UIAlertAction(title: "OK", style: .default){//pokud se stikne tlacitko OK
            (ACTION) in
            autoReconnect=false
            let configData = "Wifi CONFIG:SSID:\(messageBox.textFields?[0].text ?? "")PASSW:\(messageBox.textFields?[1].text ?? ""   )MAIL:\(messageBox.textFields?[2].text ?? "")END"
            self.writeValue(data: configData)
            while(BLEzpravaOdeslana){}
            print("Odeslane nastaveni do modulu")
            print("configData:\(configData)")
            self.performSegue(withIdentifier: "testConnection", sender: Any?.self)
        }
        let AkceZpet = UIAlertAction(title: "BACK", style: .default){//kliknuti na tlacitko BACK
            (ACTION) in
            //Stisk BACK
        }
        //tady se to musi dodelat aby dobre naplnil data k odeslani
        messageBox.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "<Your WiFi name here>"}
        messageBox.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "<Your password here>"}
        messageBox.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "<Your mail address here>"}
        
        messageBox.addAction(AkceZpet)
        messageBox.addAction(AkceOK)
        self.present(messageBox,animated: true)
        }
        
        if volbaZarizeni=="termostat"{
        let nadpis = "Zadejte Nazev a heslo WIFi:"
        let messageBox = UIAlertController(title: nadpis, message: "Zadejte nazev a heslo Vasi WiFI site", preferredStyle: .alert)
        let AkceOK = UIAlertAction(title: "OK", style: .default){//pokud se stikne tlacitko OK
            (ACTION) in
            autoReconnect=false
            let configData = "Wifi CONFIG:SSID:\(messageBox.textFields?[0].text ?? "")PASSW:\(messageBox.textFields?[1].text ?? "")MAC:\(seznamMACZarizeni[self.outletPickerSeSeznamem.selectedRow(inComponent: 0)])IP:\(seznamIPZarizeni[self.outletPickerSeSeznamem.selectedRow(inComponent: 0)])NUM:\(self.outletPickerSeSeznamem.selectedRow(inComponent:0)%2)END"
            self.writeValue(data: configData)
            print("configData:\(configData)")
            
            
            while(BLEzpravaOdeslana){}
            
            print("Odeslane nastaveni do modulu")
            self.performSegue(withIdentifier: "testConnection", sender: Any?.self)
        }
        let AkceZpet = UIAlertAction(title: "BACK", style: .default){//kliknuti na tlacitko BACK
            (ACTION) in
            //Stisk BACK
        }
        //tady se to musi dodelat aby dobre naplnil data k odeslani
        messageBox.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "<Your WiFi name here>"}
        messageBox.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "<Your password here>"}
        
        messageBox.addAction(AkceZpet)
        messageBox.addAction(AkceOK)
        self.present(messageBox,animated: true)
        }
        
    }
    
    
    var centralManager : CBCentralManager!
    
    var writeData: String = ""
    var peripherals: [CBPeripheral] = []
    var characteristicValue = [CBUUID: NSData]()
    var timer = Timer()
    var characteristics = [String : CBCharacteristic]()
    var nameOfBLEmodule : CBPeripheral?=nil
    var readRSSITimer: Timer!
    var RSSIholder: NSNumber = 0
    
    
    var peripheralManager: CBPeripheralManager?
    var peripheral: CBPeripheral!
    
    
    
    //--------------------------------------------------------
    // MARK: parsujDataBLE --------------------------------
    //--------------------------------------------------------
    
    public func parsujDataBLE(prvniZnak:Character,druhyZnak:Character) -> String
    {
        if dataZuartu.contains(prvniZnak)&&dataZuartu.contains(druhyZnak){
            let startIndex = dataZuartu.index(after:dataZuartu.firstIndex(of: prvniZnak)!)
            let endIndex = dataZuartu.firstIndex(of: druhyZnak)!
            let range = startIndex..<endIndex
            return(String(dataZuartu[range]))//pokud najde platna data tak je vrati
        }
        else {
            return("")//pokud to slovo je nejaky spatny tak vraci prazdny retezec aby to nikdy nebylo NILL
        }
    }
    
    func updateIncomingData () {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "Notify"), object: nil , queue: nil){
            notification in
            uartData=((characteristicASCIIValue as String))
            dataZuartu=uartData;
            print("Dosla data z BLE:\(dataZuartu)")
            
            if dataZuartu.contains("Hi Emtron!") && obdrzelJsempoZdrav==false//naslo to pozadavek na data z modulu
            {
                
                //print("Data z uartu: \(dataZuartu)")
                var dataProPozdrav:String=""
                dataProPozdrav+="Hi ESP!"//odpovi modulu ze muze zacit posilat data
                dataProPozdrav+=" Name:"
                dataProPozdrav+=UIDevice.current.name//tohle posle nazev telefonu
                self.writeValue(data: dataProPozdrav)
                print("odeslana data pres BLE: \(dataProPozdrav)")
                dataZuartu = ""
                obdrzelJsempoZdrav=true
                
                
                
            }//konec Hi Emtron
            
                //";" nahrazeno 191 17
                //"~" nahrazeno 192 18
                //"!" nahrazeno 193 19
                //"@" nahrazeno 194 20
                //"#" nahrazeno 195 21
                //"$" nahrazeno 196 22
                //"%" nahrazeno 197 23
                //"^" nahrazeno 200 24
                //"&" nahrazeno 201 25
                //"*" nahrazeno 202 26
                //"(" nahrazeno 203 27
            else if dataZuartu.contains(Character(UnicodeScalar(17))) && dataZuartu.contains(Character(UnicodeScalar(27))) //dosel seznam wifi siti
            {
                print("Doisli data se seznamem wifi")
                //ProgressHUD.showSuccess()
                aktualniJmenoZarizeni=self.parsujDataBLE(prvniZnak:Character(UnicodeScalar(17)), druhyZnak: Character(UnicodeScalar(18)))
                aktualniMacAdressa = self.parsujDataBLE(prvniZnak: Character(UnicodeScalar(18)), druhyZnak: Character(UnicodeScalar(19)))
                print("aktualniJmenoZarizeni:\(aktualniJmenoZarizeni)")
                print("aktualniMacAdressa:\(aktualniMacAdressa)")
                
                self.LabelWifi1.text = self.parsujDataBLE(prvniZnak: Character(UnicodeScalar(19)), druhyZnak: Character(UnicodeScalar(20)))
                var wifisignal = self.parsujDataBLE(prvniZnak: Character(UnicodeScalar(20)), druhyZnak: Character(UnicodeScalar(21)))
            
                print (wifisignal)
                if Int(wifisignal) ?? -100 > 0 && Int(wifisignal) ?? -100 < -100{
                    wifisignal="-100"
                }
                if wifisignal == "--"{
                    wifisignal = "-100"
                }
                if Int(wifisignal) ?? 0 > -50{
                 //plny signal
                    self.RSSIwifi1.image=UIImage(named: "wifiSignalFull")
                }
                else if Int(wifisignal) ?? 0 <= -50 && Int(wifisignal) ?? 0 > -55{
                 //4 carky
                    self.RSSIwifi1.image=UIImage(named: "wifiSignal4")
                }
                else if Int(wifisignal) ?? 0 <= -55 && Int(wifisignal) ?? 0 > -62{
                 //3 carky
                    self.RSSIwifi1.image=UIImage(named: "wifiSignal3")
                }
                else if Int(wifisignal) ?? 0 <= -62 && Int(wifisignal) ?? 0 > -65{
                 //2 carky
                    self.RSSIwifi1.image=UIImage(named: "wifiSignal2")
                }
                else if Int(wifisignal) ?? 0 <= -65 && Int(wifisignal) ?? 0 > -74{
                 //1 carky
                    self.RSSIwifi1.image=UIImage(named: "wifiSignal1")
                }
                else {
                 //zadny signal
                    //print("slaby signal")
                    self.RSSIwifi1.image=UIImage(named: "wifiSignal0")
                }
                self.LabelWifi2.text = self.parsujDataBLE(prvniZnak: Character(UnicodeScalar(21)), druhyZnak: Character(UnicodeScalar(22)))
                
                wifisignal = (self.parsujDataBLE(prvniZnak: Character(UnicodeScalar(22)), druhyZnak: Character(UnicodeScalar(23))))
                if Int(wifisignal) ?? -100 > 0 && Int(wifisignal) ?? -100 < -100{
                    wifisignal="-100"
                }
                if wifisignal == "--"{
                    wifisignal = "-100"
                }
                print ((wifisignal))
                if Int(wifisignal) ?? 0 > -50{
                 //plny signal
                    self.RSSIwifi2.image=UIImage(named: "wifiSignalFull")
                }
                else if Int(wifisignal) ?? 0 <= -50 && Int(wifisignal) ?? 0 > -55{
                 //4 carky
                    self.RSSIwifi2.image=UIImage(named: "wifiSignal4")
                }
                else if Int(wifisignal) ?? 0 <= -55 && Int(wifisignal) ?? 0 > -62{
                 //3 carky
                    self.RSSIwifi2.image=UIImage(named: "wifiSignal3")
                }
                else if Int(wifisignal) ?? 0 <= -62 && Int(wifisignal) ?? 0 > -65{
                 //2 carky
                    self.RSSIwifi2.image=UIImage(named: "wifiSignal2")
                }
                else if Int(wifisignal) ?? 0 <= -65 && Int(wifisignal) ?? 0 > -74{
                 //1 carky
                    self.RSSIwifi2.image=UIImage(named: "wifiSignal1")
                }
                else {
                 //zadny signal
                    //print("slaby signal")
                    self.RSSIwifi2.image=UIImage(named: "wifiSignal0")
                }
                self.LabelWifi3.text = self.parsujDataBLE(prvniZnak: Character(UnicodeScalar(23)), druhyZnak: Character(UnicodeScalar(24)))
                
               
                wifisignal = (self.parsujDataBLE(prvniZnak: Character(UnicodeScalar(24)), druhyZnak: Character(UnicodeScalar(25))))
                if Int(wifisignal) ?? -100 > 0 && Int(wifisignal) ?? -100 < -100{
                    wifisignal="-100"
                }
                if wifisignal == "--"{
                    wifisignal = "-100"
                }
                print ((wifisignal))
                if Int(wifisignal) ?? 0 > -50{
                 //plny signal
                    self.RSSIwifi3.image=UIImage(named: "wifiSignalFull")
                }
                else if Int(wifisignal) ?? 0 <= -50 && Int(wifisignal) ?? 0 > -55{
                 //4 carky
                    self.RSSIwifi3.image=UIImage(named: "wifiSignal4")
                }
                else if Int(wifisignal) ?? 0 <= -55 && Int(wifisignal) ?? 0 > -62{
                 //3 carky
                    self.RSSIwifi3.image=UIImage(named: "wifiSignal3")
                }
                else if Int(wifisignal) ?? 0 <= -62 && Int(wifisignal) ?? 0 > -65{
                 //2 carky
                    self.RSSIwifi3.image=UIImage(named: "wifiSignal2")
                }
                else if Int(wifisignal) ?? 0 <= -65 && Int(wifisignal) ?? 0 > -74{
                 //1 carky
                    self.RSSIwifi3.image=UIImage(named: "wifiSignal1")
                }
                else {
                 //zadny signal
                    //print("slaby signal")
                    self.RSSIwifi3.image=UIImage(named: "wifiSignal0")
                }
                self.LabelWifi4.text = self.parsujDataBLE(prvniZnak: Character(UnicodeScalar(25)), druhyZnak: Character(UnicodeScalar(26)))
                
                
                wifisignal = (self.parsujDataBLE(prvniZnak: Character(UnicodeScalar(26)), druhyZnak: Character(UnicodeScalar(27))))
                if Int(wifisignal) ?? -100 > 0 && Int(wifisignal) ?? -100 < -100{
                    wifisignal="-100"
                }
                if wifisignal == "--"{
                    wifisignal = "-100"
                }
                print ((wifisignal))
                if Int(wifisignal) ?? 0 > -50{
                 //plny signal
                    self.RSSIwifi4.image=UIImage(named: "wifiSignalFull")
                }
                else if Int(wifisignal) ?? 0 <= -50 && Int(wifisignal) ?? 0 > -55{
                 //4 carky
                    self.RSSIwifi4.image=UIImage(named: "wifiSignal4")
                }
                else if Int(wifisignal) ?? 0 <= -55 && Int(wifisignal) ?? 0 > -62{
                 //3 carky
                    self.RSSIwifi4.image=UIImage(named: "wifiSignal3")
                }
                else if Int(wifisignal) ?? 0 <= -62 && Int(wifisignal) ?? 0 > -65{
                 //2 carky
                    self.RSSIwifi4.image=UIImage(named: "wifiSignal2")
                }
                else if Int(wifisignal) ?? 0 <= -65 && Int(wifisignal) ?? 0 > -74{
                 //1 carky
                    self.RSSIwifi4.image=UIImage(named: "wifiSignal1")
                }
                else {
                 //zadny signal
                    //print("slaby signal")
                    self.RSSIwifi4.image=UIImage(named: "wifiSignal0")
                }
                
                
                //tady projit pole jestli uz zarizeni nebylo jednou pridano a pridat do seznamu
                if seznamMACZarizeni.contains(aktualniMacAdressa)
                {
                    print("zarizeni je jiz v seznamu")
                }
                else {
                    if aktualniMacAdressa.contains("EMTRON-CZ-2-RELAYS-MODULE"){
                    //prida prvni rele
                    seznamMACZarizeni.append(aktualniMacAdressa)
                    seznamNazvuZarizeni.append(aktualniJmenoZarizeni)
                        var MACadress = aktualniMacAdressa.replacingOccurrences(of: "EMTRON-CZ-2-RELAYS-MODULE{", with: "")
                        MACadress = MACadress.replacingOccurrences(of: "}", with: "/")
                        seznamTopicu.append(MACadress)//prida to topic
                        
                        
                        seznamOnlineZarizeni.append("ONline")
                    seznamIPZarizeni.append("0.0.0.0")
                    seznamUmisteniZarizeni.append("No defined")
                    seznamObrazkuZarizeni.append("Prvni zarizeni")
                    poradoveCisloRele.append("1")
                    seznamMerenychTeplot.append("20.0")
                    seznamPozadovanychTeplot.append("0.0")
                    seznamProvoznichRezimu.append(" ")
                    seznamVerziFirmwaru.append(" ")
                    poleKalendaru.append(kalendarTyden)
                    poleZobrazenychteplotnaTopeni.append("")
                    seznamCasuVmodulech.append("")
                    seznamDostupnychAktualizaciVmodulech.append("")
                    seznamZparovanychZarizeni.append("")
                    seznamPripojenychTeplomeru.append("")
                        seznamNotifikaci.append("")
                        seznamKoduHomekitu.append("")
                        seznamMinimalnichTeplot.append("0")
                        seznamMaximalnichTeplot.append("40")
                        seznamRSSI.append("")
                        seznamQRkodu.append("")
                        seznamZparovanychShomekitem.append("")
                        seznamSSID.append("")
                        seznamBarevModulu.append(UIColor.init(red: 90/255, green: 90/255, blue: 90/255, alpha: 1))//nastavi se seda barva
                        seznamTopoimChladim.append("Topim")
                        seznamKladnaHystereze.append("0.5")
                        seznamZapornaHystereze.append("0.25")
                        seznamTimeru.append("0")
                        seznamMDNSvsAWS.append("MDNS")
                    //prida druhe rele
                    seznamMACZarizeni.append(aktualniMacAdressa)
                    seznamNazvuZarizeni.append(aktualniJmenoZarizeni)
                    seznamOnlineZarizeni.append("ONline")
                    seznamIPZarizeni.append("0.0.0.0")
                    seznamUmisteniZarizeni.append("No defined")
                    seznamObrazkuZarizeni.append("Druhe zarizeni")
                    poradoveCisloRele.append("2")
                    seznamMerenychTeplot.append("20.0")
                    seznamPozadovanychTeplot.append("1.0")
                    seznamProvoznichRezimu.append(" ")
                    seznamVerziFirmwaru.append(" ")
                    poleKalendaru.append(kalendarTyden)
                    poleZobrazenychteplotnaTopeni.append("")
                    seznamCasuVmodulech.append("")
                    seznamDostupnychAktualizaciVmodulech.append("")
                    seznamZparovanychZarizeni.append("")
                    seznamPripojenychTeplomeru.append("")
                        seznamNotifikaci.append("")
                        seznamMDNSvsAWS.append("MDNS")
                        seznamKoduHomekitu.append("")
                        seznamMinimalnichTeplot.append("0")
                        seznamMaximalnichTeplot.append("40")
                        seznamRSSI.append("")
                        seznamQRkodu.append("")
                        seznamZparovanychShomekitem.append("")
                        seznamSSID.append("")
                        seznamTopoimChladim.append("Topim")
                        seznamKladnaHystereze.append("0.5")
                        seznamZapornaHystereze.append("0.25")
                        seznamBarevModulu.append(UIColor.init(red: 90/255, green: 90/255, blue: 90/255, alpha: 1))//nastavi se seda barva
                        seznamTimeru.append("0")
                        UserDefaults.standard.setValue(seznamKladnaHystereze, forKey: "seznamKladnaHystereze")
                        UserDefaults.standard.setValue(seznamZapornaHystereze, forKey: "seznamZapornaHystereze")
                    UserDefaults.standard.setValue(seznamTopoimChladim, forKey: "seznamTopoimChladim")
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
                    UserDefaults.standard.setValue(seznamVerziFirmwaru, forKey: "seznamVerziFirmwaru")
                    UserDefaults.standard.setValue(poleKalendaru, forKey: "poleKalendaru")
                    UserDefaults.standard.setValue(poleZobrazenychteplotnaTopeni, forKey: "poleZobrazenychteplotnaTopeni")
                        UserDefaults.standard.setValue(seznamMinimalnichTeplot, forKey: "seznamMinimalnichTeplot")
                        UserDefaults.standard.setValue(seznamMaximalnichTeplot, forKey: "seznamMaximalnichTeplot")
                       // UserDefaults.standard.setValue(seznamBarevModulu, forKey: "seznamBarevModulu")
                    UserDefaults.standard.setValue("ANO", forKey: "JizByloSpusteno")
                    
                        print("pridal nove dve zarizeni")
                        
                        //var sdilenaDataProWatch = UserDefaults.init(suiteName: "group.dataProWatch")
                        //sdilenaDataProWatch?.set(seznamNazvuZarizeni, forKey: "seznamNazvuZarizeni")
                        //sdilenaDataProWatch?.synchronize()
                    }
                }
                self.view.dismissProgress()
            }
            else
            {
                /*self.timer.invalidate();
                self.citacProBluetoothTimeout=0
                               
                let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)

                let message  = "Modul neodpovídá"
                var messageMutableString = NSMutableAttributedString()
                messageMutableString = NSMutableAttributedString(string: message as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Aller", size: 18.0)!])
                messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 60/255, green: 60/255, blue: 60/255, alpha: 1), range:NSRange(location:0,length:message.count))
                alertController.setValue(messageMutableString, forKey: "attributedMessage")


                let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    if DEBUGMSG{
                    print("Alert Click OK")
                    }
                    let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeviceListController")
                    viewController.modalPresentationStyle = .fullScreen
                    self.present(viewController, animated: true, completion: nil)
                }

                
                alertController.addAction(okAction)

                
                alertController.view.tintColor = UIColor.init(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
                //alertController.view.backgroundColor = UIColor.black
                alertController.view.layer.cornerRadius = 40

                self.present(alertController, animated: true, completion: nil)*/
            }
            
            
        }
    }
    
    // Write functions
    func writeValue(data: String){
        BLEzpravaOdeslana=false
        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
        //change the "data" to valueString
        if let blePeripheral = blePeripheral{
            if let txCharacteristic = txCharacteristic {
                blePeripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }
    
    func writeCharacteristic(val: Int8){
        var val = val
        let ns = NSData(bytes: &val, length: MemoryLayout<Int8>.size)
        blePeripheral!.writeValue(ns as Data, for: txCharacteristic!, type: CBCharacteristicWriteType.withResponse)
    }
    
    
    
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            return
        }
        print("Peripheral manager is running")
    }
    
    //Check when someone subscribe to our characteristic, start sending the data
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("Device subscribe to characteristic")
    }
    
    /**************************************************BLUETOOTH***************************************/
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            // We will just handle it the easy way here: if Bluetooth is on, proceed...start scan!
            print("Bluetooth Enabled")
            //if spojenoBluetooth==false  {
            
            startScan()
            //}
            
        } else {
            //If Bluetooth is off, display a UI alert message saying "Bluetooth is not enable" and "Make sure that your bluetooth is turned on"
            print("Bluetooth Disabled - Make sure your Bluetooth is turned on")
            
            let alertVC = UIAlertController(title: "Bluetooth is not enabled", message: "Make sure that your bluetooth is turned on", preferredStyle: UIAlertController.Style.alert)
            let action = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) -> Void in
                //self.dismiss(animated: true, completion: nil)
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                  UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                }
            })
            alertVC.addAction(action)
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func startScan() {
        //showSpinner(onView: self.view)
        
        if citacProBluetoothTimeout == 0 {
            print("zapinam timer")
          let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
                timer.tolerance = 0.5
            
                print("timer tick")
                self.citacProBluetoothTimeout=self.citacProBluetoothTimeout+1
            //ProgressHUD.show("Connecting...")
                if self.citacProBluetoothTimeout>5 {
                    //sem dat hlasku ze se nepodarilo pripojit
                    print("nepodarilo se pripojit k BLE")
                    //self.removeSpinner()
                    //ProgressHUD.dismiss()
                    //self.removeBlur() //zakomentoval jsem
                    
                    timer.invalidate();
                    self.citacProBluetoothTimeout=0
                    
                    
                    let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)

                    let message  = "Modul neodpovídá"
                    var messageMutableString = NSMutableAttributedString()
                    messageMutableString = NSMutableAttributedString(string: message as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Aller", size: 18.0)!])
                    messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 60/255, green: 60/255, blue: 60/255, alpha: 1), range:NSRange(location:0,length:message.count))
                    alertController.setValue(messageMutableString, forKey: "attributedMessage")


                    let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                        if DEBUGMSG{
                        print("Alert Click OK")
                        }
                        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeviceListController")
                        viewController.modalPresentationStyle = .fullScreen
                        self.present(viewController, animated: true, completion: nil)
                    }

                    
                    alertController.addAction(okAction)

                    
                    alertController.view.tintColor = UIColor.init(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
                    //alertController.view.backgroundColor = UIColor.black
                    alertController.view.layer.cornerRadius = 40

                    self.present(alertController, animated: true, completion: nil)
                }
            if vypniTimer==true{
                timer.invalidate()
                self.citacProBluetoothTimeout=0
                print("vypinam timer")
                self.view.dismissProgress()
                
            }
                
            })
        }
        peripherals = []
        print("Now Scanning...")
        //ProgressHUD.show("Now scanning...")
        //self.timer.invalidate()
        centralManager?.scanForPeripherals(withServices: [BLEService_UUID] , options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
        //centralManager?.scanForPeripherals(withServices: [BLEService_UUID] , options: nil)
        //centralManager?.scanForPeripherals(withServices: nil)
        //Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.cancelScan), userInfo: nil, repeats: false)
    }
    
    
    /*
     Called when the central manager discovers a peripheral while scanning. Also, once peripheral is connected, cancel scanning.
     */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        
        blePeripheral = peripheral
        self.peripherals.append(peripheral)
        peripheral.delegate = self
        if blePeripheral != nil {
            print("Found new pheripheral devices with services")
            print("Peripheral name: \(String(describing: peripheral.name))")
            print("**********************************")
            //print ("Advertisement Data : \(advertisementData)")
            //if (blePeripheral?.name?.hasPrefix(SerialNumber) ?? false)
            //{
                timer.invalidate()
                self.centralManager?.stopScan()
                print("Scan Stopped")
                print(" OK Naslo to modul se zadanou mac adresou")
                print("RSSI:\(RSSI)")
                connectToDevice()
            //}
            //else {
                
            //    print("Nasel modul ale s jinou MAC adressou")
            //}
        }
        else{
            print("Nic nenasel")
            let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)

            let message  = "Modul neodpovídá"
            var messageMutableString = NSMutableAttributedString()
            messageMutableString = NSMutableAttributedString(string: message as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Aller", size: 18.0)!])
            messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 60/255, green: 60/255, blue: 60/255, alpha: 1), range:NSRange(location:0,length:message.count))
            alertController.setValue(messageMutableString, forKey: "attributedMessage")


            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                if DEBUGMSG{
                print("Alert Click OK")
                }
                let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeviceListController")
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true, completion: nil)
            }

            
            alertController.addAction(okAction)

            
            alertController.view.tintColor = UIColor.init(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
            //alertController.view.backgroundColor = UIColor.black
            alertController.view.layer.cornerRadius = 40

            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    //Peripheral Connections: Connecting, Connected, Disconnected
    
    //-Connection
    func connectToDevice () {
        centralManager?.connect(blePeripheral!, options: nil)
        print("Connect to device")
        //removeSpinner()
        //removeActivityIndicator()
    }
    
    /*
     Invoked when a connection is successfully created with a peripheral.
     This method is invoked when a call to connect(_:options:) is successful. You typically implement this method to set the peripheral’s delegate and to discover its services.
     */
    //-Connected
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("*****************************")
        print("Connection complete")
        print("Peripheral info: \(String(describing: blePeripheral))")
        
        data.length = 0
        
        //Discovery callback
        peripheral.delegate = self
        //Only look for services that matches transmit uuid
        peripheral.discoverServices([BLEService_UUID])
        updateIncomingData()
        spojenoBluetooth = true
        indikaceIkonaBluetooth=true;
        NotificationCenter.default.post(name:NSNotification.Name("zjistenaZmenaNaBLE"), object: nil)
        
        //peripheral.readRSSI()
        //self.startReadRSSI()
        
    }
    
    
    /*
     Invoked when you discover the peripheral’s available services.
     This method is invoked when your app calls the discoverServices(_:) method. If the services of the peripheral are successfully discovered, you can access them through the peripheral’s services property. If successful, the error parameter is nil. If unsuccessful, the error parameter returns the cause of the failure.
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("*******************************************************")
        
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            return
        }
        //We need to discover the all characteristic
        for service in services {
            
            peripheral.discoverCharacteristics(nil, for: service)
            // bleService = service
        }
        print("Discovered Services: \(services)")
    }
    
    /*
     Invoked when you discover the characteristics of a specified service.
     This method is invoked when your app calls the discoverCharacteristics(_:for:) method. If the characteristics of the specified service are successfully discovered, you can access them through the service's characteristics property. If successful, the error parameter is nil. If unsuccessful, the error parameter returns the cause of the failure.
     */
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        print("*******************************************************")
        
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        print("Found \(characteristics.count) characteristics!")
        
        for characteristic in characteristics {
            //looks for the right characteristic
            
            if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Rx)  {
                rxCharacteristic = characteristic
                
                //Once found, subscribe to the this particular characteristic...
                peripheral.setNotifyValue(true, for: rxCharacteristic!)
                // We can return after calling CBPeripheral.setNotifyValue because CBPeripheralDelegate's
                // didUpdateNotificationStateForCharacteristic method will be called automatically
                peripheral.readValue(for: characteristic)
                print("Rx Characteristic: \(characteristic.uuid)")
            }
            if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Tx){
                txCharacteristic = characteristic
                print("Tx Characteristic: \(characteristic.uuid)")
            }
            peripheral.discoverDescriptors(for: characteristic)
        }
    }
    
    // Getting Values From Characteristic
    
    /*After you've found a characteristic of a service that you are interested in, you can read the characteristic's value by calling the peripheral "readValueForCharacteristic" method within the "didDiscoverCharacteristicsFor service" delegate.
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("error: \(error)")
        }
        else{
            if characteristic == rxCharacteristic {
               //let value = String.init(data: characteristic.value!, encoding: .utf8)!
                
                //print("dosli data:\(value)")
                if let ASCIIstring = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue) {
                  characteristicASCIIValue = ASCIIstring
                //print("Value Recieved: \((characteristicASCIIValue as String))")
                NotificationCenter.default.post(name:NSNotification.Name(rawValue: "Notify"), object: nil)
                
            }
        }
    }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("*******************************************************")
        
        if error != nil {
            print("\(error.debugDescription)")
            return
        }
        if ((characteristic.descriptors) != nil) {
            vypniTimer=true;
            print("vypinam timer pro bluetooth timeout")
            for x in characteristic.descriptors!{
                let descript = x as CBDescriptor
                print("function name: DidDiscoverDescriptorForChar \(String(describing: descript.description))")
                print("Rx Value \(String(describing: rxCharacteristic?.value))")
                print("Tx Value \(String(describing: txCharacteristic?.value))")
                //readRSSITimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateRSSI), userInfo: nil, repeats: true)//tohle vypisuje periodicky signal na BLE
                indikaceIkonaBluetooth=true;
                zjistenaZmenaNaBLE();
                
            }
        }
    }
    
    @objc func updateRSSI(){
        if (blePeripheral != nil){
            //blePeripheral?.delegate = self
            blePeripheral?.readRSSI()
        } else {
            print("peripheral = nil")
        }
        
    }
    
    
    func peripheral(_ peripheral: CBPeripheral,didReadRSSI RSSI: NSNumber,error: Error?)
    {
        self.RSSIholder = RSSI
        print("RSSI: \(RSSI)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("*******************************************************")
        
        if (error != nil) {
            print("Error changing notification state:\(String(describing: error?.localizedDescription))")
            //problem na BLE
            let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)

            let message  = "Modul neodpovídá"
            var messageMutableString = NSMutableAttributedString()
            messageMutableString = NSMutableAttributedString(string: message as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Aller", size: 18.0)!])
            messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 60/255, green: 60/255, blue: 60/255, alpha: 1), range:NSRange(location:0,length:message.count))
            alertController.setValue(messageMutableString, forKey: "attributedMessage")


            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                if DEBUGMSG{
                print("Alert Click OK")
                }
                let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeviceListController")
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true, completion: nil)
            }

            
            alertController.addAction(okAction)

            
            alertController.view.tintColor = UIColor.init(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
            //alertController.view.backgroundColor = UIColor.black
            alertController.view.layer.cornerRadius = 40

            self.present(alertController, animated: true, completion: nil)
            
        } else {
            print("Characteristic's value subscribed")
        }
        
        if (characteristic.isNotifying) {
            print ("Subscribed. Notification has begun for: \(characteristic.uuid)")
            //timer.invalidate();
        }
    }
    
    
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected !!!")
        if (error != nil) {
            print("Error:\(String(describing: error?.localizedDescription))")
            
        }
        view.dismissProgress()
        vypniTimer=false
        obdrzelJsempoZdrav=false//to je kuli reconectu kdyz se vypne modul a aplikace bezi
        indikaceIkonaBluetooth=false;
        zjistenaZmenaNaBLE()
        NotificationCenter.default.post(name:NSNotification.Name("zjistenaZmenaNaBLE"), object: nil)
        //connectToDevice() //tohle je kvuli znocupripojeni po odpojeni
        
        if autoReconnect==true{
            self.centralManager?.stopScan()
            if blePeripheral != nil {
                // We have a connection to the device but we are not subscribed to the Transfer Characteristic for some reason.
                // Therefore, we will just disconnect from the peripheral
                centralManager?.cancelPeripheralConnection(blePeripheral!)
            }
            blePeripheral=nil
            self.peripherals = []
            
            if byloScanovano==false{
                centralManager = CBCentralManager(delegate: self, queue: nil)
            }
            else {
                centralManager?.delegate = self
                //startScan()
            }
            print("pokousi se znovu pripojit")
        }
        /*
        else {
            self.removeActivityIndicator()
            timer.invalidate();
            self.citacProBluetoothTimeout=0
            
            
            let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)

            let message  = "Modul neodpovídá"
            var messageMutableString = NSMutableAttributedString()
            messageMutableString = NSMutableAttributedString(string: message as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Aller", size: 18.0)!])
            messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 60/255, green: 60/255, blue: 60/255, alpha: 1), range:NSRange(location:0,length:message.count))
            alertController.setValue(messageMutableString, forKey: "attributedMessage")


            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                if DEBUGMSG{
                print("Alert Click OK")
                }
                let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeviceListController")
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true, completion: nil)
            }

            
            alertController.addAction(okAction)

            
            alertController.view.tintColor = UIColor.init(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
            //alertController.view.backgroundColor = UIColor.black
            alertController.view.layer.cornerRadius = 40

            self.present(alertController, animated: true, completion: nil)
        }*/
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Error discovering services: error")
            BLEzpravaOdeslana=false
            return
        }
        BLEzpravaOdeslana=true
        print("BLE zprava opravdu odeslana")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        guard error == nil else {
            print("Error discovering services: error")
            return
        }
        print("Succeeded!")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let iprogress: iProgressHUD = iProgressHUD()
        iprogress.modalColor = .black
        iprogress.boxColor = .clear
        iprogress.isBlurModal=true
        iprogress.boxSize=25
        iprogress.isTouchDismiss = false
        iprogress.indicatorStyle = .circleStrokeSpin
        iprogress.YOffset=(view.bounds.size.height / 2)
        iprogress.attachProgress(toView: self.view)
        view.updateCaption(text: "Connecting...")
        view.showProgress()
        outletLabelZvolte.alpha=0;
        self.pozadiView.alpha=1
        self.outletPickerSeSeznamem.delegate = self
        self.outletPickerSeSeznamem.dataSource = self
        
        //self.pozadiView.alpha=0
        pozadiView.layer.cornerRadius=20
        if volbaZarizeni=="termostat"{
            outletLabelZvolte.alpha=1;
            outletPickerSeSeznamem.alpha=1
            outletPickerSeSeznamem.layer.cornerRadius=20
            SerialNumber="EmtronThermostat"
            kBLEService_UUID = "6E400004-B5A3-F393-E0A9-E50E24DCCA9E"
            //let kBLEService_UUID = "bc3c0bb3-07ab-4d12-d66c-21b185e0ce6b"
            kBLE_Characteristic_uuid_Tx = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"//6E400002
            kBLE_Characteristic_uuid_Rx = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"//6E400003

            BLEService_UUID = CBUUID(string: kBLEService_UUID)
            BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx)//(Property = Write without response)
            BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx)// (Property = Read/Notify)
           

        }
        if volbaZarizeni=="modul"{
            outletLabelZvolte.alpha=0;
            outletPickerSeSeznamem.alpha=0
            SerialNumber="Emtron2RelaysModule"
            kBLEService_UUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
            //let kBLEService_UUID = "bc3c0bb3-07ab-4d12-d66c-21b185e0ce6b"
            kBLE_Characteristic_uuid_Tx = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
            kBLE_Characteristic_uuid_Rx = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

            BLEService_UUID = CBUUID(string: kBLEService_UUID)
            BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx)//(Property = Write without response)
            BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx)// (Property = Read/Notify)

        }
        if byloScanovano==false{
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }
        else {
            centralManager?.delegate = self
            //startScan()
        }
        //ProgressHUD.show("Connecting...")
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        outletPickerSeSeznamem.selectRow(0, inComponent: 0, animated: false)
        
        //ProgressHUD.show("Connecting...")
        
    }
    
    @objc private func zjistenaZmenaNaBLE(){
        print("skocilo to do notifikace od BLE")
        //if (indikaceIkonaBluetooth==false){
        //    self.LogoBluetooth.image = UIImage(named: "IKONA_bluetooth_OFF")
        //}
        //else {
        //    self.LogoBluetooth.image = UIImage(named: "IKONA_bluetooth_ON")
        //}
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        autoReconnect=false
        NotificationCenter.default.removeObserver(self)
        self.centralManager?.stopScan()
        if blePeripheral != nil {
            // We have a connection to the device but we are not subscribed to the Transfer Characteristic for some reason.
            // Therefore, we will just disconnect from the peripheral
            centralManager?.cancelPeripheralConnection(blePeripheral!)
        }
        blePeripheral=nil
        self.peripherals = []
        
    }
    

    
    //override var preferredStatusBarStyle: UIStatusBarStyle {//tohle prebarvi //statusbar na svetlou
     //   return .lightContent
    //}
    
    
}









