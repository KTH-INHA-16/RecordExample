//
//  AudioPlayer.swift
//  RecordSample
//
//  Created by 김태훈 on 2022/04/05.
//

import Foundation
import Combine
import AVFoundation
import SwiftUI

final class AudioPlayer: NSObject, ObservableObject {
    private(set) var audioPlayer: AVAudioPlayer?
    @Published var progress: Double = 0.0
    @Published var isPlaying: Bool = false
    var duration: Double = 0.0
    
    override init() {
        super.init()
    }
    
    func load(fileName: String) {
        guard var directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first, let url = Bundle.main.url(forResource: "music", withExtension: "mp3") else {
            return
        }
        directoryURL.appendPathComponent(fileName)
        
        do {
            print(directoryURL)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = 1.0
            duration = audioPlayer?.duration ?? 0.0
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func play() {
        
        isPlaying.toggle()
        
        if isPlaying {
            print("play")
            audioPlayer?.play()
        } else {
            print("pause")
            audioPlayer?.pause()
        }
        print(audioPlayer?.isPlaying)
    }
}
