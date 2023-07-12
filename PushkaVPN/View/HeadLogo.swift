//
//  HeadLogo.swift
//  PushkaVPN
//
//  Created by Slava on 09/07/2023.
//

import SwiftUI

struct HeadLogo: View {
    var body: some View {
        HStack
        {
            Image("Logo")
                .resizable()
                .frame(width: 140, height: 140)
            
            VStack(alignment: .leading)
            {
                Text("Pushka")
                    .font(.system(size: 48))
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .bold()
                
                Text("VPN")
                    .font(.system(size: 48))
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .bold()
            }
        }
    }
}

struct HeadLogo_Previews: PreviewProvider {
    static var previews: some View {
        HeadLogo().preferredColorScheme(.dark)
    }
}
