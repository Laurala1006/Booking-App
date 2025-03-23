import SwiftUI
import CoreData

struct LoginView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var account = ""
    @State private var password = ""
    @State private var loginStatus = ""

    @Binding var isLoggedIn: Bool // 傳遞登入狀態

    var body: some View {
        VStack(spacing: 20) {
            Text("LogIn")
                .font(.largeTitle)
                .bold()

            // 帳號輸入框
            TextField("Account", text: $account)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            // 密碼輸入框
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            // 登入按鈕
            Button("Log In") {
                login()
            }
            .font(.title2)
            .bold()
            .frame(maxWidth: .infinity, minHeight: 50)
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.horizontal)

            // 登入狀態提示
            Text(loginStatus)
                .foregroundColor(.red)
                .font(.callout)
        }
        .padding()
    }

    /// 登入邏輯
    private func login() {
        let fetchRequest: NSFetchRequest<MemberEntity> = MemberEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "account == %@ AND password == %@", account, password)

        do {
            let results = try viewContext.fetch(fetchRequest)
            if results.isEmpty {
                loginStatus = "Invalid account or password."
            } else {
                loginStatus = "Login successful!"

                // 儲存登入的帳號到 UserDefaults
                UserDefaults.standard.set(account, forKey: "currentAccount")

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    isLoggedIn = true // 切換到登入狀態
                }
            }
        } catch {
            loginStatus = "An error occurred. Please try again."
            print("Error: \(error.localizedDescription)")
        }
    }

}
