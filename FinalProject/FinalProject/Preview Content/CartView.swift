import SwiftUI

struct CartView: View {
    @Binding var cartItems: [Product] // @Binding 用於綁定父視圖中的 cartItems

    @State private var showConfirmation = false
    @State private var showPurchaseCompleteAlert = false

    let gridColumns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            ZStack {
                Color.brown.ignoresSafeArea()

                VStack {
                    Text("購物車")
                        .font(.largeTitle)
                        .padding()

                    if cartItems.isEmpty {
                        Spacer()
                        Text("購物車中沒有商品")
                            .foregroundColor(.black)
                            .padding()
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: gridColumns, spacing: 20) {
                                ForEach(cartItems.indices, id: \.self) { index in
                                    NavigationLink(destination: ProductDetailView(product: cartItems[index])) {
                                        ZStack(alignment: .topLeading) {
                                            VStack {
                                                Image(cartItems[index].image)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 150, height: 150)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                                    .shadow(radius: 5)

                                                Text(cartItems[index].name)
                                                    .font(.headline)
                                                    .multilineTextAlignment(.center)
                                                    .padding(.top, 5)

                                                Text(cartItems[index].price)
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)

                                                HStack {
                                                    Button(action: {
                                                        decreaseQuantity(for: index)
                                                    }) {
                                                        Image(systemName: "minus.circle")
                                                            .foregroundColor(.red)
                                                            .font(.title2)
                                                    }
                                                    Text("\(cartItems[index].quantity)")
                                                        .font(.headline)
                                                        .frame(minWidth: 30)
                                                    Button(action: {
                                                        increaseQuantity(for: index)
                                                    }) {
                                                        Image(systemName: "plus.circle")
                                                            .foregroundColor(.green)
                                                            .font(.title2)
                                                    }
                                                }
                                                .padding(.top, 5)
                                            }
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(10)
                                            .shadow(radius: 5)

                                            HStack {
                                                Button(action: {
                                                    cartItems[index].isSelected.toggle()
                                                }) {
                                                    Image(systemName: cartItems[index].isSelected ? "checkmark.circle.fill" : "circle")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 30, height: 30)
                                                        .foregroundColor(.green)
                                                }
                                                Spacer()
                                            }
                                            .padding(10)

                                            HStack {
                                                Spacer()
                                                Button(action: {
                                                    removeItem(at: index)
                                                }) {
                                                    Image(systemName: "trash.circle.fill")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 30, height: 30)
                                                        .foregroundColor(.red)
                                                }
                                                .padding(10)
                                            }
                                        }
                                        .padding()
                                    }
                                    
                                }
                            }
                            .padding()
                        }

                        Button(action: {
                            showConfirmation = true
                        }) {
                            Text("購買 (\(totalItems()) 件商品)")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray)
                                .cornerRadius(10)
                        }
                        .sheet(isPresented: $showConfirmation) {
                            // 传递已选中的商品到 ConfirmationSheet
                            ConfirmationSheet(cartItems: $cartItems, totalAmount: calculateTotalAmount()) {
                                showConfirmation = false
                                showPurchaseCompleteAlert = true
                                purchaseItems()
                            }
                        }

                        .alert("購買完成", isPresented: $showPurchaseCompleteAlert) {
                            Button("確認") { }
                        } message: {
                            Text("您已成功購買所有商品！")
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    private func decreaseQuantity(for index: Int) {
        if cartItems[index].quantity > 1 {
            cartItems[index].quantity -= 1
        } else {
            cartItems.remove(at: index)
        }
    }

    private func increaseQuantity(for index: Int) {
        cartItems[index].quantity += 1
    }

    private func totalItems() -> Int {
        selectedItems().reduce(0) { $0 + $1.quantity }
    }

    private func calculateTotalAmount() -> String {
        let total = selectedItems().reduce(0.0) { result, product in
            let productPrice = Double(product.price.replacingOccurrences(of: "$", with: "")) ?? 0.0
            return result + productPrice * Double(product.quantity)
        }
        return String(format: "$%.2f", total)
    }

    func selectedItems() -> [Product] {
        cartItems.filter { $0.isSelected }
    }

    private func removeItem(at index: Int) {
        cartItems.remove(at: index)
    }

    private func purchaseItems() {
        let context = PersistenceController.shared.container.viewContext
        
        // 儲存每個選中的商品到 CoreData 購買紀錄
        for item in selectedItems() {
            let purchase = Purchase(context: context)
            purchase.id = UUID()
            purchase.name = item.name
            purchase.price = item.price
            purchase.image = item.image
            purchase.purchaseDate = Date() // 設定為當前日期
            
            // 儲存購買記錄
            do {
                try context.save()
            } catch {
                print("無法儲存購買記錄: \(error.localizedDescription)")
            }
        }
        
        // 清空選中的商品
        cartItems.removeAll { $0.isSelected }
    }

    
}

struct ConfirmationSheet: View {
    @Binding var cartItems: [Product]
    var totalAmount: String
    var onConfirm: () -> Void

    var body: some View {
        NavigationView {
            VStack {
                Text("確認購買")
                    .font(.largeTitle)
                    .padding()

                ScrollView {
                    ForEach(cartItems.indices, id: \.self) { index in
                        HStack {
                            // 勾選框
                            Button(action: {
                                cartItems[index].isSelected.toggle()
                            }) {
                                Image(systemName: cartItems[index].isSelected ? "checkmark.circle.fill" : "circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.green)
                            }
                            // 商品圖片
                            Image(cartItems[index].image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            VStack(alignment: .leading) {
                                Text(cartItems[index].name)
                                    .font(.headline)
                                Text("價格: \(cartItems[index].price)")
                            }

                            // 數量調整按鈕
                            HStack {
                                Button(action: {
                                    if cartItems[index].quantity > 1 {
                                        cartItems[index].quantity -= 1
                                    }
                                }) {
                                    Image(systemName: "minus.circle")
                                        .foregroundColor(.red)
                                        .font(.title2)
                                }
                                Text("\(cartItems[index].quantity)")
                                    .font(.headline)
                                    .frame(minWidth: 30)
                                Button(action: {
                                    cartItems[index].quantity += 1
                                }) {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                }
                            }
                            .padding(.leading)

                            
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                    }
                }

                Text("總金額：\(totalAmount)")
                    .font(.title2)
                    .padding()

                Button(action: {
                    onConfirm() // 執行購買邏輯並顯示 Alert
                }) {
                    Text("確認購買")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
    
}



struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView(cartItems: .constant([
            Product(id: UUID(), image: "image1", name: "產品 1", price: "$100", description: "這是產品1的詳細描述", quantity: 1, isSelected: false),
            Product(id: UUID(), image: "image2", name: "產品 2", price: "$150", description: "這是產品2的詳細描述", quantity: 2, isSelected: false),
            Product(id: UUID(), image: "image3", name: "產品 3", price: "$200", description: "這是產品3的詳細描述", quantity: 3, isSelected: false)
        ]))
    }
}
