//
//  Avaliacao.swift
//  Easy Decision 2
//
//  Created by Angélica Andrade de Meira on 28/03/22.
//

import Foundation
import UIKit
import FirebaseFirestore

struct Avaliacao: Codable {
    var id: String?
    var idDecisao: String
    var idCriterio: String
    var idOpcao: String
    var valor: String
    
    init(id: String, idDecisao: String, dictionary: [String: Any]) throws {
        self = try JSONDecoder().decode(Avaliacao.self, from: JSONSerialization.data(withJSONObject: dictionary))
        self.id = id
        self.idDecisao = idDecisao
    }
}
