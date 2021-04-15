//
//  UserModel.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 11/04/2021.
//

import Foundation

class User: ObservableObject {    
    @Published var username: String = UserDefaults.standard.string(forKey: "username") ?? ""
    @Published var password: String = UserDefaults.standard.string(forKey: "password") ?? ""
    @Published var token: String = UserDefaults.standard.string(forKey: "accessToken") ?? ""
}

class TokenResponse: Codable {
    var auth: Bool? = nil
    var accessToken: String? = nil
    
    //    {
    //        "auth": true,
    //        "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MiwiaWF0IjoxNjE4MjM1Mzg1LCJleHAiOjE2MTgzMjE3ODV9.h36usnCzRfVAln25s9JCMJOUHy-zdhjHFNYdG7hIs40"
    //    }
}

class apiUser {
    
    func authenticate(apiBaseUrl:String, login:String, password:String, completion:@escaping (TokenResponse) -> ()){
        let semaphore = DispatchSemaphore (value: 0)
        
        let parameters = " {\r\n    \"login\": \"" + login + "\",\r\n    \"password\": \"" + password + "\"\r\n}"
        let postData = parameters.data(using: .utf8)
        
        var request = URLRequest(url: URL(string: apiBaseUrl + "/auth/signin")!,timeoutInterval: Double.infinity)
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
                    print(String(data: data, encoding: .utf8)!)
                    let tokenResponse = try! JSONDecoder().decode(TokenResponse.self, from: data)
                    DispatchQueue.main.async {
                        // print(tokenResponse)
                        completion(tokenResponse)
                    }
                }
            }
            
            
            
            
            print(String(data: data, encoding: .utf8)!)
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        
    }
}
