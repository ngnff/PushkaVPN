import SwiftUI

struct PersonView: View {
    @StateObject private var MainView = MainViewModel()
    
    @State private var email: String? = ""
    
    @State private var countOfDay = 0
    
    @Binding var showSignInView: Bool
    
    @State private var showLogOutAlert: Bool = false
    
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        NavigationView
        {
            List()
            {
                VStack
                {
                    HStack
                    {
                        ZStack
                        {
                            Rectangle()
                                .cornerRadius(10)
                                .foregroundColor(.red)
                                .frame(width: 100, height: 100)
                            
                            Circle()
                                .frame(width: 79, height: 79)
                                .foregroundColor(.white)
                            VStack
                            {
                                Text("\(countOfDay)")
                                Text("дней")
                            }.fontWeight(.bold)
                                .foregroundColor(.black)
                        }
                        
                        Text("Продлите подписку, чтобы иметь больше возможностей!")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .padding(.leading)
                    }
                    
                    if(MainView.authProviders.contains(.email))
                    {
                        ZStack(alignment: .leading)
                        {                            
                            Rectangle()
                                .cornerRadius(10)
                                .frame(width: 358, height: 94)
                                .foregroundColor(Color(red: 0.173, green: 0.172, blue: 0.181))
                            
                            Rectangle()
                                .frame(width: 358, height: 1)
                                .foregroundColor(.black)
                            
                            VStack
                            {
                                Image(systemName: "envelope.fill")
                                    .padding(.bottom, 10)
                                
                                Image(systemName: "lock")
                                    .padding(.top, 10)
                            }.padding(.leading, 320)
                            
                            VStack(alignment: .leading)
                            {
                                Text(email ?? "")
                                    .padding(.bottom, 10)
                                
                                Text("···············")
                                    .fontWeight(.bold)
                                    .padding(.top, 10)
                            }.padding(.leading)
                        }.padding(.vertical, 50.0)
                    }
                }
                .onAppear{
                    let authUser = try? AuthenticationManger.shared.getAuthenticatedUser()
                    email = authUser?.email
                    MainView.loadAuthProviders()
                }
                
                Button(action:
                        {
                    
                })
                {
                    Text("Отмена подписки")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .font(.body)
                }
                
                Button(action:
                        {
                    showDeleteAlert = true
                })
                {
                    Text("Удаление учетной записи")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .font(.body)
                }
                .alert("Удалить аккаунт", isPresented: $showDeleteAlert, actions: {
                    Button("Да")
                    {
                        Task{
                            try MainView.DeleteCurrentUser()
                            showSignInView = true
                        }
                    }
                    Button("Нет"){}
                },
                       message:  {
                    Text("Вы действительно хотите удалить аккаунт?")
                    
                })
                
                Button(action:
                        {
                    showLogOutAlert = true
                })
                {
                    Text("Выйти из аккаунта")
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .font(.body)
                }
                .alert("Выйти из аккаунта", isPresented: $showLogOutAlert, actions: {
                    Button("Да")
                    {
                        Task{
                            try MainView.logOut()
                            showSignInView = true
                        }
                    }
                    Button("Нет"){}
                },
                       message:  {
                    Text("Вы действительно хотите выйти из аккаунта?")
                    
                })
                
            }.navigationTitle("PushkaVPN")
                .listStyle(.plain)
                .buttonStyle(BorderlessButtonStyle())
        }
    }
}

struct PersonView_Previews: PreviewProvider {
    static var previews: some View {
        PersonView(showSignInView: .constant(false))
    }
}
