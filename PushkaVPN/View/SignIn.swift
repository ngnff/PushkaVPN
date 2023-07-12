import SwiftUI

struct SignIn: View {
    
    @StateObject private var viewModel = SignInEmail()
    
    @State private var errorMessage: String = ""
    
    @State private var registrationMode = false
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        ZStack
        {
            Color.black
                .ignoresSafeArea()
            
            VStack()
            {
                HeadLogo()
                
                Spacer()
                
                Text(errorMessage)
                    .foregroundColor(.red)
                
                ZStack
                {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.white)
                        .frame(width: nil, height: 65)
                    
                    TextField("Почта",text: $viewModel.email)
                        .disableAutocorrection(true)
                        .foregroundColor(.black)
                        .font(.title)
                }
                
                ZStack
                {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.white)
                        .frame(width: nil, height: 65)
                    
                    SecureField("Пароль", text: $viewModel.password)
                        .disableAutocorrection(true)
                        .foregroundColor(.black)
                        .font(.title)
                }
                .opacity(self.viewModel.email != "" ? 1 : 0)
                .animation(.easeIn)
                
                Spacer()
                
                VStack
                {
                    Button(action:
                            {
                        Task
                        {
                            errorMessage = try await viewModel.SignInWithEmail()
                            
                            if (try await viewModel.CheckVerify())
                            {
                                showSignInView = false
                            }
                            else if (viewModel.email != "" || viewModel.password != "")
                            {
                                errorMessage = "Подтвердите почту."
                            }
                        }
                    })
                    {
                        ZStack
                        {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 2)
                                .foregroundColor(.white)
                                .frame(width: nil, height: 65)
                            
                            
                            Text("Вход")
                                .foregroundColor(.white)
                                .font(.title)
                                .bold()
                        }
                    }
                    
                    HStack{
                        Button(action:
                                {
                            return
                        })
                        {
                            ZStack
                            {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.white)
                                    .frame(width: nil, height: 65)
                                
                                HStack
                                {
                                    Image("search 2")
                                        .padding(.trailing)
                                    
                                    Text("Google")
                                        .foregroundColor(.gray)
                                        .font(.title)
                                        .bold()
                                        .padding(.trailing)
                                }
                            }
                        }
                        
                        Button(action:
                                {
                            return
                        })
                        {
                            ZStack
                            {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.gray)
                                    .frame(width: nil, height: 65)
                                
                                HStack
                                {
                                    Image(systemName: "applelogo")
                                        .resizable()
                                        .padding(.trailing)
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 30)
                                    
                                    Text("Apple")
                                        .foregroundColor(.white)
                                        .font(.title)
                                        .bold()
                                        .padding(.trailing)
                                }
                            }
                        }
                    }.padding(.top)
                }
                
                Spacer()
                
                Button(action: {
                    return
                })
                {
                    Text("Забыли пароль?")
                        .foregroundColor(.white)
                        .bold()
                }.padding(.bottom, 5)
                
                HStack
                {
                    Text("У вас нет аккаунта?")
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        self.registrationMode = true
                    })
                    {
                        Text("Зарегестрироваться")
                            .foregroundColor(.white)
                            .bold()
                    }.sheet(isPresented: $registrationMode){
                        SignUp(showSignUpView: $registrationMode)
                    }
                }
            }.padding()
        }.animation(.spring())
    }
}

struct SignIn_Previews: PreviewProvider {
    static var previews: some View {
        SignIn(showSignInView: .constant(false))
    }
}
