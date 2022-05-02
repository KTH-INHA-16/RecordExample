//
//  PlayView.swift
//  RecordSample
//
//  Created by 김태훈 on 2022/03/31.
//

import SwiftUI

struct PlayView: View {
    @ObservedObject var player = AudioPlayer(fileName: "")
    
    var body: some View {
        VStack {
            
            Text(player.time)
                .onChange(of: player.progress, perform: { _ in
                    player.update()
                })
            
            Slider(value: $player.progress, in: 0...1, onEditingChanged: { _ in
                player.isTaped.toggle()
                
                if !player.isTaped {
                    let targetTime = player.duration * player.progress
                    player.audioPlayer?.currentTime = targetTime
                }
            })
            .padding(.all, 50.0)
            
            Button(action: {
                player.play()
            }, label: {
                Image(systemName: player.isPlaying ? "pause" : "play")
                    .frame(width: 50, height: 50, alignment: .center)
                    .foregroundColor(.orange)
                    .clipShape(Circle())
                    .overlay {
                        Circle().stroke(.orange, lineWidth: 2)
                    }
            })
            .padding(.bottom, 20.0)
            
            HStack {
                Spacer()
                
                Button("AVAudioFile", action: {
                    share(items: [player.originURL])
                }).padding(.trailing, 15.0)
                
                Button("MP3File", action: {
                    share(items: [player.fileURL])
                }).padding(.leading, 15.0)
                
                Spacer()
                
            }
        }
        .onAppear{
            player.publish()
        }
        .onDisappear {
            player.cancel()
        }
        .navigationTitle(player.fileName)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @discardableResult
    func share(items: [Any], excludedActivityTypes: [UIActivity.ActivityType]? = nil) -> Bool {
        guard let source = UIApplication.shared.keyWindow?.rootViewController else {
            return false
        }
        let vc = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        vc.excludedActivityTypes = excludedActivityTypes
        vc.popoverPresentationController?.sourceView = source.view
        source.present(vc, animated: true)
        return true
    }
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView(player: AudioPlayer(fileName: ""))
    }
}
