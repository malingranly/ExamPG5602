//
//  SplashView.swift
//  Ratatouille


import SwiftUI

struct SplashView: View {
    /// Variables
    @State private var isActive: Bool = false
    @State private var hatAnimationComplete: Bool = false

    var body: some View {
        if isActive {
            FavoritesView()
        } else {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                Image("remy_without_hat")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)

                Image("hat")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(hatAnimationComplete ? 1 : 0)
                    .offset(y: hatAnimationComplete ? +50 : -UIScreen.main.bounds.height / 2) 
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeInOut(duration: 2.0)) {
                        hatAnimationComplete = true
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            isActive = true
                        }
                    }
                }
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
