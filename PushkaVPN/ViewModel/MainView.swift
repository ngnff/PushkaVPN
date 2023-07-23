import SwiftUI

struct MainView: View {
    @Binding var showSignInView: Bool
    
    @State private var selection = 0
    var body: some View {
        ZStack(alignment: .bottom)
        {
            TabView(selection: $selection)
            {
                HomeView()
                    .tag(0)
                
                PersonView(showSignInView: $showSignInView)
                    .tag(1)
                
                SettingsView()
                    .tag(2)
            }
            
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 90)
                .offset(y: 50)
                .foregroundColor(Color(red: 0.08627450980392157, green: 0.08627450980392157, blue: 0.08627450980392157))
            
            HStack
            {
                Button(action: {
                    self.selection = 0
                })
                {
                    Image(systemName: "globe")
                        .scaleEffect(2)
                        .padding(.bottom, 0.5)
                        .foregroundColor(self.selection == 0 ? .red : .white)
                }
                
                Spacer(minLength: 10)
                
                Button(action: {
                    self.selection = 1
                })
                {
                    Image(systemName: "person")
                        .scaleEffect(2)
                        .padding(.bottom, 0.5)
                        .foregroundColor(self.selection == 1 ? .red : .white)
                }
                
                Spacer(minLength: 10)
                
                Button(action: {
                    self.selection = 2
                })
                {
                    
                    Image(systemName: "gearshape")
                        .scaleEffect(2)
                        .padding(.bottom, 0.5)
                        .foregroundColor(self.selection == 2 ? .red : .white)
                }
            }
            .padding(.horizontal, 50)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(showSignInView: .constant(false))
    }
}
