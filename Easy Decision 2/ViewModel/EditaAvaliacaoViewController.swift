//
//  EditaAvaliacaoViewController.swift
//  Easy Decision 2
//
//  Created by Angélica Andrade de Meira on 28/03/22.
//

import UIKit
import FirebaseFirestore

class EditaAvaliacaoViewController: UIViewController {
    
    var firestore: Firestore!
    var criterio: Criterio?
    var opcao: Opcao?
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
            campoPeso,
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
        
        campoPeso.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 60).isActive = true
        campoPeso.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        campoPeso.widthAnchor.constraint(equalToConstant: 230).isActive = true
        botaoStepper.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 60).isActive = true
        botaoStepper.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        guard let campoPeso = campoPeso.text
        else { return }
        botaoStepper.value = Double(campoPeso) ?? 1
    }
    
    @objc func didTouchStepper(sender: UIStepper) {
        campoPeso.text = String(Int(sender.value))
    }
    
    func atualizarAvaliacao() {
        guard let decisao = decisao
        else { return }
        guard let idDecisao = decisao.id
        else { return }
        guard let idCriterio = criterio?.id
        else { return }
        guard let idOpcao = opcao?.id
        else { return }
        guard let idAvaliacao = avaliacao?.id
        else { return }
        firestore.collection("avaliacoes").document(idAvaliacao).setData([
            "idDecisao" : idDecisao as Any,
            "idCriterio" : idCriterio as Any,
            "idOpcao" : idOpcao as Any,
            "valor" : campoPeso.text as Any
        ])
    }
    
    func salvarNovaAvalicao() {
        guard let decisao = decisao
        else { return }
        guard let idDecisao = decisao.id
        else { return }
        guard let idCriterio = criterio?.id
        else { return }
        guard let idOpcao = opcao?.id
        else { return }
        firestore.collection("avaliacoes").document().setData([
            "idDecisao" : idDecisao as Any,
            "idCriterio" : idCriterio as Any,
            "idOpcao" : idOpcao as Any,
            "valor" : campoPeso.text as Any
        ])
    }
    
    @objc func feito() {
        if avaliacao == nil{
            salvarNovaAvalicao()
        }else{
            atualizarAvaliacao()
        }
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func setup() {
        guard self.criterio != nil
        else { return }
        guard self.opcao != nil
        else { return }
        guard let avaliacao = self.avaliacao
        else { return }
        campoPeso.text = String(avaliacao.valor)
    }
}
