import Foundation

class RecordManager {
    static let shared = RecordManager()
    
    private let defaultsKey = "com.relievestress.venting.records"
    
    private init() {}
    
    // MARK: - Save and Load
    
    func saveOrUpdate(record: VentingRecord) {
        var existingRecords = fetchAllRecords()
        
        if let index = existingRecords.firstIndex(where: { $0.sessionId == record.sessionId }) {
            // Update existing session record
            existingRecords[index] = record
            print("Successfully updated record for session \(record.sessionId)")
        } else {
            // Add new record
            existingRecords.append(record)
            print("Successfully saved new record for target \(record.targetName)")
        }
        
        // Sort descending by date (newest first)
        existingRecords.sort { $0.date > $1.date }
        
        do {
            let encoded = try JSONEncoder().encode(existingRecords)
            UserDefaults.standard.set(encoded, forKey: defaultsKey)
        } catch {
            print("Failed to save record: \(error)")
        }
    }
    
    func fetchAllRecords() -> [VentingRecord] {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey) else { return [] }
        do {
            let records = try JSONDecoder().decode([VentingRecord].self, from: data)
            return records
        } catch {
            print("Failed to load records: \(error)")
            return []
        }
    }
    
    // MARK: - Statistic Helpers
    
    func fetchRecords(since date: Date) -> [VentingRecord] {
        return fetchAllRecords().filter { $0.date >= date }
    }
    
    func printRecentStatistics() {
        let all = fetchAllRecords()
        let thisWeek = fetchRecords(since: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date())
        let thisMonth = fetchRecords(since: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date())
        
        let totalWeekScore = thisWeek.reduce(0) { $0 + $1.totalVentingScore }
        let totalMonthScore = thisMonth.reduce(0) { $0 + $1.totalVentingScore }
        
        print("\n===============================")
        print("📊 最近发泄统计数据")
        print("总计发泄局数: \(all.count)")
        print("本周发泄次数: \(thisWeek.count) 局, 总计释放压力值: \(totalWeekScore)")
        print("本月发泄次数: \(thisMonth.count) 局, 总计释放压力值: \(totalMonthScore)")
        print("===============================\n")
    }
}
