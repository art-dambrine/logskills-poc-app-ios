//
//  PomodoroView.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 11/04/2021.
//

import SwiftUI

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
                            self.timerManager.setTimerlength(secondes: self.availableMinutes[self.selectedPickerIndex]*60)
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
