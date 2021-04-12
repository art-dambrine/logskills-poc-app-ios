//
//  SoundManager.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 12/04/2021.
//

import AVFoundation

class SoundManager {
    
    var audioPlayer: AVAudioPlayer?
    
    func playSound(sound: String, type: String) {                        
        
        if let path = Bundle.main.path(forResource: sound, ofType: type) {
            print("Sound is : " + sound)
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                self.audioPlayer?.play()
            } catch {
                print("ERROR")
            }
        }
    }
    
    func getSoundPossibilities() -> Array<String> {
        return ["tone","temple","doorbell","bikehorn","metalgong"]
    }
}


