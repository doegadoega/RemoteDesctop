import SwiftUI
import RoyalVNCKit

struct CredentialView: View {
    let authenticationType: VNCAuthenticationType?
    let previousUsername: String?
    let previousPassword: String?
    let completion: (VNCCredential?) -> Void
    
    @State private var username: String = ""
    @State private var password: String = ""
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    if authenticationType?.requiresUsername ?? false {
                        TextField("ユーザー名", text: $username)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    SecureField("パスワード", text: $password)
                }
                
                Section {
                    Button("OK") {
                        let credential = createCredential()
                        completion(credential)
                        presentationMode.wrappedValue.dismiss()
                    }
                    
                    Button("キャンセル") {
                        completion(nil)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("認証")
            .onAppear {
                username = previousUsername ?? ""
                password = previousPassword ?? ""
                
                if authenticationType?.requiresUsername ?? false {
                    // TODO: Focus username field
                } else {
                    // TODO: Focus password field
                }
            }
        }
    }
    
    private func createCredential() -> VNCCredential? {
        if authenticationType?.requiresUsername ?? false {
            return VNCUsernamePasswordCredential(username: username, password: password)
        } else {
            return VNCPasswordCredential(password: password)
        }
    }
} 