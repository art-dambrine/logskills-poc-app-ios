//
//  Activity.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 11/04/2021.
//

import Foundation
import SwiftUI

struct Activity: Codable {
    let id: Int
    let nom: String
    let temps_focus: Int
    let temps_pause: Int
    let nb_round: Int
    let id_categorie: Int
}


class ActivitiesObs: ObservableObject {
    @ObservedObject var settings = Settings()
    @Published var activities: [Activity] = []
    
    init(){
        print("Init activities")
        self.refreshActivityList()
    }
    
    func refreshActivityList(){
        activityApi().getAllActivities(apiBaseUrl: settings.apiBaseUrl) { (activities) in
            self.activities = activities
        }
    }
    
}


class activityApi {
    func getAllActivities(apiBaseUrl:String, completion:@escaping ([Activity]) -> ()) {

        let semaphore = DispatchSemaphore (value: 0)
        
        var request = URLRequest(url: URL(string: apiBaseUrl + "/activites")!,timeoutInterval: Double.infinity)
        request.addValue(UserDefaults.standard.string(forKey: "accessToken") ?? "", forHTTPHeaderField: "x-access-token")
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                semaphore.signal()
                return
            }
            
            
            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode \(httpResponse.statusCode)")
                
                if (httpResponse.statusCode == 200) {
                    let activites = try! JSONDecoder().decode([Activity].self, from: data)
                    
                    DispatchQueue.main.async {
                        completion(activites)
                    }
                } else {
                    // Pour eviter de planter l'app au lancement
                    completion([Activity(id: 0, nom: "", temps_focus: 0, temps_pause: 0, nb_round: 0, id_categorie: 0)])
                }
            }
            
            
            print(String(data: data, encoding: .utf8)!)
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
    }
    
    
    func postActivity(apiBaseUrl:String, activity: Activity) {
                
        let semaphore = DispatchSemaphore (value: 0)

        let parameters = "{\r\n    \"nom\": \"" + activity.nom + "\",\r\n    \"focus\": " + String(activity.temps_focus) + ",\r\n    \"pause\": " + String(activity.temps_pause) + ",\r\n    \"round\": " + String(activity.nb_round) + ",\r\n    \"id_categorie\": " + String(activity.id_categorie) + ",\r\n  \"tags\": []\r\n}\r\n"
        
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: apiBaseUrl + "/activites")!,timeoutInterval: Double.infinity)
        request.addValue(UserDefaults.standard.string(forKey: "accessToken") ?? "", forHTTPHeaderField: "x-access-token")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            semaphore.signal()
            return
          }
          print(String(data: data, encoding: .utf8)!)
          semaphore.signal()
        }

        task.resume()
        semaphore.wait()
    }
    
    func updateActivity(apiBaseUrl:String, activity: Activity){
                
        let semaphore = DispatchSemaphore (value: 0)

        let parameters = "{\r\n    \"nom\": \"" + String(activity.nom) + "\",\r\n    \"focus\": " + String(activity.temps_focus) + ",\r\n    \"pause\": " + String(activity.temps_pause) + ",\r\n    \"round\": " + String(activity.nb_round) + ",\r\n    \"id_categorie\": " + String(activity.id_categorie) + "    \r\n}\r\n"
        
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: apiBaseUrl + "/activites/" + String(activity.id) )!,timeoutInterval: Double.infinity)

        request.addValue(UserDefaults.standard.string(forKey: "accessToken") ?? "", forHTTPHeaderField: "x-access-token")

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "PUT"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            semaphore.signal()
            return
          }
          print(String(data: data, encoding: .utf8)!)
          semaphore.signal()
        }

        task.resume()
        semaphore.wait()
        
    }
    
    
    func deleteActivity(apiBaseUrl:String, activityId: Int){
        
        let semaphore = DispatchSemaphore (value: 0)
        
        var request = URLRequest(url: URL(string: apiBaseUrl + "/activites/" + String(activityId) )!,timeoutInterval: Double.infinity)
        request.httpMethod = "DELETE"
        
        request.addValue(UserDefaults.standard.string(forKey: "accessToken") ?? "", forHTTPHeaderField: "x-access-token")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                semaphore.signal()
                return
            }
            print(String(data: data, encoding: .utf8)!)
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        
    }
}

