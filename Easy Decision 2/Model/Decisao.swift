//
//  Decisao.swift
//  Easy Decision 2
//
//  Created by Angélica Andrade de Meira on 21/03/22.
//

import Foundation
import UIKit
import FirebaseFirestore

struct Decisao: Codable {
    var id: String?
    var descricao: String
    
    init(id: String, dictionary: [String: Any]) throws {
        self = try JSONDecoder().decode(Decisao.self, from: JSONSerialization.data(withJSONObject: dictionary))
        self.id = id
    }
}
