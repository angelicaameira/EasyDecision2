//
//  AdicionaOpcaoViewController.swift
//  Easy Decision 2
//
//  Created by Angélica Andrade de Meira on 25/03/22.
//

import UIKit
import FirebaseFirestore

class AdicionaOpcaoViewController: UIViewController, UITextFieldDelegate {
    
    var firestore: Firestore!
    var opcao: Opcao?
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
        view.placeholder = "Insira a descrição da opção"
        view.returnKeyType = .done
        view.becomeFirstResponder()
        return view
    }()
    
    override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = .white
        self.navigationItem.rightBarButtonItems = [botaoFeito]
        self.view.addSubview(campoDescricao)
        
        if opcao != nil {
            self.title = "Editar opção"
        } else {
            self.title = "Adicionar opção"
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
    
    func salvarNovaOpcao() {
        guard
            let decisao = decisao,
            let idDecisao = decisao.id
        else { return }
        
        firestore.collection("opcoes").document().setData([
            "idDecisao" : idDecisao as Any,
            "descricao" : campoDescricao.text as Any
        ])
    }
    
    func atualizarOpcao() {
        guard
            let decisao = decisao,
            let idDecisao = decisao.id,
            let id = opcao?.id
        else { return }
        
        firestore.collection("opcoes").document(id).setData([
            "idDecisao" : idDecisao as Any,
            "descricao" : campoDescricao.text as Any
        ])
    }
    
    @objc func feito() {
        if opcao == nil {
            salvarNovaOpcao()
        } else {
            atualizarOpcao()
        }
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func setup() {
        guard let opcao = self.opcao
        else { return }
        campoDescricao.text = (opcao.descricao)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        feito()
        return true
    }
}
