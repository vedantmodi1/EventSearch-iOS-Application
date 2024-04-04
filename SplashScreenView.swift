//
//  SplashScreenView.swift
//  hw9
//
//  Created by Vedant Modi on 5/4/23.
//

import SwiftUI

struct SplashScreenView: View {
    //credit: https://www.youtube.com/watch?v=0ytO3wCRKZU
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.6
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            VStack {
                VStack {
                    Image("launchScreen")
                        .resizable()
                        .frame(width: 300, height: 190)
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear{
                    withAnimation(.easeIn(duration: 1.0)) {
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.isActive = true
                }
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
