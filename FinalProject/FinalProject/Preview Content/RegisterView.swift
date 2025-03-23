import SwiftUI
import CoreData

enum Gender: String, CaseIterable {
    case male = "男性"
    case female = "女性"
    case unspecified = "未指定"
}

struct RegisterView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var name: String = ""
    @State private var age: String = ""
    @State private var birthday: Date = Date()
    @State private var email: String = ""
    @State private var account: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var profileImage: UIImage? = nil // 頭貼圖片
    @State private var isImagePickerPresented = false // 控制圖片選擇器
    @State private var errorMessage: String = ""
    @State private var gender: Gender = .unspecified // 預設為未指定性別

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                // 頭貼和基本資料並排顯示
                HStack(alignment: .top) {
                    // 頭貼按鈕
                    VStack {
                        Button(action: {
                            isImagePickerPresented = true
                        }) {
                            if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 90, height: 90)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                            } else {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 90, height: 90)
                                    .overlay(Text("選擇頭貼").foregroundColor(.white))
                            }
                        }
                    }
                    .frame(width: 100) // 固定頭貼按鈕的寬度，避免過多佔用

                    Spacer()
                        .frame(width: 20) // 增加頭貼與基本資料之間的間距

                    // 基本資料輸入欄位
                    VStack(alignment: .leading) {
                        Section() {
                            TextField("姓名", text: $name)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)

                            TextField("年齡", text: $age)
                                .keyboardType(.numberPad)

                            // 性別選擇器
                            Picker("性別", selection: $gender) {
                                ForEach(Gender.allCases, id: \.self) { gender in
                                    Text(gender.rawValue).tag(gender)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            DatePicker("生日", selection: $birthday, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                        }
                    }
                    .frame(maxWidth: .infinity) // 允許基本資料欄位填滿剩餘空間
                }

                // 聯絡資料區
                Section(header: Text("聯絡資料")) {
                    TextField("電子郵件", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .disableAutocorrection(true)
                }

                // 帳號內容區
                Section(header: Text("帳號內容")) {
                    TextField("帳號", text: $account)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    SecureField("密碼", text: $password)

                    SecureField("確認密碼", text: $confirmPassword)
                }

                // 顯示錯誤訊息
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                // 註冊按鈕
                Button(action: registerMember) {
                    Text("註冊")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("註冊")
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $profileImage)
        }
    }

    /// 註冊邏輯
    private func registerMember() {
        guard !name.isEmpty else {
            errorMessage = "姓名不能為空"
            return
        }

        guard let ageInt = Int(age), ageInt > 0 else {
            errorMessage = "請輸入有效的年齡"
            return
        }

        guard isValidEmail(email) else {
            errorMessage = "請輸入有效的電子郵件"
            return
        }

        guard !account.isEmpty else {
            errorMessage = "帳號不能為空"
            return
        }

        guard password.count >= 6 else {
            errorMessage = "密碼長度不得低於6"
            return
        }

        guard password == confirmPassword else {
            errorMessage = "兩次輸入的密碼不一致"
            return
        }

        if isAccountExists(account: account) {
            errorMessage = "帳號已存在，請使用其他帳號"
            return
        }

        // 保存資料
        withAnimation {
            let newMember = MemberEntity(context: viewContext)
            newMember.name = name
            newMember.age = Int32(ageInt)
            newMember.birthday = birthday
            newMember.email = email
            newMember.account = account
            newMember.password = password
            newMember.gender = gender.rawValue // 儲存性別

            if let profileImage = profileImage {
                let fileName = "\(account)_profile.jpg"
                if let savedPath = saveImageToDocuments(image: profileImage, fileName: fileName) {
                    newMember.profileImagePath = savedPath
                }
            }

            do {
                try viewContext.save()
                errorMessage = ""
                presentationMode.wrappedValue.dismiss()
            } catch {
                errorMessage = "註冊失敗，請稍後再試"
                print("註冊失敗：\(error.localizedDescription)")
            }
        }
    }

    /// 檢查帳號是否已存在
    private func isAccountExists(account: String) -> Bool {
        let fetchRequest: NSFetchRequest<MemberEntity> = MemberEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "account == %@", account)

        do {
            let count = try viewContext.count(for: fetchRequest)
            return count > 0
        } catch {
            print("檢查帳號失敗：\(error.localizedDescription)")
            return false
        }
    }

    /// 儲存圖片到文件夾
    private func saveImageToDocuments(image: UIImage, fileName: String) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL)
            return fileURL.lastPathComponent
        } catch {
            print("保存圖片失敗：\(error.localizedDescription)")
            return nil
        }
    }

    /// 驗證電子郵件格式是否正確
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
