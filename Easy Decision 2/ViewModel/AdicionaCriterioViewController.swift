//
//  AdicionaCriterioViewController.swift
//  Easy Decision 2
//
//  Created by Angélica Andrade de Meira on 27/03/22.
//

import UIKit
import FirebaseFirestore

class AdicionaCriterioViewController: UIViewController, UITextFieldDelegate {
    
    var firestore: Firestore!
    var decisao: Decisao?
    var criterio: Criterio?
    
    // MARK: - View code
    
    private lazy var botaoFeito: UIBarButtonItem = {
        let view = UIBarButtonItem()
        view.title = "Feito"
        view.target = self
        view.action = #selector(feito)
        return view
    }()
    
    private lazy var campoDescricao: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.borderStyle = .roundedRect
        view.placeholder = "Insira a descrição do critério"
        view.returnKeyType = .done
        view.becomeFirstResponder()
        return view
    }()
    
    private lazy var campoPeso: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.borderStyle = .roundedRect
        view.returnKeyType = .done
        view.isEnabled = false
        view.text = String(Int(botaoStepper.value))
        return view
    }()
    
    private lazy var botaoStepper: UIStepper = {
        let view = UIStepper()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.minimumValue = 1
        view.maximumValue = 5
        view.addTarget(self, action: #selector(didTouchStepper), for: .valueChanged)
        return view
    }()
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .white
        self.navigationItem.rightBarButtonItems = [botaoFeito]
        
        for view in [
            campoDescricao,
            campoPeso,
            botaoStepper
        ] {
            self.view.addSubview(view)
        }
        
        if criterio != nil {
            self.title = "Editar critério"
        } else {
            self.title = "Adicionar critério"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firestore = Firestore.firestore()
        setup()
        
        campoDescricao.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 60).isActive = true
        campoDescricao.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        campoDescricao.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        campoPeso.topAnchor.constraint(equalTo: self.campoDescricao.bottomAnchor, constant: 10).isActive = true
        campoPeso.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        campoPeso.widthAnchor.constraint(equalToConstant: 230).isActive = true
        botaoStepper.topAnchor.constraint(equalTo: self.campoDescricao.bottomAnchor, constant: 10).isActive = true
        botaoStepper.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        
        campoDescricao.delegate = self
        
        guard let campoPeso = campoPeso.text
        else { return }
        
        botaoStepper.value = Double(campoPeso) ?? 1
    }
    
    @objc func didTouchStepper(sender: UIStepper) {
        campoPeso.text = String(Int(sender.value))
    }
    
    func salvarNovoCriterio() {
        guard
            let decisao = decisao,
            let idDecisao = decisao.id
        else { return }
        
        firestore.collection("criterios").document().setData([
            "idDecisao" : idDecisao as Any,
            "descricao" : campoDescricao.text as Any,
            "peso" : campoPeso.text as Any
        ])
    }
    
    func atualizarCriterio(){
        guard
            let decisao = decisao,
            let idDecisao = decisao.id,
            let id = criterio?.id
        else { return }
        
        firestore.collection("criterios").document(id).setData([
            "idDecisao" : idDecisao as Any,
            "descricao" : campoDescricao.text as Any,
            "peso" : campoPeso.text as Any
        ])
    }
    
    @objc func feito() {
        if criterio == nil {
            salvarNovoCriterio()
        } else {
            atualizarCriterio()
        }
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func setup() {
        guard let criterio = self.criterio
        else { return }
        
        campoDescricao.text = (criterio.descricao)
        campoPeso.text = String(criterio.peso)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        feito()
        return true
    }
}
