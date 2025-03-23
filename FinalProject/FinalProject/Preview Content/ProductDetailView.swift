import SwiftUI
import CoreData

struct ProductDetailView: View {
    var product: Product // 接收從 HomeView 傳遞過來的商品資料
    
    var body: some View {
        ZStack {
            // 背景顏色延伸到全螢幕
            Color(hex: "#deb887")
                .edgesIgnoringSafeArea(.all) // 背景延伸到整個畫面
            
            // 內容區域
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 顯示產品圖片
                    Image(product.image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width, height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 10)
                    
                    // 顯示產品名稱
                    Text(product.name)
                        .font(.largeTitle)
                        .bold()
                    
                    // 顯示價格
                    Text(product.price)
                        .font(.title)
                        .bold()
                        .foregroundColor(Color(hex: "#2f4f4f"))
                    
                    // 顯示產品描述
                    Text(product.description)
                        .font(.body)
                        .foregroundColor(.black)
                        .font(.title2)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("產品詳情")
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailView(product: Product(id: UUID(), image: "image1", name: "產品 1", price: "$100", description: "這是產品1的詳細描述", quantity: 1, isSelected: false))
    }
}

