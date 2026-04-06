import Foundation
import CloudKit
import UIKit

class CloudKitAnalyticsManager {
    static let shared = CloudKitAnalyticsManager()
    
    private let container = CKContainer(identifier: "iCloud.com.syl.RelieveStress")
    private var publicDB: CKDatabase {
        return container.publicCloudDatabase
    }
    
    private let uniqueIDKey = "com.relievestress.user.analytics.uniqueid"
    
    // Unique user identifier per installation
    private var userId: String {
        if let id = UserDefaults.standard.string(forKey: uniqueIDKey) {
            return id
        } else {
            let newId = UUID().uuidString
            UserDefaults.standard.set(newId, forKey: uniqueIDKey)
            return newId
        }
    }
    
    // Prevent concurrent syncs which cause "record to insert already exists"
    private var isSyncing = false
    private let syncQueue = DispatchQueue(label: "com.relievestress.cloudkit.sync")
    
    private init() {}
    
    // MARK: - Device Info Helpers
    
    private var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    private var systemVersion: String {
        return UIDevice.current.systemVersion
    }
    
    // MARK: - Sync Logic
    
    /// Collects metrics and syncs to CloudKit public database
    func syncAnalytics() {
        syncQueue.async { [weak self] in
            guard let self = self else { return }
            guard !self.isSyncing else { return }
            self.isSyncing = true
            
            // Collect metrics
            let allRecords = RecordManager.shared.fetchAllRecords()
            let totalCount = allRecords.count
            let totalAnger = allRecords.reduce(0) { $0 + Int64($1.totalVentingScore) }
            
            let recordID = CKRecord.ID(recordName: self.userId)
            let model = self.deviceModel
            let version = self.systemVersion
            
            // Fetch to see if it exists
            self.publicDB.fetch(withRecordID: recordID) { [weak self] record, error in
                guard let self = self else { return }
                
                if let record = record {
                    // Check if any significant change happened to avoid unnecessary saves (optional, but good practice if needed)
                    let currentCount = record["ventCount"] as? Int ?? 0
                    let currentAnger = record["totalAnger"] as? Int64 ?? 0
                    
                    if currentCount == totalCount && currentAnger == totalAnger {
                        // Nothing new to sync
                        print("☁️ CloudKit Analytics: Data is already up to date.")
                        self.isSyncing = false
                        return
                    }
                    
                    // Exists, update it
                    record["ventCount"] = totalCount
                    record["totalAnger"] = totalAnger
                    record["deviceModel"] = model
                    record["systemVersion"] = version
                    record["lastUpdated"] = Date()
                    
                    self.saveRecord(record)
                } else {
                    // Determine if error is "not found" or something else
                    if let ckError = error as? CKError {
                        if ckError.code == .unknownItem {
                            // Doesn't exist, create new
                            let newRecord = CKRecord(recordType: "UserAnalytics", recordID: recordID)
                            newRecord["ventCount"] = totalCount
                            newRecord["totalAnger"] = totalAnger
                            newRecord["deviceModel"] = model
                            newRecord["systemVersion"] = version
                            newRecord["lastUpdated"] = Date()
                            newRecord["createdDate"] = Date()
                            
                            self.saveRecord(newRecord)
                            return
                        }
                    }
                    
                    // Other error (like network issue or no iCloud account)
                    print("☁️ CloudKit Analytics fetch failed: \(error?.localizedDescription ?? "Unknown Error")")
                    self.isSyncing = false
                }
            }
        }
    }
    
    private func saveRecord(_ record: CKRecord) {
        publicDB.save(record) { [weak self] savedRecord, saveError in
            defer { self?.isSyncing = false }
            
            if let error = saveError {
                // If it's literally just a serverRecordChanged due to race condition, it's safe to ignore
                if let ckError = error as? CKError, ckError.code == .serverRecordChanged {
                    print("☁️ CloudKit Analytics: Record was already updated by another thread.")
                } else {
                    print("☁️ CloudKit Analytics save failed: \(error.localizedDescription)")
                }
            } else {
                print("☁️ CloudKit Analytics successfully saved for user ID: \(record.recordID.recordName)")
            }
        }
    }
}
