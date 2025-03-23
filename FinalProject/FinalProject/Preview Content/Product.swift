import Foundation

struct Product: Identifiable {
    var id: UUID
    var image: String
    var name: String
    var price: String
    var description: String
    var quantity: Int // 商品數量
    var isSelected: Bool // 是否被選中
}


