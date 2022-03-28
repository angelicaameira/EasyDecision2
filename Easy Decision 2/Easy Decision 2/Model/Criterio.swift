//
//  Criterio.swift
//  Easy Decision 2
//
//  Created by Angélica Andrade de Meira on 27/03/22.
//

import Foundation
import UIKit
import FirebaseFirestore

struct Criterio: Codable {
    var id: String?
    var idDecisao: String
    var descricao: String
    var peso: String
    
    init(id: String, idDecisao: String, dictionary: [String: Any]) throws {
        self = try JSONDecoder().decode(Criterio.self, from: JSONSerialization.data(withJSONObject: dictionary))
        self.id = id
        self.idDecisao = idDecisao
    }
    
}
