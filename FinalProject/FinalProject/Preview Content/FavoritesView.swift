import SwiftUI

struct FavoritesView: View {
    @Binding var favorites: [Product] // 用 @Binding 傳入
    @Binding var cartItems: [Product]

    let gridColumns = [GridItem(.flexible()), GridItem(.flexible())] // 定義兩列的網格

    var body: some View {
        NavigationView {
            ZStack {
                // 背景顏色
                Color.brown.ignoresSafeArea()

                VStack {
                    Text("我的最愛")
                        .font(.largeTitle)
                        .padding()

                    if favorites.isEmpty {
                        Spacer()
                        Text("目前沒有最愛商品")
                            .foregroundColor(.black)
                            .padding()
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: gridColumns, spacing: 20) {
                                ForEach(favorites) { product in
                                    NavigationLink(destination: ProductDetailView(product: product)) {
                                        VStack {
                                            // 商品圖片
                                            Image(product.image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 150, height: 150)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .shadow(radius: 5)

                                            // 商品名稱
                                            Text(product.name)
                                                .font(.headline)
                                                .multilineTextAlignment(.center)
                                                .padding(.top, 5)

                                            // 商品價格
                                            Text(product.price)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)

                                            // 按鈕區域
                                            HStack {
                                                // 加入購物車 / 取消加入購物車
                                                Button(action: {
                                                    if cartItems.contains(where: { $0.id == product.id }) {
                                                        removeFromCart(product: product) // 移除商品
                                                    } else {
                                                        addToCart(product: product) // 加入購物車
                                                    }
                                                }) {
                                                    Image(systemName: cartItems.contains(where: { $0.id == product.id }) ? "cart.fill.badge.minus" : "cart.fill")
                                                        .font(.title2)
                                                        .foregroundColor(.brown)
                                                        .padding(5)
                                                }
                                                .padding(.top, 10)

                                                // 取消最愛
                                                Button(action: { removeFromFavorites(product: product) }) {
                                                    Image(systemName: "heart.fill")
                                                        .foregroundColor(.red)
                                                        .padding(5)
                                                        .background(Color.white)
                                                        .clipShape(Circle())
                                                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                                }
                                                .padding(.top, 10)
                                            }
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    // 加入購物車
    private func addToCart(product: Product) {
        if !cartItems.contains(where: { $0.id == product.id }) {
            cartItems.append(product)
        }
    }

    // 從購物車移除商品
    private func removeFromCart(product: Product) {
        if let index = cartItems.firstIndex(where: { $0.id == product.id }) {
            cartItems.remove(at: index)
        }
    }

    // 取消最愛
    private func removeFromFavorites(product: Product) {
        if let index = favorites.firstIndex(where: { $0.id == product.id }) {
            favorites.remove(at: index)
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView(
            favorites: .constant([
                Product(id: UUID(), image: "image1", name: "產品 1", price: "$100", description: "這是產品1的詳細描述", quantity: 1, isSelected: false),
                Product(id: UUID(), image: "image2", name: "產品 2", price: "$150", description: "這是產品2的詳細描述", quantity: 1, isSelected: false),
                Product(id: UUID(), image: "image3", name: "產品 3", price: "$200", description: "這是產品3的詳細描述", quantity: 1, isSelected: false),
                Product(id: UUID(), image: "image4", name: "產品 4", price: "$250", description: "這是產品4的詳細描述", quantity: 1, isSelected: false)
            ]),
            cartItems: .constant([]) // 傳遞一個空的 cartItems 數組
        )
    }
}
