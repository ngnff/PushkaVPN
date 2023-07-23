import SwiftUI

struct SignUp: View {
    
    @State private var errorMessage: String = ""
    
    @StateObject private var viewModel = SignInEmail()
    
    @Binding var showSignUpView: Bool
    
    @State private var showSignUpAlert: Bool = false
    
    var body: some View {
        ZStack
        {
            Color.black
                .ignoresSafeArea()
            
            VStack
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
                                
                VStack
                {
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
                    
                    ZStack
                    {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.white)
                            .frame(width: nil, height: 65)
                        
                        SecureField("Подтвердите пароль", text: $viewModel.passwordConfirm)
                            .disableAutocorrection(true)
                            .foregroundColor(.black)
                            .font(.title)
                    }
                    .opacity(self.viewModel.password != "" && self.viewModel.email != "" ? 1 : 0)
                    .animation(.easeIn)
                }
                
                Spacer()
                
                Button(action:
                        {
                    Task
                    {
                        errorMessage = try await viewModel.SignUpWithEmail()
                        if(errorMessage == "Успешно")
                        {
                            showSignUpAlert = true
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
                            
                        
                        Text("Регистрация")
                            .foregroundColor(.white)
                            .font(.title)
                            .bold()
                    }
                }
                .alert("Успех!", isPresented: $showSignUpAlert, actions: {
                    Button("Ок"){
                        showSignUpView.toggle()
                    }
                }, message: {
                    Text("Письмо с подтверждением отправлено на почту.")
                })
                
                Spacer()
                
                Button(action: {
                    showSignUpView.toggle()
                })
                {
                    Text("Уже есть аккаунт")
                        .foregroundColor(.white)
                }
            }.padding()
        }.animation(.spring())
    }
}

struct SignUp_Previews: PreviewProvider {
    static var previews: some View {
        SignUp(showSignUpView: .constant(true))
    }
}
