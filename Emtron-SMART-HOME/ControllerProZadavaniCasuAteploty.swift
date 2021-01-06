//
//  ControllerProZadavaniCasuAteploty.swift
//  Emtron-SMART-HOME
//
//  Created by Ivo Dvorak on 13/11/2019.
//  Copyright © 2019 Ivo Dvorak. All rights reserved.
//


import UIKit
import Foundation
import AudioToolbox
import Socket

var vracimSeZnatsaveniTeploty = false

class ControllerProZadavaniCasuAteploty: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var outletPickerDenVtydnu: UIPickerView!
    var pickerData: [String] = ["Pondělí","Úterý","Středa","Čtvrtek","Pátek","Sobota","Neděle"]
    var pickerHodiny = [String]()
    var pickerMinuty = [String]()
    
    let blurView = UIVisualEffectView()
    let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    @IBOutlet weak var viewSONOFF: UIView!
    
    @IBAction func btnOKdenvTydnuClick(_ sender: Any) {//kopirovani dnu
        if odkudBylSpustenKalendar=="Topeni"
        {
            if DenVtydnu=="Pondeli"{
                
                if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pondělí"){
                    //PondeliSpinaciCasyAteploty.removeAll()
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Úterý"){
                    PondeliSpinaciCasyAteploty.removeAll()
                    PondeliSpinaciCasyAteploty=UterySpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Středa"){
                    PondeliSpinaciCasyAteploty.removeAll()
                    PondeliSpinaciCasyAteploty=StredaSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Čtvrtek"){
                    PondeliSpinaciCasyAteploty.removeAll()
                    PondeliSpinaciCasyAteploty=CtvrtekSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pátek"){
                    PondeliSpinaciCasyAteploty.removeAll()
                    PondeliSpinaciCasyAteploty=PatekSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Sobota"){
                    PondeliSpinaciCasyAteploty.removeAll()
                    PondeliSpinaciCasyAteploty=SobotaSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Neděle"){
                    PondeliSpinaciCasyAteploty.removeAll()
                    PondeliSpinaciCasyAteploty=NedeleSpinaciCasyAteploty
                }
                
            }
            else if DenVtydnu=="Utery"{
                
                if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pondělí"){
                    UterySpinaciCasyAteploty.removeAll()
                    UterySpinaciCasyAteploty=PondeliSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Úterý"){
                    //PondeliSpinaciCasyAteploty.removeAll()
                    //PondeliSpinaciCasyAteploty=UterySpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Středa"){
                    UterySpinaciCasyAteploty.removeAll()
                    UterySpinaciCasyAteploty=StredaSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Čtvrtek"){
                    UterySpinaciCasyAteploty.removeAll()
                    UterySpinaciCasyAteploty=CtvrtekSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pátek"){
                    UterySpinaciCasyAteploty.removeAll()
                    UterySpinaciCasyAteploty=PatekSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Sobota"){
                    UterySpinaciCasyAteploty.removeAll()
                    UterySpinaciCasyAteploty=SobotaSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Neděle"){
                    UterySpinaciCasyAteploty.removeAll()
                    UterySpinaciCasyAteploty=NedeleSpinaciCasyAteploty
                }
            }
            else if DenVtydnu=="Streda"{
                
                if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pondělí"){
                    StredaSpinaciCasyAteploty.removeAll()
                    StredaSpinaciCasyAteploty=PondeliSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Úterý"){
                    StredaSpinaciCasyAteploty.removeAll()
                    StredaSpinaciCasyAteploty=UterySpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Středa"){
                    //UterySpinaciCasyAteploty.removeAll()
                    //UterySpinaciCasyAteploty=StredaSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Čtvrtek"){
                    StredaSpinaciCasyAteploty.removeAll()
                    StredaSpinaciCasyAteploty=CtvrtekSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pátek"){
                    StredaSpinaciCasyAteploty.removeAll()
                    StredaSpinaciCasyAteploty=PatekSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Sobota"){
                    StredaSpinaciCasyAteploty.removeAll()
                    StredaSpinaciCasyAteploty=SobotaSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Neděle"){
                    StredaSpinaciCasyAteploty.removeAll()
                    StredaSpinaciCasyAteploty=NedeleSpinaciCasyAteploty
                }
            }
            else if DenVtydnu=="Ctvrtek"{
                
                if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pondělí"){
                    CtvrtekSpinaciCasyAteploty.removeAll()
                    CtvrtekSpinaciCasyAteploty=PondeliSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Úterý"){
                    CtvrtekSpinaciCasyAteploty.removeAll()
                    CtvrtekSpinaciCasyAteploty=UterySpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Středa"){
                    CtvrtekSpinaciCasyAteploty.removeAll()
                    CtvrtekSpinaciCasyAteploty=StredaSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Čtvrtek"){
                    //StredaSpinaciCasyAteploty.removeAll()
                    //StredaSpinaciCasyAteploty=CtvrtekSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pátek"){
                    CtvrtekSpinaciCasyAteploty.removeAll()
                    CtvrtekSpinaciCasyAteploty=PatekSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Sobota"){
                    CtvrtekSpinaciCasyAteploty.removeAll()
                    CtvrtekSpinaciCasyAteploty=SobotaSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Neděle"){
                    CtvrtekSpinaciCasyAteploty.removeAll()
                    CtvrtekSpinaciCasyAteploty=NedeleSpinaciCasyAteploty
                }
            }
            else if DenVtydnu=="Patek"{
                
                if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pondělí"){
                    PatekSpinaciCasyAteploty.removeAll()
                    PatekSpinaciCasyAteploty=PondeliSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Úterý"){
                    PatekSpinaciCasyAteploty.removeAll()
                    PatekSpinaciCasyAteploty=UterySpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Středa"){
                    PatekSpinaciCasyAteploty.removeAll()
                    PatekSpinaciCasyAteploty=StredaSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Čtvrtek"){
                    PatekSpinaciCasyAteploty.removeAll()
                    PatekSpinaciCasyAteploty=CtvrtekSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pátek"){
                    //CtvrtekSpinaciCasyAteploty.removeAll()
                    //CtvrtekSpinaciCasyAteploty=PatekSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Sobota"){
                    PatekSpinaciCasyAteploty.removeAll()
                    PatekSpinaciCasyAteploty=SobotaSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Neděle"){
                    PatekSpinaciCasyAteploty.removeAll()
                    PatekSpinaciCasyAteploty=NedeleSpinaciCasyAteploty
                }
            }
            else if DenVtydnu=="Sobota"{
                
                if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pondělí"){
                    SobotaSpinaciCasyAteploty.removeAll()
                    SobotaSpinaciCasyAteploty=PondeliSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Úterý"){
                    SobotaSpinaciCasyAteploty.removeAll()
                    SobotaSpinaciCasyAteploty=UterySpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Středa"){
                    SobotaSpinaciCasyAteploty.removeAll()
                    SobotaSpinaciCasyAteploty=StredaSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Čtvrtek"){
                    SobotaSpinaciCasyAteploty.removeAll()
                    SobotaSpinaciCasyAteploty=CtvrtekSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pátek"){
                    SobotaSpinaciCasyAteploty.removeAll()
                    SobotaSpinaciCasyAteploty=PatekSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Sobota"){
                    //PatekSpinaciCasyAteploty.removeAll()
                    //PatekSpinaciCasyAteploty=SobotaSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Neděle"){
                    SobotaSpinaciCasyAteploty.removeAll()
                    SobotaSpinaciCasyAteploty=NedeleSpinaciCasyAteploty
                }
            }
            else if DenVtydnu=="Nedele"{
                
                if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pondělí"){
                    NedeleSpinaciCasyAteploty.removeAll()
                    NedeleSpinaciCasyAteploty=PondeliSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Úterý"){
                    NedeleSpinaciCasyAteploty.removeAll()
                    NedeleSpinaciCasyAteploty=UterySpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Středa"){
                    NedeleSpinaciCasyAteploty.removeAll()
                    NedeleSpinaciCasyAteploty=StredaSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Čtvrtek"){
                    NedeleSpinaciCasyAteploty.removeAll()
                    NedeleSpinaciCasyAteploty=CtvrtekSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pátek"){
                    NedeleSpinaciCasyAteploty.removeAll()
                    NedeleSpinaciCasyAteploty=PatekSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Sobota"){
                    NedeleSpinaciCasyAteploty.removeAll()
                    NedeleSpinaciCasyAteploty=SobotaSpinaciCasyAteploty
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Neděle"){
                    //SobotaSpinaciCasyAteploty.removeAll()
                    //SobotaSpinaciCasyAteploty=NedeleSpinaciCasyAteploty
                }
            }
            
        }
        else if odkudBylSpustenKalendar=="Svetlo"{
            if DenVtydnu=="Pondeli"{
                
                if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pondělí"){
                    //PondeliSpinaciCasy.removeAll()
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Úterý"){
                    PondeliSpinaciCasy.removeAll()
                    PondeliSpinaciCasy=UterySpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Středa"){
                    PondeliSpinaciCasy.removeAll()
                    PondeliSpinaciCasy=StredaSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Čtvrtek"){
                    PondeliSpinaciCasy.removeAll()
                    PondeliSpinaciCasy=CtvrtekSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pátek"){
                    PondeliSpinaciCasy.removeAll()
                    PondeliSpinaciCasy=PatekSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Sobota"){
                    PondeliSpinaciCasy.removeAll()
                    PondeliSpinaciCasy=SobotaSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Neděle"){
                    PondeliSpinaciCasy.removeAll()
                    PondeliSpinaciCasy=NedeleSpinaciCasy
                }
                
            }
            else if DenVtydnu=="Utery"{
                
                if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pondělí"){
                    UterySpinaciCasy.removeAll()
                    UterySpinaciCasy=PondeliSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Úterý"){
                    //PondeliSpinaciCasy.removeAll()
                    //PondeliSpinaciCasy=UterySpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Středa"){
                    UterySpinaciCasy.removeAll()
                    UterySpinaciCasy=StredaSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Čtvrtek"){
                    UterySpinaciCasy.removeAll()
                    UterySpinaciCasy=CtvrtekSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pátek"){
                    UterySpinaciCasy.removeAll()
                    UterySpinaciCasy=PatekSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Sobota"){
                    UterySpinaciCasy.removeAll()
                    UterySpinaciCasy=SobotaSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Neděle"){
                    UterySpinaciCasy.removeAll()
                    UterySpinaciCasy=NedeleSpinaciCasy
                }
            }
            else if DenVtydnu=="Streda"{
                
                if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pondělí"){
                    StredaSpinaciCasy.removeAll()
                    StredaSpinaciCasy=PondeliSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Úterý"){
                    StredaSpinaciCasy.removeAll()
                    StredaSpinaciCasy=UterySpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Středa"){
                    //UterySpinaciCasy.removeAll()
                    //UterySpinaciCasy=StredaSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Čtvrtek"){
                    StredaSpinaciCasy.removeAll()
                    StredaSpinaciCasy=CtvrtekSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pátek"){
                    StredaSpinaciCasy.removeAll()
                    StredaSpinaciCasy=PatekSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Sobota"){
                    StredaSpinaciCasy.removeAll()
                    StredaSpinaciCasy=SobotaSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Neděle"){
                    StredaSpinaciCasy.removeAll()
                    StredaSpinaciCasy=NedeleSpinaciCasy
                }
            }
            else if DenVtydnu=="Ctvrtek"{
                
                if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pondělí"){
                    CtvrtekSpinaciCasy.removeAll()
                    CtvrtekSpinaciCasy=PondeliSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Úterý"){
                    CtvrtekSpinaciCasy.removeAll()
                    CtvrtekSpinaciCasy=UterySpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Středa"){
                    CtvrtekSpinaciCasy.removeAll()
                    CtvrtekSpinaciCasy=StredaSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Čtvrtek"){
                    //StredaSpinaciCasy.removeAll()
                    //StredaSpinaciCasy=CtvrtekSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pátek"){
                    CtvrtekSpinaciCasy.removeAll()
                    CtvrtekSpinaciCasy=PatekSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Sobota"){
                    CtvrtekSpinaciCasy.removeAll()
                    CtvrtekSpinaciCasy=SobotaSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Neděle"){
                    CtvrtekSpinaciCasy.removeAll()
                    CtvrtekSpinaciCasy=NedeleSpinaciCasy
                }
            }
            else if DenVtydnu=="Patek"{
                
                if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pondělí"){
                    PatekSpinaciCasy.removeAll()
                    PatekSpinaciCasy=PondeliSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Úterý"){
                    PatekSpinaciCasy.removeAll()
                    PatekSpinaciCasy=UterySpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Středa"){
                    PatekSpinaciCasy.removeAll()
                    PatekSpinaciCasy=StredaSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Čtvrtek"){
                    PatekSpinaciCasy.removeAll()
                    PatekSpinaciCasy=CtvrtekSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pátek"){
                    //CtvrtekSpinaciCasy.removeAll()
                    //CtvrtekSpinaciCasy=PatekSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Sobota"){
                    PatekSpinaciCasy.removeAll()
                    PatekSpinaciCasy=SobotaSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Neděle"){
                    PatekSpinaciCasy.removeAll()
                    PatekSpinaciCasy=NedeleSpinaciCasy
                }
            }
            else if DenVtydnu=="Sobota"{
                
                if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pondělí"){
                    SobotaSpinaciCasy.removeAll()
                    SobotaSpinaciCasy=PondeliSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Úterý"){
                    SobotaSpinaciCasy.removeAll()
                    SobotaSpinaciCasy=UterySpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Středa"){
                    SobotaSpinaciCasy.removeAll()
                    SobotaSpinaciCasy=StredaSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Čtvrtek"){
                    SobotaSpinaciCasy.removeAll()
                    SobotaSpinaciCasy=CtvrtekSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pátek"){
                    SobotaSpinaciCasy.removeAll()
                    SobotaSpinaciCasy=PatekSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Sobota"){
                    //PatekSpinaciCasy.removeAll()
                    //PatekSpinaciCasy=SobotaSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Neděle"){
                    SobotaSpinaciCasy.removeAll()
                    SobotaSpinaciCasy=NedeleSpinaciCasy
                }
            }
            else if DenVtydnu=="Nedele"{
                
                if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pondělí"){
                    NedeleSpinaciCasy.removeAll()
                    NedeleSpinaciCasy=PondeliSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Úterý"){
                    NedeleSpinaciCasy.removeAll()
                    NedeleSpinaciCasy=UterySpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Středa"){
                    NedeleSpinaciCasy.removeAll()
                    NedeleSpinaciCasy=StredaSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Čtvrtek"){
                    NedeleSpinaciCasy.removeAll()
                    NedeleSpinaciCasy=CtvrtekSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Pátek"){
                    NedeleSpinaciCasy.removeAll()
                    NedeleSpinaciCasy=PatekSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Sobota"){
                    NedeleSpinaciCasy.removeAll()
                    NedeleSpinaciCasy=SobotaSpinaciCasy
                }
                else if (pickerData[outletPickerDenVtydnu.selectedRow(inComponent: 0)]=="Neděle"){
                    //SobotaSpinaciCasy.removeAll()
                    //SobotaSpinaciCasy=NedeleSpinaciCasy
                }
            }
            
        }
        odesliNastaveniKalendareDoModulu()
        print("Odesilam nastaveni kalendare po kopirovani")
        vracimSeZnatsaveniTeploty=true//aby to ted nevycitalo zbytecne zase nastaveni z modulu
        //self.performSegue(withIdentifier: "NavratNaKalendar", sender: Any?.self)
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var outletViewCalendar: UIView!
    @IBAction func ButtonKopirujDenClick(_ sender: Any) {
        blurView.frame = view.frame
        blurView.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        view.addSubview(blurView)
        outletViewCalendar.alpha=1;
        view.addSubview(outletViewCalendar)
    }
    @IBOutlet weak var OutletButtonKopirujDen: UIButton!
    @IBOutlet weak var outletViewScasem: UIView!
    var seznamNaPickeru = [String]()
    //var time="10:00"
    var hodiny=12
    var minuty=0
    
    @IBOutlet weak var pickerProZadavaniTeploty: UIPickerView!
    @IBOutlet weak var pickerScasem: UIPickerView!
    
    @IBOutlet weak var pickerSminutami: UIPickerView!
    @IBOutlet weak var outletNadPicker: UILabel!
    
    /*
     @IBAction func dataPickerTimeChange(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"//this your string date format
        let strDate = dateFormatter.string(from: pickerScasem.date)
        time=strDate
        print("cas:\(strDate)")
        
    }
    */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let touch = touches.first
        guard let location = touch?.location(in: self.view) else { return }
        if !outletViewCalendar.frame.contains(location) {
            print("Tapped outside the view AA")
            outletViewCalendar.alpha=0
            blurView.removeFromSuperview()
        } else {
            print("Tapped inside the view AA")
        }
        
        
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        notificationFeedbackGenerator.notificationOccurred(.success)
    }
    //
    // Number of columns of data
    
    
    
    
    @IBAction func btnOKclick(_ sender: Any) {
        if odkudBylSpustenKalendar=="Topeni"{
            if DenVtydnu=="Pondeli"{
                PondeliSpinaciCasyAteploty.append(["\(pickerHodiny[pickerScasem.selectedRow(inComponent: 0)]):\(pickerMinuty[pickerSminutami.selectedRow(inComponent: 0)])",seznamNaPickeru[pickerProZadavaniTeploty.selectedRow(inComponent: 0)]])
            }
            else if DenVtydnu=="Utery"{
                UterySpinaciCasyAteploty.append(["\(pickerHodiny[pickerScasem.selectedRow(inComponent: 0)]):\(pickerMinuty[pickerSminutami.selectedRow(inComponent: 0)])",seznamNaPickeru[pickerProZadavaniTeploty.selectedRow(inComponent: 0)]])
            }
            else if DenVtydnu=="Streda"{
                StredaSpinaciCasyAteploty.append(["\(pickerHodiny[pickerScasem.selectedRow(inComponent: 0)]):\(pickerMinuty[pickerSminutami.selectedRow(inComponent: 0)])",seznamNaPickeru[pickerProZadavaniTeploty.selectedRow(inComponent: 0)]])
            }
            else if DenVtydnu=="Ctvrtek"{
                CtvrtekSpinaciCasyAteploty.append(["\(pickerHodiny[pickerScasem.selectedRow(inComponent: 0)]):\(pickerMinuty[pickerSminutami.selectedRow(inComponent: 0)])",seznamNaPickeru[pickerProZadavaniTeploty.selectedRow(inComponent: 0)]])
            }
            else if DenVtydnu=="Patek"{
                PatekSpinaciCasyAteploty.append(["\(pickerHodiny[pickerScasem.selectedRow(inComponent: 0)]):\(pickerMinuty[pickerSminutami.selectedRow(inComponent: 0)])",seznamNaPickeru[pickerProZadavaniTeploty.selectedRow(inComponent: 0)]])
            }
            else if DenVtydnu=="Sobota"{
                SobotaSpinaciCasyAteploty.append(["\(pickerHodiny[pickerScasem.selectedRow(inComponent: 0)]):\(pickerMinuty[pickerSminutami.selectedRow(inComponent: 0)])",seznamNaPickeru[pickerProZadavaniTeploty.selectedRow(inComponent: 0)]])
            }
            else if DenVtydnu=="Nedele"{
                NedeleSpinaciCasyAteploty.append(["\(pickerHodiny[pickerScasem.selectedRow(inComponent: 0)]):\(pickerMinuty[pickerSminutami.selectedRow(inComponent: 0)])",seznamNaPickeru[pickerProZadavaniTeploty.selectedRow(inComponent: 0)]])
            }
        }
        if odkudBylSpustenKalendar=="Svetlo"{
            if DenVtydnu=="Pondeli"{
                PondeliSpinaciCasy.append(["\(pickerHodiny[pickerScasem.selectedRow(inComponent: 0)]):\(pickerMinuty[pickerSminutami.selectedRow(inComponent: 0)])",seznamNaPickeru[pickerProZadavaniTeploty.selectedRow(inComponent: 0)]])
            }
            else if DenVtydnu=="Utery"{
                UterySpinaciCasy.append(["\(pickerHodiny[pickerScasem.selectedRow(inComponent: 0)]):\(pickerMinuty[pickerSminutami.selectedRow(inComponent: 0)])",seznamNaPickeru[pickerProZadavaniTeploty.selectedRow(inComponent: 0)]])
            }
            else if DenVtydnu=="Streda"{
                StredaSpinaciCasy.append(["\(pickerHodiny[pickerScasem.selectedRow(inComponent: 0)]):\(pickerMinuty[pickerSminutami.selectedRow(inComponent: 0)])",seznamNaPickeru[pickerProZadavaniTeploty.selectedRow(inComponent: 0)]])
            }
            else if DenVtydnu=="Ctvrtek"{
                CtvrtekSpinaciCasy.append(["\(pickerHodiny[pickerScasem.selectedRow(inComponent: 0)]):\(pickerMinuty[pickerSminutami.selectedRow(inComponent: 0)])",seznamNaPickeru[pickerProZadavaniTeploty.selectedRow(inComponent: 0)]])
            }
            else if DenVtydnu=="Patek"{
                PatekSpinaciCasy.append(["\(pickerHodiny[pickerScasem.selectedRow(inComponent: 0)]):\(pickerMinuty[pickerSminutami.selectedRow(inComponent: 0)])",seznamNaPickeru[pickerProZadavaniTeploty.selectedRow(inComponent: 0)]])
            }
            else if DenVtydnu=="Sobota"{
                SobotaSpinaciCasy.append(["\(pickerHodiny[pickerScasem.selectedRow(inComponent: 0)]):\(pickerMinuty[pickerSminutami.selectedRow(inComponent: 0)])",seznamNaPickeru[pickerProZadavaniTeploty.selectedRow(inComponent: 0)]])
            }
            else if DenVtydnu=="Nedele"{
                NedeleSpinaciCasy.append(["\(pickerHodiny[pickerScasem.selectedRow(inComponent: 0)]):\(pickerMinuty[pickerSminutami.selectedRow(inComponent: 0)])",seznamNaPickeru[pickerProZadavaniTeploty.selectedRow(inComponent: 0)]])
            }
        }
        if PondeliSpinaciCasyAteploty.count>0{
        PondeliSpinaciCasyAteploty.sort(by: {$0[0] < $1[0] })//seradi pole
        PondeliSpinaciCasyAteploty.remove(at: 0)//smaze plusko
        PondeliSpinaciCasyAteploty.append(["",""])//prida plusko na konec
        }
        if UterySpinaciCasyAteploty.count>0{
        UterySpinaciCasyAteploty.sort(by: {$0[0] < $1[0] })
        UterySpinaciCasyAteploty.remove(at: 0)
        UterySpinaciCasyAteploty.append(["",""])
        }
        if StredaSpinaciCasyAteploty.count>0{
        StredaSpinaciCasyAteploty.sort(by: {$0[0] < $1[0] })
        StredaSpinaciCasyAteploty.remove(at: 0)
        StredaSpinaciCasyAteploty.append(["",""])
            
        }
        if CtvrtekSpinaciCasyAteploty.count>0{
        CtvrtekSpinaciCasyAteploty.sort(by: {$0[0] < $1[0] })
        CtvrtekSpinaciCasyAteploty.remove(at: 0)
        CtvrtekSpinaciCasyAteploty.append(["",""])
        }
        if PatekSpinaciCasyAteploty.count>0{
        PatekSpinaciCasyAteploty.sort(by: {$0[0] < $1[0] })
        PatekSpinaciCasyAteploty.remove(at: 0)
        PatekSpinaciCasyAteploty.append(["",""])
        }
        if SobotaSpinaciCasyAteploty.count>0{
        SobotaSpinaciCasyAteploty.sort(by: {$0[0] < $1[0] })
        SobotaSpinaciCasyAteploty.remove(at: 0)
        SobotaSpinaciCasyAteploty.append(["",""])
        }
        if NedeleSpinaciCasyAteploty.count>0{
        NedeleSpinaciCasyAteploty.sort(by: {$0[0] < $1[0] })
        NedeleSpinaciCasyAteploty.remove(at: 0)
        NedeleSpinaciCasyAteploty.append(["",""])
        }
        if PondeliSpinaciCasy.count>0{
        PondeliSpinaciCasy.sort(by: {$0[0] < $1[0] })//seradi pole
        PondeliSpinaciCasy.remove(at: 0)//smaze plusko
        PondeliSpinaciCasy.append(["",""])//prida plusko na konec
        }
        if UterySpinaciCasy.count>0{
        UterySpinaciCasy.sort(by: {$0[0] < $1[0] })
        UterySpinaciCasy.remove(at: 0)
        UterySpinaciCasy.append(["",""])
        }
        if StredaSpinaciCasy.count>0{
        StredaSpinaciCasy.sort(by: {$0[0] < $1[0] })
        StredaSpinaciCasy.remove(at: 0)
        StredaSpinaciCasy.append(["",""])
        }
        if CtvrtekSpinaciCasy.count>0{
        CtvrtekSpinaciCasy.sort(by: {$0[0] < $1[0] })
        CtvrtekSpinaciCasy.remove(at: 0)
        CtvrtekSpinaciCasy.append(["",""])
        }
        if PatekSpinaciCasy.count>0{
        PatekSpinaciCasy.sort(by: {$0[0] < $1[0] })
        PatekSpinaciCasy.remove(at: 0)
        PatekSpinaciCasy.append(["",""])
        }
        if SobotaSpinaciCasy.count>0{
        SobotaSpinaciCasy.sort(by: {$0[0] < $1[0] })
        SobotaSpinaciCasy.remove(at: 0)
        SobotaSpinaciCasy.append(["",""])
        }
        if NedeleSpinaciCasy.count>0{
        NedeleSpinaciCasy.sort(by: {$0[0] < $1[0] })
        NedeleSpinaciCasy.remove(at: 0)
        NedeleSpinaciCasy.append(["",""])
        }
        
        
        
        odesliNastaveniKalendareDoModulu()
        vracimSeZnatsaveniTeploty=true//aby to ted nevycitalo zbytecne zase nastaveni z modulu
        //self.performSegue(withIdentifier: "NavratNaKalendar", sender: Any?.self)
        self.dismiss(animated: true, completion: nil)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)

            if let firstVC = presentingViewController as? TemperatureCalnedarController {
                DispatchQueue.main.async {
                    firstVC.collectionViewOutlet.reloadData()
                }
            }
        }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
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
            }
        }
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
            //zpracujTCPdata()
        }
        else {
            print("Error decoding response ...")
            return
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {//POCET VALCU V PICKERU
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {//POCET HODNOT V PICKERU
        if pickerView.tag == 0 {
            return pickerHodiny.count
            
        }
        if pickerView.tag == 3 {
            return pickerMinuty.count
            
        }
        if pickerView.tag == 1 {
            return seznamNaPickeru.count
            
        }
        else if pickerView.tag == 2 {
            return pickerData.count
            
        }
        else {return 0}
    }

        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let pickerLabel: UILabel
            if let label = view as? UILabel {
                pickerLabel = label
            } else {
                pickerLabel = UILabel()
                pickerLabel.textAlignment = .center
                pickerLabel.font = UIFont.boldSystemFont(ofSize: 28)
                pickerLabel.adjustsFontSizeToFitWidth = true
                pickerLabel.minimumScaleFactor = 0.5
            }
            if pickerView.tag == 1 {
                if odkudBylSpustenKalendar=="Topeni"{
                    pickerLabel.text = "\(seznamNaPickeru[row])°C"
                }
                else if odkudBylSpustenKalendar=="Svetlo"{
                    pickerLabel.text = "\(seznamNaPickeru[row])"
                }
                
            }
            else if pickerView.tag == 2 {
                pickerLabel.text = pickerData[row]
            }
            else if pickerView.tag == 0 {
                pickerLabel.text = pickerHodiny[row]
            }
            else if pickerView.tag == 3 {
                pickerLabel.text = pickerMinuty[row]
            }
            //pickerLabel.text = pickerData[row] //This is your string
            return pickerLabel
        }
        
        
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        pickerScasem.reloadInputViews()
        outletPickerDenVtydnu.selectRow(3, inComponent: 0, animated: false)
        pickerScasem.selectRow(hodiny, inComponent: 0, animated: true)
        pickerSminutami.selectRow(minuty, inComponent: 0, animated: true)
    }
    
    func currentTime() {
        let date = Date()
         let calendar = Calendar.current
         hodiny = calendar.component(.hour, from: date)
         minuty = calendar.component(.minute, from: date)
         
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerHodiny=["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23"]
        pickerMinuty=["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59"]
        outletViewCalendar.layer.cornerRadius=20
        outletViewScasem.layer.cornerRadius=20
        OutletButtonKopirujDen.layer.cornerRadius=20
        viewSONOFF.layer.cornerRadius=20
        if odkudBylSpustenKalendar=="Topeni"{
            outletNadPicker.text="Zvolte teplotu"
            for citac in 0..<((maximalniTeplota-minimalniTeplota)*2)+1 {
                print(Double(citac)*0.5)//tohle naplni pole na picker datama
                seznamNaPickeru.append("\(Double(citac)*0.5+Double(minimalniTeplota))")
            }
        }
        pickerProZadavaniTeploty.selectRow((maximalniTeplota-minimalniTeplota), inComponent: 0, animated: true)
        if odkudBylSpustenKalendar=="Svetlo"{
            outletNadPicker.text="Vyberte požadovaný stav"
            seznamNaPickeru.append("ON")
            seznamNaPickeru.append("OFF")
        }
        currentTime()//nastavi aktualni cas
        print("aktualni cas v did load:\(hodiny):\(minuty)")
        //pickerScasem.setValue(<#T##value: Any?##Any?#>, forKey: <#T##String#>)
        
        //setGradientBackground()
    }
    
    
}//konec class

