//
//  SelectAddDeviceController.swift
//  Emtron-SMART-HOME
//
//  Created by Ivo Dvorak on 03/06/2020.
//  Copyright © 2020 Ivo Dvorak. All rights reserved.
//

import Foundation
import UIKit

class ShareOverQRcode: UIViewController {
    
    @IBOutlet weak var QRCodeImage: UIImageView!
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.utf8)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel")
            guard let qrCodeImage = filter.outputImage
                            else {
                                return nil
                        }
            let scaleX=QRCodeImage.frame.size.width / qrCodeImage.extent.size.width
            //let scaleY=QRCodeImage.frame.size.height / (filter.outputImage?.extent.size.height)!
            
            let transform = CGAffineTransform(scaleX: scaleX, y: scaleX)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        QRCodeImage.layer.cornerRadius=20
        let dataQR="MAC:\(Character(UnicodeScalar(17)))\(seznamMACZarizeni[indexVybranehoZarizeni*2])\(Character(UnicodeScalar(18)))\(seznamNazvuZarizeni[indexVybranehoZarizeni*2])\(Character(UnicodeScalar(19)))\(seznamNazvuZarizeni[indexVybranehoZarizeni*2+1])\(Character(UnicodeScalar(20)))\(seznamUmisteniZarizeni[indexVybranehoZarizeni*2])\(Character(UnicodeScalar(21)))\(seznamUmisteniZarizeni[indexVybranehoZarizeni*2+1])\(Character(UnicodeScalar(22)))\(seznamObrazkuZarizeni[indexVybranehoZarizeni*2])\(Character(UnicodeScalar(23)))\(seznamObrazkuZarizeni[indexVybranehoZarizeni*2+1])\(Character(UnicodeScalar(24)))\(seznamProvoznichRezimu[indexVybranehoZarizeni*2])\(Character(UnicodeScalar(25)))\(seznamProvoznichRezimu[indexVybranehoZarizeni*2+1])\(Character(UnicodeScalar(26)))END"
        QRCodeImage.image = generateQRCode(from: dataQR)
        print("Index \(indexVybranehoZarizeni) data QR:\(dataQR)")
        //"MAC:!\(seznamMACZarizeni[indexVybranehoZarizeni])@NAME1:\(seznamNazvuZarizeni[indexVybranehoZarizeni])NAME2:\(seznamNazvuZarizeni[indexVybranehoZarizeni+1])LOCATION1:\(seznamUmisteniZarizeni[indexVybranehoZarizeni])LOCATION2:\(seznamUmisteniZarizeni[indexVybranehoZarizeni+1])IMAGE1:\(seznamObrazkuZarizeni[indexVybranehoZarizeni])IMAGE2:\(seznamObrazkuZarizeni[indexVybranehoZarizeni+1])REZIM1:\(seznamProvoznichRezimu[indexVybranehoZarizeni])REZIM2:\(seznamProvoznichRezimu[indexVybranehoZarizeni+1])END")
        /*
        //var seznamNazvuZarizeni = [String]()
        //var seznamMACZarizeni = [String]()
        /////var seznamOnlineZarizeni = [String]()
        /////var seznamIPZarizeni = [String]()
        //var seznamUmisteniZarizeni = [String]()
        //var seznamObrazkuZarizeni = [String]()
        ////var poradoveCisloRele = [String]()
        ////var seznamMerenychTeplot = [String]()
        //var seznamPozadovanychTeplot = [String]()
        //var seznamProvoznichRezimu = [String]()
        //var seznamVerziFirmwaru = [String]()
        var seznamZparovanychZarizeni = [String]()
        var seznamPripojenychTeplomeru = [String]()
        var seznamCasuVmodulech = [String]()
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
 */
    }
}
