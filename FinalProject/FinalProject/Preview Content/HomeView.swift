import SwiftUI

struct HomeView: View {
    @Binding var cartItems: [Product]
    @Binding var favorites: [Product]

    let images = ["image1", "image2", "image3", "image4", "image5", "image6"]

    private let productss: [Product] = [
        Product(id: UUID(), image: "image1", name: "Mean Girl", price: "$120.0", description: "2020.03.08", quantity: 1, isSelected: false),
        Product(id: UUID(), image: "image2", name: "雲端", price: "$180.0", description: "Wish I could just let my mind wander in the clouds 🌙☁️ 2020.04.25", quantity: 1, isSelected: false),
        Product(id: UUID(), image: "image3", name: "宇宙", price: "$220.0", description: "2019.10.30", quantity: 1, isSelected: false),
        Product(id: UUID(), image: "image4", name: "紅鶴", price: "$300.0", description: "2021.02.13", quantity: 1, isSelected: false),
        Product(id: UUID(), image: "image5", name: "Hey You", price: "$270.0", description: "2019.10.09", quantity: 1, isSelected: false),
        Product(id: UUID(), image: "image6", name: "銀杏", price: "$270.0", description: "Miss ginkgo trees in autumn🍂 2024.10.15", quantity: 1, isSelected: false)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // 照片滑動區域
                    TabView {
                        ForEach(images, id: \.self) { imageName in
                            Image(imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 5)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .frame(height: 200)
                    .padding(.top)

                    Divider().padding(.horizontal)

                    // 商品顯示區域
                    let columns = [GridItem(.adaptive(minimum: 150))] // 每個格子的最小寬度為150
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(productss) { product in
                            NavigationLink(destination: ProductDetailView(product: product)){
                                VStack {
                                    // 產品圖片
                                    Image(product.image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 150, height: 150)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .shadow(radius: 5)

                                    // 產品名稱
                                    Text(product.name)
                                        .font(.headline)
                                        .padding(.top, 5)
                                        .foregroundColor(Color(hex: "#2f4f4f"))
                                    // 價格
                                    Text(product.price)
                                        .font(.subheadline)
                                        .foregroundColor(Color(hex: "#191970"))
                                        .padding(.top, 2)

                                    // 按鈕區域
                                    HStack {
                                        // 購物車按鈕
                                        Button(action: { toggleCartStatus(for: product) }) {
                                            Image(systemName: cartItems.contains(where: { $0.id == product.id }) ? "cart.fill.badge.minus" : "cart.fill")
                                                .font(.title2)
                                                .foregroundColor(.brown)
                                                .padding(5)
                                        }
                                        
                                        // 立即購買按鈕
                                        Button(action: {
                                            purchaseNow(product: product)
                                        }) {
                                            Text("立即購買")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                                .padding(5)
                                                .background(Color.gray)
                                                .cornerRadius(5)
                                        }
                                        
                                        // 最愛按鈕
                                        Button(action: {
                                            addToFavorites(product: product)
                                        }) {
                                            Image(systemName: "heart.fill")
                                                .foregroundColor(favorites.contains(where: { $0.id == product.id }) ? .red : .gray)
                                                .padding(5)
                                                .background(Color.white)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                        }
                                    }
                                    .padding(.top, 10)
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
            .background(Color.brown)
            .onAppear {
                print("Products count: \(productss.count)")
            }
        }
    }

    // 加入或移除購物車
    private func toggleCartStatus(for product: Product) {
        if let index = cartItems.firstIndex(where: { $0.id == product.id }) {
            // 商品已經在購物車中，移除它
            cartItems.remove(at: index)
        } else {
            // 商品不在購物車中，加入它
            cartItems.append(product)
        }
    }

    // 立即購買商品
    private func purchaseNow(product: Product) {
        // 立即購買邏輯在此處可以進行處理，但已經不需要顯示 sheet
        print("立即購買 \(product.name)")
    }

    // 加入最愛
    private func addToFavorites(product: Product) {
        if !favorites.contains(where: { $0.id == product.id }) {
            favorites.append(product)
        } else {
            favorites.removeAll { $0.id == product.id }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(cartItems: .constant([]), favorites: .constant([]))
    }
}
