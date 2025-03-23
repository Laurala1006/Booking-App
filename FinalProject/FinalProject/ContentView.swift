import SwiftUI
import CoreData

struct ContentView: View {
    
    @State private var isLoggedIn = false // 管理登入狀態
    @State private var cartItems: [Product] = [] // 管理購物車，使用正確的 Product 類型
    @State private var favorites: [Product] = [] // 管理最愛商品，使用正確的 Product 類型
    @State private var products: [Product] = [
        Product(id: UUID(), image: "image1", name: "Product 1", price: "$10", description: "Description of Product 1", quantity: 1, isSelected: false),
        Product(id: UUID(), image: "image2", name: "Product 2", price: "$20", description: "Description of Product 2", quantity: 1, isSelected: false)
    ]

    var body: some View {
        ZStack {
            // 背景顏色設定，並延伸到整個畫面
            Color.brown
                .ignoresSafeArea() // 背景顏色延伸至安全區域外

            if isLoggedIn {
                // 登入後顯示主頁
                MainTabView(isLoggedIn: $isLoggedIn, cartItems: $cartItems, favorites: $favorites, products: products)
            } else {
                // 顯示登入/註冊頁面
                NavigationStack {
                    VStack(spacing: 20) {
                        Image(systemName: "person.3")
                            .font(.largeTitle)
                            .bold()
                            .padding()

                        // 註冊按鈕
                        NavigationLink(destination: RegisterView()) {
                            Text("Register")
                                .font(.title2)
                                .bold()
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }

                        // 登入按鈕
                        NavigationLink(destination: LoginView(isLoggedIn: $isLoggedIn)) {
                            Text("LogIn")
                                .font(.title2)
                                .bold()
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .foregroundColor(.white)
                                .background(Color.green)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                    // 設定 NavigationStack 的背景顏色為透明
                    .background(Color.clear)
                }
                .navigationBarBackButtonHidden(true) // 如果需要隱藏返回按鈕
                .toolbarBackground(Color.red, for: .navigationBar) // 改變導航欄的背景顏色
            }
        }
    }
}

#Preview {
    ContentView()
}
