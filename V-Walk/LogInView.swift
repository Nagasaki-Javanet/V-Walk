import SwiftUI
import FirebaseAuth // Import for Firebase Authentication

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = "" // Variable to display error messages
    @State private var isLoggedIn = false // Variable to track login status

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("ログイン") // "Login"
                    .font(.largeTitle)
                    .bold()

                // Email input field
                TextField("メールアドレス", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never) // Disable auto-capitalization
                    .keyboardType(.emailAddress)

                // Password input field
                SecureField("パスワード", text: $password)
                    .textFieldStyle(.roundedBorder)

                // Error message display
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                }

                // Login button
                Button {
                    loginUser()
                } label: {
                    Text("ログインする") // "Log In"
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green) // Different color to distinguish from Sign Up
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                }
                
                // Link to Sign Up view
                HStack {
                    Text("アカウントをお持ちでない方は") // "Don't have an account?"
                        .font(.footnote)
                    NavigationLink("新規登録") { // "Sign Up"
                        SignUpView()
                    }
                    .font(.footnote)
                }
                .padding(.top, 10)
            }
            .padding()
            .navigationDestination(isPresented: $isLoggedIn) {
                // Navigate to Main View after successful login
                ContentView()
            }
        }
    }

    // Function to log in user with Firebase
    func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                // Handle login error
                errorMessage = "ログイン失敗: \(error.localizedDescription)"
            } else {
                // Success case
                errorMessage = ""
                isLoggedIn = true
                print("Login successful: \(result?.user.uid ?? "")")
            }
        }
    }
}

#Preview {
    LoginView()
}
