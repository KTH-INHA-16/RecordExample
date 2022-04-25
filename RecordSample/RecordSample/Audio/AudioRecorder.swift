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
    private var audioEngine: AVAudioEngine?
    private var mixerNode: AVAudioMixerNode?
    private var cancellable: AnyCancellable?
    private var fileName: String
    let dataManager = DataManager.shared
    let objectWillChange = PassthroughSubject<AudioRecorder, Never>()
    @Published var authority = false
    @Published var recording = false {
        didSet {
            objectWillChange.send(self)
            if recording {
                startRecording()
            } else {
                cancellable?.cancel()
                stopRecording()
            }
        }
    }
    
    override init() {
        fileName = ""
        super.init()
        configureSession()
        configureEngine()
    }
    
    func configureSession() {
        let session = AVAudioSession.sharedInstance()
        session.requestRecordPermission { [unowned self] result in
            switch result {
            case true:
                do {
                    try session.setCategory(.playAndRecord)
                    try session.setActive(result, options: .notifyOthersOnDeactivation)
                } catch {
                    print(error.localizedDescription)
                }
            case false:
                print(result)
            }
            self.authority = result
        }
    }
    
    func configureEngine() {
        audioEngine = AVAudioEngine()
        mixerNode = AVAudioMixerNode()
        
        guard let audioEngine = audioEngine, let mixerNode = mixerNode else {
            return
        }

        
        mixerNode.volume = 0
        audioEngine.attach(mixerNode)
        
        configureNodes()
        
        audioEngine.prepare()
    }
    
    func startRecording() {
        guard let mixerNode = mixerNode, let audioEngine = audioEngine, let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        let tapNode: AVAudioNode = mixerNode
        let format = tapNode.outputFormat(forBus: 0)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMddhhmmssSSS"
        let dateString = dateFormatter.string(from: Date())
        
        do {
            let file = try AVAudioFile(forWriting: fileURL.appendingPathComponent(dateString), settings: format.settings)
            dataManager.save(attributes: ["file": dateString], type: "Record")
            tapNode.installTap(onBus: 0, bufferSize: 8192, format: format) { buffer, time in
                try? file.write(from: buffer)
                if file.length >= (Int(format.sampleRate) * 10 + 256) {
                    self.stopRecording()
                }
            }
            try audioEngine.start()
        } catch {
            print(error.localizedDescription)
       }
    }
    
    func stopRecording() {
        mixerNode?.removeTap(onBus: 0)
        
        audioEngine?.stop()
    }
    
    private func configureNodes() {
        guard let audioEngine = audioEngine, let mixerNode = mixerNode else {
            return
        }
        
        let inputNode = audioEngine.inputNode
        let inputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 48000, channels: 1, interleaved: false)
        //let inputFormat = inputNode.outputFormat(forBus: 0)
        audioEngine.connect(inputNode, to: mixerNode, format: inputFormat)
        
        let mainMixerNode = audioEngine.mainMixerNode

        let mixerFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 48000, channels: 1, interleaved: false)
        audioEngine.connect(mixerNode, to: mainMixerNode, format: mixerFormat)
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    }
}
