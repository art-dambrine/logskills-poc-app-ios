//
//  NotificationManager.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 13/04/2021.
//

import Foundation
import UserNotifications

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
    
    @objc func scheduleLocal(triggerTimeInterval: Int, currentIsRound: Bool) {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        
        if(currentIsRound){
            content.title = "Fin du round!"
            content.body = "Revenez sur l'application et pensez à prendre une pause."
            
        } else {
            // Si on était en pause au moment de verouiller
            content.title = "Fin de la pause!"
            content.body = "Retour en mode mode focus, let's go!"
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
