//
//  TeamNameStorage.swift
//  TrailblazersTrivia
//
//  Created by AI Assistant on 11/19/25.
//

import Foundation

/// Manages persistent storage of custom team/player names
struct TeamNameStorage {
    
    private enum Keys {
        static let groupTeam1 = "customGroupTeam1Name"
        static let groupTeam2 = "customGroupTeam2Name"
        static let couchPlayer1 = "customCouchPlayer1Name"
        static let couchPlayer2 = "customCouchPlayer2Name"
    }
    
    // MARK: - Group Mode (Team Names)
    
    static var groupTeam1Name: String {
        get {
            UserDefaults.standard.string(forKey: Keys.groupTeam1) ?? "Team One"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.groupTeam1)
        }
    }
    
    static var groupTeam2Name: String {
        get {
            UserDefaults.standard.string(forKey: Keys.groupTeam2) ?? "Team Two"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.groupTeam2)
        }
    }
    
    // MARK: - Couch Mode (Player Names)
    
    static var couchPlayer1Name: String {
        get {
            UserDefaults.standard.string(forKey: Keys.couchPlayer1) ?? "Player 1"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.couchPlayer1)
        }
    }
    
    static var couchPlayer2Name: String {
        get {
            UserDefaults.standard.string(forKey: Keys.couchPlayer2) ?? "Player 2"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.couchPlayer2)
        }
    }
    
    // MARK: - Reset to Defaults
    
    static func resetGroupNames() {
        UserDefaults.standard.removeObject(forKey: Keys.groupTeam1)
        UserDefaults.standard.removeObject(forKey: Keys.groupTeam2)
    }
    
    static func resetCouchNames() {
        UserDefaults.standard.removeObject(forKey: Keys.couchPlayer1)
        UserDefaults.standard.removeObject(forKey: Keys.couchPlayer2)
    }
    
    static func resetAllNames() {
        resetGroupNames()
        resetCouchNames()
    }
}
