//
//  Logs.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 13/04/2021.
//

import Foundation
import SwiftUI

struct Logs: Codable {
    let id: Int
    let temps_total: Int // en minutes
    let temps_actif: Int // en minutes
    let id_activite: Int
    let date: String
}

struct Focus_jour: Codable {
    let date_jour: String
    let focus_total_jour: Int
}

struct Focus_activite: Codable {
    let id_activite: Int
    let focus_total_activite: Int
}

struct Stats: Codable {
    let focus_moyen_jour_periode: Int
    let focus_jours: Focus_jour
    let focus_activites: [Focus_activite]
}

class logsApi {
    
    func getStatsToday(apiBaseUrl:String, token:String, completion:@escaping (Stats) -> ()){
        
        let semaphore = DispatchSemaphore (value: 0)

        let parameters = "{\r\n \"date_debut\" : \"2021-04-14\",\r\n \"date_fin\" : \"2021-04-15\"\r\n}"
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: apiBaseUrl + "/stats")!,timeoutInterval: Double.infinity)
        request.addValue(token, forHTTPHeaderField: "x-access-token")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            semaphore.signal()
            return
          }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode \(httpResponse.statusCode)")
                
                if (httpResponse.statusCode == 200) {
                    let stats = try! JSONDecoder().decode(Stats.self, from: data)
                    
                    DispatchQueue.main.async {
                        completion(stats)
                    }
                }
            }
            
            
          print(String(data: data, encoding: .utf8)!)
          semaphore.signal()
        }

        task.resume()
        semaphore.wait()
        
    }

    
    func getRecentLogs(apiBaseUrl:String,token:String, completion:@escaping ([Logs]) -> ()){
        let semaphore = DispatchSemaphore (value: 0)

        var request = URLRequest(url: URL(string: apiBaseUrl + "/logs")!,timeoutInterval: Double.infinity)
        request.addValue(token, forHTTPHeaderField: "x-access-token")

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
                    let logs = try! JSONDecoder().decode([Logs].self, from: data)
                    
                    DispatchQueue.main.async {
                        completion(logs)
                    }
                } else {
                    // Pour eviter de planter l'app au lancement
                    completion([Logs(id: 0, temps_total: 0, temps_actif: 0, id_activite: 0, date: "")])
                }
            }
            
          print(String(data: data, encoding: .utf8)!)
          semaphore.signal()
        }

        task.resume()
        semaphore.wait()

    }
    
    func createLog(apiBaseUrl:String,token:String, log: Logs){
        let semaphore = DispatchSemaphore (value: 0)

        let parameters = "{\r\n    \"temps_total\": " + String(log.temps_total) + ",\r\n    \"temps_actif\": " + String(log.temps_actif) + "\r\n}"
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: apiBaseUrl + "/activites/" + String(log.id_activite) + "/logs")!,timeoutInterval: Double.infinity)
        request.addValue(token, forHTTPHeaderField: "x-access-token")
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
          print(log)
            
          semaphore.signal()
        }

        task.resume()
        semaphore.wait()
    }
    
}
