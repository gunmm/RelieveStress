import Foundation

class VentingSession {
    let id: UUID = UUID()
    let target: TargetModel
    
    // Tracking current session states
    var strikesCount: Int = 0
    var accumulatedVentingValue: Int = 0
    
    // Calculated Energy Value
    var energyValue: Int {
        return max(1, accumulatedVentingValue / 100)
    }
    
    // Level scaling system
    var currentLevel: Int = 1
    
    // The next target threshold to prompt the user (e.g., 1000, 3000, 5000, 8000...)
    var nextThreshold: Int {
        switch currentLevel {
        case 1: return 1000
        case 2: return 3000
        case 3: return 5000
        case 4: return 8000
        default: return 8000 + (currentLevel - 4) * 4000
        }
    }
    
    // Check if we hit the threshold this precise strike
    var hasHitThreshold: Bool {
        return accumulatedVentingValue >= nextThreshold
    }
    
    init(target: TargetModel) {
        self.target = target
    }
    
    /// Apply weapon hit and return the actual damage dealt
    func applyHit(weapon: WeaponModel) -> Int {
        // Accumulate statistics
        strikesCount += 1
        
        let damage = weapon.damageValue
        // Bonus multiplier for higher levels!
        let levelMultiplier = Int(Double(currentLevel) * 1.5)
        let totalDamage = damage * levelMultiplier
        
        accumulatedVentingValue += totalDamage
        return totalDamage
    }
    
    func levelUp() {
        currentLevel += 1
    }
}
