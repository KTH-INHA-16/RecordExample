//
//  PlayView.swift
//  RecordSample
//
//  Created by 김태훈 on 2022/03/31.
//

import SwiftUI

struct PlayView: View {
    @State var num: Float = 0.0
    @ObservedObject var viewModel: PlayViewModel
    @ObservedObject var player = AudioPlayer()
    
    var body: some View {
        VStack {
            
            Text("33")
            
            Slider(value: $player.progress, in: 0...1, onEditingChanged: { _ in
                let targetTime = player.duration * player.progress
                player.audioPlayer?.currentTime = targetTime
            })
            .padding(.all, 50.0)
            
            Button(action: {
                player.play()
            }, label: {
                Image(systemName: player.isPlaying ? "play" : "pause")
                    .frame(width: 50, height: 50, alignment: .center)
                    .foregroundColor(.orange)
                    .clipShape(Circle())
                    .overlay {
                        Circle().stroke(.orange, lineWidth: 2)
                    }
            })
        }
        .onAppear {
            player.load(fileName: viewModel.fileName)
        }
        .navigationTitle(viewModel.fileName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView(viewModel: PlayViewModel(fileName: ""))
    }
}
