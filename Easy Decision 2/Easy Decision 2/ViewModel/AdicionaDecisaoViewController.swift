//
//  AdicionaDecisaoViewController.swift
//  Easy Decision 2
//
//  Created by Angélica Andrade de Meira on 21/03/22.
//

import UIKit
import FirebaseFirestore

class AdicionaDecisaoViewController: UIViewController {
    
    var firestore: Firestore!
    var decisao: Decisao?
    var idDecisao: String = ""
    var descricaoDecisao: String = ""

    
    @IBOutlet weak var campoDescricao: UITextField!
    
    override func loadView() {
        super.loadView()
        
//        self.view.backgroundColor = .white
//        self.title = "Adicionar Decisão"
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firestore = Firestore.firestore()
        setup()
        
        if decisao != nil {
            self.navigationItem.title = "Editar decisão"
        }
    }
    
    func salvarNovaDecisao(){
        firestore.collection("decisoes").document().setData([
            "descricao" : campoDescricao.text as Any
        ])
    }
    
    func atualizarDecisao(){
        let id = decisao?.id
        
        firestore.collection("decisoes").document(id!).setData([
            "descricao" : campoDescricao.text as Any
        ])
    }
    
    @IBAction func botaoFeito(_ sender: Any) {
        
        if decisao == nil{
            salvarNovaDecisao()
        }else{
            atualizarDecisao()
        }
  
        self.navigationController?.dismiss(animated: true, completion: nil)

    }
    
    func setup() {
        if let decisao = self.decisao{
            campoDescricao.text = (decisao.descricao)
        }
    }
}
