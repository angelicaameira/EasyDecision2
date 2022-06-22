//
//  AdicionaDecisaoViewController.swift
//  Easy Decision 2
//
//  Created by Angélica Andrade de Meira on 21/03/22.
//

import UIKit
import FirebaseFirestore

class AdicionaDecisaoViewController: UIViewController, UITextFieldDelegate {
    
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
        view.returnKeyType = .done
        view.becomeFirstResponder()
        return view
    }()
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .white
        self.navigationItem.rightBarButtonItems = [botaoFeito]
        self.view.addSubview(campoDescricao)
        
        if decisao != nil {
            self.title = "Editar decisão"
        } else {
            self.title = "Adicionar Decisão"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firestore = Firestore.firestore()
        setup()
        
        campoDescricao.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        campoDescricao.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15).isActive = true
        campoDescricao.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        campoDescricao.delegate = self
    }
    
    func salvarNovaDecisao() {
        firestore.collection("decisoes").document().setData([
            "descricao" : campoDescricao.text as Any
        ])
    }
    
    func atualizarDecisao() {
        guard
            let decisao = decisao,
            let id = decisao.id
        else { return }
        
        firestore.collection("decisoes").document(id).setData([
            "descricao" : campoDescricao.text as Any
        ])
    }
    
    @objc func feito() {
        if decisao == nil {
            salvarNovaDecisao()
        } else {
            atualizarDecisao()
        }
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func setup() {
        guard let decisao = self.decisao
        else { return }
        
        campoDescricao.text = (decisao.descricao)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        feito()
        return true
    }
}
