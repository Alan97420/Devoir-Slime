//
//  slime_interface.swift
//  Happy_slime
//
//  Created by Alan CHAN CHUN TIM on 21/11/2019.
//  Copyright © 2019 Alan CHAN CHUN TIM. All rights reserved.
//


import UIKit
import SceneKit
import CoreMotion
import CoreLocation
import AVFoundation

class slime_interface: UIViewController, CLLocationManagerDelegate, AVAudioPlayerDelegate {


    @IBOutlet weak var SceneView: SCNView!
    @IBOutlet weak var bar1: UIProgressView!
    @IBOutlet weak var bar2: UIProgressView!
    @IBOutlet weak var bar3: UIProgressView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var Point: UILabel!
    
    
    
    private let activityManager = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    private var shouldStartUpdating: Bool = false
    private var startDate: Date? = nil
    
    var audioPlayer: AVAudioPlayer?
     
    var popo:Int = 0
    var lifeTimer: Timer?
    var energieTimer: Timer?
    var hengerTimer: Timer?
    
    private let manager = CLLocationManager()
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        startBackgroundMusic(backgroundMusicFileName: "gamemus")
        // timer for diffrents elements
        lifeTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(progLife), userInfo: nil, repeats: true)
        energieTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(progEnergie), userInfo: nil, repeats: true)
        hengerTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(proHenger), userInfo: nil, repeats: true)
        
        
        
        let scene = SCNScene(named: "art.scnassets/slim.scn")!
            bar1.transform = bar1.transform.scaledBy(x: 1, y: 8)
            bar2.transform = bar2.transform.scaledBy(x: 1, y: 8)
            bar3.transform = bar3.transform.scaledBy(x: 1, y: 8)
                            
            // create and add a camera to the scene
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            scene.rootNode.addChildNode(cameraNode)
            self.view.backgroundColor = UIColor.white
                            
            // place the camera
            cameraNode.position = SCNVector3(x: 5, y: 1, z: 0)
            cameraNode.rotation = SCNVector4(x: 0, y: 1, z: 0, w:1.5708)
                                                
            // create and add an ambient light to the scene
            let ambientLightNode = SCNNode()
            ambientLightNode.light = SCNLight()
            ambientLightNode.light!.type = .ambient
            ambientLightNode.light!.color = UIColor.white
            
            scene.rootNode.addChildNode(ambientLightNode)
            startButton.addTarget(self, action: #selector(didTapStartButton), for: .touchUpInside)
                            

            // set the scene to the view
            SceneView.scene = scene
                            
            // allows the user to manipulate the camera
            SceneView.allowsCameraControl = true
                            
                            
            // configure the view
            SceneView.backgroundColor = UIColor.white
     
           
        }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location  = locations[0]

        label3.text = String(Int(location.altitude))
    }

    @objc private func progLife (){
        if (self.bar2.progress)<=0.00{
            self.bar1.progress -= 0.05
        }
    }
    @objc private func progEnergie (){
        
        if (self.bar3.progress) <= 0.00 {
            self.bar2.progress -= 0.05*2
        }else{
            self.bar2.progress -= 0.05
        }
    }
    @objc private func proHenger (){
        self.bar3.progress -= 0.06
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let startDate = startDate else { return }
        updateStepsCountLabelUsing(startDate: startDate)
    }
    @objc private func didTapStartButton() {
            shouldStartUpdating = !shouldStartUpdating
            shouldStartUpdating ? (onStart()) : (onStop())
        }
    
    
    @IBAction func btn1(_ sender: Any) {
        if self.popo > 10{
            self.bar1.progress += 0.01
            self.popo -= 10
        }else{
            print("Erreur")
        }
    }
    @IBAction func btn2(_ sender: Any) {
        if self.popo > 5{
            self.bar2.progress += 0.05
            self.popo -= 5
        }else{
            print("Erreur")
        }
    }
    
    @IBAction func btn3(_ sender: Any) {
        if self.popo > 2 {
            self.bar3.progress += 0.05
                self.popo -= 2
            }else{
                print("Erreur")
            }
    }
    func startBackgroundMusic(backgroundMusicFileName: String) {
        if let bundle = Bundle.main.path(forResource: backgroundMusicFileName, ofType: "mp3") {
            let backgroundMusic = NSURL(fileURLWithPath: bundle)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf:backgroundMusic as URL)
                guard let audioPlayer = audioPlayer else { return }
                audioPlayer.numberOfLoops = -1
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            } catch {
                print(error)
            }
        }
    }
    
        
}

extension slime_interface {
    private func onStart() {
        startButton.setTitle("Stop", for: .normal)
        startDate = Date()
        checkAuthorizationStatus()
        startUpdating()
    }
    private func onStop() {
        startButton.setTitle("Start", for: .normal)
        startDate = nil
        stopUpdating()
    }
    private func startUpdating() {
        if CMMotionActivityManager.isActivityAvailable() {
            startTrackingActivityType()
        } else {
            label2.text = NSLocalizedString("text_title1", comment: "Labels")
        }

        if CMPedometer.isStepCountingAvailable() {
            startCountingSteps()
        } else {
            label1.text =  NSLocalizedString("text_title1", comment: "Labels")
        }
    }
    private func checkAuthorizationStatus() {
        switch CMMotionActivityManager.authorizationStatus() {
        case CMAuthorizationStatus.denied:
            onStop()
            label2.text =  NSLocalizedString("text_title1", comment: "Labels")
            label1.text =  NSLocalizedString("text_title1", comment: "Labels")
        default:break
        }
    }
    private func stopUpdating() {
        activityManager.stopActivityUpdates()
        pedometer.stopUpdates()
        pedometer.stopEventUpdates()
    }
    private func on(error: Error) {
        //handle error
    }
    private func updateStepsCountLabelUsing(startDate: Date) {
        pedometer.queryPedometerData(from: startDate, to: Date()) {
            [weak self] pedometerData, error in
            if let error = error {
                self?.on(error: error)
            } else if let pedometerData = pedometerData {
                DispatchQueue.main.async {
                    self?.label1.text = String(describing: pedometerData.numberOfSteps)
                }
            }
        }
    }
    private func startTrackingActivityType() {
        activityManager.startActivityUpdates(to: OperationQueue.main) {
            [weak self] (activity: CMMotionActivity?) in
            guard let activity = activity else { return }
            DispatchQueue.main.async {
                if activity.walking {
                    self?.label2.text =  NSLocalizedString("text_title2", comment: "Labels")
                } else if activity.stationary {
                    self?.label2.text =  NSLocalizedString("text_title3", comment: "Labels")
                } else if activity.running {
                    self?.label2.text =  NSLocalizedString("text_title4", comment: "Labels")
                } else if activity.automotive {
                    self?.label2.text =  NSLocalizedString("text_title5", comment: "Labels")
                }
            }
        }
    }
    private func startCountingSteps() {
            pedometer.startUpdates(from: Date()) {
                [weak self] pedometerData, error in
                guard let pedometerData = pedometerData, error == nil else { return }

                DispatchQueue.main.async {
                    self?.label1.text = pedometerData.numberOfSteps.stringValue
                    self?.popo += (pedometerData.numberOfSteps.intValue) % 2
                    let lolo = String(self?.popo ?? 0)
                    self?.Point.text = lolo
                    
                }
            }
        }
    
       
   }


