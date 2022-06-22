//
//  OpcoesTableViewController.swift
//  Easy Decision 2
//
//  Created by Angélica Andrade de Meira on 25/03/22.
//

import UIKit
import FirebaseFirestore

class OpcoesTableViewController: UITableViewController {
    
    var decisao: Decisao?
    var listaDeOpcoes: [Opcao] = []
    var firestore: Firestore!
    var opcoesListener: ListenerRegistration!
    var opcaoSelecionada: Opcao?
    var alertaRecuperarOpcoes = UIAlertController(title: "Atenção!", message: "Um erro ocorreu ao recuperar a lista de opções", preferredStyle: .alert)
    
    // MARK: - View code
    
    private lazy var botaoAdicionarOpcao: UIBarButtonItem = {
        let view = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(vaiParaAdicionarOpcao))
        return view
    }()
    
    private lazy var botaoContinuar: UIBarButtonItem = {
        let view = UIBarButtonItem()
        view.title = "Continuar"
        view.target = self
        view.action = #selector(vaiParaTelaDeCriterios)
        return view
    }()
    
    @objc func vaiParaAdicionarOpcao() {
        let viewDeDestino = AdicionaOpcaoViewController()
        viewDeDestino.decisao = self.decisao
        self.present(UINavigationController(rootViewController: viewDeDestino), animated: true)
    }
    
    @objc func vaiParaTelaDeCriterios() {
        let viewDestino = CriteriosTableViewController()
        viewDestino.decisao = self.decisao
        self.navigationController?.pushViewController(viewDestino, animated: true)
    }
    
    override func loadView() {
        super.loadView()
        self.navigationItem.title = "Opções"
        self.navigationItem.rightBarButtonItems = [botaoContinuar, botaoAdicionarOpcao]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firestore = Firestore.firestore()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "celulaOpcao")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addListenerRecuperarOpcoes()
        self.opcaoSelecionada = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        opcoesListener.remove()
    }
    
    func addListenerRecuperarOpcoes() {
        guard
            self.decisao != nil,
            let idDecisao = self.decisao?.id
        else { return }
        
        opcoesListener = firestore.collection("opcoes").whereField("idDecisao", isEqualTo: idDecisao).addSnapshotListener { [self] querySnapshot, erro in
            
            if erro != nil {
                self.alertaRecuperarOpcoes.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "tente novamente"), style: .default, handler: nil))
                return
            }
            
            self.listaDeOpcoes.removeAll()
            
            guard let snapshot = querySnapshot
            else { return }
            
            for document in snapshot.documents {
                do {
                    let dictionary = document.data()
                    let opcao = try Opcao(id: document.documentID, idDecisao: idDecisao, dictionary: dictionary)
                    self.listaDeOpcoes.append(opcao)
                } catch let erro {
                    self.alertaRecuperarOpcoes.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "tente novamente"), style: .default, handler: nil))
                    print("Error when trying to decode Opção:" + erro.localizedDescription)
                }
            }
            ordenaListaDeOpcoesPorOrdemAlfabetica()
            self.tableView.reloadData()
        }
    }
    
    func ordenaListaDeOpcoesPorOrdemAlfabetica() {
        listaDeOpcoes.sort(by: { opcaoEsquerda, opcaoDireita in
            return opcaoEsquerda.descricao < opcaoDireita.descricao
        })
    }
    
    func removerOpcao(indexPath: IndexPath) {
        let opcao = self.listaDeOpcoes[indexPath.row]
        guard let id = opcao.id
        else { return }
        firestore.collection("opcoes").document(id).delete()
        self.listaDeOpcoes.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listaDeOpcoes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celula = tableView.dequeueReusableCell(withIdentifier: "celulaOpcao", for: indexPath)
        let indice = indexPath.row
        let dadosOpcao = self.listaDeOpcoes[indice]
        
        celula.textLabel?.text = dadosOpcao.descricao
        
        return celula
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let acoes = [
            UIContextualAction(style: .destructive, title: "Apagar", handler: { [weak self] (contextualAction, view, _) in
                guard let self = self
                else { return }
                self.removerOpcao(indexPath: indexPath)
                tableView.reloadData()
            }),
            UIContextualAction(style: .normal, title: "Editar", handler: { [weak self] (contextualAction, view, _) in
                guard let self = self
                else { return }
                let indice = indexPath.row
                self.opcaoSelecionada = self.listaDeOpcoes[indice]
                let viewDeDestino = AdicionaOpcaoViewController()
                viewDeDestino.opcao = self.opcaoSelecionada
                viewDeDestino.decisao = self.decisao
                self.present(UINavigationController(rootViewController: viewDeDestino), animated: true)
            })
        ]
        return UISwipeActionsConfiguration(actions: acoes)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
