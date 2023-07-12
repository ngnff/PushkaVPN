import Foundation
import FirebaseAuth

@MainActor
final class SignInEmail: ObservableObject
{
    @Published var email = ""
    
    @Published var password = ""
    
    @Published var passwordConfirm = ""        
    
    func SignUpWithEmail() async throws -> String
    {
        guard !email.isEmpty, !password.isEmpty else
        {
            return "Не найдена почта или пароль."
        }
        
        guard password == passwordConfirm else
        {
            return "Пароли не совпадают."
        }
        
        do
        {
            try await AuthenticationManger.shared.createUser(email: email, password: password)
        }
        catch
        {
            return "Неправильные почта или пароль."
        }
        
        return "Успешно"
    }
    
    func SignInWithEmail() async throws -> String
    {
        guard !email.isEmpty, !password.isEmpty else
        {
            return "Не найдена почта или пароль."
        }
                
        do
        {
            let returnedUserData = try await AuthenticationManger.shared.SignIn(email: email, password: password)
        }
        catch
        {
            return "Неправильные почта или пароль."
        }
        
        return ""
    }
    
    func CheckVerify() async throws -> Bool
    {
        return try await AuthenticationManger.shared.CheckVerified()
    }
}

struct AuthDataResultModel
{
    let uid: String
    let email: String?
    
    init(user: UserInfo)
    {
        self.uid = user.uid
        self.email = user.email
    }
}

final class AuthenticationManger
{
    static let shared = AuthenticationManger()
    
    private init() { }
    
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel
    {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        try await authDataResult.user.sendEmailVerification()
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    @discardableResult
    func SignIn(email: String, password: String)  async throws -> AuthDataResultModel
    {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func getAuthenticatedUser() throws -> AuthDataResultModel
    {
        guard let user = Auth.auth().currentUser else
        {
            throw URLError(.badServerResponse)
        }
        
        return AuthDataResultModel(user: user)
    }
    
    func CheckVerified() -> Bool
    {
        if let user = Auth.auth().currentUser
        {
            guard user.isEmailVerified else
            {
                return false
            }
            return true
        }
        return false
    }
    
    func logOut() throws
    {
        try Auth.auth().signOut()
    }
}
