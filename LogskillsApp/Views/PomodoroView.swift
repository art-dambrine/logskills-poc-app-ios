//
//  PomodoroView.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 11/04/2021.
//

import SwiftUI

struct PomodoroView: View {
    
    @State var seconds: Int = 0
    @State var minutes: Int = 0
    @State var hours: Int = 0
    
    @State var timer: Timer? = nil
    @State var timerIsPaused: Bool = true
    
    func startTimer(){
        timerIsPaused = false
        // 1. Make a new timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ tempTimer in
            // 2. Check time to add to H:M:S
            if self.seconds == 59 {
                self.seconds = 0
                if self.minutes == 59 {
                    self.minutes = 0
                    self.hours = self.hours + 1
                } else {
                    self.minutes = self.minutes + 1
                }
            } else {
                self.seconds = self.seconds + 1
            }
        }
    }
    
    func stopTimer(){
        timerIsPaused = true
        timer?.invalidate()
        timer = nil
    }
    
    func restartTimer(){
        self.hours = 0
        self.minutes = 0
        self.seconds = 0
    }
    
    var body: some View {
        VStack {
            Text("\(hours):\(minutes):\(seconds)")
            
            if timerIsPaused {
                HStack {
                    Button(action:{
                        self.restartTimer()
                        print("RESTART")
                    }){
                        Image(systemName: "backward.end.alt")
                            .padding(.all)
                    }
                    .padding(.all)
                    Button(action:{
                        self.startTimer()
                        print("START")
                    }){
                        Image(systemName: "play.fill")
                            .padding(.all)
                    }
                    .padding(.all)
                }
            } else {
                Button(action:{
                    print("STOP")
                    self.stopTimer()
                }){
                    Image(systemName: "stop.fill")
                        .padding(.all)
                }
                .padding(.all)
            }
            
        }
    }
}

struct PomodoroView_Previews: PreviewProvider {
    static var previews: some View {
        PomodoroView()
    }
}
