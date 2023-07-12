//
//  MainView.swift
//  PushkaVPN
//
//  Created by Slava on 09/07/2023.
//

import SwiftUI

@MainActor
final class MainViewModel: ObservableObject
{
    func logOut() throws
    {
        try AuthenticationManger.shared.logOut()
    }
}

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        ZStack
        {
            Color.black
                .ignoresSafeArea()
            
            Button(action:
                    {
                Task{
                    do
                    {
                        try viewModel.logOut()
                        showSignInView = true
                    }
                }
            })
            {
                Text("Выход")
                    .foregroundColor(.white)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(showSignInView: .constant(false))
    }
}
