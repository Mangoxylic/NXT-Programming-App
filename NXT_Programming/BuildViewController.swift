//
//  BuildViewController.swift
//  NXT_Programming
//
//  Created by Alina Sun on 10/26/17.
//  Copyright © 2017 LA's BEST. All rights reserved.
//

import UIKit
import SocketIO

protocol TableDelegate {
    func initializeTable(selectedIndex: Int, macAddressArray: Array<String>)
}

protocol CollectionDelegate {
    func sendEventToCollectionView()
}

class BrickObject{
    var type: String!
    init(typeObj: String){
        type = typeObj;
    }
}
class MotorObject : BrickObject {
    var speed: Int = 0
    var rotations: Int = 0
    var brake: Bool = true
    var port: String = ""
    
    init(ty: String) {
        super.init(typeObj: ty)
    }
    
    func setSpeed(newSpeed: Int){ speed = newSpeed }
    func setRotations(newRot: Int){ rotations = newRot }
    func setBrake(newBrake: Bool){ brake = newBrake }
    func setPort(newPort: String){port = newPort }
    func getSpeed()->Int{ return speed }
    func getRotations()->Int{ return rotations }
    func getBrake()->Bool{ return brake }
}

class DisplayObject : BrickObject{
    var clear: Bool = true
    var xLoc: Int = 0
    var yLoc: Int = 0
    
    init(ty: String) {
        super.init(typeObj: ty)
    }
    
    func setClear(newClear: Bool){ clear = newClear }
    func setX(x: Int){ xLoc = x }
    func setY(y: Int){ yLoc = y }
    func getClear()->Bool{ return clear }
    func getXLoc()->Int{ return xLoc }
    func getYLoc()->Int{ return yLoc }
}
class SoundObject : BrickObject {
    var volume: Int = 0
    var typeSound: String = ""
    var duration: Int = 0
    
    init(ty: String) {
        super.init(typeObj: ty)
    }
    
    func setVolume(newVol: Int){volume = newVol}
    func setTypeSound(newType: String){typeSound = newType}
    func getVolume()->Int{return volume}
    func getTypeSound()->String{return typeSound}
    func setDuration(newDur: Int){duration = newDur}
    
}
class WaitObject : BrickObject{
    var time: Int = 0
    
    init(ty: String){
        super.init(typeObj: ty)
    }
    
    func setTime(newTime: Int){time = newTime}
    func getTime()->Int{return time}
}

class StartLoopObject : BrickObject {
    var loops: Int = 0
    var sensor: String = ""
    var param: Int = 0
    var port: String = ""
    
    var sensorType: String = ""
    var checkAmount: Int = 0
    
    init(ty: String) {
        super.init(typeObj: ty)
    }
    
    func setLoops(newLoops: Int){ loops = newLoops }
    func getLoops()->Int{ return loops }
    func setSensor(newSensor: String){sensor = newSensor }
    func getSensor()->String{return sensor}
    func setParam(newParam: Int){param = newParam}
    func getParam()->Int{return param}
    func setPort(newPort: String){port = newPort}
    func getPort()->String{return port}
}

class EndLoopObject : BrickObject {
    init(ty: String) {
        super.init(typeObj: ty)
    }
}

class SteerObject : BrickObject {
    var brake: Bool = true
    var power: Int = 0
    var revolutions: Int = 0
    var leadport: String = "B"
    var followport: String = "C"
    var turnratio: Int = 0
    
    init(ty: String) {
        super.init(typeObj: ty)
    }
    
    func getBrake()->Bool{ return brake }
    func getPower()->Int{ return power}
    func getRevolutions()->Int{ return revolutions }
    func getLeadPort()->String{ return leadport}
    func getFollowPort()->String{ return followport }
    func getTurnRatio()->Int{ return turnratio }
    
    func setBrake(newBrake: Bool){ brake = newBrake }
    func setPower(newPower: Int){ power = newPower }
    func setRevolutions(newRev: Int){ revolutions = newRev }
    func setLeadPort(newLP: String){ leadport = newLP}
    func setFollowPort(newFP: String){ followport = newFP }
    func setTurnRatio(newTurnRatio: Int){ turnratio = newTurnRatio }
}

class BuildViewController: UIViewController, AddressDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate {
    
    
    
    @IBOutlet weak var mediumMotorButtonUI: UIButton!
    @IBOutlet weak var largeMotorButtonUI: UIButton!
    @IBOutlet weak var moveSteeringButtonUI: UIButton!
    @IBOutlet weak var moveTankButtonUI: UIButton!
    @IBOutlet weak var soundButtonUI: UIButton!
    @IBOutlet weak var SteerButtonUI: UIButton!
    @IBOutlet weak var idLabel: UILabel!
    
    //Color UI
    let PrimaryOrange = UIColor(red:0.95, green:0.40, blue:0.19, alpha:1.0)
    let PrimaryRed = UIColor(red:0.84, green:0.20, blue:0.19, alpha:1.0)
    let PrimaryBlue = UIColor(red:0.22, green:0.53, blue:0.59, alpha:1.0)
    let PrimaryBlack = UIColor(red:0.21, green:0.21, blue:0.19, alpha:1.0)
    let PrimaryGold = UIColor(red:0.98, green:0.74, blue:0.24, alpha:1.0)
    
    var scrollView: UIScrollView! = nil
    let startButton = UIButton()
    var startPoint = CGPoint()
    var nextPoint = CGPoint()
    
    var sendJSON = UIButton();
    var customizeBrick = UIButton();
    
    var tabOne = UIButton();
    var tabTwo = UIButton();
    
    var medMotorView = UIView()
    var largeMotorView = UIView()
    var displayView = UIView()
    var soundView = UIView()
    var waitView = UIView()
    var startLoopView = UIView()
    var endLoopView = UIView()
    var steerView = UIView()
    var viewSequence = [UIView]()
    
    var speedInputView = UIView()
    
    let speedMotorLabel = UILabel()
    let rotationsMotorLabel = UILabel()
    let brakeMotorLabel = UILabel()
    let portMotorLabel = UILabel()
    
    let speedMM = UILabel()
    let rotationMM = UILabel()
    let brakeMM = UILabel()
    let loops = UILabel()
    let time = UILabel()
    let brakeS = UILabel()
    let powerS = UILabel()
    let revolutions = UILabel()
    let leadport = UILabel()
    let followport = UILabel()
    let turnratio = UILabel()
    var objectSequence = [BrickObject]()
    
    var testButton = UIButton()
    
    var address = ""
    
    // MARK: Variables Erick added
    let client = Client.sharedInstance
    
    var tableDelegate: TableDelegate?
    var macAddressArray: Array<String> = [] // Used to reload tableView
    var chosenMacAddress: String = "" // The MAC address that the app will "build" to
    var chosenMacAddressIndex: Int = -1 // Also used to reload the tableView
    
    // Variables to modify from the StartupViewController
    var isNewProgram: Bool?
    var programName: String = ""
    var programJSON: String = ""
    var realmID: String = ""
    
    var commandsArray: Array<Dictionary<String, Any>> = []
    
    var collectionDelegate: CollectionDelegate?
    
    //Picker View stuff
    var picker = UIPickerView()
    var sensorOptions: [String] = [String]()
    var compOptions: [String] = [String]()
    var portOptions: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create the scroll view
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 200, width: view.frame.width, height: 240))
        scrollView.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        scrollView.contentSize = CGSize(width: view.bounds.size.width * 100, height: 240)
        self.view.addSubview(scrollView)
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = false
        //End scroll view stuff
        
        createStartButton()
        medMotorView = createMedMotor()
        soundView = createSound()
        waitView = createWait()
        startLoopView = createStartLoop()
        endLoopView = createEndLoop()
        steerView = createSteer()
        
        //        sendJSON = createButton(title: "send", _x: 700, _y: 700, _width: 120, _height: 80)
        //        sendJSON.addTarget(self, action: #selector(sendToServer), for: UIControlEvents.touchUpInside)
        //        self.view.addSubview(sendJSON)
        
        testButton = createButton(title: "test", _x: 500, _y: 100, _width: 100, _height: 100)
        testButton.addTarget(self, action: #selector(test), for: UIControlEvents.touchUpInside)
        self.view.addSubview(testButton)
        createTabs()
        loadViewTabOne()
        
        picker = UIPickerView(frame: CGRect(x: 250, y: 250, width: 400, height: 200))
        picker.backgroundColor = UIColor.white
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
    
        self.picker.delegate = self
        self.picker.dataSource = self
        sensorOptions = ["Touched", "Not touched", "Sound", "Light", "Ultrasonic"]
        compOptions = [">", "<", "==", "!=", ">=", "<="]
        portOptions = ["Port A", "Port B", "Port C", "Port 1", "Port 2", "Port 3"]
        
        //view.addSubview(picker)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch != nil && touch.view!.isKind(of: UISlider)){
            return false
        }
        return true
    }
    /*
     PICKER VIEW STUFF
 
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 0){
            return sensorOptions.count
        } else if(component == 1) {
            return compOptions.count
        } else {
            return portOptions.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (component == 0){
            return sensorOptions[row]
        } else if(component == 1) {
            return compOptions[row]
        } else {
            return portOptions[row]
        }
    }
    
    func displayPicker(){
        
        self.picker.isHidden = false
    }
    
    func donePicker(){
        self.picker.isHidden = true
        print("\(picker.selectedRow(inComponent: 0))")
    }
    
    /**
     * functions to do UI buttons (replacing, creating, dragging and
     */
    
    func createTabButton(type: String, _x: Int, _y: Int) -> UIButton {
        let button = UIButton()
        button.frame = CGRect(x: _x, y: _y, width: 96, height: 40)
        button.setTitle(type, for: UIControlState())
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = PrimaryOrange
        button.layer.borderColor = PrimaryOrange.cgColor
        button.layer.borderWidth = 1.2
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.tag = 1
        self.view.addSubview(button)
        return button
    }
    
    func createStartButton(){
        startButton.frame = CGRect(x: 0, y: 20, width: 125, height: 100)
        startButton.setTitle("start", for: UIControlState())
//        startButton.addTarget(self, action: #selector(dragStart(control:event:)), for: UIControlEvents.touchDragExit)
        startButton.layer.borderColor = PrimaryOrange.cgColor
        startButton.backgroundColor = PrimaryOrange
        startButton.layer.borderWidth = 1.2
        startButton.layer.cornerRadius = 5
        startButton.layer.masksToBounds = true
        startButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        startButton.tag = 1
        startPoint = startButton.frame.origin
        self.scrollView.addSubview(startButton)
        nextPoint = startPoint
        nextPoint.x = nextPoint.x + 128
        startButton.addTarget(self, action: #selector(test), for: UIControlEvents.touchUpInside)
    }
    
    func dragStart(control: UIControl, event: UIEvent) {
        print("in drag")
        if let center = event.allTouches?.first?.location(in: self.view) {
            control.center = center
        }
        startPoint = startButton.frame.origin
    }
    
    func createButton(title: String, _x: Int, _y: Int, _width: Int, _height: Int)->UIButton{
        let button = UIButton()
        button.frame = CGRect(x: _x, y: _y, width: _width, height: _height)
        button.setTitle(title, for: UIControlState())
        button.backgroundColor = UIColor.clear
        //button.layer.borderColor = PrimaryOrange.cgColor
        //button.layer.borderWidth = 1.2
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.setTitleColor(PrimaryOrange, for: UIControlState.normal)
        return button;
    }
    
    func createMedMotor()->UIView{
        let tempView = UIView()
        tempView.backgroundColor = UIColor.clear
        tempView.layer.borderColor = PrimaryOrange.cgColor
        tempView.layer.borderWidth = 1.2
        tempView.layer.cornerRadius = 5
        tempView.layer.masksToBounds = true
        tempView.frame = CGRect(x: 25, y: 525, width: 120, height: 160)
        
        var speedButton = UIButton()
        speedButton = createButton(title: "", _x: 0, _y: 80, _width: 35, _height: 40);
        speedButton.setImage(UIImage(named:"speed"), for: UIControlState.normal)
        
        var rotationButton = UIButton();
        rotationButton = createButton(title: "", _x: 40, _y: 80, _width: 35, _height: 40)
        rotationButton.setImage(UIImage(named:"rotate"), for: UIControlState.normal)
        
        var brakeButton = UIButton();
        brakeButton = createButton(title: "", _x: 80, _y: 80, _width: 35, _height: 40)
        brakeButton.setImage(UIImage(named:"brake"), for: UIControlState.normal)
        
        var deleteButton = UIButton();
        deleteButton = createButton(title: "", _x: 95, _y: 0, _width: 20, _height: 30)
        deleteButton.setImage(UIImage(named:"trash"), for: UIControlState.normal)
        
        var portButton = UIButton();
        portButton = createButton(title: "", _x: 0, _y: 120, _width: 35, _height: 40)
        portButton.setImage(UIImage(named:"port"), for: UIControlState.normal)
        
        let name = UILabel()
        name.frame = CGRect(x: 0, y: 0, width: 120, height: 40)
        name.text = "Motor"
        name.textColor = PrimaryOrange
        name.textAlignment = .center
        
//        let speedLabel = UILabel()
//        speedLabel.frame = CGRect(x: 0, y: 40, width: 120, height: 40)
//        speedLabel.text = "50"
//
//        let rotationsLabel = UILabel()
//        rotationsLabel.frame = CGRect(x: 30, y: 40, width: 120, height: 40)
//        rotationsLabel.text = "5"
//
//        let brakeLabel = UILabel()
//        brakeLabel.frame = CGRect(x: 60, y: 40, width: 120, height: 40)
//        brakeLabel.text = "true"
//
//        let portLabel = UILabel()
//        portLabel.frame = CGRect(x: 90, y: 40, width: 120, height: 40)
//        portLabel.text = "A"
        
        var panGesture = UIPanGestureRecognizer()
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedViewMM(_:)))
        tempView.isUserInteractionEnabled = true
        tempView.addGestureRecognizer(panGesture)
        
        speedButton.addTarget(self, action: #selector(speedAlertMotor(sender:event:)), for: UIControlEvents.touchUpInside)
        rotationButton.addTarget(self, action: #selector(rotationsAlertMotor(sender:event:)), for: UIControlEvents.touchUpInside)
        brakeButton.addTarget(self, action: #selector(brakeAlertMotor(sender:event:)), for: UIControlEvents.touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteBlock(sender:event:)), for: UIControlEvents.touchUpInside)
        portButton.addTarget(self, action: #selector(portAlertMotor(sender:event:)), for: UIControlEvents.touchUpInside)
        tempView.addSubview(name)
        tempView.addSubview(speedButton)
        tempView.addSubview(rotationButton)
        tempView.addSubview(brakeButton)
        tempView.addSubview(deleteButton)
        tempView.addSubview(portButton)
//        tempView.addSubview(speedLabel)
//        tempView.addSubview(rotationsLabel)
//        tempView.addSubview(brakeLabel)
//        tempView.addSubview(portLabel)
        self.view.addSubview(tempView)
        
        return tempView
    }
    
    //Update the frequency here
    func frequencyChange(_ sender: UISlider){
        let labels = self.getLabelsInView(view: self.soundView)
        print("End")
        if labels.count == 5 {
            labels[3].text = "\(Int(sender.value))"
        }
    }
    
    //Update the frequency here
    func durationChange(_ sender: UISlider){
        let labels = self.getLabelsInView(view: self.soundView)
        if labels.count == 5 {
            labels[4].text = "\(Int(sender.value))"
        }
    }

    func createSound()->UIView{
        let tempView = UIView()
        tempView.backgroundColor = UIColor.clear
        tempView.layer.borderColor = PrimaryOrange.cgColor
        tempView.layer.borderWidth = 1.2
        tempView.layer.cornerRadius = 5
        tempView.layer.masksToBounds = true
        tempView.frame = CGRect(x: 295, y: 525, width: 120, height: 160)
        
        let volumeSlider = UISlider(frame: CGRect(x: 5, y: 45, width: 110, height: 25))
        volumeSlider.maximumValue = 1000
        volumeSlider.minimumValue = 0
        volumeSlider.value = 500
        volumeSlider.addTarget(self, action: #selector(self.frequencyChange), for: .valueChanged)
        
        let volumeTitle  = UILabel()
        volumeTitle.frame = CGRect(x: 10, y: 75, width: 60, height: 15)
        volumeTitle.text = "Pitch:"

        let volumeLabel = UILabel()
        volumeLabel.frame = CGRect(x: 70, y: 75, width: 60, height: 15)
        volumeLabel.text = "500"
        
        let durationSlider = UISlider(frame: CGRect(x: 5, y: 100, width: 110, height: 25))
        durationSlider.maximumValue = 10
        durationSlider.minimumValue = 1
        durationSlider.value = 5
        durationSlider.addTarget(self, action: #selector(self.durationChange(_:)), for: .valueChanged)
    
        let durationTitle  = UILabel()
        durationTitle.frame = CGRect(x: 10, y: 130, width: 60, height: 15)
        durationTitle.text = "Time:"
        let durationLabel = UILabel()
        durationLabel.frame = CGRect(x: 70, y: 130, width: 60, height: 15)
        durationLabel.text = "5"
        
        var deleteButton = UIButton();
        deleteButton = createButton(title: "", _x: 95, _y: 0, _width: 20, _height: 30)
        deleteButton.setImage(UIImage(named:"trash"), for: UIControlState.normal)
        
        var playTypeButton = UIButton();
        playTypeButton = createButton(title: "type", _x: 40, _y: 140, _width: 35, _height: 40)
        playTypeButton.setImage(UIImage(named:"play"), for: UIControlState.normal)
        
        let playTypeLabel = UILabel()
        playTypeLabel.frame = CGRect(x: 30, y: 150, width: 120, height: 40)
        playTypeLabel.text = "file"
        
        let name = UILabel()
        name.frame = CGRect(x: 0, y: 0, width: 120, height: 40)
        name.text = "Sound"
        name.textColor = PrimaryOrange
        name.textAlignment = .center
        
        var panGesture = UIPanGestureRecognizer()
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedViewS(_:)))
        panGesture.delegate = self
        tempView.isUserInteractionEnabled = true
        tempView.addGestureRecognizer(panGesture)
        
        playTypeButton.addTarget(self, action: #selector(playTypeAlertSound(sender:event:)), for: UIControlEvents.touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteBlock(sender:event:)), for: UIControlEvents.touchUpInside)
        tempView.addSubview(name)
        tempView.addSubview(volumeSlider)
        tempView.addSubview(volumeTitle)
        //tempView.addSubview(playTypeButton)
        tempView.addSubview(deleteButton)
        tempView.addSubview(durationSlider)
        tempView.addSubview(durationTitle)
        tempView.addSubview(volumeLabel)
        //tempView.addSubview(playTypeLabel)
        tempView.addSubview(durationLabel)
        self.view.addSubview(tempView)
        
        return tempView
    }
    
    func createWait()->UIView{
        let tempView = UIView()
        tempView.backgroundColor = PrimaryGold
        tempView.layer.borderColor = PrimaryGold.cgColor
        tempView.layer.borderWidth = 1.2
        tempView.layer.cornerRadius = 5
        tempView.layer.masksToBounds = true
        tempView.frame = CGRect(x: 295, y: 525, width: 120, height: 160)
        
        var timeButton = UIButton();
        timeButton = createButton(title: "", _x: 5, _y: 80, _width: 110, _height: 40)
        timeButton.setTitleColor(PrimaryGold, for: .normal)
        timeButton.backgroundColor = UIColor.white
        timeButton.addTarget(self, action: #selector(timeAlertWait(sender:event:)), for: UIControlEvents.touchUpInside)
        timeButton.setImage(UIImage(named:"time"), for: UIControlState.normal)
        
        var deleteButton = UIButton();
        deleteButton = createButton(title: "", _x: 95, _y: 0, _width: 20, _height: 30)
        deleteButton.setImage(UIImage(named:"trash"), for: UIControlState.normal)
        
        let name = UILabel()
        name.frame = CGRect(x: 40, y: 25, width: 120, height: 40)
        name.text = "Wait"
        name.textColor = UIColor.white
        
        let timeLabel = UILabel()
        timeLabel.frame = CGRect(x:5, y: 45, width: 110, height: 40)
        timeLabel.text = "5"
        timeLabel.textColor = UIColor.white
        timeLabel.textAlignment = .center
        
        var panGesture = UIPanGestureRecognizer()
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedViewW(_:)))
        tempView.isUserInteractionEnabled = true
        tempView.addGestureRecognizer(panGesture)
        
        deleteButton.addTarget(self, action: #selector(deleteBlock(sender:event:)), for: UIControlEvents.touchUpInside)
        
        tempView.addSubview(name)
        tempView.addSubview(timeButton)
        tempView.addSubview(deleteButton)
        tempView.addSubview(timeLabel)
        
        self.view.addSubview(tempView)
        
        return tempView
    }

    
    func createStartLoop()->UIView{
        let tempView = UIView()
        tempView.backgroundColor = PrimaryBlue
        tempView.layer.borderColor = PrimaryBlue.cgColor
        tempView.layer.borderWidth = 1.2
        tempView.layer.cornerRadius = 5
        tempView.layer.masksToBounds = true
        tempView.frame = CGRect(x: 25, y: 525, width: 120, height: 160)
        
        var loopsButton = UIButton()
        loopsButton = createButton(title: "", _x: 5, _y: 80, _width: 110, _height: 40)
        loopsButton.backgroundColor = UIColor.white
        loopsButton.setTitleColor(PrimaryBlue, for: .normal)
        loopsButton.addTarget(self, action: #selector(loopsAlertLoop(sender:event:)), for: UIControlEvents.touchUpInside)
        loopsButton.setImage(UIImage(named:"loop"), for: UIControlState.normal)
        
        let name = UILabel()
        name.frame = CGRect(x: 20, y: 25, width: 120, height: 40)
        name.text = "Start Loop"
        name.textColor = UIColor.white
        
        let itLabel = UILabel()
        itLabel.frame = CGRect(x: 5, y: 45, width: 110, height: 40)
        itLabel.text = "3"
        itLabel.textColor = UIColor.white
        itLabel.textAlignment = .center
        
        var panGesture = UIPanGestureRecognizer()
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedViewSL(_:)))
        tempView.isUserInteractionEnabled = true
        tempView.addGestureRecognizer(panGesture)
        
        var deleteButton = UIButton();
        deleteButton = createButton(title: "", _x: 95, _y: 0, _width: 20, _height: 30)
        deleteButton.addTarget(self, action: #selector(deleteBlock(sender:event:)), for: UIControlEvents.touchUpInside)
        deleteButton.setImage(UIImage(named:"trash"), for: UIControlState.normal)
        
        tempView.addSubview(name)
        tempView.addSubview(loopsButton)
        tempView.addSubview(deleteButton)
        tempView.addSubview(itLabel)
        self.view.addSubview(tempView)
        
        return tempView
    }
    
    func createEndLoop()->UIView{
        let tempView = UIView()
        tempView.backgroundColor = PrimaryRed
        tempView.layer.borderColor = PrimaryRed.cgColor
        tempView.layer.borderWidth = 1.2
        tempView.layer.cornerRadius = 5
        tempView.layer.masksToBounds = true
        tempView.frame = CGRect(x: 160, y: 525, width: 120, height: 160)
        
        var panGesture = UIPanGestureRecognizer()
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedViewEL(_:)))
        tempView.isUserInteractionEnabled = true
        tempView.addGestureRecognizer(panGesture)
        
        let name = UILabel()
        name.frame = CGRect(x: 20, y: 25, width: 120, height: 40)
        name.text = "End Loop"
        name.textColor = UIColor.white
        
        var deleteButton = UIButton();
        deleteButton = createButton(title: "", _x: 95, _y: 0, _width: 20, _height: 30)
        deleteButton.addTarget(self, action: #selector(deleteBlock(sender:event:)), for: UIControlEvents.touchUpInside)
        deleteButton.setImage(UIImage(named:"trash"), for: UIControlState.normal)
        
        tempView.addSubview(name)
        tempView.addSubview(deleteButton)
        self.view.addSubview(tempView)
        
        return tempView
    }
    
    func createSteer()->UIView{
        let tempView = UIView()
        tempView.backgroundColor = UIColor.clear
        tempView.layer.borderColor = PrimaryOrange.cgColor
        tempView.layer.borderWidth = 1.2
        tempView.layer.cornerRadius = 5
        tempView.layer.masksToBounds = true
        tempView.frame = CGRect(x: 160, y: 525, width: 120, height: 160)

        var brakeButton = UIButton()
        brakeButton = createButton(title: "", _x: 0, _y: 50, _width: 35, _height: 40);
        brakeButton.setImage(UIImage(named:"brake"), for: UIControlState.normal)
        
        var powerButton = UIButton();
        powerButton = createButton(title: "", _x: 40, _y: 50, _width: 35, _height: 40)
        powerButton.setImage(UIImage(named:"power"), for: UIControlState.normal)
        
        var revolutionsButton = UIButton();
        revolutionsButton = createButton(title: "", _x: 80, _y: 50, _width: 35, _height: 40)
        revolutionsButton.setImage(UIImage(named:"revolution"), for: UIControlState.normal)
        
        var leadportButton = UIButton();
        leadportButton = createButton(title: "", _x: 0, _y: 110, _width: 35, _height: 40)
        leadportButton.setImage(UIImage(named:"lead"), for: UIControlState.normal)
        
        var followportButton = UIButton();
        followportButton = createButton(title: "follow port", _x: 40, _y: 110, _width: 35, _height: 40)
        followportButton.setImage(UIImage(named:"follow"), for: UIControlState.normal)
        
        var turnratioButton = UIButton();
        turnratioButton = createButton(title: "", _x: 80, _y: 110, _width: 35, _height: 40)
        turnratioButton.setImage(UIImage(named:"ratio"), for: UIControlState.normal)
        
        var deleteButton = UIButton();
        deleteButton = createButton(title: "", _x: 95, _y: 0, _width: 20, _height: 30)
        deleteButton.setImage(UIImage(named:"trash"), for: UIControlState.normal)
        
        let name = UILabel()
        name.frame = CGRect(x: 0, y: 0, width: 120, height: 40)
        name.text = "Steer"
        name.textColor = PrimaryOrange
        name.textAlignment = .center
        
        var panGesture = UIPanGestureRecognizer()
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedViewSteer(_:)))
        tempView.isUserInteractionEnabled = true
        tempView.addGestureRecognizer(panGesture)
        
        brakeButton.addTarget(self, action: #selector(brakeAlertSteer(sender:event:)), for: UIControlEvents.touchUpInside)
        powerButton.addTarget(self, action: #selector(powerAlertSteer(sender:event:)), for: UIControlEvents.touchUpInside)
        revolutionsButton.addTarget(self, action: #selector(revolutionsAlertSteer(sender:event:)), for: UIControlEvents.touchUpInside)
        leadportButton.addTarget(self, action: #selector(leadPortAlert(sender:event:)), for: UIControlEvents.touchUpInside)
        followportButton.addTarget(self, action: #selector(followPortAlert(sender:event:)), for: UIControlEvents.touchUpInside)
        turnratioButton.addTarget(self, action: #selector(turnRatioAlert(sender:event:)), for: UIControlEvents.touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteBlock(sender:event:)), for: UIControlEvents.touchUpInside)
        
        tempView.addSubview(name)
        tempView.addSubview(brakeButton)
        tempView.addSubview(powerButton)
        tempView.addSubview(revolutionsButton)
        tempView.addSubview(leadportButton)
        tempView.addSubview(followportButton)
        tempView.addSubview(turnratioButton)
        tempView.addSubview(deleteButton)
        self.view.addSubview(tempView)
        
        return tempView
    }
    
    func replaceView(type: String) -> UIView{
        if(type == "medMotorView"){
            medMotorView = createMedMotor()
            return medMotorView
        }else if(type == "soundView"){
            soundView = createSound()
            return soundView
        }else if(type == "waitView"){
            waitView = createWait()
            return waitView
        }else if(type == "startLoopView"){
            startLoopView = createStartLoop()
            return startLoopView
        }
        else if (type == "endLoopView"){
            endLoopView = createEndLoop()
            return endLoopView
        }
        //else if (type == "steerView") {
        else {
            steerView = createSteer()
            return steerView
        }
    }
    
    func updateUIViewOrder(){
        var x = startPoint.x + 128
        let y = startPoint.y
        for view in viewSequence{
            view.frame.origin = CGPoint(x: x, y: y)
            x = x + 128
        }
    }
    
    func draggedViewMM(_ sender:UIPanGestureRecognizer){
        let translation = sender.translation(in: self.view)
        
        medMotorView.center = CGPoint(x: medMotorView.center.x + translation.x, y: medMotorView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
        
        let xLoc = medMotorView.center.x + translation.x + scrollView.contentOffset.x
        let yLoc = medMotorView.center.y + translation.y
        
        var index = Int()
        index = viewSequence.count
        var toAppend = Bool()
        toAppend = false
        
        if(yLoc > 200 && yLoc < 400){
            //if dragged to end
            if(xLoc > (nextPoint.x + 128)){
                toAppend = true
            }
        }
        if(sender.state == UIGestureRecognizerState.ended){
            let labels = getLabelsInView(view: medMotorView)
//            var speed = labels[6].text!
//            var rotations = labels[7].text!
//            var brake = labels[8].text!
//            var port = labels[9].text!
//            let brakeBool = brake.lowercased() == "true"

            var speed = speedMotorLabel.text!
            var rotations = rotationsMotorLabel.text!
            var brake = brakeMotorLabel.text!
            var port = portMotorLabel.text!
            let brakeBool = brake.lowercased() == "true"
            
            let newMM = MotorObject(ty: "motor");
            newMM.setSpeed(newSpeed: Int(speed)!)
            newMM.setBrake(newBrake: brakeBool)
            newMM.setRotations(newRot: Int(rotations)!)
            newMM.setPort(newPort: port)
            var oldPanGesture = UIPanGestureRecognizer()
            oldPanGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedViewMM(_:)))
            var newPanGesture = UIPanGestureRecognizer()
            newPanGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedBlockInCode(_:)))
            medMotorView.removeGestureRecognizer(oldPanGesture)
            medMotorView.addGestureRecognizer(newPanGesture)
            if(toAppend){
                medMotorView.center = CGPoint(x: nextPoint.x + 128, y: nextPoint.y)
                nextPoint.x = nextPoint.x + 128
                objectSequence.append(newMM)
                medMotorView.removeFromSuperview()
                scrollView.addSubview(medMotorView)
                viewSequence.append(medMotorView)
            }else{
                
                if (viewSequence.count > 0){
                    for i in 0..<(viewSequence.count - 1){
                        var leftStart = viewSequence[i].frame.origin.x
                        var rightEnd = viewSequence[i+1].frame.origin.x + 128
                        //If sandwiched between these two blocks, then take the position of the second block
                        if (xLoc > leftStart && xLoc < rightEnd){
                            index = i + 1
                        }
                    }
                }
                
                medMotorView.removeFromSuperview()
                objectSequence.insert(newMM, at: index)
                scrollView.addSubview(medMotorView)
                viewSequence.insert(medMotorView, at: index)
            }
            updateUIViewOrder()
            
            medMotorView = replaceView(type: "medMotorView")
        }
    }
    
    func draggedViewD(_ sender:UIPanGestureRecognizer){
        let translation = sender.translation(in: self.view)
        displayView.center = CGPoint(x: displayView.center.x + translation.x, y: displayView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
        
        let xLoc = displayView.center.x + translation.x
        let yLoc = displayView.center.y + translation.y
        
        var index = Int()
        index = viewSequence.count
        var toAppend = Bool()
        toAppend = false
        
        if(yLoc > 200 && yLoc < 400){
            //if dragged to end
            if(xLoc > (nextPoint.x + 128)){
                displayView.center = CGPoint(x: nextPoint.x + 128, y: nextPoint.y)
                nextPoint.x = nextPoint.x + 128
                toAppend = true
            }
                //if dragged to middle
            else if(xLoc > startPoint.x && xLoc < nextPoint.x){
                var beginXRange = startPoint.x
                var endXRange = startPoint.x + 128
                for i in  0..<viewSequence.count {
                    if(xLoc < endXRange && xLoc > beginXRange){
                        index = i
                    }else{
                        beginXRange += 128
                        endXRange += 128
                    }
                }
            }
        }
        if(sender.state == UIGestureRecognizerState.ended){
            let newD = DisplayObject(ty: "display");
            newD.setX(x: 10)
            newD.setY(y: 10)
            newD.setClear(newClear: true)
            if(toAppend){
                objectSequence.append(newD);
                viewSequence.append(displayView)
            }else{
                objectSequence.insert(newD, at: index)
                viewSequence.insert(displayView, at: index)
            }
            updateUIViewOrder()
            displayView = replaceView(type: "displayView")
        }
    }
    
    func draggedViewS(_ sender:UIPanGestureRecognizer){
        let labels = getLabelsInView(view: soundView)

        let translation = sender.translation(in: self.view)
        soundView.center = CGPoint(x: soundView.center.x + translation.x, y: soundView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
        
        let xLoc = soundView.center.x + translation.x + scrollView.contentOffset.x
        let yLoc = soundView.center.y + translation.y
        
        var index = Int()
        index = viewSequence.count
        var toAppend = Bool()
        toAppend = false
        
        if(yLoc > 200 && yLoc < 400){
            //if dragged to end
            if(xLoc > (nextPoint.x + 128)){
                toAppend = true
            }
        }
        if(sender.state == UIGestureRecognizerState.ended){
            
            let freq = labels[3].text!
            let duration = labels[4].text!
            
            let newS = SoundObject(ty: "sound")
            newS.setVolume(newVol: Int(freq)!)
            newS.setDuration(newDur: Int(duration)!)
            var oldPanGesture = UIPanGestureRecognizer()
            oldPanGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedViewS(_:)))
            var newPanGesture = UIPanGestureRecognizer()
            newPanGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedBlockInCode(_:)))
            soundView.removeGestureRecognizer(oldPanGesture)
            soundView.addGestureRecognizer(newPanGesture)
            if(toAppend){
                soundView.center = CGPoint(x: nextPoint.x + 128, y: nextPoint.y)
                nextPoint.x = nextPoint.x + 128
                soundView.removeFromSuperview()
                scrollView.addSubview(soundView)
                objectSequence.append(newS);
                viewSequence.append(soundView)
            }else{
                
                if (viewSequence.count > 0){
                    for i in 0..<(viewSequence.count - 1){
                        var leftStart = viewSequence[i].frame.origin.x
                        var rightEnd = viewSequence[i+1].frame.origin.x + 128
                        //If sandwiched between these two blocks, then take the position of the second block
                        if (xLoc > leftStart && xLoc < rightEnd){
                            index = i + 1
                        }
                    }
                }
                
                soundView.removeFromSuperview()
                scrollView.addSubview(soundView)
                objectSequence.insert(newS, at: index)
                viewSequence.insert(soundView, at: index)
            }
            print("views in count \(self.viewSequence.count)")
            updateUIViewOrder()
            soundView = replaceView(type: "soundView")
        }
    }
    
    func draggedViewW(_ sender:UIPanGestureRecognizer){
        let labels = getLabelsInView(view: waitView)
        
        let translation = sender.translation(in: self.view)
        waitView.center = CGPoint(x: waitView.center.x + translation.x, y: waitView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
        
        let xLoc = waitView.center.x + translation.x + scrollView.contentOffset.x
        let yLoc = waitView.center.y + translation.y
        
        var index = Int()
        index = viewSequence.count
        var toAppend = Bool()
        toAppend = false
        
        if(yLoc > 200 && yLoc < 400){
            //if dragged to end
            if(xLoc > (nextPoint.x + 128)){
                toAppend = true
            }
        }
        if(sender.state == UIGestureRecognizerState.ended){
            
            let time = labels[1].text!
            
            let newW = WaitObject(ty: "wait");
            newW.setTime(newTime: Int(time)!);
            
            var oldPanGesture = UIPanGestureRecognizer()
            oldPanGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedViewW(_:)))
            var newPanGesture = UIPanGestureRecognizer()
            newPanGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedBlockInCode(_:)))
            waitView.removeGestureRecognizer(oldPanGesture)
            waitView.addGestureRecognizer(newPanGesture)
            
            if(toAppend){
                waitView.center = CGPoint(x: nextPoint.x + 128, y: nextPoint.y)
                nextPoint.x = nextPoint.x + 128
                waitView.removeFromSuperview()
                scrollView.addSubview(waitView)
                print("Created a new wait block \(newW.getTime())")
                objectSequence.append(newW)
                viewSequence.append(waitView)
            }else{
                
                if (viewSequence.count > 0){
                    for i in 0..<(viewSequence.count - 1){
                        var leftStart = viewSequence[i].frame.origin.x
                        var rightEnd = viewSequence[i+1].frame.origin.x + 128
                        //If sandwiched between these two blocks, then take the position of the second block
                        if (xLoc > leftStart && xLoc < rightEnd){
                            index = i + 1
                        }
                    }
                }
                
                waitView.removeFromSuperview()
                scrollView.addSubview(waitView)
                objectSequence.insert(newW, at: index)
                viewSequence.insert(waitView, at: index)
            }
            updateUIViewOrder()
            waitView = replaceView(type: "waitView")
        }
    }
    
    func draggedViewSL(_ sender:UIPanGestureRecognizer){
        let translation = sender.translation(in: self.view)
        
        startLoopView.center = CGPoint(x: startLoopView.center.x + translation.x, y: startLoopView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
        
        let xLoc = startLoopView.center.x + translation.x + scrollView.contentOffset.x
        let yLoc = startLoopView.center.y + translation.y
        
        var index = Int()
        index = viewSequence.count
        var toAppend = Bool()
        toAppend = false
        
        if(yLoc > 200 && yLoc < 400){
            //if dragged to end
            if(xLoc > (nextPoint.x + 128)){
                toAppend = true
            }
        }
        
        if(sender.state == UIGestureRecognizerState.ended){
            let labels = getLabelsInView(view: startLoopView)
            var iterations: Int = 5
            if (labels.count == 2){
                iterations = Int(labels[1].text!)!
            }
            
            let newSL = StartLoopObject(ty: "startLoop")
            newSL.setLoops(newLoops: iterations)
            var oldPanGesture = UIPanGestureRecognizer()
            oldPanGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedViewSL(_:)))
            var newPanGesture = UIPanGestureRecognizer()
            newPanGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedBlockInCode(_:)))
            startLoopView.removeGestureRecognizer(oldPanGesture)
            startLoopView.addGestureRecognizer(newPanGesture)
            
            if(toAppend){
                startLoopView.center = CGPoint(x: nextPoint.x + 128, y: nextPoint.y)
                nextPoint.x = nextPoint.x + 128
                objectSequence.append(newSL)
                startLoopView.removeFromSuperview()
                self.scrollView.addSubview(startLoopView)
                viewSequence.append(startLoopView)
            }else{
                
                if (viewSequence.count > 0){
                    for i in 0..<(viewSequence.count - 1){
                        let leftStart = viewSequence[i].frame.origin.x
                        let rightEnd = viewSequence[i+1].frame.origin.x + 128
                        //If sandwiched between these two blocks, then take the position of the second block
                        if (xLoc > leftStart && xLoc < rightEnd){
                            index = i + 1
                        }
                    }
                }
                
                objectSequence.insert(newSL, at: index)
                startLoopView.removeFromSuperview()
                self.scrollView.addSubview(startLoopView)
                viewSequence.insert(startLoopView, at: index)
            }
            updateUIViewOrder()
            startLoopView = replaceView(type: "startLoopView")
        }
    }
    
    func draggedViewEL(_ sender:UIPanGestureRecognizer){
        
        let translation = sender.translation(in: self.view)
        
        endLoopView.center = CGPoint(x: endLoopView.center.x + translation.x, y: endLoopView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
        
        
        let xLoc = endLoopView.center.x + translation.x + scrollView.contentOffset.x
        let yLoc = endLoopView.center.y + translation.y
        var index = Int()
        index = viewSequence.count
        var toAppend = Bool()
        toAppend = false
        
        //if it's within the bounds of the scroll view
        if(self.scrollView.frame.contains(CGPoint(x: xLoc, y: yLoc))){
            //if dragged to end
            if(xLoc > (nextPoint.x + 128)){
                toAppend = true
            }
        }
        
        if(sender.state == UIGestureRecognizerState.ended){
            
            let newEL = EndLoopObject(ty: "endLoop");
            var oldPanGesture = UIPanGestureRecognizer()
            oldPanGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedViewEL(_:)))
            var newPanGesture = UIPanGestureRecognizer()
            newPanGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedBlockInCode(_:)))
            endLoopView.removeGestureRecognizer(oldPanGesture)
            endLoopView.addGestureRecognizer(newPanGesture)
            if(toAppend){
                endLoopView.center = CGPoint(x: nextPoint.x + 128, y: nextPoint.y)
                nextPoint.x = nextPoint.x + 128
                endLoopView.removeFromSuperview()
                objectSequence.append(newEL)
                scrollView.addSubview(endLoopView)
                viewSequence.append(endLoopView)
            }else{
                
                if (viewSequence.count > 0){
                    for i in 0..<(viewSequence.count - 1){
                        var leftStart = viewSequence[i].frame.origin.x
                        var rightEnd = viewSequence[i+1].frame.origin.x + 128
                        //If sandwiched between these two blocks, then take the position of the second block
                        if (xLoc > leftStart && xLoc < rightEnd){
                            index = i + 1
                        }
                    }
                }
                
                objectSequence.insert(newEL, at: index)
                endLoopView.removeFromSuperview()
                scrollView.addSubview(endLoopView)
                viewSequence.insert(endLoopView, at: index)
                
            }
            updateUIViewOrder()
            endLoopView = replaceView(type: "endLoopView")
        }
    }
    
    func draggedViewSteer(_ sender:UIPanGestureRecognizer){
        let labels = getLabelsInView(view: steerView)
        if(labels.count != 8){
            invalidInputAlert(_title: "Invalid input for Steer", msg: "Please enter all inputs")
            return
        }
        let translation = sender.translation(in: self.view)
        
        steerView.center = CGPoint(x: steerView.center.x + translation.x, y: steerView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
        
        let xLoc = steerView.center.x + translation.x + scrollView.contentOffset.x
        let yLoc = steerView.center.y + translation.y
        
        var index = Int()
        index = viewSequence.count
        var toAppend = Bool()
        toAppend = false
        
        if(yLoc > 300 && yLoc < 440){
            //if dragged to end
            if(xLoc > (nextPoint.x + 128)){
                toAppend = true
            }
        }
        if(sender.state == UIGestureRecognizerState.ended){
            let labels = getLabelsInView(view: steerView)
            //TODO: Fix label numbers
            let brake = labels[2].text!
            let power = labels[3].text!
            let revolutions = labels[4].text!
            let leadport = labels[5].text!
            let followport = labels[6].text!
            let turnratio = labels[7].text!
            let brakeBool = brake.lowercased() == "true"
            
            let newS = SteerObject(ty: "steer");
            newS.setBrake(newBrake: brakeBool)
            newS.setPower(newPower: Int(power)!)
            newS.setRevolutions(newRev: Int(revolutions)!)
            newS.setLeadPort(newLP: leadport)
            newS.setFollowPort(newFP: followport)
            newS.setTurnRatio(newTurnRatio: Int(turnratio)!)
            
            
            if(toAppend){
                steerView.center = CGPoint(x: nextPoint.x + 128, y: nextPoint.y)
                nextPoint.x = nextPoint.x + 128
                steerView.removeFromSuperview()
                scrollView.addSubview(steerView)
                objectSequence.append(newS);
                viewSequence.append(steerView)
            }else{
                
                if (viewSequence.count > 0){
                    for i in 0..<(viewSequence.count - 1){
                        let leftStart = viewSequence[i].frame.origin.x
                        let rightEnd = viewSequence[i+1].frame.origin.x + 128
                        //If sandwiched between these two blocks, then take the position of the second block
                        if (xLoc > leftStart && xLoc < rightEnd){
                            index = i + 1
                        }
                    }
                }
                
                steerView.removeFromSuperview()
                scrollView.addSubview(steerView)
                objectSequence.insert(newS, at: index)
                viewSequence.insert(steerView, at: index)
            }
            updateUIViewOrder()
            
            steerView = replaceView(type: "steerView")
        }
    }
    
    func getContent(s: String)->String{
        var str = s
        let index = str.index(str.startIndex, offsetBy: 10);
        str =  str.substring(from: index)
        let index2 = str.index(str.startIndex, offsetBy: str.characters.count - 2)
        str = str.substring(to: index2)
        return str
    }
    
    func speedAlertMotor(sender: Any, event: UIEvent)->String{
        let myButton:UIButton = sender as! UIButton
        let touches: Set<UITouch>? = event.touches(for: myButton)
        let touch: UITouch? = touches?.first
        let touchPoint: CGPoint? = touch?.location(in: self.scrollView)
        
        var ans = String()
        let alert = UIAlertController(title: "Motor Speed", message: "Enter a speed number from -100 to 100", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "50"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(String(describing: textField?.text))");
            
            let x = String(describing: textField?.text);
            ans = self.getContent(s: x)
            print("ans")
            print(ans)
            
//            let index = self.getIndexOfBlock(xLoc: touchPoint!)
//            print("index: ")
//            print(index)
//
//            let tempView = self.viewSequence[index]
//            let labels = self.getLabelsInView(view: tempView)
//            labels[5].text = ans
//
//            let tempObj = self.objectSequence[index] as! MotorObject
//            tempObj.speed = Int(ans)!
//
            self.speedMotorLabel.frame = CGRect(x: 0, y: 40, width: 120, height: 40)
            self.speedMotorLabel.text = ans
            self.medMotorView.addSubview(self.speedMotorLabel)
        }))
        
        self.present(alert, animated: true, completion: nil)
        return ans;
    }
    
    func rotationsAlertMotor(sender: Any, event: UIEvent)->String{
        let myButton:UIButton = sender as! UIButton
        let touches: Set<UITouch>? = event.touches(for: myButton)
        let touch: UITouch? = touches?.first
        let touchPoint: CGPoint? = touch?.location(in: self.scrollView)
        
        var ans = String()
        let alert = UIAlertController(title: "Motor Rotations", message: "Enter a rotation number greater than 1", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "1"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(String(describing: textField?.text))");
            
            let x = String(describing: textField?.text);
            ans = self.getContent(s: x)
            print(ans)
            
//            let index = self.getIndexOfBlock(xLoc: touchPoint!)
//            print("index: ")
//            print(index)
//
//            let tempView = self.viewSequence[index]
//            let labels = self.getLabelsInView(view: tempView)
//            labels[6].text = ans
//
//            let tempObj = self.objectSequence[index] as! MotorObject
//            tempObj.rotations = Int(ans)!
            self.rotationsMotorLabel.frame = CGRect(x: 30, y: 40, width: 120, height: 40)
            self.rotationsMotorLabel.text = ans
            
            self.medMotorView.addSubview(self.rotationsMotorLabel)
        }))
        
        self.present(alert, animated: true, completion: nil)
        return ans;
    }
    
    func brakeAlertMotor(sender: Any, event: UIEvent)->String{
        let myButton:UIButton = sender as! UIButton
        let touches: Set<UITouch>? = event.touches(for: myButton)
        let touch: UITouch? = touches?.first
        let touchPoint: CGPoint? = touch?.location(in: self.scrollView)
        
        var ans = String()
        let alert = UIAlertController(title: "Motor Brake", message: "Do you want to brake at the end? True or false.", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "true"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(String(describing: textField?.text))");
            
            let x = String(describing: textField?.text);
            ans = self.getContent(s: x)
            print(ans)
            
//            let index = self.getIndexOfBlock(xLoc: touchPoint!)
//            print("index: ")
//            print(index)
//
//            let tempView = self.viewSequence[index]
//            let labels = self.getLabelsInView(view: tempView)
//            labels[7].text = ans
//
//            let tempObj = self.objectSequence[index] as! MotorObject
//            //tempObj.brake = BOOL(ans)
            self.brakeMotorLabel.frame = CGRect(x: 60, y: 40, width: 120, height: 40)
            self.brakeMotorLabel.text = ans
            
            self.medMotorView.addSubview(self.brakeMotorLabel)
        }))
        
        self.present(alert, animated: true, completion: nil)
        return ans;
    }
    
    func portAlertMotor(sender: Any, event: UIEvent)->String{
        let myButton:UIButton = sender as! UIButton
        let touches: Set<UITouch>? = event.touches(for: myButton)
        let touch: UITouch? = touches?.first
        let touchPoint: CGPoint? = touch?.location(in: self.scrollView)
        
        var ans = String()
        let alert = UIAlertController(title: "Motor Port", message: "Please enter a port A to C for the motor", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "A"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(String(describing: textField?.text))");
            
            let x = String(describing: textField?.text);
            ans = self.getContent(s: x)
            print(ans)
            
//            let index = self.getIndexOfBlock(xLoc: touchPoint!)
//            print("index: ")
//            print(index)
//
//            let tempView = self.viewSequence[index]
//            let labels = self.getLabelsInView(view: tempView)
//            labels[8].text = ans
//
//            let tempObj = self.objectSequence[index] as! MotorObject
//            tempObj.port = ans
            self.portMotorLabel.frame = CGRect(x: 90, y: 40, width: 120, height: 40)
            self.portMotorLabel.text = ans
            
            self.medMotorView.addSubview(self.portMotorLabel)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        return ans;
    }
    
    func volumeAlertSound(sender: Any, event: UIEvent)->String{
        let myButton:UIButton = sender as! UIButton
        let touches: Set<UITouch>? = event.touches(for: myButton)
        let touch: UITouch? = touches?.first
        let touchPoint: CGPoint? = touch?.location(in: self.scrollView)
        let views = self.viewSequence
        let objs = self.objectSequence
        var ans = String()
        let alert = UIAlertController(title: "Sound Pitch", message: "Enter a frequency from 0 to 1000", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "100"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            let x = String(describing: textField?.text);
            ans = self.getContent(s: x)
            
            let index = self.getIndexOfBlock(xLoc: touchPoint!)
            let tempView = views[index]
            let labels = self.getLabelsInView(view: tempView)
            labels[5].text = ans
            
            let tempObj = objs[index] as! SoundObject
            tempObj.volume = Int(ans)!
        }))
        self.present(alert, animated: true, completion: nil)
        return ans;
    }
    
    func playTypeAlertSound(sender: Any, event: UIEvent)->String{
        var ans = String()
        let alert = UIAlertController(title: "Sound File", message: "Enter a file name to play sound", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.text = ""
        }

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(String(describing: textField?.text))");

            let x = String(describing: textField?.text);
            ans = self.getContent(s: x)
            print(ans)

            let playType = UILabel()
            playType.frame = CGRect(x: 40, y: 40, width: 35, height: 30)
            playType.text = ans

            self.soundView.addSubview(playType)

        }))

        self.present(alert, animated: true, completion: nil)
        return ans;
    }
    
    func timeAlertWait(sender: Any, event: UIEvent)->String{
        var ans = String()
        let alert = UIAlertController(title: "Wait time", message: "How many seconds to wait?", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "5"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(String(describing: textField?.text))");
            
            let x = String(describing: textField?.text);
            ans = self.getContent(s: x)
            
            if (self.waitView.subviews.count == 4){
                var timeLbl = self.waitView.subviews[3] as! UILabel
                
                if (ans == ""){
                    timeLbl.text = "2"
                } else {
                    timeLbl.text = "\(ans)"
                }
            }
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        return ans;
    }
    
//    func typeAlertLoop(sender: Any, event: UIEvent)->String{
//        var ans = String()
//        let alert = UIAlertController(title: "Some Title", message: "Enter a text", preferredStyle: .alert)
//
//        alert.addTextField { (textField) in
//            textField.text = "default text"
//        }
//
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
//            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
//            print("Text field: \(String(describing: textField?.text))");
//
//            let x = String(describing: textField?.text);
//            ans = self.getContent(s: x)
//            print(ans)
//
//            let time = UILabel()
//            time.frame = CGRect(x: 40, y: 40, width: 35, height: 30)
//            time.text = ans
//
//            self.startLoopView.addSubview(time)
//
//        }))
//
//        self.present(alert, animated: true, completion: nil)
//        return ans;
//    }
    
    func loopsAlertLoop(sender: Any, event: UIEvent)->String{
        var ans = String()
        let alert = UIAlertController(title: "Loops", message: "How many times should this loop?", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "2"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            
            let x = String(describing: textField?.text);
            ans = self.getContent(s: x)
            
            if (self.startLoopView.subviews.count == 4){
                let timeLbl = self.startLoopView.subviews[3] as! UILabel
                timeLbl.text = ans
            } else {
                let loops = UILabel()
                loops.frame = CGRect(x: 10, y: 55, width: 35, height: 30)
                loops.textColor = UIColor.white
                loops.text = ans
                
                self.startLoopView.addSubview(loops)
            }
            
            
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        return ans;
    }
    
    func brakeAlertSteer(sender: Any, event: UIEvent)->String{
        var ans = String()
        let alert = UIAlertController(title: "Steer Brake", message: "Enter true or false", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "true"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(String(describing: textField?.text))");
            
            let x = String(describing: textField?.text);
            ans = self.getContent(s: x)
            print("ans")
            print(ans)
            
            self.brakeS.frame = CGRect(x: 0, y: 25, width: 35, height: 30)
            self.brakeS.text = ans
            
            self.steerView.addSubview(self.brakeS)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        return ans;
    }
    
    func powerAlertSteer(sender: Any, event: UIEvent)->String{
        var ans = String()
        let alert = UIAlertController(title: "Motor Power", message: "Enter a number from -100 to 100", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "75"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(String(describing: textField?.text))");
            
            let x = String(describing: textField?.text);
            ans = self.getContent(s: x)
            print("ans")
            print(ans)
            
            self.powerS.frame = CGRect(x: 40, y: 25, width: 35, height: 30)
            self.powerS.text = ans
            
            self.steerView.addSubview(self.powerS)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        return ans;
    }
    
    func revolutionsAlertSteer(sender: Any, event: UIEvent)->String{
        var ans = String()
        let alert = UIAlertController(title: "Number of Revolutions", message: "Enter number of revolutions", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "1"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(String(describing: textField?.text))");
            
            let x = String(describing: textField?.text);
            ans = self.getContent(s: x)
            print("ans")
            print(ans)
            
            self.revolutions.frame = CGRect(x: 80, y: 25, width: 35, height: 30)
            self.revolutions.text = ans
            
            self.steerView.addSubview(self.revolutions)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        return ans;
    }
    
    func leadPortAlert(sender: Any, event: UIEvent)->String{
        var ans = String()
        let alert = UIAlertController(title: "Lead Port", message: "Enter port number or letter", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "B"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(String(describing: textField?.text))");
            
            let x = String(describing: textField?.text);
            ans = self.getContent(s: x)
            print("ans")
            print(ans)
            
            self.leadport.frame = CGRect(x: 0, y: 85, width: 35, height: 30)
            self.leadport.text = ans
            
            self.steerView.addSubview(self.leadport)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        return ans;
    }
    
    func followPortAlert(sender: Any, event: UIEvent)->String{
        var ans = String()
        let alert = UIAlertController(title: "Follow Port", message: "Enter port number or letter", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "C"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(String(describing: textField?.text))");
            
            let x = String(describing: textField?.text);
            ans = self.getContent(s: x)
            print("ans")
            print(ans)
            
            self.followport.frame = CGRect(x: 40, y: 85, width: 35, height: 30)
            self.followport.text = ans
            
            self.steerView.addSubview(self.followport)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        return ans;
    }
    
    func turnRatioAlert(sender: Any, event: UIEvent)->String{
        var ans = String()
        let alert = UIAlertController(title: "Turn Ratio", message: "Enter a turn ratio from 0 to 100", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "0"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(String(describing: textField?.text))");
            
            let x = String(describing: textField?.text);
            ans = self.getContent(s: x)
            print("ans")
            print(ans)
            
            self.turnratio.frame = CGRect(x: 80, y: 85, width: 35, height: 30)
            self.turnratio.text = ans
            
            self.steerView.addSubview(self.turnratio)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        return ans;
    }
    
    
    func printViewSequence(){
        for view in viewSequence{
            print(view)
        }
    }
    
    func test(action: UIAlertAction){
        sendToServer()
    }
    
    func getLabelsInView(view: UIView) -> [UILabel] {
        var results = [UILabel]()
        for subview in view.subviews as [UIView] {
            if let labelView = subview as? UILabel {
                results += [labelView]
            } else {
                results += getLabelsInView(view: subview)
            }
        }
        return results
    }
    
    func hello(){
        print("hello")
    }
    
    func loadSpeedInputView(){
        print("sup")
        let speedInputFrame = CGRect(x: 250, y: 250, width: 120, height: 160)
        speedInputView = UIView(frame: speedInputFrame)
        speedInputView.backgroundColor = UIColor.clear
        speedInputView.layer.borderColor = PrimaryOrange.cgColor
        speedInputView.layer.borderWidth = 1.2
        speedInputView.layer.cornerRadius = 5
        speedInputView.layer.masksToBounds = true
        speedInputView.isHidden = false
        
        let okayButtonFrame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let okayButton = UIButton(frame: okayButtonFrame )
        okayButton.backgroundColor = UIColor.green
        
        speedInputView.addSubview(okayButton)
        
        okayButton.addTarget(self, action: #selector(self.didPressButtonFromSpeedInputView), for: UIControlEvents.touchUpInside)
        self.view.addSubview(speedInputView)
        
    }
    
    func didPressButtonFromSpeedInputView(sender:UIButton) {
        // do whatever you want
        // make view disappears again, or remove from its superview
        print("quit the popup")
        speedInputView.isHidden = true
        
    }
    
    // MARK: IBActions
    
    func sendToServer()->String{
        var jsonArray = [JSON]()
        var loopOpened = false
        var loopCommands = [JSON]()
        var loopIterations = 0
        for i in  0..<objectSequence.count{
            if(objectSequence[i].type == "motor"){
                let motorObj = objectSequence[i] as! MotorObject
                let json: JSON = ["type":"motor", "brake": motorObj.brake , "power": motorObj.speed, "revolutions": motorObj.rotations, "port":motorObj.port]
                if (loopOpened){
                    loopCommands.append(json)
                } else {
                    jsonArray.append(json)
                }
            }else if(objectSequence[i].type == "sound"){
                let soundObj = objectSequence[i] as! SoundObject
                let json: JSON = ["type": "playsound", "freq": soundObj.getVolume(), "duration": soundObj.duration * 1000]
                if (loopOpened){
                    loopCommands.append(json)
                } else {
                    jsonArray.append(json)
                }
            }else if(objectSequence[i].type == "wait"){
                let waitObj = objectSequence[i] as! WaitObject
                let json: JSON = ["type":"wait", "duration": waitObj.time]
                if (loopOpened){
                    print("Appending a wait to the loop")
                    loopCommands.append(json)
                } else {
                    jsonArray.append(json)
                }
            }else if(objectSequence[i].type == "startLoop"){
                loopOpened = true
                let loopObj = objectSequence[i] as! StartLoopObject
                loopIterations = loopObj.getLoops()
            }else if(objectSequence[i].type == "endLoop"){
                loopOpened = false
                let json: JSON = ["type": "loop", "iterations": loopIterations, "commands": loopCommands]
                jsonArray.append(json)
                loopIterations = 0
                loopCommands = []
            } else if (objectSequence[i].type == "steer") {
                var steerObj = SteerObject(ty: "steer")
                steerObj = objectSequence[i] as! SteerObject
                let json: JSON = ["type":"syncmotor", "brake": steerObj.brake , "power": steerObj.power, "revolutions": steerObj.revolutions, "leadport": steerObj.leadport, "followport": steerObj.followport, "turnratio":steerObj.turnratio]
                if (loopOpened){
                    loopCommands.append(json)
                } else {
                    jsonArray.append(json)
                }
            }
        }
        
        for BrickObject in objectSequence {
            print(BrickObject.type)
//            else if(BrickObject.type == "startLoop"){
//                /***********************************/
//                //TODO: startloop, endloop and steer jsons need testing
//                /***********************************/
//                var startLoopObj = StartLoopObject(ty: "startLoop")
//                startLoopObj = BrickObject as! StartLoopObject
//                let json = JSON()
//                if(startLoopObj.sensor == "touch"){
//                    json = ["type":"touch", "port": startLoopObj.port, "condition:" ]
//                }
//                jsonArray.append(json)
//            } else if(BrickObject.type == "endLoop") {
//                var endLoopObj = EndLoopObject(ty: "endLoop")
//                endLoopObj = BrickObject as! EndLoopObject
//                let json: JSON = ["type":"endLoop"]
//                jsonArray.append(json)
//            } else if (BrickObject.type == "steer") {
//                var steerObj = SteerObject(ty: "steer")
//                steerObj = BrickObject as! SteerObject
//                let json: JSON = ["type":"syncmotor", "brake": steerObj.brake , "power": steerObj.power, "revolutions": steerObj.revolutions, "leadport": steerObj.leadport, "followport": steerObj.followport, "turnratio":steerObj.turnratio]
//                jsonArray.append(json)
//            }
        }
        
        let jsonStr: JSON = ["address" : self.chosenMacAddress, "commands" : jsonArray]
        let jsonString = jsonStr.description
        
        print(jsonString)
        
        return jsonString
//        self.client.socket.emit("run code", jsonString)
//
//        print("SENDING THIS JSON: " )
//        print(jsonString.description)
    }
    
    @IBAction func buildBarButtonDidPress(_ sender: UIBarButtonItem) {
        if self.chosenMacAddressIndex > -1 && self.client.connected {
            //print("Mac address that is selected: \(self.chosenMacAddress)")
            let jsonString = sendToServer()
            self.client.socket.emit("run code", jsonString)
            print("Sending this to the server")
            print(jsonString)
            print("Build request was sent to server with the selected mac address")
        }
    }
    
    // NEED THIS IBAction FUNCTION TO SAVE A PROGRAM
    @IBAction func saveBarButtonDidPress(_ sender: UIBarButtonItem) {
        
        let jsonString = sendToServer()
        
        
        if self.isNewProgram! {
            let alertController = UIAlertController(title: title, message: "Enter the name of this program", preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
                if let field = alertController.textFields?[0] {
                    let valid = ProgramManager.saveNewProgramWith(programName: field.text!, programJSON: jsonString)
                    print("Saving program with name: \(field.text!)")
                    print ("Saving program with json: \(jsonString)")
                    if !valid {
                        self.addAlert(title: "Error", message: "A program with the same name already exists")
                    } else {
                        self.isNewProgram = false
                        self.programName = field.text!
                        self.realmID = ProgramManager.getID(programName: self.programName)
                        self.addAlert(title: "Success", message: "\(field.text!) has been saved")
                        self.collectionDelegate?.sendEventToCollectionView()
                    }
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addTextField(configurationHandler: nil)
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true)
        } else {
            let valid = ProgramManager.updateProgramWith(programName: self.programName, programJSON: jsonString, id: self.realmID)
            print("Saving program with name: \(programName)")
            print ("Saving program with json: \(jsonString)")
            if !valid {
                self.addAlert(title: "Error", message: "A program with the same name already exists")
            } else {
                self.addAlert(title: "Success", message: "\(self.programName) has been saved")
                self.collectionDelegate?.sendEventToCollectionView()
            }
        }
    }
    
    // NEED THIS IBAction FUNCTION TO RETURN TO THE STARTUP SCREEN. COMMENT THIS OUT IF ERRORS SHOW UP
    @IBAction func backBarButtonDidPress(_ sender: UIBarButtonItem) {
        self.collectionDelegate?.sendEventToCollectionView()
        self.dismiss(animated: true)
    }
    
    func createTabs(){
        tabOne = createTabButton(type: "General", _x: 20, _y: 450)
        tabTwo = createTabButton(type: "Loops", _x: 118, _y: 450)
        
        tabOne.addTarget(self, action: #selector(loadViewTabOne), for: UIControlEvents.allTouchEvents)
        tabTwo.addTarget(self, action: #selector(loadViewTabTwo), for: UIControlEvents.allTouchEvents)
    }
    
    func loadViewTabOne(){
        showViewsTabTwo(show: true);
        showViewsTabOne(show: false);
    }
    
    func loadViewTabTwo(){
        showViewsTabTwo(show: false);
        showViewsTabOne(show: true);
    }
    
    func showViewsTabOne(show: Bool){
        medMotorView.isHidden = show;
        largeMotorView.isHidden = show;
        displayView.isHidden = show;
        soundView.isHidden = show;
        steerView.isHidden = show;
    }
    
    func showViewsTabTwo(show: Bool){
        waitView.isHidden = show;
        startLoopView.isHidden = show;
        endLoopView.isHidden = show;
    }
    
    func deleteBlock(sender: Any, event: UIEvent){
        let myButton:UIButton = sender as! UIButton
        let touches: Set<UITouch>? = event.touches(for: myButton)
        let touch: UITouch? = touches?.first
        let touchPoint: CGPoint? = touch?.location(in: self.scrollView)
        
        var i = 0
        for view in viewSequence {
            if(touchPoint != nil && view.frame.contains(touchPoint!)){
                view.isHidden = true
                viewSequence.remove(at: i)
                objectSequence.remove(at: i)
                updateUIViewOrder()
                return
            }
            i = i + 1
        }

    }
    
    func getIndexOfBlock(xLoc: CGPoint)->Int{
        var beginXRange = startPoint.x + 128
        var endXRange = startPoint.x + 128 + 128
        
        print("begin x range: ")
        print(beginXRange)
        print("end x range: ")
        print(endXRange)
        
        print(xLoc)
        var x = xLoc.x
        
        var index = Int()
        index = viewSequence.count
        for i in  0..<viewSequence.count {
            if(x < endXRange && x > beginXRange){
                let view = viewSequence[i]
                view.isHidden = true
                viewSequence.remove(at: i)
                objectSequence.remove(at: i)
                index = i
                updateUIViewOrder()
                return index
            }else{
                beginXRange += 128
                endXRange += 128
            }
        }
        
        return index
    }
    
    func invalidInputAlert(_title: String, msg: String){
        let alert = UIAlertController(title: _title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func addAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
    
    
    // MARK: AddressDelegate functions
    func updateMacAddressWith(index: Int) {
        self.chosenMacAddressIndex = index
        if index > -1 {
            self.chosenMacAddress = self.macAddressArray[self.chosenMacAddressIndex]
        } else {
            self.chosenMacAddress = ""
        }
    }
    
    func storeMacAddressesWith(macAddressArray: Array<String>) {
        self.macAddressArray = macAddressArray
    }
    
    func initializeTableView() {
        self.tableDelegate?.initializeTable(selectedIndex: self.chosenMacAddressIndex, macAddressArray: self.macAddressArray)
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    // NEED THIS FUNCTION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AddressTableViewController {
            destination.addressDelegate = self
            self.tableDelegate = destination
        }
        
        if let destination = segue.destination as? PickerViewController {
            destination.sensorOptions = self.sensorOptions
            destination.compOptions = self.compOptions
            destination.portOptions = self.portOptions
        }
    }
    
    func draggedBlockInCode(_ sender:UIPanGestureRecognizer){
//                let translation = sender.translation(in: self.view)
//                if (sender.state == .began){
//
//                }
//
//                let loc = sender.location(in: scrollView)
//                var touchedView: UIView? = nil
//                for view in viewSequence {
//                    if(view.frame.contains(loc)){
//                        touchedView = view
//                    }
//                }
//                if (touchedView != nil){
//                    touchedView!.center = CGPoint(x: touchedView!.center.x + translation.x, y: touchedView!.center.y + translation.y)
//                    sender.setTranslation(CGPoint.zero, in: self.view)
//
//                    let xLoc = touchedView!.center.x + translation.x
//                    let yLoc = touchedView!.center.y + translation.y
//
//                    if (sender.state == .ended){
//                        for view in viewSequence {
//                            if (view.frame.contains(touchedView!.center)){
//                                print("Dragged onto another block")
//                            }
//                        }
//                    }
//                }
//
        
    }
    
    func openSavedFile(){
        var jsonHelper = JSONHelper()
        let savedArray = JSONHelper.parseJSONWith(json: programJSON) //is a Array<Dictionary<String, Any>>
        for sa in savedArray{
            let typeView = sa["type"] as! String!
            if(typeView == "motor"){
                let tempView = createMedMotor()
                let labels = getLabelsInView(view: tempView)
                labels[6].text = sa["power"] as! String!
                labels[7].text = sa["revolutions"] as! String!
                labels[8].text = sa["brake"] as! String!
                labels[9].text = sa["port"] as! String!
                viewSequence.append(tempView)
            }else if(typeView == "playsound"){
                let tempView = createSound()
                let labels = getLabelsInView(view: tempView)
                labels[5].text = sa["frequency"] as! String!
                labels[6].text = sa["soundfile"] as! String!
                labels[7].text = sa["duration"] as! String!
                viewSequence.append(tempView)
            }else if(typeView == "touch"){
                
            }else if(typeView == "wait"){
                let tempView = createWait()
                let labels = getLabelsInView(view: tempView)
                labels[3].text = sa["duration"] as! String!
                viewSequence.append(tempView)
            }
        }
        updateUIViewOrder()
    }
    
}

