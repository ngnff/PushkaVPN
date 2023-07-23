import SwiftUI

struct SettingsView: View {
    @State private var subDay = 0
    
    var body: some View {
        NavigationView
        {
            List
            {
                NavigationLink(destination:
                    SubscribeView())
                {
                    HStack{
                        Text("Подписка")
                        
                        Spacer()
                        
                        Text("\(subDay) дней осталось")
                            .foregroundColor(.gray)
                    }
                }
                
                NavigationLink(destination: HelpView())
                {
                    HStack{
                        Text("Помощь")
                        
                        Spacer()
                        
                        Text("Связаться с поддержкой")
                            .foregroundColor(.gray)
                    }
                }

            }.navigationTitle("PushkaVPN")
                .listStyle(.plain)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
