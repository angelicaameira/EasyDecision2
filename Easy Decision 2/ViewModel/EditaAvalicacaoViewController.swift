//
//  EditaAvalicacaoViewController.swift
//  Easy Decision 2
//
//  Created by Angélica Andrade de Meira on 12/06/22.
//

import UIKit
import FirebaseFirestore

class EditaAvalicacaoViewController: UIViewController {
    
    var firestore: Firestore!
    var decisao: Decisao?
    var avaliacao: Avaliacao?
    
    // MARK: - View code
    
    private lazy var botaoFeito: UIBarButtonItem = {
        let view = UIBarButtonItem()
        view.title = "Feito"
        view.target = self
        view.action = #selector(feito)
        return view
    }()
    
    private lazy var campoValor: UITextField = {
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
            campoValor,
            botaoStepper
        ] {
            self.view.addSubview(view)
        }
       
        self.title = "Editar Avaliação"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        firestore = Firestore.firestore()
        setup()
        
        campoValor.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        campoValor.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        campoValor.widthAnchor.constraint(equalToConstant: 230).isActive = true
        botaoStepper.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        botaoStepper.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15).isActive = true
        
        guard let campoValor = campoValor.text
        else { return }
        botaoStepper.value = Double(campoValor) ?? 1
    }
    
    @objc func didTouchStepper(sender: UIStepper) {
        campoValor.text = String(Int(sender.value))
    }
    
    func atualizarAvaliacao(){
        guard let decisao = decisao
        else { return }
        guard let idDecisao = decisao.id
        else { return }
        guard let id = avaliacao?.id
        else { return }
        firestore.collection("avaliacoes").document(id).setData([
            "idCriterio" : avaliacao?.idCriterio as Any,
            "idDecisao" : idDecisao as Any,
            "idOpcao" : avaliacao?.idOpcao as Any,
            "valor" : campoValor.text as Any
        ])
    }
    
    @objc func feito() {
        atualizarAvaliacao()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func setup() {
        guard let avaliacao = self.avaliacao
        else { return }
        campoValor.text = String(avaliacao.valor)
    }
}
