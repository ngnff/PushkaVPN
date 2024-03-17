import SwiftUI

struct JoinButton: View {
    @State private var ButtonOn: Bool = false
    
    @State private var WireGuard = WG(collection: "servers", serverName: "Netherland")
    
    var body: some View {
        Button(action: {
            ButtonOn.toggle()
            if(ButtonOn)
            {
                WireGuard.StartTunnel()
            }
            else
            {
                WireGuard.StopTunnel()
            }
        })
        {
            if(!ButtonOn)
            {
                Image("JoinButtonBegin")
            }
            else
            {
                ZStack
                {
                    Image("JoinButtonFinal")
                    Text("Отключиться")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
            }
        }
    }
}

struct JoinButton_Previews: PreviewProvider {
    static var previews: some View {
        JoinButton()
    }
}
