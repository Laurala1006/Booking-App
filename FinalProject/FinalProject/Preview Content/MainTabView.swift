import SwiftUI

struct MainTabView: View {
    @Binding var isLoggedIn: Bool
    @Binding var cartItems: [Product]  // 使用全局 Product
    @Binding var favorites: [Product]  // 使用全局 Product
    var products: [Product]  // 傳遞 products 陣列

    var body: some View {
        TabView {
            // 傳遞 cartItems 和 favorites 到 HomeView，並傳遞 products
            HomeView(cartItems: $cartItems, favorites: $favorites)
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            // 傳遞 favorites 和 cartItems 到 FavoritesView
            FavoritesView(favorites: $favorites, cartItems: $cartItems)
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }

            // 傳遞 cartItems 到 CartView
            CartView(cartItems: $cartItems)
                .tabItem {
                    Label("Cart", systemImage: "cart")
                }

            // 傳遞 isLoggedIn 到 ProfileView
            ProfileView(isLoggedIn: $isLoggedIn)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    @State static var isLoggedIn = true
    @State static var cartItems: [Product] = []  // 修改為 Product
    @State static var favorites: [Product] = []  // 修改為 Product
    @State static var products: [Product] = [
        Product(id: UUID(), image: "image1", name: "Product 1", price: "$10", description: "Description of Product 1", quantity: 1, isSelected: false),
        Product(id: UUID(), image: "image2", name: "Product 2", price: "$20", description: "Description of Product 2", quantity: 1, isSelected: false)
    ]  // 傳遞一些預設的 products 資料

    static var previews: some View {
        MainTabView(isLoggedIn: $isLoggedIn, cartItems: $cartItems, favorites: $favorites, products: products)  // 確保將 products 綁定到視圖
    }
}

