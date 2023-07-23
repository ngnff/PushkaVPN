import SwiftUI
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices
import CryptoKit

@MainActor
final class MainViewModel: ObservableObject
{
    @Published var authProviders: [AuthProviderOption] = []
    
    func DeleteCurrentUser() throws
    {
        try AuthenticationManger.shared.DeleteUser()
    }
    
    func loadAuthProviders()
    {
        if let providers = try? AuthenticationManger.shared.GetProvider()
        {
            authProviders = providers
        }
    }
    
    func logOut() throws
    {
        try AuthenticationManger.shared.logOut()
    }
}

struct GoogleSignInResultModel
{
    let idToken: String
    let accessToken: String
}

struct SignInWithAppleButtonViewRepresentable: UIViewRepresentable
{
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton
    {
        ASAuthorizationAppleIDButton(authorizationButtonType: type, authorizationButtonStyle: style)
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        
    }
}

@MainActor
final class AuthenticationViewModel: NSObject ,ObservableObject
{
    @Published var didSignInWithApple: Bool = false
    
    private var currentNonce: String?
    
    func SignInGoogle() async throws
    {
        guard let topVC = Utilities.shared.topViewController() else
        {
            throw URLError(.cannotFindHost)
        }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken: String = gidSignInResult.user.idToken?.tokenString else
        {
            throw URLError(.badServerResponse)
        }
        
        let accessToken: String = gidSignInResult.user.accessToken.tokenString
        
        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken)
        
        try await AuthenticationManger.shared.SignInWithGoogle(tokens: tokens)
    }
    
    func SignInApple() async throws
    {
        startSignInWithAppleFlow()
    }
    
    func startSignInWithAppleFlow() {
        guard let topVC = Utilities.shared.topViewController() else {
            return
        }
        
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = topVC
        authorizationController.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

struct SignInWithAppleResult
{
    let token: String
    let nonce: String
}

extension AuthenticationViewModel: ASAuthorizationControllerPresentationContextProviding
{
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return Utilities.shared.topViewController()!.view.window!
    }
}

extension UIViewController: ASAuthorizationControllerPresentationContextProviding
{
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

@available(iOS 13.0, *)
extension AuthenticationViewModel: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        guard
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let appleIDToken = appleIDCredential.identityToken,
            let idTokenString = String(data: appleIDToken, encoding: .utf8),
            let nonce = currentNonce else
        {
            return
        }
        
        let tokens = SignInWithAppleResult(token: idTokenString, nonce: nonce)
            
        Task
        {
            do
            {
                try await AuthenticationManger.shared.SignInWithApple(tokens: tokens)
                didSignInWithApple = true
            }
            catch
            {                
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
    }
    
}

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

enum AuthProviderOption: String
{
    case email = "password"
    case google = "google.com"
    case apple = "apple.com"
}

final class AuthenticationManger
{
    static let shared = AuthenticationManger()
    
    private init() { }
    
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
    
    func GetProvider() throws -> [AuthProviderOption]
    {
        guard let providerData = Auth.auth().currentUser?.providerData else
        {
            throw URLError(.badServerResponse)
        }
        
        var providers: [AuthProviderOption] = []
        
        for provider in providerData
        {
            if let option = AuthProviderOption(rawValue: provider.providerID)
            {
                providers.append(option)
            }
            else
            {
                assertionFailure("Provider option not found \(provider.providerID)")
            }
        }
        
        return providers
    }
    
    func DeleteUser() throws
    {
        let user = Auth.auth().currentUser
        user?.delete()
    }
}

// MARK: SIGN IN EMAIL

extension AuthenticationManger
{
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
}

// MARK: SIGN IN SSO

extension AuthenticationManger
{
    @discardableResult
    func SignInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel
    {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await SignIn(credential: credential)
    }
    
    @discardableResult
    func SignInWithApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel
    {
        let credential = OAuthProvider.credential(withProviderID: AuthProviderOption.apple.rawValue, idToken: tokens.token, rawNonce: tokens.nonce)
        return try await SignIn(credential: credential)
    }
    
    func SignIn(credential: AuthCredential) async throws -> AuthDataResultModel
    {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}
