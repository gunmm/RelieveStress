import Foundation

struct VentingRecord: Codable {
    let id: UUID
    let sessionId: UUID
    let date: Date
    let targetName: String
    let totalVentingScore: Int
    let energyValue: Int
    let weaponUsedTimes: Int
    
    init(sessionId: UUID, targetName: String, totalVentingScore: Int, energyValue: Int, weaponUsedTimes: Int) {
        self.id = UUID()
        self.sessionId = sessionId
        self.date = Date()
        self.targetName = targetName
        self.totalVentingScore = totalVentingScore
        self.energyValue = energyValue
        self.weaponUsedTimes = weaponUsedTimes
    }
}
