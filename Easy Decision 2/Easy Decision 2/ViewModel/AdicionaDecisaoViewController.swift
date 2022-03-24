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
    
    // MARK: - View code
    
    private lazy var botaoFeito: UIBarButtonItem = {
        let view = UIBarButtonItem()
        view.title = "Feito"
        view.action = #selector(feito)
        return view
      }()
    
    private lazy var campoDescricao: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.borderStyle = .roundedRect
        view.placeholder = "Insira a descrição da decisão"
        return view
      }()
    
    override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = .white
        self.navigationItem.rightBarButtonItems = [botaoFeito]
        self.view.addSubview(campoDescricao)
        
        if decisao != nil {
            self.title = "Editar decisão"
        }else{
            self.title = "Adicionar Decisão"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firestore = Firestore.firestore()
        setup()
        
        campoDescricao.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 60).isActive = true
        
        campoDescricao.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        
        campoDescricao.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
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
    
    @objc func feito() {
        
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
