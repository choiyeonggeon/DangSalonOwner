//
//  SoundManager.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/22/25.
//

import Foundation
import AVFoundation

final class SoundManager {
    static let shared = SoundManager()
    private var player: AVAudioPlayer?
    
    func playNotificationSound() {
        guard let url = Bundle.main.url(forResource: "speech", withExtension: "wav") else {
            print("Sound file not found")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
            
        } catch {
            print("Sound play error:", error)
        }
    }
}
