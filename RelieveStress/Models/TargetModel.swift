import Foundation
import UIKit

enum TargetType {
    case text(String)
    case image(UIImage)
    
    // Categorized built-in presets for ease of use
    static let categorizedPresets: [(category: String, tags: [String])] = [
        ("打工日常", ["画饼老板", "戏精同事", "临近下班开会", "无脑改需求", "加量不加价的工资", "背锅侠本侠", "通勤挤成肉饼"]),
        ("数字焦虑", ["大模型又降智了", "会员又偷偷涨价", "服务器又崩了", "需求文档写得像诗", "写不完的Bug", "天天要追新框架"]),
        ("生活暴击", ["干瘪的钱包", "无脑催婚催生", "日渐后移的发际线", "深夜失眠患者", "周末比上班累", "房租又猛涨了"]),
        ("网络与社交", ["网络杠精", "已读不回", "势利眼亲戚", "无底线键盘侠", "极品相亲对象", "阴阳怪气"]),
        ("日常踩雷", ["出门忘带伞", "点外卖大翻车", "脚趾撞到桌角", "刚洗车就下雨", "错失抢红包", "起步就遇红灯"])
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
