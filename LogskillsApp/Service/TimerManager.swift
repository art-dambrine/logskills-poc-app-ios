//
//  TimerManager.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 12/04/2021.
//

import Foundation
import UIKit

enum TimerMode {
    case running
    case paused
    case initial
    case breaktime
}

class TimerManager: ObservableObject {
    
    @Published var timerMode: TimerMode = .initial
    
    @Published var secondsLeft = UserDefaults.standard.integer(forKey: "timerlength") + 1
    
    @Published var seconds: String = "00"
    @Published var minutes: String = "00"
    
    @Published var pomodoroCompleted: Bool = false
    
    @Published var roundCurrent = 1
    @Published var pauseCurrent = 0
    
    var nbRoundMax = 3
    var nbPauseMax = 2
    var pauseLength = 5
    
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    var timer: Timer? = nil
    
    init(){
        NotificationCenter.default.addObserver(
            self, selector: #selector(reinstateBackgroundTask),
            name: UIApplication.didBecomeActiveNotification, object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    func startTimerBackPreceeding(nbRoundMaxParam: Int, nbPauseMaxParam: Int, pauseLengthParam: Int){
        
        self.nbRoundMax = nbRoundMaxParam
        self.nbPauseMax = nbPauseMaxParam
        self.pauseLength = pauseLengthParam
        
        timerMode = .running
        
        self.roundCurrent = 1
        self.pauseCurrent = 0
        
        startTimerBack()
        
    }
    
    
    @IBAction func startTimerBack() {
        
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                          selector: #selector(calculateRemainingTime), userInfo: nil, repeats: true)
        // register background task
        registerBackgroundTask()
        
    }
    
    
    
    @objc func calculateRemainingTime() {
        
        // 2. Check time to change values
        self.secondsLeft -= 1
        
        self.displayHumanReadableTimer()
        
        
        if self.secondsLeft == 0 {
            
            if(self.roundCurrent == nbRoundMax && self.pauseCurrent == nbPauseMax){
                
                self.endTimer()
                
                // Launch call to API to save completion
                // ...
                
            } else {
                
                if (self.roundCurrent > self.pauseCurrent){
                    self.pauseCurrent += 1
                    self.secondsLeft = pauseLength
                    self.timerMode = .breaktime
                } else {
                    self.roundCurrent += 1
                    self.secondsLeft = UserDefaults.standard.integer(forKey: "timerlength") + 1
                    self.timerMode = .running
                }
                
            }
            
            
        }
        
        switch UIApplication.shared.applicationState {
        case .active:
            //print("App is backgrounded. Next secondsLeft = \(secondsLeft)")
            break
        case .background:
            print("App is backgrounded. Next secondsLeft = \(secondsLeft)")
            print("Background time remaining = \(UIApplication.shared.backgroundTimeRemaining) seconds")
            break
        case .inactive:
            break
        @unknown default:
            print("Background ERROR default l 212")
            break
        }
        
    }
    
    
    func displayHumanReadableTimer(){
        if (self.secondsLeft > 60) {
            
            if (self.secondsLeft % 60) < 10 {
                self.seconds = "0" + String(self.secondsLeft % 60)
            } else {
                self.seconds = String(self.secondsLeft % 60)
            }
            
            
            if (self.secondsLeft / 60) < 10 {
                self.minutes = "0" + String(self.secondsLeft / 60)
            } else {
                self.minutes = String(self.secondsLeft / 60)
            }
            
        } else {
            
            if self.secondsLeft < 10 {
                self.seconds = "0" + String(self.secondsLeft)
            } else {
                self.seconds = String(self.secondsLeft)
            }
            self.minutes = String("00")
        }
    }
    
    func stopTimer(){
        timerMode = .paused
        self.timer?.invalidate()
        self.timer = nil
        
        if backgroundTask != .invalid {
            endBackgroundTask()
        }
    }
    
    func restartTimer(){
        timerMode = .initial
        self.secondsLeft = UserDefaults.standard.integer(forKey: "timerlength")
        self.minutes = "00"
        self.seconds = "00"
    }
    
    func endTimer(){
        timerMode = .initial
        self.timer?.invalidate()
        self.timer = nil
        self.minutes = "00"
        self.seconds = "00"
    }
    
    func setTimerlength(secondes: Int){
        UserDefaults.standard.set(secondes, forKey: "timerlength")
        self.secondsLeft = secondes
    }
    
    
    
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != .invalid)
    }
    
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
    
    
    @objc func reinstateBackgroundTask() {
        if self.timer != nil && backgroundTask == .invalid {
            registerBackgroundTask()
        }
    }
    
}
