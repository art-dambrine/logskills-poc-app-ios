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
}

class logsApi {
    
    func createLog(apiBaseUrl:String, log: Logs){
        let semaphore = DispatchSemaphore (value: 0)

        let parameters = "{\r\n    \"temps_total\": " + String(log.temps_total) + ",\r\n    \"temps_actif\": " + String(log.temps_actif) + "\r\n}"
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: "https://api.art-dambrine.ovh/activites/" + String(log.id_activite) + "/logs")!,timeoutInterval: Double.infinity)
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
          print(log)
            
          semaphore.signal()
        }

        task.resume()
        semaphore.wait()
    }
    
}
