//
//  Activity.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 11/04/2021.
//

import Foundation

struct Activity: Codable {
    let id: Int
    let nom: String
    let temps_focus: Int
    let temps_pause: Int
    let nb_round: Int
    let category: String
}


class activityApi {
    func getAllActivities(apiBaseUrl:String, completion:@escaping ([Activity]) -> ()) {
        
        guard let url = URL(string: apiBaseUrl+"/activities.json") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            if (data != nil) {
                let activites = try! JSONDecoder().decode([Activity].self, from: data!)
                
                DispatchQueue.main.async {
                    completion(activites)
                }
            }
                        
        }
        .resume()
    }
    
    
    func postActivity(apiBaseUrl:String, activity: Activity) {
        
        let semaphore = DispatchSemaphore (value: 0)

        let parameters = "{\n  \"nom\": \"" + activity.nom + "\",\n  \"category\": \"" + activity.category + "\",\n  \"tempsFocus\": " + String(activity.temps_focus) + ",\n  \"tempsPause\": " + String(activity.temps_pause) + ",\n  \"nbRound\": " + String(activity.nb_round) + "\n}"
        
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: apiBaseUrl + "/activities")!,timeoutInterval: Double.infinity)
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

        let parameters = "{\n  \"nom\": \"" + activity.nom + "\",\n  \"category\": \"" + activity.category + "\",\n  \"tempsFocus\": " + String(activity.temps_focus) + ",\n  \"tempsPause\": " + String(activity.temps_pause) + ",\n  \"nbRound\": " + String(activity.nb_round) + "\n}"
        
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: apiBaseUrl + "/activities/" + String(activity.id) )!,timeoutInterval: Double.infinity)
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

        var request = URLRequest(url: URL(string: apiBaseUrl + "/activities/" + String(activityId) )!,timeoutInterval: Double.infinity)
        request.httpMethod = "DELETE"

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

