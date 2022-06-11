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
    var id: Int64
    var idDecisao: String
    var idOpcao: String
    var percentual: String
    
    init(idDecisao: String, idOpcao: String, percentual: String) throws {
        self.id = -1
        self.idDecisao = idDecisao
        self.idOpcao = idOpcao
        self.percentual = percentual
    }
    
    private init(id: Int64, idDecisao: String, idOpcao: String, percentual: String) throws {
        self.id = id
        self.idDecisao = idDecisao
        self.idOpcao = idOpcao
        self.percentual = percentual
    }
}
