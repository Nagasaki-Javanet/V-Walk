import SwiftUI
import FirebaseAuth
struct SignUpView: View {
    @State private var name = "" // Name input
    @State private var email = ""
    @State private var password = ""
    
    // Use UserManager to save extra data
    @StateObject private var userManager = UserManager()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("新規登録")
                .font(.largeTitle)
                .bold()

            // Name Input Field
            TextField("お名前", text: $name) // "Name"
                .textFieldStyle(.roundedBorder)

            TextField("メールアドレス", text: $email)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)

            SecureField("パスワード", text: $password)
                .textFieldStyle(.roundedBorder)

            Button {
                registerUser()
            } label: {
                Text("登録する")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }

    func registerUser() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                // Success! Now save the name to Firestore
                // Firebase Auth only stores Email/Password, so we need Firestore for the name
                userManager.createNewUser(name: name)
                
                dismiss()
            }
        }
    }
}
