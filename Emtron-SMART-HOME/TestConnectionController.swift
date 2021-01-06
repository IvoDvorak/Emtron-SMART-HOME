//
//  ViewController.swift
//  Control center
//
//  Created by Ivo Dvorak on 10/07/2019.
//  Copyright © 2019 Ivo Dvorak. All rights reserved.
//

import UIKit
import Foundation
import iProgressHUD



var prvniStart = true
var dataKeZpracovani = ""
var indexVybranehoZarizeni=0
var IPadresaZarizeni="0.0.0.0"
var timer: Timer!
var hledamZarizeni = false
var citacHledaniOnlineZarizeni=0

class TestConnectionController: UIViewController,NetServiceBrowserDelegate,
NetServiceDelegate {
    
    @IBOutlet weak var imageLogo: UIImageView!
    @IBOutlet weak var labelText1: UILabel!
    @IBOutlet weak var labelText2: UILabel!
    
    var nsb : NetServiceBrowser!
    var services = [NetService]()
    
    //--------------------------------------------------------
    // MARK: viewDidLoad --------------------------------
    //--------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TestConnection controller DidLoad")
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
        labelText1.alpha=0
        labelText2.alpha=0
        imageLogo.alpha=0
    }
    
    
    
    //--------------------------------------------------------
    // MARK: viewDidAppear --------------------------------
    //--------------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        
        print("Jdu hledat jestli uz je zarizeni online")
        startDiscovery()
        timer = Timer.scheduledTimer(timeInterval: 7, target: self, selector: #selector(funkcevykonanakazdouvterinu), userInfo: nil, repeats: true)
        timer.tolerance=1
        
    }
    
    
    @objc func funkcevykonanakazdouvterinu()
    {
        print("Aktualni mac adresa:\(aktualniMacAdressa)")
        startDiscovery()
        print("funkce funkcevykonanakazdouvterinu citac:\(citacHledaniOnlineZarizeni)")
        if citacHledaniOnlineZarizeni>7{
            self.view.dismissProgress()
            citacHledaniOnlineZarizeni=0
            
            timer.invalidate()
            let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
            
            let message  = "Modulu se nepodařilo připojit k Vaší wifi síti, prosím opakujte předchozí kroky"
            var messageMutableString = NSMutableAttributedString()
            messageMutableString = NSMutableAttributedString(string: message as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Aller", size: 18.0)!])
            messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 1), range:NSRange(location:0,length:message.count))
            alertController.setValue(messageMutableString, forKey: "attributedMessage")
            
            
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                if DEBUGMSG{
                    print("Alert Click OK")
                }
                self.nsb.stop()
                self.services.removeAll()
                self.performSegue(withIdentifier: "showNavod1", sender: Any?.self)
            }
            
            
            alertController.addAction(okAction)
            
            
            alertController.view.tintColor = UIColor.init(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
            //alertController.view.backgroundColor = UIColor.black
            alertController.view.layer.cornerRadius = 40
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    
    
    
    
    
    //--------------------------------------------------------
    // MARK: searchServices --------------------------------
    //--------------------------------------------------------
    
    private func startDiscovery() {
        print("listening for services...")
            if services.count==0{
                seznamOnlineZarizeni.removeAll()
                for _ in 0..<seznamMACZarizeni.count{
                    //po zapnuti jsou vsechny offline
                    //print("index je:\(index)")
                    seznamOnlineZarizeni.append("OFFline")
                    
                }
                
            }
        self.services.removeAll()
        self.nsb = NetServiceBrowser()
        self.nsb.delegate = self
        self.nsb.searchForServices(ofType:"_emtron-device-info._tcp", inDomain: "")
        citacHledaniOnlineZarizeni=citacHledaniOnlineZarizeni+1
        probehloDiscovery=true
    }
    
    // MARK: Service discovery
    
    func updateInterface () {
        //prvne nastavim ve na offline a pak se uvidi
        seznamOnlineZarizeni.removeAll()
        for _ in 0..<seznamMACZarizeni.count{
            //po zapnuti jsou vsechny offline
            //print("index je:\(index)")
            seznamOnlineZarizeni.append("OFFline")
            
        }
        for service in self.services {
            if service.port == -1 {
                print("service \(service.name) of type \(service.type)" +
                    " not yet resolved")
                service.delegate = self
                service.resolve(withTimeout:5)//10
            } else {
                //print("service \(service.name) of type \(service.type)," +
                //    "port \(service.port), addresses \(service.addresses)")
                
                if service.name.hasPrefix(aktualniMacAdressa)
                       {
                           
                           //nasel zarizeni online
                    
                           citacHledaniOnlineZarizeni=0
                           timer.invalidate()//vypnu hledaci timer
                           
                           if let serviceIp = resolveIPv4(addresses: service.addresses!) {
                               print("Found \(service.name) with IPV4:", serviceIp)
                               if seznamMACZarizeni.contains(service.name)
                               {
                                   
                                   if service.name.contains("EMTRON-CZ-2-RELAYS-MODULE"){
                                       //pokud je modul se 2 rele musi aktualizovat IP adresu u obou
                                       print("Nasel 2 RELAYS MODULE zarizeni")
                                       let indexKdeJeVpoliZarizeni = seznamMACZarizeni.firstIndex(of: service.name)!
                                       seznamOnlineZarizeni[indexKdeJeVpoliZarizeni]="ONline"
                                       seznamIPZarizeni[indexKdeJeVpoliZarizeni]=serviceIp
                                       seznamOnlineZarizeni[indexKdeJeVpoliZarizeni+1]="ONline"
                                       seznamIPZarizeni[indexKdeJeVpoliZarizeni+1]=serviceIp
                                       
                                       print("aktualizuji IP adresu 2 zarizeni \(service.name) na IP:\(serviceIp)")
                                       if let data = service.txtRecordData() {
                                           if data.count<100 {return}//ochrana kdyz to nenacte txt record data
                                           //print(data)
                                           let dict = NetService.dictionary(fromTXTRecord: data)
                                           
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
                                           if dict.keys.contains("ICONE1"){
                                               /*seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni] = "\(String(data: dict["ICONE1"]!, encoding: String.Encoding.utf8)!)OFF"
                                               if seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].contains("NONE"){
                                                   seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni]="Prvni zarizeni"
                                               }
 */
                                            if seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].contains("zarovka")||seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].contains("ventilator")||seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].contains("radiator")||seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].contains("zasuvka")||seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].contains("Prvni zarizeni"){
                                                
                                                if seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].contains("NoRespone"){
                                                    seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni] = "\(String(data: dict["ICONE1"]! , encoding: String.Encoding.utf8)!)NoRespone"
                                                }
                                                else if seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].contains("ON"){
                                                    seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni] = "\(String(data: dict["ICONE1"]! , encoding: String.Encoding.utf8)!)ON"
                                                }
                                                else if seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni].contains("OFF"){
                                                    seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni] = "\(String(data: dict["ICONE1"]! , encoding: String.Encoding.utf8)!)OFF"
                                                }
                                                else {
                                                    seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni] = "\(String(data: dict["ICONE1"]! , encoding: String.Encoding.utf8)!)"
                                                }
                                                
                                            }
                                            else {
                                                seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni] = "Prvni zarizeni"
                                            }
                                           }
                                           
                                           if dict.keys.contains("ICONE2"){
                                               /*seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni+1] = "\(String(data: dict["ICONE2"]!, encoding: String.Encoding.utf8)!)OFF"
                                               if seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni+1].contains("NONE"){
                                                   seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni+1]="Druhe zarizeni"
                                               }*/
                                            if seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni+1].contains("zarovka")||seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni+1].contains("ventilator")||seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni+1].contains("radiator")||seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni+1].contains("zasuvka")||seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni+1].contains("Druhe zarizeni"){
                                                if seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni+1].contains("NoRespone"){
                                                    seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni+1] = "\(String(data: dict["ICONE2"]! , encoding: String.Encoding.utf8)!)NoRespone"
                                                }
                                                else if seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni+1].contains("ON"){
                                                    seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni+1] = "\(String(data: dict["ICONE2"]! , encoding: String.Encoding.utf8)!)ON"
                                                }
                                                else if seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni+1].contains("OFF"){
                                                    seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni+1] = "\(String(data: dict["ICONE2"]! , encoding: String.Encoding.utf8)!)OFF"
                                                }
                                                else{
                                                    seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni+1] = "\(String(data: dict["ICONE2"]! , encoding: String.Encoding.utf8)!)"
                                                }
                                            }
                                            else {
                                                seznamObrazkuZarizeni[indexKdeJeVpoliZarizeni+1] = "Druhe zarizeni"
                                            }
                                           }
                                        
                                           
                                       }
                                   }
                               }
                               
                           } else {
                               print("Did not find IPV4 address")
                           }
                           
                           nsb.stop()
                           services.removeAll()
                           labelText1.alpha=1
                           labelText2.alpha=1
                           imageLogo.alpha=1
                    probehloDiscovery=false
                        self.view.dismissProgress()
                          DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                              self.performSegue(withIdentifier: "showDeviceList", sender: Any?.self)
                          }
                       
                       }
                
                
                
            }
        }
        
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
    override func viewDidDisappear(_ animated: Bool) {
        
        UserDefaults.standard.setValue(seznamMACZarizeni, forKey: "seznamMACZarizeni")
        UserDefaults.standard.setValue(seznamNazvuZarizeni, forKey: "seznamNazvuZarizeni")
        UserDefaults.standard.setValue(seznamOnlineZarizeni, forKey: "seznamOnlineZarizeni")
        UserDefaults.standard.setValue(seznamIPZarizeni, forKey: "seznamIPZarizeni")
        UserDefaults.standard.setValue(seznamUmisteniZarizeni, forKey: "seznamUmisteniZarizeni")
        UserDefaults.standard.setValue(seznamObrazkuZarizeni, forKey: "seznamObrazkuZarizeni")
        timer.invalidate()
        if probehloDiscovery==true{
            //nsb.ex
            self.nsb.stop()
            self.services.removeAll()
        }
        probehloDiscovery=false
        super.viewDidDisappear(animated)
        
    }
}
