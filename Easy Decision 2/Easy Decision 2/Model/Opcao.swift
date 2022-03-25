//
//  Opcao.swift
//  Easy Decision 2
//
//  Created by Angélica Andrade de Meira on 25/03/22.
//

import Foundation
import UIKit
import FirebaseFirestore

struct Opcao: Codable {
    var id: String?
    var idDecisao: String
    var descricao: String
    
    init(id: String, idDecisao: String, dictionary: [String: Any]) throws {
        self = try JSONDecoder().decode(Opcao.self, from: JSONSerialization.data(withJSONObject: dictionary))
        self.id = id
        self.idDecisao = idDecisao
    }
    
}
