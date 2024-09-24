//
//  Dictionary+Data.swift
//  BonnetAlternator
//
//  Created by Ana Marquez on 24/09/2024.
//

import Foundation

extension Dictionary {
    var jsonData: Data? {
        try? JSONSerialization.data(withJSONObject: self, options: [])
    }
}
