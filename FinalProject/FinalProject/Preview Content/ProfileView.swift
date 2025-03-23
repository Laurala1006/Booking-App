import SwiftUI
import CoreData

struct ProfileView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isLoggedIn: Bool // 綁定登入狀態

    @State private var userName: String = "未設定"
    @State private var userAge: String = "未設定"
    @State private var userBirthday: String = "未設定"
    @State private var userAccount: String = "未設定"
    @State private var profileImage: UIImage? = nil

    @State private var isImagePickerPresented = false
    @State private var isLoading = true
    @State private var showLogoutConfirmation = false
    @State private var showDeleteAccountConfirmation = false
    
    // 用來控制購買紀錄顯示的狀態
    @State private var isPurchaseListVisible: Bool = false

    @FetchRequest(
        entity: Purchase.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Purchase.purchaseDate, ascending: false)]
    ) private var purchases: FetchedResults<Purchase>

    var body: some View {
        ZStack {
            Color.brown.ignoresSafeArea()

            VStack(spacing: 20) {
                if isLoading {
                    ProgressView("加載中...")
                        .padding()
                } else {
                    Button(action: { isImagePickerPresented = true }) {
                        if let profileImage = profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                        } else {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 120, height: 120)
                                .overlay(Text("選擇圖片").foregroundColor(.white))
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        ProfileInfoRow(title: "姓名", value: userName)
                        ProfileInfoRow(title: "年齡", value: userAge)
                        ProfileInfoRow(title: "生日", value: userBirthday)
                        ProfileInfoRow(title: "帳號", value: userAccount)
                    }

                    ProfileButton(title: "登出", action: { showLogoutConfirmation = true })
                        .alert("確定要登出嗎？", isPresented: $showLogoutConfirmation) {
                            Button("登出", role: .destructive, action: logout)
                            Button("取消", role: .cancel) {}
                        }

                    ProfileButton(title: "刪除帳號", action: { showDeleteAccountConfirmation = true })
                        .alert("確定要刪除帳號嗎？", isPresented: $showDeleteAccountConfirmation) {
                            Button("刪除", role: .destructive, action: deleteAccount)
                            Button("取消", role: .cancel) {}
                        }

                    Spacer()

                    // 購買紀錄按鈕
                    ProfileButton(title: "顯示購買紀錄", action: {
                        isPurchaseListVisible.toggle() // 切換購買紀錄的顯示狀態
                    })

                    // 顯示購買紀錄列表
                    if isPurchaseListVisible {
                        List {
                            Section(header: Text("購買記錄").foregroundColor(.white)) {
                                ForEach(purchases) { purchase in
                                    PurchaseRow(purchase: purchase)
                                }
                            }
                        }
                        .listStyle(InsetGroupedListStyle()) // 讓 List 更符合 iOS 風格
                    }
                }
            }
            .padding()
            .navigationTitle("個人檔案")
            .onAppear(perform: loadUserData)
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $profileImage)
            }
            .onChange(of: profileImage) { _ in saveProfileImage() } // 確保儲存新圖片
        }
    }

    // 加載使用者資料
    private func loadUserData() {
        isLoading = true
        guard let currentAccount = UserDefaults.standard.string(forKey: "currentAccount") else {
            isLoading = false
            return
        }

        let fetchRequest: NSFetchRequest<MemberEntity> = MemberEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "account == %@", currentAccount)

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let results = try viewContext.fetch(fetchRequest)
                if let member = results.first {
                    DispatchQueue.main.async {
                        userName = member.name ?? "未設定"
                        userAge = "\(member.age)"
                        userBirthday = formattedDate(member.birthday)
                        userAccount = member.account ?? "未設定"
                        profileImage = loadImageFromDocuments(fileName: member.profileImagePath)
                        isLoading = false
                    }
                }
            } catch {
                print("加載使用者資料失敗：\(error.localizedDescription)")
                DispatchQueue.main.async {
                    isLoading = false
                }
            }
        }
    }

    // 儲存圖片
    private func saveProfileImage() {
        guard let profileImage = profileImage else { return }
        let fileName = "\(userAccount)_profile.jpg"
        _ = saveImageToDocuments(image: profileImage, fileName: fileName)
    }

    private func logout() {
        UserDefaults.standard.removeObject(forKey: "currentAccount")
        isLoggedIn = false
    }

    private func deleteAccount() {
        guard let currentAccount = UserDefaults.standard.string(forKey: "currentAccount") else { return }

        let fetchRequest: NSFetchRequest<MemberEntity> = MemberEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "account == %@", currentAccount)

        do {
            let results = try viewContext.fetch(fetchRequest)
            if let member = results.first {
                viewContext.delete(member)
                try viewContext.save()
                UserDefaults.standard.removeObject(forKey: "currentAccount")
                isLoggedIn = false
            }
        } catch {
            print("刪除帳號失敗：\(error.localizedDescription)")
        }
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "未設定" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// 小組件：顯示使用者資訊
struct ProfileInfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text("\(title):")
                .font(.title3)
                .bold()
                .foregroundColor(.white)
            Text(value)
                .font(.title3)
                .foregroundColor(.white)
        }
    }
}

// 小組件：按鈕樣式
struct ProfileButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity, minHeight: 50)
                .foregroundColor(.white)
                .background(Color(hex: "#d2b48c"))
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

// 小組件：購買記錄
struct PurchaseRow: View {
    let purchase: Purchase
    var body: some View {
        HStack {
            if let imageName = purchase.image,
               let uiImage = loadImageFromAssets(imageName: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                // 如果圖片名稱無效或找不到，顯示一個灰色的占位圖
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 50, height: 50)
            }

            VStack(alignment: .leading) {
                Text(purchase.name ?? "未知商品")
                    .font(.headline)
                Text("$\(purchase.price ?? "0")")
                    .font(.subheadline)
            }
        }
    }
}

// 用來從 Assets 加載圖片的方法
func loadImageFromAssets(imageName: String) -> UIImage? {
    return UIImage(named: imageName)
}


// MARK: - 文件存取工具方法
func loadImageFromDocuments(fileName: String?) -> UIImage? {
    guard let fileName = fileName else { return nil }
    
    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName)
    
    if let fileURL = fileURL, let imageData = try? Data(contentsOf: fileURL) {
        return UIImage(data: imageData)
    }
    
    return nil
}

func saveImageToDocuments(image: UIImage, fileName: String) -> Bool {
    guard let data = image.jpegData(compressionQuality: 0.8) else { return false }
    
    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName)
    
    if let fileURL = fileURL {
        do {
            try data.write(to: fileURL)
            return true
        } catch {
            print("Failed to save image: \(error.localizedDescription)")
            return false
        }
    }
    
    return false
}


// 預覽
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView(isLoggedIn: .constant(true))
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}

