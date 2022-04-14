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
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView(player: AudioPlayer(fileName: ""))
    }
}
