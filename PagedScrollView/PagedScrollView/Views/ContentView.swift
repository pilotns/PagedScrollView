//
//  ContentView.swift
//  PagedScrollView
//
//  Created by pilotns on 08.05.2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader { geometry in
            PagedScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(0..<4, id: \.self) { _ in
                        Rectangle()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .foregroundColor(randomColor)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private var randomColor: Color {
        let red: CGFloat = CGFloat(arc4random_uniform(UINT32_MAX)) / Double(UINT32_MAX)
        let green: CGFloat = CGFloat(arc4random_uniform(UINT32_MAX)) / Double(UINT32_MAX)
        let blue: CGFloat = CGFloat(arc4random_uniform(UINT32_MAX)) / Double(UINT32_MAX)

        return Color(uiColor: UIColor(
            red: red, green: green, blue: blue, alpha: 1)
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
