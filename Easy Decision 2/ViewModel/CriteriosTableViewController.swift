//
//  CriteriosTableViewController.swift
//  Easy Decision 2
//
//  Created by Angélica Andrade de Meira on 27/03/22.
//

import UIKit
import FirebaseFirestore

class CriteriosTableViewController: UITableViewController, CriterioTableViewControllerDelegate {
    
    var decisao: Decisao?
    var listaDeCriterios: [Criterio] = []
    var firestore: Firestore!
    var criteriosListener: ListenerRegistration!
    var criterioSelecionado: Criterio?
    var alertaRecuperarCriterios = UIAlertController(title: "Atenção!", message: "Um erro ocorreu ao recuperar a lista de critérios", preferredStyle: .alert)
    
    // MARK: - View code
    
    private lazy var botaoAdicionarCriterio: UIBarButtonItem = {
        let view = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(vaiParaAdicionarCriterio))
        return view
    }()
    
    private lazy var botaoContinuar: UIBarButtonItem = {
        let view = UIBarButtonItem()
        view.title = "Continuar"
        view.target = self
        view.action = #selector(vaiParaTelaDeAvaliacao)
        return view
    }()
    
    @objc func vaiParaAdicionarCriterio() {
        let viewDeDestino = AdicionaCriterioViewController()
        viewDeDestino.decisao = self.decisao
        self.present(UINavigationController(rootViewController: viewDeDestino), animated: true)
    }
    
    @objc func vaiParaTelaDeAvaliacao() {
        let viewDestino = AvaliacaoTableViewController()
        viewDestino.listaDeCriterios = self.listaDeCriterios
        viewDestino.decisao = self.decisao
        self.navigationController?.pushViewController(viewDestino, animated: true)
    }
    
    override func loadView() {
        super.loadView()
        self.navigationItem.title = "Critérios"
        self.navigationItem.rightBarButtonItems = [botaoContinuar, botaoAdicionarCriterio]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firestore = Firestore.firestore()
        self.tableView.register(CelulaCriterioTableViewCell.self, forCellReuseIdentifier: "celulaCriterio")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addListenerRecuperarCriterios()
        self.criterioSelecionado = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        criteriosListener.remove()
    }
    
    func addListenerRecuperarCriterios() {
        guard
            self.decisao != nil,
            let idDecisao = self.decisao?.id
        else { return }
        
        criteriosListener = firestore.collection("criterios").whereField("idDecisao", isEqualTo: idDecisao).addSnapshotListener { [self] querySnapshot, erro in
            
            if erro != nil {
                self.alertaRecuperarCriterios.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "tente novamente"), style: .default, handler: nil))
                return
            }
            
            self.listaDeCriterios.removeAll()
            guard let snapshot = querySnapshot
            else { return }
            for document in snapshot.documents {
                do {
                    let dictionary = document.data()
                    let criterio = try Criterio(id: document.documentID, idDecisao: idDecisao, dictionary: dictionary)
                    self.listaDeCriterios.append(criterio)
                } catch let erro {
                    self.alertaRecuperarCriterios.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "tente novamente"), style: .default, handler: nil))
                    print("Error when trying to decode critério:" + erro.localizedDescription)
                }
            }
            
            ordenaListaDeCriteriosPorOrdemAlfabetica()
            self.tableView.reloadData()
        }
    }
    
    func ordenaListaDeCriteriosPorOrdemAlfabetica() {
        listaDeCriterios.sort(by: { criterioEsquerda, criterioDireita in
            return criterioEsquerda.descricao < criterioDireita.descricao
        })
    }
    
    func removerCriterio(indexPath: IndexPath){
        let criterio = self.listaDeCriterios[indexPath.row]
        guard let id = criterio.id
        else { return }
        firestore.collection("criterios").document(id).delete()
        self.listaDeCriterios.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func atualizaDadosCriterio(celula: UITableViewCell, peso: String) {
        guard
            let indexPath = self.tableView.indexPath(for: celula),
            let idCriterio = self.listaDeCriterios[indexPath.row].id
        else { return }
        
        let dadosCriterio = self.listaDeCriterios[indexPath.row]
        
        self.firestore.collection("criterios").document(idCriterio).setData([
            "idDecisao" : dadosCriterio.idDecisao as Any,
            "descricao" : dadosCriterio.descricao as Any,
            "peso" : peso as Any
        ])
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listaDeCriterios.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let celula = tableView.dequeueReusableCell(withIdentifier: "celulaCriterio", for: indexPath) as? CelulaCriterioTableViewCell,
            !self.listaDeCriterios.isEmpty
        else { return UITableViewCell() }
        
        celula.delegate = self
        
        let indice = indexPath.row
        let dadosCriterio = self.listaDeCriterios[indice]
        
        celula.labelDescricao.text = dadosCriterio.descricao
        celula.labelPeso.text = dadosCriterio.peso
        
        return celula
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let acoes = [
            UIContextualAction(style: .destructive, title: "Apagar", handler: { [weak self] (contextualAction, view, _) in
                guard let self = self
                else { return }
                self.removerCriterio(indexPath: indexPath)
                tableView.reloadData()
            }),
            UIContextualAction(style: .normal, title: "Editar", handler: { [weak self] (contextualAction, view, _) in
                guard let self = self
                else { return }
                let indice = indexPath.row
                self.criterioSelecionado = self.listaDeCriterios[indice]
                let viewDeDestino = AdicionaCriterioViewController()
                viewDeDestino.criterio = self.criterioSelecionado
                viewDeDestino.decisao = self.decisao
                self.present(UINavigationController(rootViewController: viewDeDestino), animated: true)
            })
        ]
        return UISwipeActionsConfiguration(actions: acoes)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.criterioSelecionado = self.listaDeCriterios[indexPath.row]
        let viewDestino = AdicionaCriterioViewController()
        viewDestino.criterio = self.criterioSelecionado
        viewDestino.decisao = self.decisao
        self.present(UINavigationController(rootViewController: viewDestino), animated: true)
    }
}

protocol CriterioTableViewControllerDelegate: AnyObject {
    func atualizaDadosCriterio(celula: UITableViewCell, peso: String)
}
