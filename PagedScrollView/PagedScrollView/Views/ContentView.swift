//
//  ContentView.swift
//  PagedScrollView
//
//  Created by pilotns on 08.05.2023.
//

import SwiftUI

struct ContentView: View {
    let colors: [Color] = [.red, .green, .blue, .yellow, .purple]
    var body: some View {
        PagedScrollView { size in
            ForEach(colors, id: \.self) { color in
                Rectangle()
                    .frame(width: size.width, height: size.height)
                    .foregroundColor(color)
            }
        }
        .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct TempView<Content: View>: View {
    let content: (CGSize) -> Content
    
    init(@ViewBuilder content: @escaping (CGSize) -> Content) {
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            content(geometry.size)
        }
    }
}
