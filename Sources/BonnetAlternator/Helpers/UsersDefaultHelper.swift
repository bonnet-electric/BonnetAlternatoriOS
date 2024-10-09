//
//  UsersDefaultHelper.swift
//  
//
//  Created by Ana Márquez on 20/06/2023.
//

import Foundation

final class UsersDefaultHelper {
    // MARK: - Shared access
    static let shared = UsersDefaultHelper()
    
    // MARK: - Storage
    
    enum StorageKeys: String {
        case userAlternatorPath = "CurrentUserAlternatorPath"
        case environment = "CurrentEnvironment"
        case filters = "CurrentUserFilters"
        case userProfile = "UserProfile"
    }
    
    // MARK: - Simple values
    
    func save(_ value: Any, withKey key: StorageKeys) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    func getString(forKey key: StorageKeys) -> String? {
        return UserDefaults.standard.string(forKey: key.rawValue)
    }
    
    // MARK: - Codable values
    
    /// Save a **Codable** value
    func set<T: Codable>(_ object: T, forKey key: StorageKeys) {
        let encoder = JSONEncoder()
        if let encodedObject = try? encoder.encode(object) {
            UserDefaults.standard.set(encodedObject, forKey: key.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    /// Returns a **Codable?** value
    func get<T: Codable>(forKey key: StorageKeys) -> T? {
        if let object = UserDefaults.standard.object(forKey: key.rawValue) as? Data {
            let decoder = JSONDecoder()
            if let decodedObject = try? decoder.decode(T.self, from: object) {
                return decodedObject
            }
        }
        return nil
    }
    
    /// Deletes Codable data for specific **key**
    func removeObject(forKey key: StorageKeys) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
}
