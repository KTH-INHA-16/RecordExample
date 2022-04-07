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
    
    var body: some View {
        VStack {
            Slider(value: $num)
                .padding(.horizontal, 50.0)
        }
    }
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView(viewModel: PlayViewModel(fileName: ""))
    }
}
