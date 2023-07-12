//
//  LaunchScreen.swift
//  PushkaVPN
//
//  Created by Slava on 08/07/2023.
//

import SwiftUI

struct LaunchScreen: View {
    
    @State private var animate = false
    
    @State private var showSignInView: Bool = false
    
    var body: some View {
        ZStack
        {
            Color.black
                .ignoresSafeArea()
            
            HStack
            {
                Image("LaunchLogo2")
                    .frame(width: 140, height: 140)
                    .scaleEffect(animate ? 0.66 : 1)
                    .onAppear {
                        animate.toggle()
                    }
                    .animation(.easeOut(duration: 0.5), value: animate)
                
                Text("Pushka\nVPN")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .bold()
                    .opacity(animate ? 1 : 0)
                    .animation(.easeOut(duration: 1), value: animate)
            }
            .padding()
            
            ZStack
            {
                MainView(showSignInView: $showSignInView)
                    .opacity(animate ? 1 : 0)
                    .animation(.spring().delay(1.5), value: animate)
            }
            .onAppear{
                let authUser = try? AuthenticationManger.shared.getAuthenticatedUser()
                self.showSignInView = authUser == nil
            }
            .fullScreenCover(isPresented: $showSignInView)
            {
                SignIn(showSignInView: $showSignInView)
                    .opacity(animate ? 1 : 0)
                    .animation(.spring().delay(1.5), value: animate)
            }
        }.animation(.spring())
    }
}


struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreen()
    }
}
