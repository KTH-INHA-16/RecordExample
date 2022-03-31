//
//  ListRowView.swift
//  RecordSample
//
//  Created by 김태훈 on 2022/03/31.
//

import SwiftUI

struct ListRowView: View {
    var model: ListModel
    
    var body: some View {
        VStack {
            HStack {
                Text(model.title)
                Spacer()
            }
            HStack {
                Text("녹음 시간: "+model.duration)
                Spacer()
            }
        }
    }
}

struct ListRowView_Previews: PreviewProvider {
    static var previews: some View {
        ListRowView(model: ListModel(title: "44", duration: "44"))
    }
}
