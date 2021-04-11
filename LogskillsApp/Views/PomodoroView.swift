//
//  PomodoroView.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 11/04/2021.
//

import SwiftUI

enum TimerMode {
    case running
    case paused
    case initial
}

class TimerManager: ObservableObject {
    
    @Published var timerMode: TimerMode = .initial
    
    @Published var secondsLeft = UserDefaults.standard.integer(forKey: "timerlength")
    
    @Published var seconds: String = "00"
    @Published var minutes: String = "00"
    
    var timer: Timer? = nil
    
    func startTimer(){
        timerMode = .running
        // 1. Make a new timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ tempTimer in
            // 2. Check time to change values
            if self.secondsLeft == 0 {
                self.restartTimer()
            }
            
            self.secondsLeft -= 1
            
            if (self.secondsLeft > 60) {
                self.seconds = String(self.secondsLeft % 60)
                if((self.secondsLeft / 60) < 10 ) {
                    self.minutes = "0" + String(self.secondsLeft / 60)
                } else {
                    self.minutes = String(self.secondsLeft / 60)
                }
                
            } else {
                self.seconds = String(self.secondsLeft)
                self.minutes = String("00")
            }
                        
        }
    }
    
    func stopTimer(){
        timerMode = .paused
        timer?.invalidate()
        timer = nil
    }
    
    func restartTimer(){
        timerMode = .initial
        self.secondsLeft = UserDefaults.standard.integer(forKey: "timerlength")
        self.minutes = "00"
        self.seconds = "00"
    }
    
    func setTimerlength(minutes: Int){
        UserDefaults.standard.set(minutes, forKey: "timerlength")
        secondsLeft = minutes
    }
    
}


struct PomodoroView: View {
    
    @ObservedObject var timerManager = TimerManager()
    
    @State var selectedPickerIndex = 1
    let availableMinutes = Array(1...45)
    
    var body: some View {
        
        VStack {
            
            Text("Start Pomodoro")
                .bold()
                .font(.title2)
            
            Text("\(timerManager.minutes):\(timerManager.seconds)")
                .font(.system(size: 60))
                .padding(.top,10)
            
            if (timerManager.timerMode == .paused || timerManager.timerMode == .initial) {
                VStack {
                    Button(action:{
                        
                        if timerManager.timerMode == .initial {
                            print(self.selectedPickerIndex)
                            self.timerManager.setTimerlength(minutes: self.availableMinutes[self.selectedPickerIndex]*60)
                         }
                        
                        timerManager.startTimer()
                        print("START")
                        
                    }){
                        Image(systemName: "play.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                            .frame(width: 90, height: 90)
                            .foregroundColor(.pink)
                        
                    }
                    .padding(.all)
                    
                    Button(action:{
                        timerManager.restartTimer()
                        print("RESTART")
                    }){
                        Image(systemName: "backward.end.alt")
                            .resizable()
                            .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.red)
                    }
                    .padding(.all)
                }
            } else {
                Button(action:{
                    print("STOP")
                    timerManager.stopTimer()
                }){
                    Image(systemName: "pause.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                        .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                        .foregroundColor(.pink)
                }
                .padding(.all)
            }
            
            if timerManager.timerMode == .initial {
                
                Picker(selection: $selectedPickerIndex, label: Text("")){
                    ForEach(0 ..< availableMinutes.count) {
                        Text("\(self.availableMinutes[$0]) min")
                    }
                }
                .labelsHidden()
                
            }
            
            Spacer()
            
        }
        .padding(.top,20)
        
    }
}

struct PomodoroView_Previews: PreviewProvider {
    static var previews: some View {
        PomodoroView()
    }
}
