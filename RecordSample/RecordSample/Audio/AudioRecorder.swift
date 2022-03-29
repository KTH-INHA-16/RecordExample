//
//  AudioRecorder.swift
//  RecordSample
//
//  Created by 김태훈 on 2022/03/24.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

final class AudioRecorder: NSObject, ObservableObject {
    private(set) var audioRecorder: AVAudioRecorder?
    private var cancellable: AnyCancellable?
    let objectWillChange = PassthroughSubject<AudioRecorder, Never>()
    @Published var authority = false
    @Published var recording = false {
        didSet {
            objectWillChange.send(self)
            if recording {
                startRecord()
            } else {
                cancellable?.cancel()
                stopRecord()
            }
        }
    }
    
    override init() {
        super.init()
        authoritySetUp()
    }
    
    private func startRecord() {
        configureRecoder()
        audioRecorder?.record()
        cancellable = Timer.publish(every: 20, tolerance: nil, on: .main, in: .default, options: nil)
            .autoconnect()
            .sink { [unowned self] _ in
                self.stopRecord()
                self.startRecord()
            }
    }
    
    private func stopRecord() {
        audioRecorder?.stop()
    }
    
    private func authoritySetUp() {
        let recordInstance = AVAudioSession.sharedInstance()
        do {
            try recordInstance.setCategory(.record, mode: .measurement)
            try recordInstance.setActive(true)
            recordInstance.requestRecordPermission { [unowned self] permission in
                self.authority = permission
            }
        } catch {
            NSLog(error.localizedDescription)
        }
    }
    
    private func configureRecoder() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.string(from: Date())
        
        let audioFileName = date + ".m4a"
        guard var directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        directoryURL.appendPathComponent(audioFileName)
        let recorderSetting: [String:Any] = [ AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC as UInt32),
                                              AVSampleRateKey: 44100.0,
                                              AVNumberOfChannelsKey: 2 ]
        audioRecorder = try? AVAudioRecorder(url: directoryURL, settings: recorderSetting)
        audioRecorder?.delegate = self
        audioRecorder?.isMeteringEnabled = true
        audioRecorder?.prepareToRecord()
    }
    
}

extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print(flag, Date())
    }
}
