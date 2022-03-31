//
//  ContentView.swift
//  RecordSample
//
//  Created by 김태훈 on 2022/03/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            RecordView(audioRecorder: AudioRecorder(), viewModel: RecordViewModel())
                .tabItem {
                    Image(systemName: "record.circle")
                    Text("Record")
                }
            
            ListView(viewModel: ListViewModel())
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("List")
                }
        }.accentColor(.orange)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
