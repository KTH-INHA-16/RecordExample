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
    private var cancellable: Cancellable?
    var isTaped: Bool = false
    @Published var time: String = "00 : 00 / 00 : 00"
    @Published var progress: Double = 0.0
    @Published var isPlaying: Bool = false
    @Published var duration: Double = 0.01
    
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
            duration = audioPlayer?.duration ?? 0.01
        } catch {
            print(error.localizedDescription)
        }
        
        cancellable = Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .sink { [unowned self] _ in
                if self.isTaped {
                    self.time = "\(self.convert(time: Int(self.progress * self.duration))) / \(self.convert(time: Int(self.duration)))"
                } else {
                    self.time = "\(self.convert(time: Int(self.audioPlayer?.currentTime ?? 0))) / \(self.convert(time: Int(self.duration)))"
                    self.progress = (self.audioPlayer?.currentTime ?? 0) / self.duration
                }
            }
    }
    
    func disappear() {
        cancellable?.cancel()
    }
    
    func play() {
        isPlaying.toggle()
        
        if isPlaying {
            audioPlayer?.play()
        } else {
            audioPlayer?.pause()
        }
    }
    
    func update() {
        let current = duration * progress
        time = "\(convert(time: Int(current))) / \(convert(time: Int(duration)))"
    }
    
    private func convert(time: Int) -> String {
        let seconds = String(Int(time) % 60).count == 1 ? "0\(String(Int(time) % 60))" : "\(String(Int(time) % 60))"
        let minutes = String(Int(time) / 60).count == 1 ? "0\(String(Int(time) / 60))" : "\(String(Int(time) / 60))"
        
        return "\(minutes) : \(seconds)"
    }
}
