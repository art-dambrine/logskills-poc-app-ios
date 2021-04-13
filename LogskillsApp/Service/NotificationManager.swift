//
//  NotificationManager.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 13/04/2021.
//

import Foundation
import UserNotifications

struct NotifParams {
    let id: Int
    let triggerTimeInterval: Int
    let isRoundNotif: Bool
    let notifRoundOrPauseCurrent: Int
    let notifRoundOrPauseMax: Int
    let isEndOfPomodoro: Bool
}

class NotificationManager {
    
    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }
    
    @objc func scheduleLocal(triggerTimeInterval: Int, currentIsRound: Bool = false,
                             nbOfCurrentRoundOrPause: Int = 0, nbOfMaxRoundOrPause: Int = 0, isEndOfPomodoro: Bool = false) {
        
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        
        if(!isEndOfPomodoro){
            if(currentIsRound){
                // Fin d'un round
                content.title = "Fin du round \(nbOfCurrentRoundOrPause)/\(nbOfMaxRoundOrPause) !"
                
                if (nbOfCurrentRoundOrPause == nbOfMaxRoundOrPause) {
                    content.body = "Fin de la session revenez sur l'app pour enregistrer la progression."
                } else {
                    content.body = "Revenez sur l'application et pensez à prendre une pause."
                }
                
            } else {
                // Fin d'une pause
                content.title = "Fin de la pause \(nbOfCurrentRoundOrPause)/\(nbOfMaxRoundOrPause) !"
                content.body = "Retour en mode mode focus, let's go !"
            }
        } else {
            // Fin du pomodoro complet
            content.title = "Fin de la session !"
            content.body = "Revenez sur l'app pour enregistrer la progression."
        }
        
        
        
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default

        // var dateComponents = DateComponents()
        // dateComponents.hour = 10
        // dateComponents.minute = 30
        
        // let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(triggerTimeInterval), repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    
    @objc func removeAllPendingNotification() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
            
}
