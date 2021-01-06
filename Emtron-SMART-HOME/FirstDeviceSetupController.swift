//
//  FirstDeviceSetupController.swift
//  Emtron-SMART-HOME
//
//  Created by Ivo Dvorak on 24/10/2019.
//  Copyright © 2019 Ivo Dvorak. All rights reserved.
//


import UIKit
import Foundation
import Socket
import AudioToolbox

var indexVybranehoObrazku=0
var cellUprostred = 0

class FirstDeviceSetupController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate {
   
    @IBOutlet weak var switchTopimChladimOutlet: UISwitch!
    @IBOutlet weak var outletViewNazev: UIView!
    @IBOutlet weak var outletBtnOK: UIButton!
    //@IBOutlet weak var uiviewOutlet: UIView!
    @IBOutlet weak var outletViewSeznam: UIView!
    
    @IBOutlet weak var outletKladnaHystereze: UITextField!
    @IBOutlet weak var outletZapornaHystereze: UITextField!
    
    @IBAction func SwitchChange(_ sender: Any) {
        
        if outletSwitch.isOn {
            seznamPripojenychTeplomeru[indexVybranehoZarizeni]="Wire"
            //outletSwitch.thumbTintColor=UIColor.white
            //outletSwitch.onTintColor
            outletSwitch.tintColor=UIColor.green
            print("Switch ON")
            }
        else {
            seznamPripojenychTeplomeru[indexVybranehoZarizeni]="None"
            //outletSwitch.thumbTintColor=UIColor.red
            outletSwitch.subviews[0].subviews[0].backgroundColor = .red
            print("Switch OFF")
        }
    }
    
    @IBAction func SwitchTopimChladimChange(_ sender: Any) {
        
        if switchTopimChladimOutlet.isOn {
            
            switchTopimChladimOutlet.tintColor=UIColor.orange
            seznamTopoimChladim[indexVybranehoZarizeni]="Topim"
           // switchTopimChladimOutlet.subviews[0].subviews[0].backgroundColor = .blue
            print("Topim")
            }
        else {
            switchTopimChladimOutlet.tintColor=UIColor.blue
            seznamTopoimChladim[indexVybranehoZarizeni]="Chladim"
            print("chladim")
            switchTopimChladimOutlet.subviews[0].subviews[0].backgroundColor = .blue
        }
    }
    
    
    
    @IBOutlet weak var outletSwitch: UISwitch!
    
    @IBOutlet weak var textFieldNazev: UITextField!
    @IBOutlet weak var textFieldUmisteni: UITextField!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    
    @IBAction func OkButtonClick(_ sender: Any) {
     
        
        seznamKladnaHystereze[indexVybranehoZarizeni]=outletKladnaHystereze.text!.replacingOccurrences(of: ",", with: ".")
        seznamZapornaHystereze[indexVybranehoZarizeni]=outletZapornaHystereze.text!.replacingOccurrences(of: ",", with: ".")
        
        //seznamObrazkuZarizeni[indexVybranehoZarizeni]="\(Images[indexVybranehoObrazku])NoRespone"//nastavi vybrany obrazek
        
        if seznamObrazkuZarizeni[indexVybranehoZarizeni].contains("NoRespone"){
        seznamObrazkuZarizeni[indexVybranehoZarizeni] = "\(Images[indexVybranehoObrazku])NoRespone"
        }
        else if seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].contains("ON"){//+1
            seznamObrazkuZarizeni[indexVybranehoZarizeni] = "\(Images[indexVybranehoObrazku])ON"
        }
        else if seznamObrazkuZarizeni[indexKdeJeZarizeniProMDNSaAWS].contains("OFF"){//+1
            seznamObrazkuZarizeni[indexVybranehoZarizeni] = "\(Images[indexVybranehoObrazku])OFF"
        }
        
        else{
            seznamObrazkuZarizeni[indexVybranehoZarizeni] = "\(Images[indexVybranehoObrazku])OFF"
        }
        
        
        
        seznamUmisteniZarizeni[indexVybranehoZarizeni]=textFieldUmisteni.text ?? "default"
        seznamNazvuZarizeni[indexVybranehoZarizeni]=textFieldNazev.text ?? "default"
        if indexVybranehoObrazku != 2{
            seznamPripojenychTeplomeru[indexVybranehoZarizeni]="None"//aby to automaticky zhodilo pripijeni cidla pokud je neco jineho nez teplomer
            seznamProvoznichRezimu[indexVybranehoZarizeni] = "RELE\(poradoveCisloRele)"
        }
        print("indexVybranehoZarizeni v OK: \(indexVybranehoZarizeni)")
        print("indexVybranehoObrazku v OK: \(indexVybranehoObrazku)")
        sendOverTCP(message: "NAME\(poradoveCisloRele[indexVybranehoZarizeni]):\(seznamNazvuZarizeni[indexVybranehoZarizeni])LOCATION\(poradoveCisloRele[indexVybranehoZarizeni]):\(seznamUmisteniZarizeni[indexVybranehoZarizeni])ICONE\(poradoveCisloRele[indexVybranehoZarizeni]):\(Images[indexVybranehoObrazku])TEMPSENS\(poradoveCisloRele[indexVybranehoZarizeni]):\(seznamPripojenychTeplomeru[indexVybranehoZarizeni])KH\(poradoveCisloRele[indexVybranehoZarizeni]):\(seznamKladnaHystereze[indexVybranehoZarizeni])ZH\(poradoveCisloRele[indexVybranehoZarizeni]):\(seznamZapornaHystereze[indexVybranehoZarizeni])TCH\(poradoveCisloRele[indexVybranehoZarizeni]):\(seznamTopoimChladim[indexVybranehoZarizeni])END\n")//tohle odesle akoutletZapornaHysterezetualni nazev,umisteni a ikonu do modulu
        
        UserDefaults.standard.setValue(seznamTopoimChladim, forKey: "seznamTopoimChladim")
        UserDefaults.standard.setValue(seznamKladnaHystereze, forKey: "seznamKladnaHystereze")
        UserDefaults.standard.setValue(seznamZapornaHystereze, forKey: "seznamZapornaHystereze")
        UserDefaults.standard.setValue(seznamNazvuZarizeni, forKey: "seznamNazvuZarizeni")
        UserDefaults.standard.setValue(seznamUmisteniZarizeni, forKey: "seznamUmisteniZarizeni")
        UserDefaults.standard.setValue(seznamObrazkuZarizeni, forKey: "seznamObrazkuZarizeni")
        
       // self.sendOverTCP(message:"R\(poradoveCisloRele[indexVybranehoZarizeni])OFF\n")//melo by to poslat R1OFF nebo R2OFF
        bylDetailController=true
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeviceListController")
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true, completion: nil)
        
        
    }
    //@IBOutlet weak var vybranyObrazekOutlet: UIImageView!
    //let Items = ["Svetlo obyvak","Ventilator","Topeni","Zarovka"]
    let Images = ["zarovka","ventilator","radiator","zasuvka"]
   
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //--------------------------------------------------------
    // MARK: viewDidLoad --------------------------------
    //--------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        hideKeyboardWhenTappedAround()
        textFieldUmisteni.text=seznamUmisteniZarizeni[indexVybranehoZarizeni]
        textFieldNazev.text=seznamNazvuZarizeni[indexVybranehoZarizeni]
        hostAdress=seznamIPZarizeni[indexVybranehoZarizeni]//nastavi IP adresu s kterou ma komunikovat
        //sem dodelat aby to podle obrazku nastavilo index ktery obrayek ma vybrany
        
        outletViewSeznam.layer.cornerRadius=20
        outletViewNazev.layer.cornerRadius=20
        if seznamPripojenychTeplomeru[indexVybranehoZarizeni]=="Wire"{
            outletSwitch.setOn(true, animated: false)
        }
        else{
            outletSwitch.setOn(false, animated: false)
            //outletSwitch.subviews[0].subviews[0].backgroundColor = .red
        }
        if seznamTopoimChladim[indexVybranehoZarizeni]=="Topim"{
            switchTopimChladimOutlet.setOn(true, animated: false)
        }
        else{
            switchTopimChladimOutlet.setOn(false, animated: false)
            //switchTopimChladimOutlet.subviews[0].subviews[0].backgroundColor = .blue
        }
        textFieldNazev.layer.cornerRadius=10
        textFieldUmisteni.layer.cornerRadius=10
        textFieldNazev.autocapitalizationType = .allCharacters
        textFieldUmisteni.autocapitalizationType = .allCharacters
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
                
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        outletBtnOK.layer.cornerRadius=15
        outletZapornaHystereze.text=seznamZapornaHystereze[indexVybranehoZarizeni]
        outletKladnaHystereze.text=seznamKladnaHystereze[indexVybranehoZarizeni]
        if seznamObrazkuZarizeni[indexVybranehoZarizeni].contains("zarovka"){
            indexVybranehoObrazku=0
            print("load indexVybranehoObrazku=0")
        }
        else if seznamObrazkuZarizeni[indexVybranehoZarizeni].contains("ventilator"){
            indexVybranehoObrazku=1
            print("load indexVybranehoObrazku=1")
        }
        else if seznamObrazkuZarizeni[indexVybranehoZarizeni].contains("radiator"){
            indexVybranehoObrazku=2
            print("load indexVybranehoObrazku=2")
        }
        else if seznamObrazkuZarizeni[indexVybranehoZarizeni].contains("zasuvka"){
            indexVybranehoObrazku=3
            print("load indexVybranehoObrazku=3")
        }
        cellUprostred=indexVybranehoObrazku
        /*NotificationCenter.default.addObserver(
          self,
          selector: #selector(keyboardWillShow(_:)),
          name: UIResponder.keyboardWillShowNotification,
          object: nil)

        NotificationCenter.default.addObserver(
          self,
          selector: #selector(keyboardWillHide(_:)),
          name: UIResponder.keyboardWillHideNotification,
          object: nil)
 */
        //setGradientBackground()
        }
        
    
    @objc func keyboardDidShow(notification: NSNotification) {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
               let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height+20, right: 0.0)
               self.scrollView.contentInset = contentInsets
               self.scrollView.scrollIndicatorInsets = contentInsets
            }
        }
            
    @objc func keyboardWillBeHidden(notification: NSNotification) {
            let contentInsets = UIEdgeInsets.zero
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
        }
        
    //1
    
    
    /*
    func adjustInsetForKeyboardShow(_ show: Bool, notification: Notification) {
      guard
        let userInfo = notification.userInfo,
        let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey]
          as? NSValue
        else {
          return
      }
        
      let adjustmentHeight = (keyboardFrame.cgRectValue.height + 20) * (show ? 1 : -1)
      scrollView.contentInset.bottom += adjustmentHeight
      scrollView.verticalScrollIndicatorInsets.bottom += adjustmentHeight
        print("posouva")
    }
      
    //2
    @objc func keyboardWillShow(_ notification: Notification) {
      adjustInsetForKeyboardShow(true, notification: notification)
    }
    @objc func keyboardWillHide(_ notification: Notification) {
      adjustInsetForKeyboardShow(false, notification: notification)
    }
    
    @IBAction func hideKeyboard(_ sender: AnyObject) {
      //textFieldNazev.endEditing(true)
    //textFieldUmisteni.endEditing(true)
    }
    */
    
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            
            return Images.count//tolik mam zarizeni
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewFirstDeviceSetup
            
            cell.contentView.layer.cornerRadius=20
            print("indexPath.item:\(indexPath.item)")
            print("cellUprostred:\(cellUprostred)")
            if indexPath.item == cellUprostred{
                   
                   cell.contentView.alpha=1.0
                   print("maluju prostredni cell")
                   UIView.animate(withDuration: 1){
                       cell.transform = CGAffineTransform(scaleX: 1.22, y: 1.22)
                    //indexVybranehoObrazku=indexPath.item
                    print("indexVybranehoObrazkuCell:\(indexPath.item)")
                    cell.uiviewOutlet.layer.borderColor=UIColor.white.cgColor
                    cell.uiviewOutlet.layer.borderWidth=2;
                    if indexPath.item==2{
                       self.outletViewSeznam.alpha=1
                        self.outletSwitch.isEnabled=true;
                        self.outletKladnaHystereze.isEnabled=true
                        self.outletZapornaHystereze.isEnabled=true
                        //self.switchTopimChladimOutlet.subviews[0].subviews[0].backgroundColor = .blue
                        self.switchTopimChladimOutlet.subviews[0].subviews[0].backgroundColor = .blue
                        self.outletSwitch.subviews[0].subviews[0].backgroundColor = .red
                    }
                    else {
                       self.outletViewSeznam.alpha=0
                    self.outletSwitch.isEnabled=false
                        self.outletKladnaHystereze.isEnabled=false
                        self.outletZapornaHystereze.isEnabled=false
                }
                }
                indexVybranehoObrazku=indexPath.item
            }
            else{
                cell.contentView.alpha=0.35
                
                cell.uiviewOutlet.layer.borderWidth=0;
                UIView.animate(withDuration: 1){
                    cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)//bylo 1.0
                }
                print("maluju ostatni")
            }
            
            cell.UIImageOutlet.image=UIImage(named: "\(Images[indexPath.item])ON")
            //if indexPath.item==indexVybranehoZarizeni)
            //cell.UIImageOutlet.alpha=0.5
            cell.uiviewOutlet.layer.cornerRadius = 20
            
            
            
            return cell
        }
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewFirstDeviceSetup
            print("klik na ikonu cislo:\(indexPath.item)")
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            //UIView.animate(withDuration: 1){
           //cell.transform = CGAffineTransform(scaleX: 1.22, y: 1.22)
           indexVybranehoObrazku=indexPath.item
                print("indexVybranehoObrazkuDid:\(indexPath.item)")
        cellUprostred=indexPath.item
        collectionView.reloadData()
        
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.alpha=0.35//bylo 0.4
        UIView.animate(withDuration: 0.3){
            cell?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)//bylo 1.0
        
        }
    }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
             
            //let width  = (view.frame.width-60)/3//trojnasobek toho co je nastaveny jako mezera
            let width  = (view.frame.width-40)/2//trojnasobek toho co je nastaveny jako mezera
            return CGSize(width: width, height: width)
        }
        
    
    
    //--------------------------------------------------------
    // MARK: viewDidAppear --------------------------------
    //--------------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        
        let indexPath = IndexPath(row: indexVybranehoObrazku, section: 0)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        cellUprostred=indexVybranehoObrazku
        print("indexVybranehoObrazku v DidiAppear\(indexVybranehoObrazku)")
        //collectionView.reloadData()
        }
        
     override func viewWillAppear(_ animated: Bool) {
         //setGradientBackground()
         super.viewWillAppear(animated)
     }
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
       // print("dismissKeyboard")
        view.endEditing(true)
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
                            self.collectionView.reloadData()
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
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToNearestVisibleCollectionViewCell()
        //print("scrollViewDidEndDecelerating")
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        if !decelerate {
            scrollToNearestVisibleCollectionViewCell()
            //print("scrollViewDidEndDragging")
        }
    }
  
    
        func scrollToNearestVisibleCollectionViewCell() {
            collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
            let visibleCenterPositionOfScrollView = Float(collectionView.contentOffset.x + (collectionView.bounds.size.width / 2))
            var closestCellIndex = -1
            var closestDistance: Float = .greatestFiniteMagnitude
            for i in 0..<collectionView.visibleCells.count {
                let cell = collectionView.visibleCells[i]
                let cellWidth = cell.bounds.size.width
                let cellCenter = Float(cell.frame.origin.x + cellWidth / 2)

                // Now calculate closest cell
                let distance: Float = fabsf(visibleCenterPositionOfScrollView - cellCenter)
                if distance < closestDistance {
                    closestDistance = distance
                    closestCellIndex = collectionView.indexPath(for: cell)!.row
                }
            }
            if closestCellIndex != -1 {
                print("scroluju na stred:\(closestCellIndex) ")
                cellUprostred=closestCellIndex
                collectionView.scrollToItem(at: IndexPath(row: closestCellIndex, section: 0), at: .centeredHorizontally, animated: true)
                collectionView.reloadData()
                
            }
        }
    
}//konec class
      
   
        
    
    

