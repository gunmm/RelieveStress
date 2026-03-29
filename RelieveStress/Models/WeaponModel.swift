import Foundation
import UIKit

// Define the type of weapon impact level
enum ImpactLevel {
    case light
    case heavy
}

struct WeaponModel: Equatable {
    let id: String
    let name: String
    let damageValue: Int
    let iconEmoji: String
    let impactLevel: ImpactLevel
    
    // Default available weapons
    static let availableWeapons: [WeaponModel] = [
        WeaponModel(id: "fist_small", name: "小拳头", damageValue: 2, iconEmoji: "🤜", impactLevel: .light),
        WeaponModel(id: "fist_large", name: "大拳头", damageValue: 5, iconEmoji: "👊", impactLevel: .heavy),
        WeaponModel(id: "stick_small", name: "小棍子", damageValue: 4, iconEmoji: "🏏", impactLevel: .light),
        WeaponModel(id: "hammer_large", name: "大铁锤", damageValue: 10, iconEmoji: "🔨", impactLevel: .heavy)
    ]
    
    public static func == (lhs: WeaponModel, rhs: WeaponModel) -> Bool {
        return lhs.id == rhs.id
    }
}
