//
//  Resultado.swift
//  Easy Decision 2
//
//  Created by Angélica Andrade de Meira on 01/04/22.
//

import Foundation
import UIKit
import FirebaseFirestore

struct Resultado: Codable {
    var id: String?
    var idDecisao: String
    var idAvaliacao: String
    var percentual: String
    
    init(id: String, idDecisao: String, idAvaliacao: String, descricaoOpcao: String, dictionary: [String: Any]) throws {
        self = try JSONDecoder().decode(Resultado.self, from: JSONSerialization.data(withJSONObject: dictionary))
        self.id = id
        self.idDecisao = idDecisao
        self.idAvaliacao = idAvaliacao
    }
}
