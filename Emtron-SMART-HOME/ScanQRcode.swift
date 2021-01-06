//
//  ScanQRcode.swift
//  Emtron-SMART-HOME
//
//  Created by Ivo Dvorak on 05/10/2020.
//  Copyright © 2020 Ivo Dvorak. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AudioToolbox

class ScanQRcode: UIViewController {
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    var dataQRcodu = ""
    var dualniKamera = false
    
    
    
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        
        probehloDiscovery=false
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get the back-facing camera for capturing videos
        if AVCaptureDevice.default(.builtInDualCamera,
                                   for: .video, position: .back) != nil
        {
            print("Dual camera")
            dualniKamera=true
        }
        else if AVCaptureDevice.default(.builtInWideAngleCamera,
                                        for: .video, position: .back) != nil
        {
            print("Single camera")
            dualniKamera=false
        }
        else {
            print("Missing expected back camera device.")
        }
        var deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        
        
        if dualniKamera==true
        {
            deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        }
        else
        {
            deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        }
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            //            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        //outletBtnLongPress.imageView!.contentMode = .scaleAspectFit
        //outletBtnLongPress.contentVerticalAlignment = .fill
        //outletBtnLongPress.contentHorizontalAlignment = .fill
        
        
        // Start video capture.
        captureSession.startRunning()
        let background = UIImage(named: "QRcodeScan")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFit
        
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        imageView.alpha=0.985
        view.addSubview(imageView)
        self.view.bringSubviewToFront(imageView)
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
        
    }
}
extension ScanQRcode: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        //if metadataObjects.count == 0 {
        //    qrCodeFrameView?.frame = CGRect.zero
        //    messageLabel.textColor=UIColor.red;
        //    messageLabel.text = "No QR code is detected"
        //    return
        //}
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                captureSession.stopRunning()
                //videoPreviewLayer?.removeFromSuperlayer()
                //qrCodeFrameView?.frame=CGRect.zero
                
                //messageLabel.text = metadataObj.stringValue
                dataQRcodu = metadataObj.stringValue!
                print(dataQRcodu)
                
                if (dataQRcodu.contains("MAC:")&&(dataQRcodu.contains("END")))
                {
                    videoPreviewLayer?.removeFromSuperlayer()
                    qrCodeFrameView?.frame=CGRect.zero
                    //messageLabel.textColor=UIColor.green;
                            // create a sound ID, in this case its the tweet sound.
                            let systemSoundID: SystemSoundID = 1111
                            
                            // to play sound
                            AudioServicesPlaySystemSound (systemSoundID)
                            
                            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)//zavibruje
                           dataKeZpracovani=dataQRcodu
                     //"MAC:!\(seznamMACZarizeni[indexVybranehoZarizeni])@\(seznamNazvuZarizeni[indexVybranehoZarizeni])#\(seznamNazvuZarizeni[indexVybranehoZarizeni+1])$\(seznamUmisteniZarizeni[indexVybranehoZarizeni])%\(seznamUmisteniZarizeni[indexVybranehoZarizeni+1])^\(seznamObrazkuZarizeni[indexVybranehoZarizeni])&\(seznamObrazkuZarizeni[indexVybranehoZarizeni+1])*\(seznamProvoznichRezimu[indexVybranehoZarizeni])<\(seznamProvoznichRezimu[indexVybranehoZarizeni+1])>END")
                    aktualniMacAdressa=parsujData(prvniZnak: Character(UnicodeScalar(17)), druhyZnak: Character(UnicodeScalar(18)))
                    if seznamMACZarizeni.contains(aktualniMacAdressa)
                    {
                        print("zarizeni je jiz v seznamu")
                        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeviceListController")
                        viewController.modalPresentationStyle = .fullScreen
                        self.present(viewController, animated: true, completion: nil)
                    }
                    else {
                        
                        
                        if aktualniMacAdressa.contains("EMTRON-CZ-2-RELAYS-MODULE"){
                        //prida prvni rele
                            
                        seznamMACZarizeni.append(aktualniMacAdressa)
                        seznamNazvuZarizeni.append(parsujData(prvniZnak: Character(UnicodeScalar(18)), druhyZnak: Character(UnicodeScalar(19))))
                        seznamOnlineZarizeni.append("ONline")
                        seznamIPZarizeni.append("0.0.0.0")
                        seznamUmisteniZarizeni.append(parsujData(prvniZnak: Character(UnicodeScalar(20)), druhyZnak: Character(UnicodeScalar(21))))
                        seznamObrazkuZarizeni.append(parsujData(prvniZnak: Character(UnicodeScalar(22)), druhyZnak: Character(UnicodeScalar(23))))
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
                            seznamKladnaHystereze.append("0.1")
                            seznamZapornaHystereze.append("0.25")
                            seznamTimeru.append("0")
                            seznamMDNSvsAWS.append("AWS")
                        //prida druhe rele
                        seznamMACZarizeni.append(aktualniMacAdressa)
                        seznamNazvuZarizeni.append(parsujData(prvniZnak: Character(UnicodeScalar(19)), druhyZnak: Character(UnicodeScalar(20))))
                        seznamOnlineZarizeni.append("ONline")
                        seznamIPZarizeni.append("0.0.0.0")
                        seznamUmisteniZarizeni.append(parsujData(prvniZnak: Character(UnicodeScalar(21)), druhyZnak: Character(UnicodeScalar(22))))
                        seznamObrazkuZarizeni.append(parsujData(prvniZnak: Character(UnicodeScalar(23)), druhyZnak: Character(UnicodeScalar(24))))
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
                            seznamKoduHomekitu.append("")
                            seznamMinimalnichTeplot.append("0")
                            seznamMaximalnichTeplot.append("40")
                            seznamRSSI.append("")
                            seznamQRkodu.append("")
                            seznamZparovanychShomekitem.append("")
                            seznamSSID.append("")
                            seznamTopoimChladim.append("Topim")
                            seznamKladnaHystereze.append("0.1")
                            seznamZapornaHystereze.append("0.25")
                            seznamBarevModulu.append(UIColor.init(red: 90/255, green: 90/255, blue: 90/255, alpha: 1))//nastavi se seda barva
                            seznamTimeru.append("0")
                            seznamMDNSvsAWS.append("AWS")
                            seznamTopicu.removeAll()
                            
                            for indexPole in 0..<seznamMACZarizeni.count/2{
                                //napni to topicama k teryma se ma kominikovat
                                var MACadress = seznamMACZarizeni[indexPole*2].replacingOccurrences(of: "EMTRON-CZ-2-RELAYS-MODULE{", with: "")
                                MACadress = MACadress.replacingOccurrences(of: "}", with: "/")
                                seznamTopicu.append(MACadress)
                                
                            }
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
                    
                    
                    
                    
                    
                            
                            //navigationController?.pushViewController(qrCodeFrameView, animated: true)
                        }
                    
                }
                    let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeviceListController")
                    viewController.modalPresentationStyle = .fullScreen
                    self.present(viewController, animated: true, completion: nil)
                }
                else {
                    print("nasel QR ale neni nas")
                    let nadpis = "QR kod nebyl rozpoznan"
                    let messageBox = UIAlertController(title: nadpis, message: "Prosim naskenujte QR kod znovu", preferredStyle: .alert)
                    
                    let AkceOK = UIAlertAction(title: "OK", style: .default){//pokud se stikne tlacitko OK
                        (ACTION) in
                        
                        self.captureSession.startRunning()//znovu zacne skenova qr kod
                        self.qrCodeFrameView?.frame=CGRect.zero
                    }
                    
                    let AkceZpet = UIAlertAction(title: "BACK", style: .default){//kliknuti na tlacitko BACK
                        (ACTION) in
                        
                        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeviceListController")
                        viewController.modalPresentationStyle = .fullScreen
                        self.present(viewController, animated: true, completion: nil)
                        
                    }
                    
                    messageBox.addAction(AkceZpet)
                    messageBox.addAction(AkceOK)
                    
                    self.present(messageBox,animated: true)
                
                }
                
            }
        }
    }
    
}
