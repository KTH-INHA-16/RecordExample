//
//  RecordViewController.swift
//  RecordExample
//
//  Created by 김태훈 on 2022/03/22.
//

import UIKit
import Combine
import AVFoundation

final class RecordViewController: UIViewController {
    private let recordInstance = AVAudioSession.sharedInstance()
    private var viewModel = RecordViewModel()

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var recordSwitch: UISwitch!
    @IBOutlet weak var authorityButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    private func setUI(_ permission: Bool) {
        let title = permission ? "아래의 토글 버튼을 전환하면 녹음이 시작됩니다.\n(5분마다 녹음기록이 저장됩니다.)" : "녹음을 하기 위해서는 권한이 필요합니다."
        
        titleLabel.text = title
        authorityButton.isHidden = permission
        recordSwitch.isHidden = !permission
    }
    
    private func authoritySetUp() {
        do {
            try recordInstance.setCategory(.record, mode: .measurement)
            try recordInstance.setActive(true)
            recordInstance.requestRecordPermission { [unowned self] permission in
                DispatchQueue.main.async {
                    self.setUI(permission)
                }
            }
        } catch {
            NSLog(error.localizedDescription)
        }
    }
}
