//
//  ResultadoTableViewController.swift
//  Easy Decision 2
//
//  Created by Angélica Andrade de Meira on 01/04/22.
//

import UIKit
import FirebaseFirestore

class ResultadoTableViewController: UITableViewController {
    
    var decisao: Decisao?
    var listaDeResultados: [Resultado] = []
    var firestore: Firestore!
    var avaliacao: Avaliacao?
    var opcoesListener: ListenerRegistration!
    var listaDeOpcoes: [Opcao] = []
    
    // MARK: - View code
    
    private lazy var botaoConcluir: UIBarButtonItem = {
        let view = UIBarButtonItem()
        view.title = "Concluir"
        view.target = self
        view.action = #selector(concluir)
        return view
    }()
    
    @objc func concluir() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func loadView() {
        super.loadView()
        self.navigationItem.title = "Resultado"
        self.navigationItem.rightBarButtonItems = [botaoConcluir]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firestore = Firestore.firestore()
        self.tableView.register(CelulaTableViewCell.self, forCellReuseIdentifier: "celulaResultado")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addListenerRecuperarOpcoes()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        opcoesListener.remove()
    }
    
    func addListenerRecuperarOpcoes() {
        guard self.decisao != nil
        else { return }
        guard let idDecisao = self.decisao?.id
        else { return }
        opcoesListener = firestore.collection("opcoes").whereField("idDecisao", isEqualTo: idDecisao).addSnapshotListener { [self] querySnapshot, erro in
            if erro == nil {
                self.listaDeOpcoes.removeAll()
                guard let snapshot = querySnapshot
                else { return }
                for document in snapshot.documents {
                    
                    do {
                        let dictionary = document.data()
                        let opcao = try Opcao(id: document.documentID, idDecisao: idDecisao, dictionary: dictionary)
                        self.listaDeOpcoes.append(opcao)
                    } catch {
                        print("Error when trying to decode Opção: \(error)")
                    }
                }
                self.tableView.reloadData()
            } else {
                return
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listaDeOpcoes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let celula = tableView.dequeueReusableCell(withIdentifier: "celulaResultado", for: indexPath) as? CelulaTableViewCell
        else { return UITableViewCell() }
        let indice = indexPath.row
        //let dadosResultado = self.listaDeResultados[indice]
        let dadosOpcao = self.listaDeOpcoes[indice]
        celula.labelDescricao.text = dadosOpcao.descricao
        // celula.labelPeso.text = dadosResultado.percentual
        
        return celula
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
