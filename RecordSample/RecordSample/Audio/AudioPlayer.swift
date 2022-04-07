//
//  AudioPlayer.swift
//  RecordSample
//
//  Created by 김태훈 on 2022/04/05.
//

import Foundation
import Combine
import AVFoundation

final class AudioPlayer: NSObject, ObservableObject {
    private(set) var audioPlayer: AVAudioPlayer?
    
    override init() {
        super.init()
    }
}
