import Foundation
import UIKit

enum TargetType {
    case text(String)
    case image(UIImage)
    
    // Categorized built-in presets for ease of use
    static let categorizedPresets: [(category: String, tags: [String])] = [
        ("职场/老板PUA", ["老板是傻瓜", "又背黑锅了", "下班开会", "画大饼", "需求全改", "明天上线"]),
        ("AI时代焦虑", ["要被AI替代了", "跟不上时代", "AI怎么又涨价了", "Prompt写不出", "算力枯竭"]),
        ("生活与压力", ["钱包空空", "天天熬夜", "发际线上移", "催婚催生", "毫无头绪"])
    ]
}

struct TargetModel {
    let id: UUID
    let type: TargetType
    let maxHealth: Int
    
    init(type: TargetType, maxHealth: Int = 100) {
        self.id = UUID()
        self.type = type
        self.maxHealth = maxHealth
    }
}
