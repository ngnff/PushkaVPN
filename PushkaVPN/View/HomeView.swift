//
//  HomeView.swift
//  PushkaVPN
//
//  Created by Slava on 19/07/2023.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView()
        {
            VStack
            {
                Text("PushkaVPN")
                    .fontWeight(.bold)
                
                Spacer()
                
                JoinButton()
                
                Spacer()
                
                HStack
                {
                    Text("Локации")
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                
                NavigationLink(destination: {
                    
                })
                {
                    Rectangle()
                        .cornerRadius(10)
                        .foregroundColor(Color(red: 0.8509803921568627, green: 0.8509803921568627, blue: 0.8509803921568627))
                        .frame(width: nil, height: 65)
                }.padding(.bottom, 35)
                
                HStack
                {
                    Text("Белый список")
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                
                NavigationLink(destination: {
                    
                })
                {
                    Rectangle()
                        .cornerRadius(10)
                        .foregroundColor(Color(red: 0.8509803921568627, green: 0.8509803921568627, blue: 0.8509803921568627))
                        .frame(width: nil, height: 65)
                }.padding(.bottom, 35)
            }.padding()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
