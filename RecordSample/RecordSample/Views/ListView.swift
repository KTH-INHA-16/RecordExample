//
//  ListView.swift
//  RecordSample
//
//  Created by 김태훈 on 2022/03/24.
//

import SwiftUI

struct ListView: View {
    @ObservedObject var viewModel: ListViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.list, id: \.id) { model in
                    NavigationLink {
                        PlayView(player: AudioPlayer(fileName: model.title))
                    } label: {
                        ListRowView(model: model)
                            .frame(height: 50)
                    }
                }.onDelete(perform: removeRows)
            }
            .onAppear {
                viewModel.fetch()
            }
            .edgesIgnoringSafeArea(.leading)
            .edgesIgnoringSafeArea(.trailing)
            .listStyle(.grouped)
            .navigationTitle("Records")
        }
    }
    
    func removeRows(at offsets: IndexSet) {
        print(offsets.first)
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(viewModel: ListViewModel())
    }
}
