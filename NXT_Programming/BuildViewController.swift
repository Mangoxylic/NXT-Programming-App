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
    
    init(ty: String) {
        super.init(typeObj: ty)
    }
    
    func setSpeed(newSpeed: Int){ speed = newSpeed }
    func setRotations(newRot: Int){ rotations = newRot }
    func setBrake(newBrake: Bool){ brake = newBrake }
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
    
    init(ty: String) {
        super.init(typeObj: ty)
    }
    
    func setVolume(newVol: Int){volume = newVol}
    func setTypeSound(newType: String){typeSound = newType}
    func getVolume()->Int{return volume}
    func getTypeSound()->String{return typeSound}
}
class WaitObject : BrickObject{
    var time: Int = 0
    
    init(ty: String){
        super.init(typeObj: ty)
    }
    
    func setTime(newTime: Int){time = newTime}
    func getTime()->Int{return time}
}

class BuildViewController: UIViewController, AddressDelegate {
    
    @IBOutlet weak var mediumMotorButtonUI: UIButton!
    @IBOutlet weak var largeMotorButtonUI: UIButton!
    @IBOutlet weak var moveSteeringButtonUI: UIButton!
    @IBOutlet weak var moveTankButtonUI: UIButton!
    @IBOutlet weak var soundButtonUI: UIButton!
    @IBOutlet weak var idLabel: UILabel!
    
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
    var viewSequence = [UIView]()
    
    var speedInputView = UIView()
    
    let speedMM = UILabel()
    let rotationMM = UILabel()
    let brakeMM = UILabel()
    var objectSequence = [BrickObject]()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createStartButton()
        medMotorView = createMedMotor()
        //largeMotorView = createLargeMotor()
        displayView = createDisplay()
        soundView = createSound()
        waitView = createWait()
        sendJSON = createButton(title: "send", _x: 700, _y: 700, _width: 120, _height: 80)
        sendJSON.addTarget(self, action: #selector(sendToServer), for: UIControlEvents.touchUpInside)
        self.view.addSubview(sendJSON)
        createTabs()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    /**
     * functions to do UI buttons (replacing, creating, dragging and
     */
    
    func createTabButton(type: String, _x: Int, _y: Int) -> UIButton {
        let button = UIButton()
        button.frame = CGRect(x: _x, y: _y, width: 96, height: 40)
        button.setTitle(type, for: UIControlState())
        button.backgroundColor = UIColor.red
        button.layer.borderWidth = 1.2
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
        button.tag = 1
        self.view.addSubview(button)
        return button
    }
    
    func createStartButton(){
        startButton.frame = CGRect(x: 20, y: 370, width: 125, height: 100)
        startButton.setTitle("start", for: UIControlState())
        startButton.addTarget(self, action: #selector(dragStart(control:event:)), for: UIControlEvents.touchDragExit)
        startButton.layer.borderColor = UIColor.yellow.cgColor
        startButton.backgroundColor = UIColor.blue
        startButton.layer.borderWidth = 1.2
        startButton.layer.cornerRadius = 5
        startButton.layer.masksToBounds = true
        startButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        startButton.tag = 1
        startPoint = startButton.frame.origin
        self.view.addSubview(startButton)
        nextPoint = startPoint
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
        button.backgroundColor = UIColor.red
        button.layer.borderWidth = 1.2
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
        return button;
    }
    
    func createMedMotor()->UIView{
        let tempView = UIView()
        tempView.backgroundColor = UIColor.yellow
        tempView.frame = CGRect(x: 25, y: 100, width: 120, height: 160)
        
        var speedButton = UIButton()
        speedButton = createButton(title: "speed", _x: 0, _y: 80, _width: 35, _height: 40);
        
        var rotationButton = UIButton();
        rotationButton = createButton(title: "rotation", _x: 40, _y: 80, _width: 35, _height: 40)
        
        var brakeButton = UIButton();
        brakeButton = createButton(title: "brake", _x: 80, _y: 80, _width: 35, _height: 40)
        
        var deleteButton = UIButton();
        deleteButton = createButton(title: "X", _x: 80, _y: 0, _width: 20, _height: 30)
        
        let name = UILabel()
        name.frame = CGRect(x: 0, y: 0, width: 120, height: 40)
        name.text = "Medium Motor"
        
        //var speed = UILabel()
        speedMM.frame = CGRect(x: 0, y: 40, width: 35, height: 30)
        speedMM.text = "50"
        
        //var rotation = UILabel()
        rotationMM.frame = CGRect(x: 40, y: 40, width: 35, height: 30)
        rotationMM.text = "1"
        
        //var brake = UILabel()
        brakeMM.frame = CGRect(x: 80, y: 40, width: 35, height: 30)
        brakeMM.text = "Yes"
        
        var panGesture = UIPanGestureRecognizer()
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedViewMM(_:)))
        tempView.isUserInteractionEnabled = true
        tempView.addGestureRecognizer(panGesture)
        
        speedButton.addTarget(self, action: #selector(testAlertInput), for: UIControlEvents.touchUpInside)
        speedButton.tag = 1
        rotationButton.addTarget(self, action: #selector(testAlert1), for: UIControlEvents.touchUpInside)
        brakeButton.addTarget(self, action: #selector(testAlert3), for: UIControlEvents.touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteBlock(sender:event:)), for: UIControlEvents.touchUpInside)
        tempView.addSubview(name)
        tempView.addSubview(speedMM)
        tempView.addSubview(rotationMM)
        tempView.addSubview(brakeMM)
        tempView.addSubview(speedButton)
        tempView.addSubview(rotationButton)
        tempView.addSubview(brakeButton)
        tempView.addSubview(deleteButton)
        self.view.addSubview(tempView)
        
        return tempView
    }
    
    func createDisplay()->UIView{
        let tempView = UIView()
        tempView.backgroundColor = UIColor.yellow
        tempView.frame = CGRect(x: 500, y: 100, width: 120, height: 160)
        
        var clearScreenButton = UIButton();
        clearScreenButton = createButton(title: "clear", _x: 0, _y: 80, _width: 35, _height: 40)
        
        var xButton = UIButton();
        xButton = createButton(title: "x", _x: 40, _y: 80, _width: 35, _height: 40)
        
        var yButton = UIButton();
        yButton = createButton(title: "y", _x: 80, _y: 80, _width: 35, _height: 40)
        
        var deleteButton = UIButton();
        deleteButton = createButton(title: "X", _x: 80, _y: 0, _width: 20, _height: 30)
        
        let name = UILabel()
        name.frame = CGRect(x: 0, y: 0, width: 120, height: 40)
        name.text = "Display"
        
        let clear = UILabel()
        clear.frame = CGRect(x: 0, y: 40, width: 35, height: 30)
        clear.text = "50"
        
        let xLoc = UILabel()
        xLoc.frame = CGRect(x: 40, y: 40, width: 35, height: 30)
        xLoc.text = "1"
        
        let yLoc = UILabel()
        yLoc.frame = CGRect(x: 80, y: 40, width: 35, height: 30)
        yLoc.text = "Yes"
        
        
        var panGesture = UIPanGestureRecognizer()
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedViewD(_:)))
        tempView.isUserInteractionEnabled = true
        tempView.addGestureRecognizer(panGesture)
        
        clearScreenButton.addTarget(self, action: #selector(testAlert1), for: UIControlEvents.touchUpInside)
        xButton.addTarget(self, action: #selector(testAlert2), for: UIControlEvents.touchUpInside)
        yButton.addTarget(self, action: #selector(testAlert3), for: UIControlEvents.touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteBlock(sender:event:)), for: UIControlEvents.touchUpInside)
        tempView.addSubview(name)
        tempView.addSubview(clear)
        tempView.addSubview(xLoc)
        tempView.addSubview(yLoc)
        tempView.addSubview(clearScreenButton)
        tempView.addSubview(xButton)
        tempView.addSubview(yButton)
        tempView.addSubview(deleteButton)
        self.view.addSubview(tempView)
        
        return tempView
    }
    
    func createSound()->UIView{
        let tempView = UIView()
        tempView.backgroundColor = UIColor.yellow
        tempView.frame = CGRect(x: 650, y: 100, width: 120, height: 160)
        
        var volumeButton = UIButton();
        volumeButton = createButton(title: "volume", _x: 0, _y: 80, _width: 35, _height: 40)
        
        var playTypeButton = UIButton();
        playTypeButton = createButton(title: "type", _x: 40, _y: 80, _width: 35, _height: 40)
        
        var deleteButton = UIButton();
        deleteButton = createButton(title: "X", _x: 80, _y: 0, _width: 20, _height: 30)
        
        let name = UILabel()
        name.frame = CGRect(x: 0, y: 0, width: 120, height: 40)
        name.text = "Sound"
        
        let volume = UILabel()
        volume.frame = CGRect(x: 0, y: 40, width: 35, height: 30)
        volume.text = "50"
        
        let playType = UILabel()
        playType.frame = CGRect(x: 40, y: 40, width: 35, height: 30)
        playType.text = "1"
        
        var panGesture = UIPanGestureRecognizer()
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedViewS(_:)))
        tempView.isUserInteractionEnabled = true
        tempView.addGestureRecognizer(panGesture)
        
        volumeButton.addTarget(self, action: #selector(testAlert1), for: UIControlEvents.touchUpInside)
        playTypeButton.addTarget(self, action: #selector(testAlert2), for: UIControlEvents.touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteBlock(sender:event:)), for: UIControlEvents.touchUpInside)
        tempView.addSubview(name)
        tempView.addSubview(volume)
        tempView.addSubview(playType)
        tempView.addSubview(volumeButton)
        tempView.addSubview(playTypeButton)
        tempView.addSubview(deleteButton)
        self.view.addSubview(tempView)
        
        return tempView
    }
    
    func createWait()->UIView{
        let tempView = UIView()
        tempView.backgroundColor = UIColor.yellow
        tempView.frame = CGRect(x: 800, y: 100, width: 120, height: 160)
        
        var timeButton = UIButton();
        timeButton = createButton(title: "time", _x: 0, _y: 80, _width: 35, _height: 40)
        
        var deleteButton = UIButton();
        deleteButton = createButton(title: "X", _x: 80, _y: 0, _width: 20, _height: 30)
        
        let name = UILabel()
        name.frame = CGRect(x: 0, y: 0, width: 120, height: 40)
        name.text = "Wait"
        
        let time = UILabel()
        time.frame = CGRect(x: 0, y: 40, width: 35, height: 30)
        time.text = "50"
        
        var panGesture = UIPanGestureRecognizer()
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedViewW(_:)))
        tempView.isUserInteractionEnabled = true
        tempView.addGestureRecognizer(panGesture)
        
        timeButton.addTarget(self, action: #selector(testAlert1), for: UIControlEvents.touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteBlock(sender:event:)), for: UIControlEvents.touchUpInside)
        
        tempView.addSubview(name)
        tempView.addSubview(time)
        tempView.addSubview(timeButton)
        tempView.addSubview(deleteButton)
        self.view.addSubview(tempView)
        
        return tempView
    }
    
    func replaceView(type: String) -> UIView{
        if(type == "medMotorView"){
            medMotorView = createMedMotor()
            return medMotorView
        }
            //        else if(type == "largeMotorView"){
            //            largeMotorView = createLargeMotor()
            //            return largeMotorView
            //        }
        else if(type == "displayView"){
            displayView = createDisplay()
            return displayView
        }else if(type == "soundView"){
            soundView = createSound()
            return soundView
        }else{ //waitView
            waitView = createWait()
            return waitView
        }
    }
    
    func updateUIViewOrder(){
        var x = startPoint.x
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
        
        let xLoc = medMotorView.center.x + translation.x
        let yLoc = medMotorView.center.y + translation.y
        
        var index = Int()
        index = viewSequence.count
        var toAppend = Bool()
        toAppend = false
        
        if(yLoc > 300 && yLoc < 440){
            //if dragged to end
            if(xLoc > (nextPoint.x + 128)){
                medMotorView.center = CGPoint(x: nextPoint.x + 128, y: nextPoint.y)
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
            //            if(validPlacement){
            let newMM = MotorObject(ty: "motor");
            newMM.setSpeed(newSpeed: 50)
            newMM.setBrake(newBrake: true)
            newMM.setRotations(newRot: 5)
            if(toAppend){
                objectSequence.append(newMM);
                viewSequence.append(medMotorView)
            }else{
                objectSequence.insert(newMM, at: index)
                viewSequence.insert(medMotorView, at: index)
            }
            updateUIViewOrder()
            //            }else{
            //                medMotorView.isHidden = true
            //            }
            
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
        
        if(yLoc > 300 && yLoc < 440){
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
            //            if(validPlacement){
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
            //            }else{
            //                displayView.isHidden = true
            //            }
            
            displayView = replaceView(type: "displayView")
        }
    }
    
    func draggedViewS(_ sender:UIPanGestureRecognizer){
        let translation = sender.translation(in: self.view)
        soundView.center = CGPoint(x: soundView.center.x + translation.x, y: soundView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
        
        let xLoc = soundView.center.x + translation.x
        let yLoc = soundView.center.y + translation.y
        
        var index = Int()
        index = viewSequence.count
        var toAppend = Bool()
        toAppend = false
        
        if(yLoc > 300 && yLoc < 440){
            //if dragged to end
            if(xLoc > (nextPoint.x + 128)){
                soundView.center = CGPoint(x: nextPoint.x + 128, y: nextPoint.y)
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
            //            if(validPlacement){
            let newS = SoundObject(ty: "sound");
            newS.setTypeSound(newType: "playsound")
            newS.setVolume(newVol: 500)
            if(toAppend){
                objectSequence.append(newS);
                viewSequence.append(soundView)
            }else{
                objectSequence.insert(newS, at: index)
                viewSequence.insert(soundView, at: index)
            }
            updateUIViewOrder()
            //            }else{
            //                soundView.isHidden = true
            //            }
            soundView = replaceView(type: "soundView")
        }
    }
    
    func draggedViewW(_ sender:UIPanGestureRecognizer){
        let translation = sender.translation(in: self.view)
        waitView.center = CGPoint(x: waitView.center.x + translation.x, y: waitView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
        
        let xLoc = waitView.center.x + translation.x
        let yLoc = waitView.center.y + translation.y
        
        var index = Int()
        index = viewSequence.count
        var toAppend = Bool()
        toAppend = false
        
        if(yLoc > 300 && yLoc < 440){
            //if dragged to end
            if(xLoc > (nextPoint.x + 128)){
                waitView.center = CGPoint(x: nextPoint.x + 128, y: nextPoint.y)
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
                        break
                    }else{
                        beginXRange += 128
                        endXRange += 128
                    }
                }
            }
        }
        if(sender.state == UIGestureRecognizerState.ended){
            print("in state ended wait")
            //if(validPlacement){
            let newW = WaitObject(ty: "wait");
            newW.setTime(newTime: 500);
            if(toAppend){
                objectSequence.append(newW);
                viewSequence.append(waitView)
                print("appending wait")
            }else{
                objectSequence.insert(newW, at: index)
                viewSequence.insert(waitView, at: index)
                print("inserting wait")
            }
            updateUIViewOrder()
            print("UI should attach")
            //}else{
            //waitView.isHidden = true
            //print("meh")
            //}
            waitView = replaceView(type: "waitView")
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
    
    func testAlertInput(){
        let alert = UIAlertController(title: "Some Title", message: "Enter a text", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = "default text"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(String(describing: textField?.text))");
            
            let x = String(describing: textField?.text);
            let ans = self.getContent(s: x)
            print("ans")
            print(ans)
            self.speedMM.text = ans
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func testAlert1(){
        let alert = UIAlertController(title: "Some Title", message: "Enter a text", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "default text"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(String(describing: textField?.text))");
            let x = String(describing: textField?.text);
            let ans = self.getContent(s: x)
            print("ans")
            print(ans)
            self.rotationMM.text = ans
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func testAlert2(){
        var alert = UIAlertController()
        alert = UIAlertController(title: "My Second Alert", message: "This is an alert type 2.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func testAlert3(){
        var alert = UIAlertController()
        alert = UIAlertController(title: "My Third Alert", message: "This is an alert type 3.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func printViewSequence(){
        for view in viewSequence{
            print(view)
        }
    }
    
    func test(action: UIAlertAction){
        print("printing objects" )
        for BrickObject in objectSequence {
            print(BrickObject)
        }
    }
    
    func loadSpeedInputView(){
        print("sup")
        let speedInputFrame = CGRect(x: 250, y: 250, width: 120, height: 160)
        speedInputView = UIView(frame: speedInputFrame)
        speedInputView.backgroundColor = UIColor.cyan
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
    
    @IBAction func sendToServer(){
        //let address: String = self.idLabel.text!
        
        var jsonArray = [JSON]()
        
        for BrickObject in objectSequence {
            print(BrickObject.type)
            if(BrickObject.type == "motor"){
                let json: JSON = ["type":"motor", "brake": true, "power": 100, "revolutions":5, "port":"A"]
                jsonArray.append(json)
            }else if(BrickObject.type == "display"){
                let json: JSON = ["type":"DISPLAY", "brake": true, "power": 100, "revolutions":5, "port":"A"]
                jsonArray.append(json)
            }else if(BrickObject.type == "sound"){
                let json: JSON = ["type":"playsound", "soundfile": "Woops"]
                jsonArray.append(json)
            }else if(BrickObject.type == "wait"){
                let json: JSON = ["type":"WAIT", "brake": true, "power": 100, "revolutions":5, "port":"A"]
                jsonArray.append(json)
            }
        }
        
        let jsonString: JSON = ["address" : "00:16:53:19:1E:AC", "commands" : jsonArray]
        let jsonFinal = jsonString.description
        self.client.socket.emit("run code", jsonFinal)
        
        print("SENDING THIS JSON: " )
        print(jsonString.description)
    }
    
    @IBAction func buildBarButtonDidPress(_ sender: UIBarButtonItem) {
        if self.chosenMacAddressIndex > -1 && self.client.connected {
            //print("Mac address that is selected: \(self.chosenMacAddress)")
            
            let json: JSON =  ["commands":[["type":"playsound", "soundfile": "Woops"], ["type":"motor", "brake": true, "power": 100, "revolutions":5, "port":"A"]], "address":self.chosenMacAddress]
            
            
                                                // *********************************************
            let jsonString = json.description   // * CHANGE THIS TO WHAT THE ACTUAL PROGRAM IS *
                                                // *********************************************
            
            self.client.socket.emit("run code", jsonString)
            //print(jsonString)
            print("Build request was sent to server with the selected mac address")
        }
    }
    
    // NEED THIS IBAction FUNCTION TO SAVE A PROGRAM
    @IBAction func saveBarButtonDidPress(_ sender: UIBarButtonItem) {
        
                            // *********************************************
        let jsonString = "" // * CHANGE THIS TO WHAT THE ACTUAL PROGRAM IS *
                            // *********************************************
        
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
        tabOne = createTabButton(type: "General", _x: 20, _y: 600)
        tabTwo = createTabButton(type: "General 2", _x: 118, _y: 600)
        
        tabOne.addTarget(self, action: #selector(loadViewTabOne), for: UIControlEvents.allTouchEvents)
        tabTwo.addTarget(self, action: #selector(loadViewTabTwo), for: UIControlEvents.allTouchEvents)
    }
    
    func loadViewTabOne(){
        waitView.isHidden = true;
        showViews(show: false);
    }
    
    func loadViewTabTwo(){
        waitView.isHidden = false;
        showViews(show: true);
    }
    
    func showViews(show: Bool){
        medMotorView.isHidden = show;
        largeMotorView.isHidden = show;
        displayView.isHidden = show;
        soundView.isHidden = show;
    }
    
    func deleteBlock(sender: Any, event: UIEvent){
        print("in delete block")
        let myButton:UIButton = sender as! UIButton
        let touches: Set<UITouch>? = event.touches(for: myButton)
        let touch: UITouch? = touches?.first
        let touchPoint: CGPoint? = touch?.location(in: self.view)
        print("touchPoint\(touchPoint)")
        
        var beginXRange = startPoint.x
        var endXRange = startPoint.x + 128
        print("begin x range: ")
        print(beginXRange)
        print("end x range: ")
        print(endXRange)
        
        let xLoc = touchPoint?.x
        print("touchpoint x: ")
        print(xLoc)
        for i in  0..<viewSequence.count {
            if(xLoc! < endXRange && xLoc! > beginXRange){
                let view = viewSequence[i]
                view.isHidden = true
                viewSequence.remove(at: i)
                objectSequence.remove(at: i)
                updateUIViewOrder()
                return
            }else{
                beginXRange += 128
                endXRange += 128
            }
        }
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
     }
    
}
