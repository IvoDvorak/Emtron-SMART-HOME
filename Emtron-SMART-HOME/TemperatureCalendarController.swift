//
//  TemperatureCalendarController.swift
//  Emtron-SMART-HOME
//
//  Created by Ivo Dvorak on 11/11/2019.
//  Copyright © 2019 Ivo Dvorak. All rights reserved.
//
import UIKit
import Foundation
import AudioToolbox
import Socket
import iProgressHUD


var PondeliSpinaciCasyAteploty = [[String]]()//prvne je cas a potom teplota
var UterySpinaciCasyAteploty = [[String]]()
var StredaSpinaciCasyAteploty = [[String]]()
var CtvrtekSpinaciCasyAteploty = [[String]]()
var PatekSpinaciCasyAteploty = [[String]]()
var SobotaSpinaciCasyAteploty = [[String]]()
var NedeleSpinaciCasyAteploty = [[String]]()
var poleZobrazenychteplotnaTopeni = [String]()
let trivialDayStringsORDINAL = ["", "Nedele","Pondeli","Utery","Streda","Ctvrtek","Patek","Sobota"]
var kalendarTyden=[PondeliSpinaciCasyAteploty,UterySpinaciCasyAteploty,StredaSpinaciCasyAteploty,CtvrtekSpinaciCasyAteploty,PatekSpinaciCasyAteploty,SobotaSpinaciCasyAteploty,NedeleSpinaciCasyAteploty]

var poleKalendaru=[[[[String]]]]()
//var pole: [[String]] = ["",""]



var PondeliSpinaciCasy = [[String]]()//prvne je cas
var UterySpinaciCasy = [[String]]()
var StredaSpinaciCasy = [[String]]()
var CtvrtekSpinaciCasy = [[String]]()
var PatekSpinaciCasy = [[String]]()
var SobotaSpinaciCasy = [[String]]()
var NedeleSpinaciCasy = [[String]]()
var provedlaSeZmena=false
var AktivniIndikator=false;

var DenVtydnu = ""//jen test
var DenVtydnuProOdeslani = ""
//var indexVyberuVseznamuTeplot

class TemperatureCalnedarController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    
    
    @IBAction func btnPingClick(_ sender: Any) {
        sendOverTCP(message: "PING\n")
    }
    
    @IBAction func btnOKclick(_ sender: Any) {
        DenVtydnuProOdeslani=DenVtydnu
        odesliNastaveniKalendareDoModulu()
        UserDefaults.standard.setValue(PondeliSpinaciCasyAteploty, forKey: "PondeliSpinaciCasyAteploty")
        UserDefaults.standard.setValue(UterySpinaciCasyAteploty, forKey: "UterySpinaciCasyAteploty")
        UserDefaults.standard.setValue(StredaSpinaciCasyAteploty, forKey: "StredaSpinaciCasyAteploty")
        UserDefaults.standard.setValue(CtvrtekSpinaciCasyAteploty, forKey: "CtvrtekSpinaciCasyAteploty")
        UserDefaults.standard.setValue(PatekSpinaciCasyAteploty, forKey: "PatekSpinaciCasyAteploty")
        UserDefaults.standard.setValue(SobotaSpinaciCasyAteploty, forKey: "SobotaSpinaciCasyAteploty")
        UserDefaults.standard.setValue(NedeleSpinaciCasyAteploty, forKey: "NedeleSpinaciCasyAteploty")
        //kalendarTyden=[PondeliSpinaciCasyAteploty,UterySpinaciCasyAteploty,StredaSpinaciCasyAteploty,CtvrtekSpinaciCasyAteploty,PatekSpinaciCasyAteploty,SobotaSpinaciCasyAteploty,NedeleSpinaciCasyAteploty]//naplnim tyden aktualnimi casy
        
        //poleKalendaru[indexVybranehoZarizeni]=kalendarTyden//ulozi aktualni kalendar
        //UserDefaults.standard.setValue(kalendarTyden, forKey: "kalendarTyden")
        //UserDefaults.standard.setValue(poleKalendaru, forKey: "poleKalendaru")
        
        //print("kalendarTyden\(kalendarTyden)")
        //print("PondeliSpinaciCasyAteploty\(PondeliSpinaciCasyAteploty)")
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeviceListController")
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var btnPondeliOutlet: UIButton!
    
    @IBOutlet weak var btnUteryOutlet: UIButton!
    
    @IBOutlet weak var btnStredaOutlet: UIButton!
    
    @IBOutlet weak var btnCtvrtekOutlet: UIButton!
    
    @IBOutlet weak var btnPatekOutlet: UIButton!
    
    @IBOutlet weak var btnSobotaOutlet: UIButton!
    
    @IBOutlet weak var btnNedeleOutlet: UIButton!
    
   /* override func viewWillAppear(_ animated: Bool) {
        //setGradientBackground()
        super.viewWillAppear(animated)
        ActivityIndicator(" Loading...")
    }
    */
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCellTemperatureCalendar
        
        //cell.contentView.layer.cornerRadius = 10
        //cell.backgroundColor = UIColor(named: "red")
        cell.layer.cornerRadius = 20
        if odkudBylSpustenKalendar=="Topeni"{
            if DenVtydnu=="Pondeli"{
                if PondeliSpinaciCasyAteploty[indexPath.item][0] != "" && PondeliSpinaciCasyAteploty[indexPath.item][1] != ""{
                    cell.labelPlusko.text=""
                    //PondeliSpinaciCasyAteploty[0]
                    cell.labelCas.text = PondeliSpinaciCasyAteploty[indexPath.item][0]
                    cell.labelPozadovanaTeplota.text = "\(PondeliSpinaciCasyAteploty[indexPath.item][1])°C"
                }
                else {
                    cell.labelPlusko.text="+"
                    cell.labelPozadovanaTeplota.text=""
                    cell.labelCas.text=""
                }
                
            }
                
            else if DenVtydnu=="Utery"{
                if UterySpinaciCasyAteploty[indexPath.item][0] != "" && UterySpinaciCasyAteploty[indexPath.item][1] != ""{
                    cell.labelPlusko.text=""
                    //PondeliSpinaciCasyAteploty[0]
                    cell.labelCas.text = UterySpinaciCasyAteploty[indexPath.item][0]
                    cell.labelPozadovanaTeplota.text = "\(UterySpinaciCasyAteploty[indexPath.item][1])°C"
                }
                else {
                    cell.labelPlusko.text="+"
                    cell.labelPozadovanaTeplota.text=""
                    cell.labelCas.text=""
                }
                
            }
                
            else if DenVtydnu=="Streda"{
                if StredaSpinaciCasyAteploty[indexPath.item][0] != "" && StredaSpinaciCasyAteploty[indexPath.item][1] != ""{
                    cell.labelPlusko.text=""
                    //PondeliSpinaciCasyAteploty[0]
                    cell.labelCas.text = StredaSpinaciCasyAteploty[indexPath.item][0]
                    cell.labelPozadovanaTeplota.text = "\(StredaSpinaciCasyAteploty[indexPath.item][1])°C"
                }
                else {
                    cell.labelPlusko.text="+"
                    cell.labelPozadovanaTeplota.text=""
                    cell.labelCas.text=""
                }
                
            }
                
            else if DenVtydnu=="Ctvrtek"{
                if CtvrtekSpinaciCasyAteploty[indexPath.item][0] != "" && CtvrtekSpinaciCasyAteploty[indexPath.item][1] != ""{
                    cell.labelPlusko.text=""
                    //PondeliSpinaciCasyAteploty[0]
                    cell.labelCas.text = CtvrtekSpinaciCasyAteploty[indexPath.item][0]
                    cell.labelPozadovanaTeplota.text = "\(CtvrtekSpinaciCasyAteploty[indexPath.item][1])°C"
                }
                else {
                    cell.labelPlusko.text="+"
                    cell.labelPozadovanaTeplota.text=""
                    cell.labelCas.text=""
                }
                
            }
                
            else if DenVtydnu=="Patek"{
                if PatekSpinaciCasyAteploty[indexPath.item][0] != "" && PatekSpinaciCasyAteploty[indexPath.item][1] != ""{
                    cell.labelPlusko.text=""
                    //PondeliSpinaciCasyAteploty[0]
                    cell.labelCas.text = PatekSpinaciCasyAteploty[indexPath.item][0]
                    cell.labelPozadovanaTeplota.text = "\(PatekSpinaciCasyAteploty[indexPath.item][1])°C"
                }
                else {
                    cell.labelPlusko.text="+"
                    cell.labelPozadovanaTeplota.text=""
                    cell.labelCas.text=""
                }
                
            }
                
            else if DenVtydnu=="Sobota"{
                if SobotaSpinaciCasyAteploty[indexPath.item][0] != "" && SobotaSpinaciCasyAteploty[indexPath.item][1] != ""{
                    cell.labelPlusko.text=""
                    //PondeliSpinaciCasyAteploty[0]
                    cell.labelCas.text = SobotaSpinaciCasyAteploty[indexPath.item][0]
                    cell.labelPozadovanaTeplota.text = "\(SobotaSpinaciCasyAteploty[indexPath.item][1])°C"
                }
                else {
                    cell.labelPlusko.text="+"
                    cell.labelPozadovanaTeplota.text=""
                    cell.labelCas.text=""
                }
                
            }
                
            else if DenVtydnu=="Nedele"{
                if NedeleSpinaciCasyAteploty [indexPath.item][0] != "" && NedeleSpinaciCasyAteploty[indexPath.item][1] != ""{
                    cell.labelPlusko.text=""
                    //PondeliSpinaciCasyAteploty[0]
                    cell.labelCas.text = NedeleSpinaciCasyAteploty[indexPath.item][0]
                    cell.labelPozadovanaTeplota.text = "\(NedeleSpinaciCasyAteploty[indexPath.item][1])°C"
                }
                else {
                    cell.labelPlusko.text="+"
                    cell.labelPozadovanaTeplota.text=""
                    cell.labelCas.text=""
                }
                
            }
            
            
        }
        else if odkudBylSpustenKalendar=="Svetlo"{
            if DenVtydnu=="Pondeli"{
                if PondeliSpinaciCasy[indexPath.item][0] != "" && PondeliSpinaciCasy[indexPath.item][1] != ""{
                    cell.labelPlusko.text=""
                    //PondeliSpinaciCasyAteploty[0]
                    cell.labelCas.text = PondeliSpinaciCasy[indexPath.item][0]
                    cell.labelPozadovanaTeplota.text = "\(PondeliSpinaciCasy[indexPath.item][1])"
                }
                else {
                    cell.labelPlusko.text="+"
                    cell.labelPozadovanaTeplota.text=""
                    cell.labelCas.text=""
                }
            }
                
            else if DenVtydnu=="Utery"{
                if UterySpinaciCasy[indexPath.item][0] != "" && UterySpinaciCasy[indexPath.item][1] != ""{
                    cell.labelPlusko.text=""
                    //PondeliSpinaciCasyAteploty[0]
                    cell.labelCas.text = UterySpinaciCasy[indexPath.item][0]
                    cell.labelPozadovanaTeplota.text = "\(UterySpinaciCasy[indexPath.item][1])"
                }
                else {
                    cell.labelPlusko.text="+"
                    cell.labelPozadovanaTeplota.text=""
                    cell.labelCas.text=""
                }
            }
                
            else if DenVtydnu=="Streda"{
                if StredaSpinaciCasy[indexPath.item][0] != "" && StredaSpinaciCasy[indexPath.item][1] != ""{
                    cell.labelPlusko.text=""
                    //PondeliSpinaciCasyAteploty[0]
                    cell.labelCas.text = StredaSpinaciCasy[indexPath.item][0]
                    cell.labelPozadovanaTeplota.text = "\(StredaSpinaciCasy[indexPath.item][1])"
                }
                else {
                    cell.labelPlusko.text="+"
                    cell.labelPozadovanaTeplota.text=""
                    cell.labelCas.text=""
                }
            }
                
            else if DenVtydnu=="Ctvrtek"{
                if CtvrtekSpinaciCasy[indexPath.item][0] != "" && CtvrtekSpinaciCasy[indexPath.item][1] != ""{
                    cell.labelPlusko.text=""
                    //PondeliSpinaciCasyAteploty[0]
                    cell.labelCas.text = CtvrtekSpinaciCasy[indexPath.item][0]
                    cell.labelPozadovanaTeplota.text = "\(CtvrtekSpinaciCasy[indexPath.item][1])"
                }
                else {
                    cell.labelPlusko.text="+"
                    cell.labelPozadovanaTeplota.text=""
                    cell.labelCas.text=""
                }
            }
                
            else if DenVtydnu=="Patek"{
                if PatekSpinaciCasy[indexPath.item][0] != "" && PatekSpinaciCasy[indexPath.item][1] != ""{
                    cell.labelPlusko.text=""
                    //PondeliSpinaciCasyAteploty[0]
                    cell.labelCas.text = PatekSpinaciCasy[indexPath.item][0]
                    cell.labelPozadovanaTeplota.text = "\(PatekSpinaciCasy[indexPath.item][1])"
                }
                else {
                    cell.labelPlusko.text="+"
                    cell.labelPozadovanaTeplota.text=""
                    cell.labelCas.text=""
                }
            }
                
            else if DenVtydnu=="Sobota"{
                if SobotaSpinaciCasy[indexPath.item][0] != "" && SobotaSpinaciCasy[indexPath.item][1] != ""{
                    cell.labelPlusko.text=""
                    //PondeliSpinaciCasyAteploty[0]
                    cell.labelCas.text = SobotaSpinaciCasy[indexPath.item][0]
                    cell.labelPozadovanaTeplota.text = "\(SobotaSpinaciCasy[indexPath.item][1])"
                }
                else {
                    cell.labelPlusko.text="+"
                    cell.labelPozadovanaTeplota.text=""
                    cell.labelCas.text=""
                }
            }
                
            else if DenVtydnu=="Nedele"{
                if NedeleSpinaciCasy[indexPath.item][0] != "" && NedeleSpinaciCasy[indexPath.item][1] != ""{
                    cell.labelPlusko.text=""
                    //PondeliSpinaciCasyAteploty[0]
                    cell.labelCas.text = NedeleSpinaciCasy[indexPath.item][0]
                    cell.labelPozadovanaTeplota.text = "\(NedeleSpinaciCasy[indexPath.item][1])"
                }
                else {
                    cell.labelPlusko.text="+"
                    cell.labelPozadovanaTeplota.text=""
                    cell.labelCas.text=""
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if odkudBylSpustenKalendar=="Topeni"{
            if DenVtydnu=="Pondeli"{
                return PondeliSpinaciCasyAteploty.count
            }
            else if DenVtydnu=="Utery"{
                return UterySpinaciCasyAteploty.count
            }
            else if DenVtydnu=="Streda"{
                return StredaSpinaciCasyAteploty.count
            }
            else if DenVtydnu=="Ctvrtek"{
                return CtvrtekSpinaciCasyAteploty.count
            }
            else if DenVtydnu=="Patek"{
                return PatekSpinaciCasyAteploty.count
            }
            else if DenVtydnu=="Sobota"{
                return SobotaSpinaciCasyAteploty.count
            }
            else if DenVtydnu=="Nedele"{
                return NedeleSpinaciCasyAteploty.count
            }
            else {
                return 1
            }
        }
        else if odkudBylSpustenKalendar=="Svetlo"{
            if DenVtydnu=="Pondeli"{
                return PondeliSpinaciCasy.count
            }
            else if DenVtydnu=="Utery"{
                return UterySpinaciCasy.count
            }
            else if DenVtydnu=="Streda"{
                return StredaSpinaciCasy.count
            }
            else if DenVtydnu=="Ctvrtek"{
                return CtvrtekSpinaciCasy.count
            }
            else if DenVtydnu=="Patek"{
                return PatekSpinaciCasy.count
            }
            else if DenVtydnu=="Sobota"{
                return SobotaSpinaciCasy.count
            }
            else if DenVtydnu=="Nedele"{
                return NedeleSpinaciCasy.count
            }
            else {
                return 1
            }
        }
        else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //let width = (self.view.frame.size.width - 5 * 2) / 2 //some width
        //let height = width * 1.5 //ratio
        //return CGSize(width: width, height: height)
        let width  = (collectionView.frame.width-40)
        let height  = (collectionView.frame.height-(6*15))/6//+15)/10
        return CGSize(width: width, height: height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
        
        guard let cell = collectionViewOutlet.cellForItem(at: indexPath) as? CollectionViewCellTemperatureCalendar
            else{return}
        
        if cell.labelPlusko.text=="+"{//kliknul na plusko
            print("kliknul na plusko")
            provedlaSeZmena=true
            //sem dodelat kontrolu kolik uz ma zadanych spinacich casu
            self.performSegue(withIdentifier: "ZadavaniCasuAteploty", sender: Any?.self)
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("didappear")
        //ProgressHUD.show("Loading...")
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(funkcevykonanakazdouvterinu), userInfo: nil, repeats: true)
        timer.tolerance=0.4
        
        
        //sleep(4)
        
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        view.addGestureRecognizer(recognizer)
        //sem dodelat vycteni kalendare z modulu
        //collectionViewOutlet.reloadData()
        
    }
 
    //--------------------------------------------------------
    // MARK: viewDidLoad --------------------------------
    //--------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        let date = Date()
        let weekday = Calendar.current.component(.weekday, from: date)
        let iprogress: iProgressHUD = iProgressHUD()
        iprogress.modalColor = .black
        iprogress.boxColor = .clear
        iprogress.isBlurModal=true
        iprogress.boxSize=25
        iprogress.isTouchDismiss = false
        iprogress.indicatorStyle = .circleStrokeSpin
        iprogress.YOffset=(view.bounds.size.height / 2)
        iprogress.attachProgress(toView: self.view)
        view.updateCaption(text: "Loading...")
        view.showProgress()
        if vracimSeZnatsaveniTeploty==false{
            PondeliSpinaciCasy.removeAll()
            PondeliSpinaciCasyAteploty.removeAll()
            UterySpinaciCasyAteploty.removeAll()
            UterySpinaciCasy.removeAll()
            StredaSpinaciCasyAteploty.removeAll()
            StredaSpinaciCasy.removeAll()
            CtvrtekSpinaciCasyAteploty.removeAll()
            CtvrtekSpinaciCasy.removeAll()
            PatekSpinaciCasyAteploty.removeAll()
            PatekSpinaciCasy.removeAll()
            SobotaSpinaciCasyAteploty.removeAll()
            SobotaSpinaciCasy.removeAll()
            NedeleSpinaciCasyAteploty.removeAll()
            NedeleSpinaciCasy.removeAll()
            if odkudBylSpustenKalendar=="Topeni"{
                sendOverTCP(message: "Kalendar\(poradoveCisloRele[indexVybranehoZarizeni])\n")
                
            }
            
            if odkudBylSpustenKalendar=="Svetlo"{
                sendOverTCP(message: "Casovac\(poradoveCisloRele[indexVybranehoZarizeni])\n")
                
            }
            DenVtydnu=trivialDayStringsORDINAL[weekday]
            print("Je \(DenVtydnu)")
            //tady cekat az dostanu data
            
        }
        vracimSeZnatsaveniTeploty=false
        hostAdress=seznamIPZarizeni[indexVybranehoZarizeni]
        
        NotificationCenter.default.addObserver(self, selector: #selector(zpracujTCPdata), name: NSNotification.Name("zpracujTCPdata"), object: nil)
        //let dow = Calendar.current.weekdaySymbols
        
        //print(trivialDayStringsORDINAL[
        //[Calendar.current.component(.weekday, from: Date())]
        print("Spoustim kalendar")
        
    }//konec viewDidLoad
    
    @objc func funkcevykonanakazdouvterinu()
    {
        print("funkcevykonanakazdouvterinu")
        if uzDoslaData==true{
            print("dosla platna data v kalendari")
            
            
            
            //PondeliSpinaciCasyAteploty.append(["10:00","25.0"])
            if PondeliSpinaciCasyAteploty.count==0 {
                PondeliSpinaciCasyAteploty.append(["",""])
                
            }
            if UterySpinaciCasyAteploty.count==0 {
                UterySpinaciCasyAteploty.append(["",""])
            }
            if StredaSpinaciCasyAteploty.count==0 {
                StredaSpinaciCasyAteploty.append(["",""])
            }
            if CtvrtekSpinaciCasyAteploty.count==0 {
                CtvrtekSpinaciCasyAteploty.append(["",""])
            }
            if PatekSpinaciCasyAteploty.count==0 {
                PatekSpinaciCasyAteploty.append(["",""])
            }
            if SobotaSpinaciCasyAteploty.count==0 {
                SobotaSpinaciCasyAteploty.append(["",""])
            }
            if NedeleSpinaciCasyAteploty.count==0 {
                NedeleSpinaciCasyAteploty.append(["",""])
                
            }
            
            if PondeliSpinaciCasy.count==0 {
                PondeliSpinaciCasy.append(["",""])
                
            }
            if UterySpinaciCasy.count==0 {
                UterySpinaciCasy.append(["",""])
            }
            if StredaSpinaciCasy.count==0 {
                StredaSpinaciCasy.append(["",""])
            }
            if CtvrtekSpinaciCasy.count==0 {
                CtvrtekSpinaciCasy.append(["",""])
            }
            if PatekSpinaciCasy.count==0 {
                PatekSpinaciCasy.append(["",""])
            }
            if SobotaSpinaciCasy.count==0 {
                SobotaSpinaciCasy.append(["",""])
            }
            if NedeleSpinaciCasy.count==0 {
                NedeleSpinaciCasy.append(["",""])
            }
            
            //DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
            //    print("done")
            //})
            srovnejPole()
            //PondeliSpinaciCasyAteploty.sort(by: {$0[0] < $1[0] })
            print(indexVybranehoZarizeni)
            print(seznamIPZarizeni[indexVybranehoZarizeni])
            
            btnPondeliOutlet.layer.cornerRadius=20
            btnUteryOutlet.layer.cornerRadius=20
            btnStredaOutlet.layer.cornerRadius=20
            btnCtvrtekOutlet.layer.cornerRadius=20
            btnPatekOutlet.layer.cornerRadius=20
            btnSobotaOutlet.layer.cornerRadius=20
            btnNedeleOutlet.layer.cornerRadius=20
            //btnPondeliOutlet.backgroundColor=UIColor.init(red: 255/255, green: 168/255, blue: 0, alpha: 0.7)
            if DenVtydnu=="Pondeli"{
                btnPoClick("")
            }
            if DenVtydnu=="Utery"{
                btnUtClick("")
            }
            if DenVtydnu=="Streda"{
                btnStClick("")
            }
            if DenVtydnu=="Ctvrtek"{
                btnCtClick("")
            }
            if DenVtydnu=="Patek"{
                btnPaClick("")
            }
            if DenVtydnu=="Sobota"{
                btnSoClick("")
            }
            if DenVtydnu=="Nedele"{
                btnNeClick("")
            }
            collectionViewOutlet.reloadData()
            //ProgressHUD.dismiss()
            
            view.dismissProgress()
            timer.invalidate()
        }
    }
    
    func srovnejPole(){
        PondeliSpinaciCasyAteploty.sort(by: {$0[0] < $1[0] })//seradi pole
        PondeliSpinaciCasyAteploty.remove(at: 0)//smaze plusko
        PondeliSpinaciCasyAteploty.append(["",""])//prida plusko na konec
        UterySpinaciCasyAteploty.sort(by: {$0[0] < $1[0] })
        UterySpinaciCasyAteploty.remove(at: 0)
        UterySpinaciCasyAteploty.append(["",""])
        StredaSpinaciCasyAteploty.sort(by: {$0[0] < $1[0] })
        StredaSpinaciCasyAteploty.remove(at: 0)
        StredaSpinaciCasyAteploty.append(["",""])
        CtvrtekSpinaciCasyAteploty.sort(by: {$0[0] < $1[0] })
        CtvrtekSpinaciCasyAteploty.remove(at: 0)
        CtvrtekSpinaciCasyAteploty.append(["",""])
        PatekSpinaciCasyAteploty.sort(by: {$0[0] < $1[0] })
        PatekSpinaciCasyAteploty.remove(at: 0)
        PatekSpinaciCasyAteploty.append(["",""])
        SobotaSpinaciCasyAteploty.sort(by: {$0[0] < $1[0] })
        SobotaSpinaciCasyAteploty.remove(at: 0)
        SobotaSpinaciCasyAteploty.append(["",""])
        NedeleSpinaciCasyAteploty.sort(by: {$0[0] < $1[0] })
        NedeleSpinaciCasyAteploty.remove(at: 0)
        NedeleSpinaciCasyAteploty.append(["",""])
        
        PondeliSpinaciCasy.sort(by: {$0[0] < $1[0] })//seradi pole
        PondeliSpinaciCasy.remove(at: 0)//smaze plusko
        PondeliSpinaciCasy.append(["",""])//prida plusko na konec
        UterySpinaciCasy.sort(by: {$0[0] < $1[0] })
        UterySpinaciCasy.remove(at: 0)
        UterySpinaciCasy.append(["",""])
        StredaSpinaciCasy.sort(by: {$0[0] < $1[0] })
        StredaSpinaciCasy.remove(at: 0)
        StredaSpinaciCasy.append(["",""])
        CtvrtekSpinaciCasy.sort(by: {$0[0] < $1[0] })
        CtvrtekSpinaciCasy.remove(at: 0)
        CtvrtekSpinaciCasy.append(["",""])
        PatekSpinaciCasy.sort(by: {$0[0] < $1[0] })
        PatekSpinaciCasy.remove(at: 0)
        PatekSpinaciCasy.append(["",""])
        SobotaSpinaciCasy.sort(by: {$0[0] < $1[0] })
        SobotaSpinaciCasy.remove(at: 0)
        SobotaSpinaciCasy.append(["",""])
        NedeleSpinaciCasy.sort(by: {$0[0] < $1[0] })
        NedeleSpinaciCasy.remove(at: 0)
        NedeleSpinaciCasy.append(["",""])
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
            
            
            let point = gestureRecognizer.location(in: collectionViewOutlet)
            
            if let indexPath = collectionViewOutlet.indexPathForItem(at: point),
                let cell = collectionViewOutlet.cellForItem(at: indexPath) {
                print("Long press:\(indexPath.row)")
                print("collectionViewOutlet.numberOfItems(inSection: 0):\(collectionViewOutlet.numberOfItems(inSection: 0))")
                
                if  indexPath.row<collectionViewOutlet.numberOfItems(inSection: 0)-1{//kliknul na neco jineho nez plusko
                    let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
                    vybruj()
                    let message  = "Zvolte jakou operaci chcete provést"
                    var messageMutableString = NSMutableAttributedString()
                    messageMutableString = NSMutableAttributedString(string: message as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Aller", size: 18.0)!])
                    messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 60/255, green: 60/255, blue: 60/255, alpha: 1), range:NSRange(location:0,length:message.count))
                    alertController.setValue(messageMutableString, forKey: "attributedMessage")
                    
                    
                    let backAction = UIAlertAction(title: "BACK", style: .default) { (action) in
                        if DEBUGMSG{
                            print("Alert Click BACK")
                            self.vybruj()
                        }
                        
                    }
                    
                    let editAction = UIAlertAction(title: "EDIT", style: .default) { (action) in
                        if DEBUGMSG{
                            print("Alert Click EDIT")
                        }
                        //AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                        //self.performSegue(withIdentifier: "showNavodOne", sender: Any?.self)
                    }
                    let deleteAction = UIAlertAction(title: "DELETE", style: .default) { (action) in
                        self.vybruj()
                        print("Alert Click DELETE")
                        if odkudBylSpustenKalendar=="Topeni"{
                            if DenVtydnu=="Pondeli"{
                                if PondeliSpinaciCasyAteploty.count>1{
                                    PondeliSpinaciCasyAteploty.remove(at: indexPath.item)
                                    self.odesliNastaveniKalendareDoModulu()
                                    print("smazal zaznam z pondeli")
                                    self.collectionViewOutlet.reloadData()
                                }
                            }
                            if DenVtydnu=="Utery"{
                                if UterySpinaciCasyAteploty.count>1{
                                    UterySpinaciCasyAteploty.remove(at: indexPath.item)
                                    self.odesliNastaveniKalendareDoModulu()
                                    print("smazal zaznam z utery")
                                    self.collectionViewOutlet.reloadData()
                                }
                            }
                            if DenVtydnu=="Streda"{
                                if StredaSpinaciCasyAteploty.count>1{
                                    StredaSpinaciCasyAteploty.remove(at: indexPath.item)
                                    self.odesliNastaveniKalendareDoModulu()
                                    print("smazal zaznam z streda")
                                    self.collectionViewOutlet.reloadData()
                                }
                            }
                            if DenVtydnu=="Ctvrtek"{
                                if CtvrtekSpinaciCasyAteploty.count>1{
                                    CtvrtekSpinaciCasyAteploty.remove(at: indexPath.item)
                                    self.odesliNastaveniKalendareDoModulu()
                                    print("smazal zaznam z ctvrtek")
                                    self.collectionViewOutlet.reloadData()
                                }
                            }
                            if DenVtydnu=="Patek"{
                                if PatekSpinaciCasyAteploty.count>1{
                                    PatekSpinaciCasyAteploty.remove(at: indexPath.item)
                                    self.odesliNastaveniKalendareDoModulu()
                                    print("smazal zaznam z patek")
                                    self.collectionViewOutlet.reloadData()
                                }
                            }
                            if DenVtydnu=="Sobota"{
                                if SobotaSpinaciCasyAteploty.count>1{
                                    SobotaSpinaciCasyAteploty.remove(at: indexPath.item)
                                    self.odesliNastaveniKalendareDoModulu()
                                    print("smazal zaznam z sobota")
                                    self.collectionViewOutlet.reloadData()
                                }
                            }
                            if DenVtydnu=="Nedele"{
                                if NedeleSpinaciCasyAteploty.count>1{
                                    NedeleSpinaciCasyAteploty.remove(at: indexPath.item)
                                    self.odesliNastaveniKalendareDoModulu()
                                    print("smazal zaznam z nedele")
                                    self.collectionViewOutlet.reloadData()
                                }
                            }
                        }//konec if topeni
                        
                        if odkudBylSpustenKalendar=="Svetlo"{
                            if DenVtydnu=="Pondeli"{
                                if PondeliSpinaciCasy.count>1{
                                    PondeliSpinaciCasy.remove(at: indexPath.item)
                                    self.odesliNastaveniKalendareDoModulu()
                                    print("smazal zaznam z pondeli")
                                    self.collectionViewOutlet.reloadData()
                                }
                            }
                            if DenVtydnu=="Utery"{
                                if UterySpinaciCasy.count>1{
                                    UterySpinaciCasy.remove(at: indexPath.item)
                                    self.odesliNastaveniKalendareDoModulu()
                                    print("smazal zaznam z utery")
                                    self.collectionViewOutlet.reloadData()
                                }
                            }
                            if DenVtydnu=="Streda"{
                                if StredaSpinaciCasy.count>1{
                                    StredaSpinaciCasy.remove(at: indexPath.item)
                                    self.odesliNastaveniKalendareDoModulu()
                                    print("smazal zaznam z streda")
                                    self.collectionViewOutlet.reloadData()
                                }
                            }
                            if DenVtydnu=="Ctvrtek"{
                                if CtvrtekSpinaciCasy.count>1{
                                    CtvrtekSpinaciCasy.remove(at: indexPath.item)
                                    self.odesliNastaveniKalendareDoModulu()
                                    print("smazal zaznam z ctvrtek")
                                    self.collectionViewOutlet.reloadData()
                                }
                            }
                            if DenVtydnu=="Patek"{
                                if PatekSpinaciCasy.count>1{
                                    PatekSpinaciCasy.remove(at: indexPath.item)
                                    self.odesliNastaveniKalendareDoModulu()
                                    print("smazal zaznam z patek")
                                    self.collectionViewOutlet.reloadData()
                                }
                            }
                            if DenVtydnu=="Sobota"{
                                if SobotaSpinaciCasy.count>1{
                                    SobotaSpinaciCasy.remove(at: indexPath.item)
                                    self.odesliNastaveniKalendareDoModulu()
                                    print("smazal zaznam z sobota")
                                    self.collectionViewOutlet.reloadData()
                                }
                            }
                            if DenVtydnu=="Nedele"{
                                if NedeleSpinaciCasy.count>1{
                                    NedeleSpinaciCasy.remove(at: indexPath.item)
                                    self.odesliNastaveniKalendareDoModulu()
                                    print("smazal zaznam z nedele")
                                    self.collectionViewOutlet.reloadData()
                                }
                            }
                        }//konec if topeni
                        
                        //AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                        //self.performSegue(withIdentifier: "showNavodOne", sender: Any?.self)
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
    
    
    func vybruj ()
    {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    
    func namalujAlert(){
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        vybruj()
        let message  = "Byla provedena zmena v kalendari, chcete zmenu ulozit nebo zahodit"
        var messageMutableString = NSMutableAttributedString()
        messageMutableString = NSMutableAttributedString(string: message as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Aller", size: 18.0)!])
        messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 60/255, green: 60/255, blue: 60/0, alpha: 1), range:NSRange(location:0,length:message.count))
        alertController.setValue(messageMutableString, forKey: "attributedMessage")
        
        
        let backAction = UIAlertAction(title: "Ulozit", style: .default) { (action) in
            if DEBUGMSG{
                print("Alert Click BACK")
                self.vybruj()
            }
            
        }
        
        let editAction = UIAlertAction(title: "EDIT", style: .default) { (action) in
            if DEBUGMSG{
                print("Alert Click EDIT")
            }
            //AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            //self.performSegue(withIdentifier: "showNavodOne", sender: Any?.self)
        }
        let deleteAction = UIAlertAction(title: "Zahodit", style: .default) { (action) in
            
        }
        
        alertController.addAction(backAction)
        //alertController.addAction(editAction)
        alertController.addAction(deleteAction)
        
        alertController.view.tintColor = UIColor.init(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        //alertController.view.backgroundColor = UIColor.black
        alertController.view.layer.cornerRadius = 40
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func btnPoClick(_ sender: Any) {
        vybruj()
        DenVtydnu="Pondeli"
        print(DenVtydnu)
        collectionViewOutlet.reloadData()
        //odesliNastaveniKalendareDoModulu()
        //DenVtydnuProOdeslani=DenVtydnu
        btnPondeliOutlet.backgroundColor=UIColor.init(red: 255/255, green: 191/255, blue: 58/255, alpha: 1)
        btnUteryOutlet.backgroundColor=UIColor.clear
        btnStredaOutlet.backgroundColor=UIColor.clear
        btnCtvrtekOutlet.backgroundColor=UIColor.clear
        btnPatekOutlet.backgroundColor=UIColor.clear
        btnSobotaOutlet.backgroundColor=UIColor.clear
        btnNedeleOutlet.backgroundColor=UIColor.clear
        
        btnPondeliOutlet.setTitleColor(UIColor.black, for: .normal)
        btnNedeleOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnUteryOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnStredaOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnCtvrtekOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnPatekOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnSobotaOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
    }
    @IBAction func btnUtClick(_ sender: Any) {
        vybruj()
        DenVtydnu="Utery"
        print(DenVtydnu)
        collectionViewOutlet.reloadData()
        //odesliNastaveniKalendareDoModulu()
        //DenVtydnuProOdeslani=DenVtydnu
        btnPondeliOutlet.backgroundColor=UIColor.clear
        btnUteryOutlet.backgroundColor=UIColor.init(red: 255/255, green: 191/255, blue: 58/255, alpha: 1)
        btnStredaOutlet.backgroundColor=UIColor.clear
        btnCtvrtekOutlet.backgroundColor=UIColor.clear
        btnPatekOutlet.backgroundColor=UIColor.clear
        btnSobotaOutlet.backgroundColor=UIColor.clear
        btnNedeleOutlet.backgroundColor=UIColor.clear
        
        btnUteryOutlet.setTitleColor(UIColor.black, for: .normal)
        btnNedeleOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnPondeliOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnStredaOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnCtvrtekOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnPatekOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnSobotaOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
    }
    @IBAction func btnStClick(_ sender: Any) {
        vybruj()
        DenVtydnu="Streda"
        print(DenVtydnu)
        collectionViewOutlet.reloadData()
        //odesliNastaveniKalendareDoModulu()
        //DenVtydnuProOdeslani=DenVtydnu
        btnPondeliOutlet.backgroundColor=UIColor.clear
        btnUteryOutlet.backgroundColor=UIColor.clear
        btnStredaOutlet.backgroundColor=UIColor.init(red: 255/255, green: 191/255, blue: 58/255, alpha: 1)
        btnCtvrtekOutlet.backgroundColor=UIColor.clear
        btnPatekOutlet.backgroundColor=UIColor.clear
        btnSobotaOutlet.backgroundColor=UIColor.clear
        btnNedeleOutlet.backgroundColor=UIColor.clear
        
        btnStredaOutlet.setTitleColor(UIColor.black, for: .normal)
        btnNedeleOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnUteryOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnPondeliOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnCtvrtekOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnPatekOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnSobotaOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
    }
    @IBAction func btnCtClick(_ sender: Any) {
        vybruj()
        DenVtydnu="Ctvrtek"
        print(DenVtydnu)
        collectionViewOutlet.reloadData()
        //odesliNastaveniKalendareDoModulu()
        //DenVtydnuProOdeslani=DenVtydnu
        btnPondeliOutlet.backgroundColor=UIColor.clear
        btnUteryOutlet.backgroundColor=UIColor.clear
        btnStredaOutlet.backgroundColor=UIColor.clear
        btnCtvrtekOutlet.backgroundColor=UIColor.init(red: 255/255, green: 191/255, blue: 58/255, alpha: 1)
        btnPatekOutlet.backgroundColor=UIColor.clear
        btnSobotaOutlet.backgroundColor=UIColor.clear
        btnNedeleOutlet.backgroundColor=UIColor.clear
        
        btnCtvrtekOutlet.setTitleColor(UIColor.black, for: .normal)
        btnNedeleOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnUteryOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnStredaOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnPondeliOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnPatekOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnSobotaOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
    }
    @IBAction func btnPaClick(_ sender: Any) {
        vybruj()
        DenVtydnu="Patek"
        print(DenVtydnu)
        collectionViewOutlet.reloadData()
        //odesliNastaveniKalendareDoModulu()
        //DenVtydnuProOdeslani=DenVtydnu
        btnPondeliOutlet.backgroundColor=UIColor.clear
        btnUteryOutlet.backgroundColor=UIColor.clear
        btnStredaOutlet.backgroundColor=UIColor.clear
        btnCtvrtekOutlet.backgroundColor=UIColor.clear
        btnPatekOutlet.backgroundColor=UIColor.init(red: 255/255, green: 191/255, blue: 58/255, alpha: 1)
        btnSobotaOutlet.backgroundColor=UIColor.clear
        btnNedeleOutlet.backgroundColor=UIColor.clear
        
        btnPatekOutlet.setTitleColor(UIColor.black, for: .normal)
        btnNedeleOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnUteryOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnStredaOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnCtvrtekOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnPondeliOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnSobotaOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
    }
    @IBAction func btnSoClick(_ sender: Any) {
        vybruj()
        DenVtydnu="Sobota"
        print(DenVtydnu)
        collectionViewOutlet.reloadData()
        //odesliNastaveniKalendareDoModulu()
        //DenVtydnuProOdeslani=DenVtydnu
        btnPondeliOutlet.backgroundColor=UIColor.clear
        btnUteryOutlet.backgroundColor=UIColor.clear
        btnStredaOutlet.backgroundColor=UIColor.clear
        btnCtvrtekOutlet.backgroundColor=UIColor.clear
        btnPatekOutlet.backgroundColor=UIColor.clear
        btnSobotaOutlet.backgroundColor=UIColor.init(red: 255/255, green: 191/255, blue: 58/255, alpha: 1)
        btnNedeleOutlet.backgroundColor=UIColor.clear
        
        btnSobotaOutlet.setTitleColor(UIColor.black, for: .normal)
        btnNedeleOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnUteryOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnStredaOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnCtvrtekOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnPatekOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnPondeliOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
    }
    @IBAction func btnNeClick(_ sender: Any) {
        vybruj()
        DenVtydnu="Nedele"
        print(DenVtydnu)
        collectionViewOutlet.reloadData()
        //odesliNastaveniKalendareDoModulu()
        //DenVtydnuProOdeslani=DenVtydnu
        btnPondeliOutlet.backgroundColor=UIColor.clear
        btnUteryOutlet.backgroundColor=UIColor.clear
        btnStredaOutlet.backgroundColor=UIColor.clear
        btnCtvrtekOutlet.backgroundColor=UIColor.clear
        btnPatekOutlet.backgroundColor=UIColor.clear
        btnSobotaOutlet.backgroundColor=UIColor.clear
        btnNedeleOutlet.backgroundColor=UIColor.init(red: 255/255, green: 191/255, blue: 58/255, alpha: 1)
        
        btnNedeleOutlet.setTitleColor(UIColor.black, for: .normal)
        btnPondeliOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnUteryOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnStredaOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnCtvrtekOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnPatekOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
        btnSobotaOutlet.setTitleColor(UIColor.init(red: 219/255, green: 220/255, blue: 221/255, alpha: 1), for: .normal)
    }
    
    
    //--------------------------------------------------------
    // MARK: sendOverTCP --------------------------------
    //--------------------------------------------------------
    func sendOverTCP(message:String){
        //DispatchQueue.global(qos: .userInitiated).async {//nove vlakno
        if seznamMDNSvsAWS[indexVybranehoZarizeni]=="MDNS"{
            //DispatchQueue.global().async {
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
                    try chatSocket.connect(to: hostAdress, port: Int32(port), timeout: 3500, familyOnly: false)//bylo 500
                    
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
                
            //}//konec novz thread
        }//konec mdns
        else if seznamMDNSvsAWS[indexVybranehoZarizeni]=="AWS"{
                AWSmessage="{\"message\": \"\(message)\"}"
                AWStopic="\(seznamTopicu[indexVybranehoZarizeni/2] as String)dataProModul"
                NotificationCenter.default.post(name:NSNotification.Name("AWSprikaz"), object: nil)
            //sleep(5)
            
        }
    }//konec sednOverTCP
    
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
        
        //print("dosla notifikace ze jsou nova data z TCP")
        //aby to bralo jen data od IP adresy s kterou se komunikuje
        
        //removeActivityIndicator()
        print("jupi data pro me")
        if dataKeZpracovani.contains("{")&&dataKeZpracovani.contains("}")//dosly kompletni data
        //if dataKeZpracovani.contains("END")
        {
            //kalendar nedele RELE 1
            var nedele1 = ""
            var pondeli1 = ""
            var utery1 = ""
            var streda1 = ""
            var ctvrtek1 = ""
            var patek1 = ""
            var sobota1 = ""
            
            var nedele2 = ""
            var pondeli2 = ""
            var utery2 = ""
            var streda2 = ""
            var ctvrtek2 = ""
            var patek2 = ""
            var sobota2 = ""
            dataKeZpracovani = dataKeZpracovani.replacingOccurrences(of: "\r", with: "")
            dataKeZpracovani = dataKeZpracovani.replacingOccurrences(of: "{", with: "")
            dataKeZpracovani = dataKeZpracovani.replacingOccurrences(of: "}", with: "")
            
            var TCPdatatVpoli = Array(dataKeZpracovani)
            //"$KNE1:@1:10T12.5#@2:10T13.5#@3:10T14.5#@4:10T15.5#@5:10T16.5#@6:10T17.5#@7:10T18.5#@8:10T19.5#@9:10T21.5#@10:10T22.5#END%"
            if poradoveCisloRele[indexVybranehoZarizeni]=="1"{
                if odkudBylSpustenKalendar=="Topeni"{//upravit odeslani na casovac
                    if TCPdatatVpoli[1]=="K" && TCPdatatVpoli[2]=="N" && TCPdatatVpoli[3]=="E" && TCPdatatVpoli[4]=="1"{
                        print("Dosil data kalendar nedele 1")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            nedele1+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA nedele1:\(nedele1)")
                        
                        for index in 0..<konecSlova+4 {//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                    }//konec nedele
                    if TCPdatatVpoli[1]=="K" && TCPdatatVpoli[2]=="P" && TCPdatatVpoli[3]=="O" && TCPdatatVpoli[4]=="1"{
                        print("Dosil data kalendar pondeli 1")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            pondeli1+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA pondeli1:\(pondeli1)")
                        
                        for index in 0..<konecSlova+4 {//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                    }//konec pondeli
                    if TCPdatatVpoli[1]=="K" && TCPdatatVpoli[2]=="U" && TCPdatatVpoli[3]=="T" && TCPdatatVpoli[4]=="1"{
                        print("Dosil data kalendar utery 1")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            utery1+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA utery1:\(utery1)")
                        
                        for index in 0..<konecSlova+4 {//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                    }//konec pondeli
                    if TCPdatatVpoli[1]=="K" && TCPdatatVpoli[2]=="S" && TCPdatatVpoli[3]=="T" && TCPdatatVpoli[4]=="1"{
                        print("Dosil data kalendar streda 1")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            streda1+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA streda1:\(streda1)")
                        
                        for index in 0..<konecSlova+4 {//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                    }//konec pondeli
                    if TCPdatatVpoli[1]=="K" && TCPdatatVpoli[2]=="C" && TCPdatatVpoli[3]=="T" && TCPdatatVpoli[4]=="1"{
                        print("Dosil data kalendar ctvrtek 1")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            ctvrtek1+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA ctvrtek1:\(ctvrtek1)")
                        
                        for index in 0..<konecSlova+4{//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                    }//konec pondeli
                    if TCPdatatVpoli[1]=="K" && TCPdatatVpoli[2]=="P" && TCPdatatVpoli[3]=="A" && TCPdatatVpoli[4]=="1"{
                        print("Dosil data kalendar patek 1")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            patek1+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA patek1:\(patek1)")
                        
                        for index in 0..<konecSlova+4 {//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                    }//konec pondeli
                    if TCPdatatVpoli[1]=="K" && TCPdatatVpoli[2]=="S" && TCPdatatVpoli[3]=="O" && TCPdatatVpoli[4]=="1"{
                        print("Dosil data kalendar sobota 1")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            sobota1+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA sobota1:\(sobota1)")
                        
                        for index in 0..<konecSlova+4 {//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                        
                        
                    }//konec sobota
                }
                /************************CASOVAC******************/
                if odkudBylSpustenKalendar=="Svetlo"{//upravit odeslani na casovac
                    if TCPdatatVpoli[1]=="C" && TCPdatatVpoli[2]=="N" && TCPdatatVpoli[3]=="E" && TCPdatatVpoli[4]=="1"{
                        print("Dosil data casovac nedele 1")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            nedele1+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA nedele1:\(nedele1)")
                        
                        for index in 0..<konecSlova+4 {//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                    }//konec nedele
                    if TCPdatatVpoli[1]=="C" && TCPdatatVpoli[2]=="P" && TCPdatatVpoli[3]=="O" && TCPdatatVpoli[4]=="1"{
                        print("Dosil data casovac pondeli 1")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            pondeli1+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA pondeli1:\(pondeli1)")
                        
                        for index in 0..<konecSlova+4 {//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                    }//konec pondeli
                    if TCPdatatVpoli[1]=="C" && TCPdatatVpoli[2]=="U" && TCPdatatVpoli[3]=="T" && TCPdatatVpoli[4]=="1"{
                        print("Dosil data casovac utery 1")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            utery1+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA utery1:\(utery1)")
                        
                        for index in 0..<konecSlova+4 {//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                    }//konec pondeli
                    if TCPdatatVpoli[1]=="C" && TCPdatatVpoli[2]=="S" && TCPdatatVpoli[3]=="T" && TCPdatatVpoli[4]=="1"{
                        print("Dosil data casovac streda 1")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            streda1+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA streda1:\(streda1)")
                        
                        for index in 0..<konecSlova+4 {//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                    }//konec pondeli
                    if TCPdatatVpoli[1]=="C" && TCPdatatVpoli[2]=="C" && TCPdatatVpoli[3]=="T" && TCPdatatVpoli[4]=="1"{
                        print("Dosil data casovac ctvrtek 1")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            ctvrtek1+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA ctvrtek1:\(ctvrtek1)")
                        
                        for index in 0..<konecSlova+4{//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                    }//konec pondeli
                    if TCPdatatVpoli[1]=="C" && TCPdatatVpoli[2]=="P" && TCPdatatVpoli[3]=="A" && TCPdatatVpoli[4]=="1"{
                        print("Dosil data casovac patek 1")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            patek1+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA patek1:\(patek1)")
                        
                        for index in 0..<konecSlova+4 {//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                    }//konec pondeli
                    if TCPdatatVpoli[1]=="C" && TCPdatatVpoli[2]=="S" && TCPdatatVpoli[3]=="O" && TCPdatatVpoli[4]=="1"{
                        print("Dosil data casovac sobota 1")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            sobota1+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA sobota1:\(sobota1)")
                        
                        for index in 0..<konecSlova+4 {//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                        
                        
                    }//konec sobota
                }
            }
            /**************************************************DRUHE RELE************************************************/
            if poradoveCisloRele[indexVybranehoZarizeni]=="2"{
                if odkudBylSpustenKalendar=="Topeni"{//upravit odeslani na casovac
                    if TCPdatatVpoli[1]=="K" && TCPdatatVpoli[2]=="N" && TCPdatatVpoli[3]=="E" && TCPdatatVpoli[4]=="2"{
                        print("Dosil data kalendar nedele 2")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            nedele2+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA nedele2:\(nedele2)")
                        
                        for index in 0..<konecSlova+4 {//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                    }//konec nedele
                    if TCPdatatVpoli[1]=="K" && TCPdatatVpoli[2]=="P" && TCPdatatVpoli[3]=="O" && TCPdatatVpoli[4]=="2"{
                        print("Dosil data kalendar pondeli 2")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            pondeli2+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA pondeli2\(pondeli2)")
                        
                        for index in 0..<konecSlova+4 {//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                    }//konec pondeli
                    if TCPdatatVpoli[1]=="K" && TCPdatatVpoli[2]=="U" && TCPdatatVpoli[3]=="T" && TCPdatatVpoli[4]=="2"{
                        print("Dosil data kalendar utery 2")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            utery2+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA utery2:\(utery2)")
                        
                        for index in 0..<konecSlova+4 {//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                    }//konec pondeli
                    if TCPdatatVpoli[1]=="K" && TCPdatatVpoli[2]=="S" && TCPdatatVpoli[3]=="T" && TCPdatatVpoli[4]=="2"{
                        print("Dosil data kalendar streda 2")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            streda2+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA streda2:\(streda1)")
                        
                        for index in 0..<konecSlova+4 {//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                    }//konec pondeli
                    if TCPdatatVpoli[1]=="K" && TCPdatatVpoli[2]=="C" && TCPdatatVpoli[3]=="T" && TCPdatatVpoli[4]=="2"{
                        print("Dosil data kalendar ctvrtek 2")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            ctvrtek2+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA ctvrtek2:\(ctvrtek2)")
                        
                        for index in 0..<konecSlova+4 {//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                    }//konec pondeli
                    if TCPdatatVpoli[1]=="K" && TCPdatatVpoli[2]=="P" && TCPdatatVpoli[3]=="A" && TCPdatatVpoli[4]=="2"{
                        print("Dosil data kalendar patek 2")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            patek2+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA patek2:\(patek2)")
                        
                        for index in 0..<konecSlova+4 {//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                    }//konec pondeli
                    if TCPdatatVpoli[1]=="K" && TCPdatatVpoli[2]=="S" && TCPdatatVpoli[3]=="O" && TCPdatatVpoli[4]=="2"{
                        print("Dosil data kalendar sobota 2")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            sobota2+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA sobota2:\(sobota1)")
                        
                        for index in 0..<konecSlova+4 {//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                    }
                }
                /************************CASOVAC***********************************/
                if odkudBylSpustenKalendar=="Svetlo"{//upravit odeslani na casovac
                    if TCPdatatVpoli[1]=="C" && TCPdatatVpoli[2]=="N" && TCPdatatVpoli[3]=="E" && TCPdatatVpoli[4]=="2"{
                        print("Dosil data casovac nedele 2")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            nedele2+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA nedele2:\(nedele2)")
                        
                        for index in 0..<konecSlova+4 {//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                    }//konec nedele
                    if TCPdatatVpoli[1]=="C" && TCPdatatVpoli[2]=="P" && TCPdatatVpoli[3]=="O" && TCPdatatVpoli[4]=="2"{
                        print("Dosil data casovac pondeli 2")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            pondeli2+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA pondeli2\(pondeli2)")
                        
                        for index in 0..<konecSlova+4 {//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                    }//konec pondeli
                    if TCPdatatVpoli[1]=="C" && TCPdatatVpoli[2]=="U" && TCPdatatVpoli[3]=="T" && TCPdatatVpoli[4]=="2"{
                        print("Dosil data casovac utery 2")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            utery2+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA utery2:\(utery2)")
                        
                        for index in 0..<konecSlova+4 {//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                    }//konec pondeli
                    if TCPdatatVpoli[1]=="C" && TCPdatatVpoli[2]=="S" && TCPdatatVpoli[3]=="T" && TCPdatatVpoli[4]=="2"{
                        print("Dosil data casovac streda 2")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            streda2+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA streda2:\(streda1)")
                        
                        for index in 0..<konecSlova+4 {//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                    }//konec pondeli
                    if TCPdatatVpoli[1]=="C" && TCPdatatVpoli[2]=="C" && TCPdatatVpoli[3]=="T" && TCPdatatVpoli[4]=="2"{
                        print("Dosil data casovac ctvrtek 2")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            ctvrtek2+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA ctvrtek2:\(ctvrtek2)")
                        
                        for index in 0..<konecSlova+4 {//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                    }//konec pondeli
                    if TCPdatatVpoli[1]=="C" && TCPdatatVpoli[2]=="P" && TCPdatatVpoli[3]=="A" && TCPdatatVpoli[4]=="2"{
                        print("Dosil data casovac patek 2")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            patek2+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA patek2:\(patek2)")
                        
                        for index in 0..<konecSlova+4 {//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                    }//konec pondeli
                    if TCPdatatVpoli[1]=="C" && TCPdatatVpoli[2]=="S" && TCPdatatVpoli[3]=="O" && TCPdatatVpoli[4]=="2"{
                        print("Dosil data casovac sobota 2")
                        let zacatekSlova = (TCPdatatVpoli.firstIndex(of: "$")!)+6
                        let konecSlova = (TCPdatatVpoli.firstIndex(of: "%")!)-3
                        for index in zacatekSlova..<konecSlova{
                            sobota2+=String(TCPdatatVpoli[index])
                        }
                        print("SeparovanaDATA sobota2:\(sobota2)")
                        
                        for index in 0..<konecSlova+4 {//ostrani uz zpracovana data
                            TCPdatatVpoli.remove(at: 0)
                        }
                    }
                }
                
            }
            print("Prosel vsechny datat a tohle zbylo v bufferu:\(TCPdatatVpoli)")
            
            if pondeli1.count>0{
                //@10:00T20.5#@10:00T20.5#@10:00T20.5#@11:57T19.0#@17:20T20.5#
                print("mam data na parsovani pondeli1:\(pondeli1)")
                if odkudBylSpustenKalendar=="Topeni"{
                    PondeliSpinaciCasyAteploty.append(["",""])
                }
                if odkudBylSpustenKalendar=="Svetlo"{
                    PondeliSpinaciCasy.append(["",""])
                }
                while pondeli1 != ""{
                    dataKeZpracovani=pondeli1
                    let casParsovany = parsujData(prvniZnak: "@", druhyZnak: "T")
                    print("cas:\(casParsovany)")
                    let teplotaParsovana = parsujData(prvniZnak: "T", druhyZnak: "#")
                    print("teplota\(teplotaParsovana)")
                    if odkudBylSpustenKalendar=="Topeni"{
                        PondeliSpinaciCasyAteploty.append([casParsovany,teplotaParsovana])
                    }
                    if odkudBylSpustenKalendar=="Svetlo"{
                        PondeliSpinaciCasy.append([casParsovany,teplotaParsovana])
                    }
                    pondeli1 = pondeli1.replacingOccurrences(of: "@\(casParsovany)T\(teplotaParsovana)#", with: "")
                }
                print("prosel cele pondeli1")
            }//konec pondeli
            
            if utery1.count>0{
                //@10:00T20.5#@10:00T20.5#@10:00T20.5#@11:57T19.0#@17:20T20.5#
                print("mam data na parsovani utery1:\(utery1)")
                if odkudBylSpustenKalendar=="Topeni"{
                    UterySpinaciCasyAteploty.append(["",""])
                }
                if odkudBylSpustenKalendar=="Svetlo"{
                    UterySpinaciCasy.append(["",""])
                }
                while utery1 != ""{
                    dataKeZpracovani=utery1
                    let casParsovany = parsujData(prvniZnak: "@", druhyZnak: "T")
                    print("cas:\(casParsovany)")
                    let teplotaParsovana = parsujData(prvniZnak: "T", druhyZnak: "#")
                    print("teplota\(teplotaParsovana)")
                    if odkudBylSpustenKalendar=="Topeni"{
                        UterySpinaciCasyAteploty.append([casParsovany,teplotaParsovana])
                    }
                    if odkudBylSpustenKalendar=="Svetlo"{
                        UterySpinaciCasy.append([casParsovany,teplotaParsovana])
                    }
                    utery1 = utery1.replacingOccurrences(of: "@\(casParsovany)T\(teplotaParsovana)#", with: "")
                }
                print("prosel cele utery1")
            }//konec pondeli
            
            if streda1.count>0{
                //@10:00T20.5#@10:00T20.5#@10:00T20.5#@11:57T19.0#@17:20T20.5#
                print("mam data na parsovani streda1:\(streda1)")
                if odkudBylSpustenKalendar=="Topeni"{
                    StredaSpinaciCasyAteploty.append(["",""])
                }
                if odkudBylSpustenKalendar=="Svetlo"{
                    StredaSpinaciCasy.append(["",""])
                }
                while streda1 != ""{
                    dataKeZpracovani=streda1
                    let casParsovany = parsujData(prvniZnak: "@", druhyZnak: "T")
                    print("cas:\(casParsovany)")
                    let teplotaParsovana = parsujData(prvniZnak: "T", druhyZnak: "#")
                    print("teplota\(teplotaParsovana)")
                    if odkudBylSpustenKalendar=="Topeni"{
                        StredaSpinaciCasyAteploty.append([casParsovany,teplotaParsovana])
                    }
                    if odkudBylSpustenKalendar=="Svetlo"{
                        StredaSpinaciCasy.append([casParsovany,teplotaParsovana])
                    }
                    streda1 = streda1.replacingOccurrences(of: "@\(casParsovany)T\(teplotaParsovana)#", with: "")
                }
                print("prosel cele streda1")
            }//konec pondeli
            
            if ctvrtek1.count>0{
                //@10:00T20.5#@10:00T20.5#@10:00T20.5#@11:57T19.0#@17:20T20.5#
                print("mam data na parsovani ctvrtek1:\(ctvrtek1)")
                if odkudBylSpustenKalendar=="Topeni"{
                    CtvrtekSpinaciCasyAteploty.append(["",""])
                }
                if odkudBylSpustenKalendar=="Svetlo"{
                    CtvrtekSpinaciCasy.append(["",""])
                }
                while ctvrtek1 != ""{
                    dataKeZpracovani=ctvrtek1
                    let casParsovany = parsujData(prvniZnak: "@", druhyZnak: "T")
                    print("cas:\(casParsovany)")
                    let teplotaParsovana = parsujData(prvniZnak: "T", druhyZnak: "#")
                    print("teplota\(teplotaParsovana)")
                    if odkudBylSpustenKalendar=="Topeni"{
                        CtvrtekSpinaciCasyAteploty.append([casParsovany,teplotaParsovana])
                    }
                    if odkudBylSpustenKalendar=="Svetlo"{
                        CtvrtekSpinaciCasy.append([casParsovany,teplotaParsovana])
                    }
                    ctvrtek1 = ctvrtek1.replacingOccurrences(of: "@\(casParsovany)T\(teplotaParsovana)#", with: "")
                }
                print("prosel cele ctvrtek1")
            }//konec ctvrtek1
            
            if patek1.count>0{
                //@10:00T20.5#@10:00T20.5#@10:00T20.5#@11:57T19.0#@17:20T20.5#
                print("mam data na parsovani patek1:\(patek1)")
                if odkudBylSpustenKalendar=="Topeni"{
                    PatekSpinaciCasyAteploty.append(["",""])
                }
                if odkudBylSpustenKalendar=="Svetlo"{
                    PatekSpinaciCasy.append(["",""])
                }
                while patek1 != ""{
                    dataKeZpracovani=patek1
                    let casParsovany = parsujData(prvniZnak: "@", druhyZnak: "T")
                    print("cas:\(casParsovany)")
                    let teplotaParsovana = parsujData(prvniZnak: "T", druhyZnak: "#")
                    print("teplota\(teplotaParsovana)")
                    if odkudBylSpustenKalendar=="Topeni"{
                        PatekSpinaciCasyAteploty.append([casParsovany,teplotaParsovana])
                    }
                    if odkudBylSpustenKalendar=="Svetlo"{
                        PatekSpinaciCasy.append([casParsovany,teplotaParsovana])
                    }
                    patek1 = patek1.replacingOccurrences(of: "@\(casParsovany)T\(teplotaParsovana)#", with: "")
                }
                print("prosel cele patek1")
            }//konec patek1
            
            if sobota1.count>0{
                //@10:00T20.5#@10:00T20.5#@10:00T20.5#@11:57T19.0#@17:20T20.5#
                print("mam data na parsovani sobota1:\(sobota1)")
                if odkudBylSpustenKalendar=="Topeni"{
                    SobotaSpinaciCasyAteploty.append(["",""])
                }
                if odkudBylSpustenKalendar=="Svetlo"{
                    SobotaSpinaciCasy.append(["",""])
                }
                while sobota1 != ""{
                    dataKeZpracovani=sobota1
                    let casParsovany = parsujData(prvniZnak: "@", druhyZnak: "T")
                    print("cas:\(casParsovany)")
                    let teplotaParsovana = parsujData(prvniZnak: "T", druhyZnak: "#")
                    print("teplota\(teplotaParsovana)")
                    if odkudBylSpustenKalendar=="Topeni"{
                        SobotaSpinaciCasyAteploty.append([casParsovany,teplotaParsovana])
                    }
                    if odkudBylSpustenKalendar=="Svetlo"{
                        SobotaSpinaciCasy.append([casParsovany,teplotaParsovana])
                    }
                    sobota1 = sobota1.replacingOccurrences(of: "@\(casParsovany)T\(teplotaParsovana)#", with: "")
                }
                print("prosel cele sobota1")
            }//konec sobota1
            
            if nedele1.count>0{
                //@10:00T20.5#@10:00T20.5#@10:00T20.5#@11:57T19.0#@17:20T20.5#
                print("mam data na parsovani nedele1:\(nedele1)")
                if odkudBylSpustenKalendar=="Topeni"{
                    NedeleSpinaciCasyAteploty.append(["",""])
                }
                if odkudBylSpustenKalendar=="Svetlo"{
                    NedeleSpinaciCasy.append(["",""])
                }
                while nedele1 != ""{
                    dataKeZpracovani=nedele1
                    let casParsovany = parsujData(prvniZnak: "@", druhyZnak: "T")
                    print("cas:\(casParsovany)")
                    let teplotaParsovana = parsujData(prvniZnak: "T", druhyZnak: "#")
                    print("teplota\(teplotaParsovana)")
                    if odkudBylSpustenKalendar=="Topeni"{
                        NedeleSpinaciCasyAteploty.append([casParsovany,teplotaParsovana])
                    }
                    if odkudBylSpustenKalendar=="Svetlo"{
                        NedeleSpinaciCasy.append([casParsovany,teplotaParsovana])
                    }
                    nedele1 = nedele1.replacingOccurrences(of: "@\(casParsovany)T\(teplotaParsovana)#", with: "")
                }
                print("prosel cele nedele1")
            }//konec nedele1
            
            if pondeli2.count>0{
                //@10:00T20.5#@10:00T20.5#@10:00T20.5#@11:57T19.0#@17:20T20.5#
                print("mam data na parsovani pondeli2:\(pondeli2)")
                if odkudBylSpustenKalendar=="Topeni"{
                    PondeliSpinaciCasyAteploty.append(["",""])
                }
                if odkudBylSpustenKalendar=="Svetlo"{
                    PondeliSpinaciCasy.append(["",""])
                }
                while pondeli2 != ""{
                    dataKeZpracovani=pondeli2
                    let casParsovany = parsujData(prvniZnak: "@", druhyZnak: "T")
                    print("cas:\(casParsovany)")
                    let teplotaParsovana = parsujData(prvniZnak: "T", druhyZnak: "#")
                    print("teplota\(teplotaParsovana)")
                    if odkudBylSpustenKalendar=="Topeni"{
                        PondeliSpinaciCasyAteploty.append([casParsovany,teplotaParsovana])
                    }
                    if odkudBylSpustenKalendar=="Svetlo"{
                        PondeliSpinaciCasy.append([casParsovany,teplotaParsovana])
                    }
                    pondeli2 = pondeli2.replacingOccurrences(of: "@\(casParsovany)T\(teplotaParsovana)#", with: "")
                }
                print("prosel cele pondeli1")
            }//konec pondeli
            
            if utery2.count>0{
                //@20:00T20.5#@20:00T20.5#@20:00T20.5#@22:57T29.0#@27:20T20.5#
                print("mam data na parsovani utery2:\(utery2)")
                if odkudBylSpustenKalendar=="Topeni"{
                    UterySpinaciCasyAteploty.append(["",""])
                }
                if odkudBylSpustenKalendar=="Svetlo"{
                    UterySpinaciCasy.append(["",""])
                }
                while utery2 != ""{
                    dataKeZpracovani=utery2
                    let casParsovany = parsujData(prvniZnak: "@", druhyZnak: "T")
                    print("cas:\(casParsovany)")
                    let teplotaParsovana = parsujData(prvniZnak: "T", druhyZnak: "#")
                    print("teplota\(teplotaParsovana)")
                    if odkudBylSpustenKalendar=="Topeni"{
                        UterySpinaciCasyAteploty.append([casParsovany,teplotaParsovana])
                    }
                    if odkudBylSpustenKalendar=="Svetlo"{
                        UterySpinaciCasy.append([casParsovany,teplotaParsovana])
                    }
                    utery2 = utery2.replacingOccurrences(of: "@\(casParsovany)T\(teplotaParsovana)#", with: "")
                }
                print("prosel cele utery2")
            }//konec pondeli
            
            if streda2.count>0{
                //@20:00T20.5#@20:00T20.5#@20:00T20.5#@22:57T29.0#@27:20T20.5#
                print("mam data na parsovani streda2:\(streda2)")
                if odkudBylSpustenKalendar=="Topeni"{
                    StredaSpinaciCasyAteploty.append(["",""])
                }
                if odkudBylSpustenKalendar=="Svetlo"{
                    StredaSpinaciCasy.append(["",""])
                }
                while streda2 != ""{
                    dataKeZpracovani=streda2
                    let casParsovany = parsujData(prvniZnak: "@", druhyZnak: "T")
                    print("cas:\(casParsovany)")
                    let teplotaParsovana = parsujData(prvniZnak: "T", druhyZnak: "#")
                    print("teplota\(teplotaParsovana)")
                    if odkudBylSpustenKalendar=="Topeni"{
                        StredaSpinaciCasyAteploty.append([casParsovany,teplotaParsovana])
                    }
                    if odkudBylSpustenKalendar=="Svetlo"{
                        StredaSpinaciCasy.append([casParsovany,teplotaParsovana])
                    }
                    streda2 = streda2.replacingOccurrences(of: "@\(casParsovany)T\(teplotaParsovana)#", with: "")
                }
                print("prosel cele streda2")
            }//konec pondeli
            
            if ctvrtek2.count>0{
                //@20:00T20.5#@20:00T20.5#@20:00T20.5#@22:57T29.0#@27:20T20.5#
                print("mam data na parsovani ctvrtek2:\(ctvrtek2)")
                if odkudBylSpustenKalendar=="Topeni"{
                    CtvrtekSpinaciCasyAteploty.append(["",""])
                }
                if odkudBylSpustenKalendar=="Svetlo"{
                    CtvrtekSpinaciCasy.append(["",""])
                }
                while ctvrtek2 != ""{
                    dataKeZpracovani=ctvrtek2
                    let casParsovany = parsujData(prvniZnak: "@", druhyZnak: "T")
                    print("cas:\(casParsovany)")
                    let teplotaParsovana = parsujData(prvniZnak: "T", druhyZnak: "#")
                    print("teplota\(teplotaParsovana)")
                    if odkudBylSpustenKalendar=="Topeni"{
                        CtvrtekSpinaciCasyAteploty.append([casParsovany,teplotaParsovana])
                    }
                    if odkudBylSpustenKalendar=="Svetlo"{
                        CtvrtekSpinaciCasy.append([casParsovany,teplotaParsovana])
                    }
                    ctvrtek2 = ctvrtek2.replacingOccurrences(of: "@\(casParsovany)T\(teplotaParsovana)#", with: "")
                }
                print("prosel cele ctvrtek2")
            }//konec ctvrtek2
            
            if patek2.count>0{
                //@20:00T20.5#@20:00T20.5#@20:00T20.5#@22:57T29.0#@27:20T20.5#
                print("mam data na parsovani patek2:\(patek2)")
                if odkudBylSpustenKalendar=="Topeni"{
                    PatekSpinaciCasyAteploty.append(["",""])
                }
                if odkudBylSpustenKalendar=="Svetlo"{
                    PatekSpinaciCasy.append(["",""])
                }
                while patek2 != ""{
                    dataKeZpracovani=patek2
                    let casParsovany = parsujData(prvniZnak: "@", druhyZnak: "T")
                    print("cas:\(casParsovany)")
                    let teplotaParsovana = parsujData(prvniZnak: "T", druhyZnak: "#")
                    print("teplota\(teplotaParsovana)")
                    if odkudBylSpustenKalendar=="Topeni"{
                        PatekSpinaciCasyAteploty.append([casParsovany,teplotaParsovana])
                    }
                    if odkudBylSpustenKalendar=="Svetlo"{
                        PatekSpinaciCasy.append([casParsovany,teplotaParsovana])
                    }
                    patek2 = patek2.replacingOccurrences(of: "@\(casParsovany)T\(teplotaParsovana)#", with: "")
                }
                print("prosel cele patek2")
            }//konec patek2
            
            if sobota2.count>0{
                //@20:00T20.5#@20:00T20.5#@20:00T20.5#@22:57T29.0#@27:20T20.5#
                print("mam data na parsovani sobota2:\(sobota2)")
                if odkudBylSpustenKalendar=="Topeni"{
                    SobotaSpinaciCasyAteploty.append(["",""])
                }
                if odkudBylSpustenKalendar=="Svetlo"{
                    SobotaSpinaciCasy.append(["",""])
                }
                while sobota2 != ""{
                    dataKeZpracovani=sobota2
                    let casParsovany = parsujData(prvniZnak: "@", druhyZnak: "T")
                    print("cas:\(casParsovany)")
                    let teplotaParsovana = parsujData(prvniZnak: "T", druhyZnak: "#")
                    print("teplota\(teplotaParsovana)")
                    if odkudBylSpustenKalendar=="Topeni"{
                        SobotaSpinaciCasyAteploty.append([casParsovany,teplotaParsovana])
                    }
                    if odkudBylSpustenKalendar=="Svetlo"{
                        SobotaSpinaciCasy.append([casParsovany,teplotaParsovana])
                    }
                    sobota2 = sobota2.replacingOccurrences(of: "@\(casParsovany)T\(teplotaParsovana)#", with: "")
                }
                print("prosel cele sobota2")
            }//konec sobota2
            
            if nedele2.count>0{
                //@20:00T20.5#@20:00T20.5#@20:00T20.5#@22:57T29.0#@27:20T20.5#
                print("mam data na parsovani nedele2:\(nedele2)")
                if odkudBylSpustenKalendar=="Topeni"{
                    NedeleSpinaciCasyAteploty.append(["",""])
                }
                if odkudBylSpustenKalendar=="Svetlo"{
                    NedeleSpinaciCasy.append(["",""])
                }
                while nedele2 != ""{
                    dataKeZpracovani=nedele2
                    let casParsovany = parsujData(prvniZnak: "@", druhyZnak: "T")
                    print("cas:\(casParsovany)")
                    let teplotaParsovana = parsujData(prvniZnak: "T", druhyZnak: "#")
                    print("teplota\(teplotaParsovana)")
                    if odkudBylSpustenKalendar=="Topeni"{
                        NedeleSpinaciCasyAteploty.append([casParsovany,teplotaParsovana])
                    }
                    if odkudBylSpustenKalendar=="Svetlo"{
                        NedeleSpinaciCasy.append([casParsovany,teplotaParsovana])
                    }
                    nedele2 = nedele2.replacingOccurrences(of: "@\(casParsovany)T\(teplotaParsovana)#", with: "")
                }
                print("prosel cele nedele2")
            }//konec nedele2
            
        }
                   
          else if dataKeZpracovani.contains("CasAktualizovan")
            {
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
                
                present(alertController, animated: true, completion: nil)
                
           
            
        }
        else {print("Dosly nekompletni data")}
        //let kalendarTyden=[PondeliSpinaciCasyAteploty,UterySpinaciCasyAteploty,StredaSpinaciCasyAteploty,CtvrtekSpinaciCasyAteploty,PatekSpinaciCasyAteploty,SobotaSpinaciCasyAteploty,NedeleSpinaciCasyAteploty]//naplnim tyden aktualnimi casy
        //print("kalendarTyden\(kalendarTyden)")
        //print("PondeliSpinaciCasyAteploty\(PondeliSpinaciCasyAteploty)")
        //print("PondeliSpinaciCasyAteplotylendaru\(poleKalendaru)")
               
        
        dataKeZpracovani=""
        uzDoslaData=true
        
    }
    //$CNE2:END%$CPO2:END%$CUT2:END%$CST2:END%$CCT2:END%$CPA2:END%$CSO2:END% prazdna data
    func odesliNastaveniKalendareDoModulu()
    {
        if odkudBylSpustenKalendar=="Topeni"{
            if DenVtydnu=="Pondeli"{
                if PondeliSpinaciCasyAteploty.count>1{
                    var message="KPO\((poradoveCisloRele[indexVybranehoZarizeni])):"
                    for index in 0..<PondeliSpinaciCasyAteploty.count-1{
                        message+="@\(PondeliSpinaciCasyAteploty[index][0])T\(PondeliSpinaciCasyAteploty[index][1])#"
                    }
                    message+="END\n"
                    sendOverTCP(message: message)
                }
                else {
                    sendOverTCP(message: "KPO\((poradoveCisloRele[indexVybranehoZarizeni])):END\n")
                }
            }
            if DenVtydnu=="Utery"{
                if UterySpinaciCasyAteploty.count>1{
                    var message="KUT\((poradoveCisloRele[indexVybranehoZarizeni])):"
                    for index in 0..<UterySpinaciCasyAteploty.count-1{
                        message+="@\(UterySpinaciCasyAteploty[index][0])T\(UterySpinaciCasyAteploty[index][1])#"
                    }
                    message+="END\n"
                    sendOverTCP(message: message)
                }
                else {
                    sendOverTCP(message: "KUT\((poradoveCisloRele[indexVybranehoZarizeni])):END\n")
                }
            }
            if DenVtydnu=="Streda"{
                if StredaSpinaciCasyAteploty.count>1{
                    var message="KST\((poradoveCisloRele[indexVybranehoZarizeni])):"
                    for index in 0..<StredaSpinaciCasyAteploty.count-1{
                        message+="@\(StredaSpinaciCasyAteploty[index][0])T\(StredaSpinaciCasyAteploty[index][1])#"
                    }
                    message+="END\n"
                    sendOverTCP(message: message)
                }
                else {
                    sendOverTCP(message: "KST\((poradoveCisloRele[indexVybranehoZarizeni])):END\n")
                }
            }
            if DenVtydnu=="Ctvrtek"{
                if CtvrtekSpinaciCasyAteploty.count>1{
                    var message="KCT\((poradoveCisloRele[indexVybranehoZarizeni])):"
                    for index in 0..<CtvrtekSpinaciCasyAteploty.count-1{
                        message+="@\(CtvrtekSpinaciCasyAteploty[index][0])T\(CtvrtekSpinaciCasyAteploty[index][1])#"
                    }
                    message+="END\n"
                    sendOverTCP(message: message)
                }
                else {
                    sendOverTCP(message: "KCT\((poradoveCisloRele[indexVybranehoZarizeni])):END\n")
                }
            }
            if DenVtydnu=="Patek"{
                if PatekSpinaciCasyAteploty.count>1{
                    var message="KPA\((poradoveCisloRele[indexVybranehoZarizeni])):"
                    for index in 0..<PatekSpinaciCasyAteploty.count-1{
                        message+="@\(PatekSpinaciCasyAteploty[index][0])T\(PatekSpinaciCasyAteploty[index][1])#"
                    }
                    message+="END\n"
                    sendOverTCP(message: message)
                }
                else {
                    sendOverTCP(message: "KPA\((poradoveCisloRele[indexVybranehoZarizeni])):END\n")
                }
            }
            if DenVtydnu=="Sobota"{
                if SobotaSpinaciCasyAteploty.count>1{
                    var message="KSO\((poradoveCisloRele[indexVybranehoZarizeni])):"
                    for index in 0..<SobotaSpinaciCasyAteploty.count-1{
                        message+="@\(SobotaSpinaciCasyAteploty[index][0])T\(SobotaSpinaciCasyAteploty[index][1])#"
                    }
                    message+="END\n"
                    sendOverTCP(message: message)
                }
                else {
                    sendOverTCP(message: "KSO\((poradoveCisloRele[indexVybranehoZarizeni])):END\n")
                }
            }
            if DenVtydnu=="Nedele"{
                if NedeleSpinaciCasyAteploty.count>1{
                    var message="KNE\((poradoveCisloRele[indexVybranehoZarizeni])):"
                    for index in 0..<NedeleSpinaciCasyAteploty.count-1{
                        message+="@\(NedeleSpinaciCasyAteploty[index][0])T\(NedeleSpinaciCasyAteploty[index][1])#"
                    }
                    message+="END\n"
                    sendOverTCP(message: message)
                }
                else {
                    sendOverTCP(message: "KNE\((poradoveCisloRele[indexVybranehoZarizeni])):END\n")
                }
            }
        }
        
        if odkudBylSpustenKalendar=="Svetlo"{//upravit odeslani na casovac
            if DenVtydnu=="Pondeli"{
                if PondeliSpinaciCasy.count>1{
                    var message="CPO\((poradoveCisloRele[indexVybranehoZarizeni])):"
                    for index in 0..<PondeliSpinaciCasy.count-1{
                        message+="@\(PondeliSpinaciCasy[index][0])T\(PondeliSpinaciCasy[index][1])#"
                    }
                    message+="END\n"
                    sendOverTCP(message: message)
                }
                else {
                    sendOverTCP(message: "CPO\((poradoveCisloRele[indexVybranehoZarizeni])):END\n")
                }
            }
            if DenVtydnu=="Utery"{
                if UterySpinaciCasy.count>1{
                    var message="CUT\((poradoveCisloRele[indexVybranehoZarizeni])):"
                    for index in 0..<UterySpinaciCasy.count-1{
                        message+="@\(UterySpinaciCasy[index][0])T\(UterySpinaciCasy[index][1])#"
                    }
                    message+="END\n"
                    sendOverTCP(message: message)
                }
                else {
                    sendOverTCP(message: "CUT\((poradoveCisloRele[indexVybranehoZarizeni])):END\n")
                }
            }
            if DenVtydnu=="Streda"{
                if StredaSpinaciCasy.count>1{
                    var message="CST\((poradoveCisloRele[indexVybranehoZarizeni])):"
                    for index in 0..<StredaSpinaciCasy.count-1{
                        message+="@\(StredaSpinaciCasy[index][0])T\(StredaSpinaciCasy[index][1])#"
                    }
                    message+="END\n"
                    sendOverTCP(message: message)
                }
                else {
                    sendOverTCP(message: "CST\((poradoveCisloRele[indexVybranehoZarizeni])):END\n")
                }
            }
            if DenVtydnu=="Ctvrtek"{
                if CtvrtekSpinaciCasy.count>1{
                    var message="CCT\((poradoveCisloRele[indexVybranehoZarizeni])):"
                    for index in 0..<CtvrtekSpinaciCasy.count-1{
                        message+="@\(CtvrtekSpinaciCasy[index][0])T\(CtvrtekSpinaciCasy[index][1])#"
                    }
                    message+="END\n"
                    sendOverTCP(message: message)
                }
                else {
                    sendOverTCP(message: "CCT\((poradoveCisloRele[indexVybranehoZarizeni])):END\n")
                }
            }
            if DenVtydnu=="Patek"{
                if PatekSpinaciCasy.count>1{
                    var message="CPA\((poradoveCisloRele[indexVybranehoZarizeni])):"
                    for index in 0..<PatekSpinaciCasy.count-1{
                        message+="@\(PatekSpinaciCasy[index][0])T\(PatekSpinaciCasy[index][1])#"
                    }
                    message+="END\n"
                    sendOverTCP(message: message)
                }
                else {
                    sendOverTCP(message: "CPA\((poradoveCisloRele[indexVybranehoZarizeni])):END\n")
                }
            }
            if DenVtydnu=="Sobota"{
                if SobotaSpinaciCasy.count>1{
                    var message="CSO\((poradoveCisloRele[indexVybranehoZarizeni])):"
                    for index in 0..<SobotaSpinaciCasy.count-1{
                        message+="@\(SobotaSpinaciCasy[index][0])T\(SobotaSpinaciCasy[index][1])#"
                    }
                    message+="END\n"
                    sendOverTCP(message: message)
                }
                else {
                    sendOverTCP(message: "CSO\((poradoveCisloRele[indexVybranehoZarizeni])):END\n")
                }
            }
            if DenVtydnu=="Nedele"{
                if NedeleSpinaciCasy.count>1{
                    var message="CNE\((poradoveCisloRele[indexVybranehoZarizeni])):"
                    for index in 0..<NedeleSpinaciCasy.count-1{
                        message+="@\(NedeleSpinaciCasy[index][0])T\(NedeleSpinaciCasy[index][1])#"
                    }
                    message+="END\n"
                    sendOverTCP(message: message)
                }
                else {
                    sendOverTCP(message: "CNE\((poradoveCisloRele[indexVybranehoZarizeni])):END\n")
                }
            }
        }
    }
}//konec class
