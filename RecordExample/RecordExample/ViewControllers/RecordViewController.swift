//
//  RecordViewController.swift
//  RecordExample
//
//  Created by κΉνν on 2022/03/22.
//

import UIKit
import Combine
import AVFoundation

final class RecordViewController: UIViewController {
    private let recordInstance = AVAudioSession.sharedInstance()
    private var cutTimerCancellable: AnyCancellable?
    private var timeTimerCancellable: AnyCancellable?
    private var viewModel = RecordViewModel()
    private var audioRecorder: AVAudioRecorder?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var recordSwitch: UISwitch!
    @IBOutlet weak var authorityButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAudio()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authoritySetUp()
    }
    
    @IBAction func authorityTouchDown(_ sender: UIButton) {
        guard let settingURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingURL) {
            UIApplication.shared.open(settingURL)
        }
    }
    
    @IBAction func recordValueChange(_ sender: UISwitch) {
        if sender.isOn {
            configureAudio()
            startRecording()
        } else {
            timeTimerCancellable?.cancel()
            cutTimerCancellable?.cancel()
            audioRecorder?.stop()
            timeLabel.text = "00 : 00 : 00"
        }
    }
    
    private func startRecording() {
        guard let audioRecorder = audioRecorder else {
            return
        }
        
        audioRecorder.record()
        
        timeTimerCancellable = Timer.publish(every: 1, tolerance: nil, on: .current, in: .default, options: nil)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else {
                    return
                }
                
                let interval = Int(Date().timeIntervalSince(self.viewModel.date))
                let second = String(interval % 60).count == 1 ? "0\(String(interval % 60))" : "\(String(interval % 60))"
                let minute = String(interval / 60).count == 1 ? "0\(String(interval / 60))" : "\(String(interval / 60))"
                let hours = String(interval / 3600).count == 1 ? "0\(String(interval / 3600))" : "\(String(interval / 3600))"
                
                self.timeLabel.text = "\(hours) : \(minute) : \(second)"
            }
        
         cutTimerCancellable = Timer.publish(every: 20, tolerance: nil, on: .current, in: .default, options: nil)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else {
                    return
                }
                
                self.audioRecorder?.stop()
                self.startRecording()
            }
    }
    
    private func configureAudio() {
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
        viewModel.set(date: Date())
    }
    
    private func configureUI(_ permission: Bool) {
        let title = permission ? "μλμ ν κΈ λ²νΌμ μ ννλ©΄ λΉμμ΄ μμλ©λλ€.\n(5λΆλ§λ€ λΉμκΈ°λ‘μ΄ μ μ₯λ©λλ€.)" : "λΉμμ νκΈ° μν΄μλ κΆνμ΄ νμν©λλ€."
        
        titleLabel.text = title
        timeLabel.text = permission ? "00 : 00 : 00" : nil
        authorityButton.isHidden = permission
        recordSwitch.isHidden = !permission
    }
    
    private func authoritySetUp() {
        do {
            try recordInstance.setCategory(.record, mode: .measurement)
            try recordInstance.setActive(true)
            recordInstance.requestRecordPermission { [unowned self] permission in
                DispatchQueue.main.async {
                    self.configureUI(permission)
                }
            }
        } catch {
            NSLog(error.localizedDescription)
        }
    }
}

extension RecordViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        NSLog("\(flag), \(Date().description)")
    }
}
