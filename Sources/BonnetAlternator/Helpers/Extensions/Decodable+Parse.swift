//
//  Decodable+Parse.swift
//  
//
//  Created by Ana Márquez on 20/06/2023.
//

import Foundation
import BFSecurity

extension Decodable {
    
    static public func parse(data: Data) throws -> Self {
        let decoder = JSONDecoder()
        
        do {
            let decodedValue = try decoder.decode(Self.self, from: data)
            return decodedValue
            
        } catch let DecodingError.dataCorrupted(context) {
            debugPrint("[Bonnet Alternator] Parsed error: \(context.codingPath)")
            throw SecurityServiceError.other(message: "Data Corrupted")
            
        } catch let DecodingError.keyNotFound(key, context) {
            debugPrint("[Bonnet Alternator] Parsed error: Key '\(key)' not found: \(context.debugDescription)")
            debugPrint("[Bonnet Alternator] Parsed error: Coding Path \(context.codingPath)")
            throw SecurityServiceError.other(message: "Key not found")
            
        } catch let DecodingError.valueNotFound(value, context) {
            debugPrint("[Bonnet Alternator] Parsed error: Key '\(value)' not found: \(context.debugDescription)")
            debugPrint("[Bonnet Alternator] Parsed error: Coding Path \(context.codingPath)")
            throw SecurityServiceError.other(message: "Value not found")
            
        } catch let DecodingError.typeMismatch(type, context)  {
            debugPrint("[Bonnet Alternator] Parsed error: Type '\(type)' mismatch:", context.debugDescription)
            debugPrint("[Bonnet Alternator] Parsed error: codingPath:", context.codingPath)
            debugPrint("[Bonnet Alternator] Parsed error: underlyingError:", context.underlyingError ?? "")
            throw SecurityServiceError.other(message: "Type Mismatch")
            
        } catch let error {
            throw error
        }
    }
}
