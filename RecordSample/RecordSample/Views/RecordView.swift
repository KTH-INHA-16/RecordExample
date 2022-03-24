//
//  RecordView.swift
//  RecordSample
//
//  Created by 김태훈 on 2022/03/24.
//

import SwiftUI
import Combine

struct RecordView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @ObservedObject var viewModel: RecordViewModel
    @State private var timerSubscription: Cancellable?
    @State private var timeTimer = Timer.publish(every: 1, tolerance: nil, on: .main, in: .default, options: nil)
    
    var body: some View {
        VStack {
            if audioRecorder.authority {
                Text("아래의 토글 버튼을 전환하면 녹음이 시작됩니다.\n(5분마다 녹음기록이 저장됩니다.)")
                    .font(.title2)
                    .multilineTextAlignment(.center)
            } else {
                Text("녹음을 하기 위해서는 권한이 필요합니다.")
                    .font(.title2)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            
            Text("\(audioRecorder.recording ? "\(viewModel.text)" : "00 : 00 : 00")")
                .onReceive(timeTimer) { value in
                    viewModel.set(from: value)
                }
            
            Spacer()
            
            
            Toggle("", isOn: $audioRecorder.recording)
                .labelsHidden()
                .frame(height: 50)
                .opacity(audioRecorder.authority ? 1 : 0)
                .onChange(of: audioRecorder.recording) { value in
                    if value {
                        viewModel.set(date: Date())
                        self.timeTimer = Timer.publish(every: 1, tolerance: nil, on: .main, in: .default, options: nil)
                        self.timerSubscription = self.timeTimer.connect()
                    } else {
                        self.timerSubscription?.cancel()
                    }
                }
            
            Button(action: {
                openSetting()
            }) {
                Text("권한 설정")
                    .foregroundColor(Color(UIColor.systemBlue))
            }
            .frame(width: 120, height: 50)
            .opacity(audioRecorder.authority ? 0 : 1)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(UIColor.lightGray), lineWidth: 1.5)
                    .opacity(audioRecorder.authority ? 0 : 1)
            )
            
        }
        .padding(.top, 100.0)
        .padding(.bottom, 100.0)
    }
    
    private func openSetting() {
        guard let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else {
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView(audioRecorder: AudioRecorder(), viewModel: RecordViewModel())
            .previewDevice("iPhone 13")
        RecordView(audioRecorder: AudioRecorder(), viewModel: RecordViewModel())
            .previewDevice("iPhone SE (2nd generation)")
    }
}
