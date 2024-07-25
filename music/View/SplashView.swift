//
//  SplashView.swift
//  music
//
//  Created by Agni Muhammad on 25/07/24.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive: Bool = false
    
    var body: some View {
        ZStack {
            if self.isActive {
                ContentView()
            } else {
                Rectangle()
                    .background(Color.white)
                    .opacity(0)
                ZStack {
                    Spacer()
                    Image(systemName: "music.note.list")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                    Spacer()
                }
                
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
    
}

#Preview {
    SplashView()
}
