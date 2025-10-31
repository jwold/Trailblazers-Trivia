//
//  Config.swift
//  TrailblazersTrivia
//
//  Created by Tony Stark on 10/30/25.
//

import Foundation

struct Config {
    static var revenueCatAPIKey: String {
        #if DEBUG
            return "test_NkFgsUayvyFaizoGGHJjpGqIYfq"
        #else
            return "appl_dgBICjdPGhKobHeQYEdZcAODdgD"
        #endif
    }
}
