//
//  ListView.swift
//  RecordSample
//
//  Created by 김태훈 on 2022/03/24.
//

import SwiftUI
import CoreData

struct ListView: View {
    @ObservedObject var viewModel: ListViewModel
    @FetchRequest(entity: Record.entity(), sortDescriptors: []) var list: FetchedResults<Record>
    
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
        }.environment(\.managedObjectContext, DataManager.shared.container.viewContext)
    }
    
    func removeRows(at offsets: IndexSet) {
        guard let index = offsets.first else {
             return
        }
        
        viewModel.delete(object: list[index])
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(viewModel: ListViewModel())
    }
}
