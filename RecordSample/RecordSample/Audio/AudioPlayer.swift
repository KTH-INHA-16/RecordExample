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
    var fileURL: URL = URL(fileURLWithPath: "")
    var originURL: URL = URL(fileURLWithPath: "")
    @Published var fileName: String
    @Published var time: String = "00 : 00 / 00 : 00"
    @Published var progress: Double = 0.0
    @Published var isPlaying: Bool = false
    @Published var duration: Double = 0.01
    
    init(fileName: String) {
        self.fileName = fileName
        super.init()
        load()
    }
    
    func publish() {
        guard let fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let url = fileUrl.appendingPathComponent(fileName)
        
        originURL = URL(fileURLWithPath: url.path)
        fileURL = fileUrl.appendingPathComponent(fileName+"3.mp3")
        
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
    
    func cancel() {
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
        var current = duration * progress
        if current.isNaN {
           current = 0
        }
        time = "\(convert(time: Int(current))) / \(convert(time: Int(duration)))"
    }
    
    private func convert(time: Int) -> String {
        let seconds = String(Int(time) % 60).count == 1 ? "0\(String(Int(time) % 60))" : "\(String(Int(time) % 60))"
        let minutes = String(Int(time) / 60).count == 1 ? "0\(String(Int(time) / 60))" : "\(String(Int(time) / 60))"
        
        return "\(minutes) : \(seconds)"
    }
    
    private func load() {
        guard var directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        directoryURL.appendPathComponent(fileName+"3.mp3")
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: directoryURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = 1.0
            duration = audioPlayer?.duration ?? 0.01
        } catch {
            print(error.localizedDescription)
        }
    }
}
