//
//  AvaliacaoTableViewController.swift
//  Easy Decision 2
//
//  Created by Angélica Andrade de Meira on 28/03/22.
//

import UIKit
import FirebaseFirestore

class AvaliacaoTableViewController: UITableViewController {
    
    var decisao: Decisao?
    var firestore: Firestore!
    var criteriosListener: ListenerRegistration!
    var criterioSelecionado: Criterio?
    var opcoesListener: ListenerRegistration!
    var opcaoSelecionada: Opcao?
    var listaDeOpcoes: [Opcao] = []
    var listaDeCriterios: [Criterio] = []
    var listaDeAvaliacoes: [Avaliacao]? = []
    var avaliacaoSelecionada: Avaliacao?
    var avaliacaoListener: ListenerRegistration!
    
    // MARK: - View code
    
    private lazy var botaoContinuar: UIBarButtonItem = {
        let view = UIBarButtonItem()
        view.title = "Continuar"
        view.target = self
        view.action = #selector(vaiParaTelaDeResultados)
        return view
    }()
    
    @objc func vaiParaTelaDeResultados() {
        let viewDestino = ResultadoTableViewController()
        viewDestino.decisao = self.decisao
        //  viewDestino.avaliacao =
        self.navigationController?.pushViewController(viewDestino, animated: true)
    }
    
    override func loadView() {
        super.loadView()
        self.navigationItem.title = "Avaliação"
        self.navigationItem.rightBarButtonItems = [botaoContinuar]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firestore = Firestore.firestore()
        self.tableView.register(CelulaTableViewCell.self, forCellReuseIdentifier: "celulaAvaliacao")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.criterioSelecionado = nil
        addListenerRecuperarCriterios()
        addListenerRecuperarOpcoes()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addListenerRecuperarAvaliacao()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        criteriosListener.remove()
        opcoesListener.remove()
        avaliacaoListener.remove()
    }
    
    func addListenerRecuperarAvaliacao() {
        guard self.decisao != nil
        else { return }
        guard let idDecisao = self.decisao?.id
        else { return }
        for itemCriterio in self.listaDeCriterios {
            guard let idCriterio = itemCriterio.id
            else { return }
            for itemOpcao in self.listaDeOpcoes {
                guard let idOpcao = itemOpcao.id
                else { return }
                avaliacaoListener = firestore.collection("avaliacoes").whereField("idDecisao", isEqualTo: idDecisao).whereField("idCriterio", isEqualTo: idCriterio).whereField("idOpcao", isEqualTo: idOpcao).addSnapshotListener { [self] querySnapshot, erro in
                    
                    if erro == nil {
                        //self.listaDeAvaliacoes?.removeAll()
                        guard let snapshot = querySnapshot
                        else { return }
                        for document in snapshot.documents {
                            
                            do {
                                let dictionary = document.data()
                                let avaliacao = try Avaliacao(id: document.documentID, idDecisao: idDecisao, idCriterio: idCriterio,idOpcao: idOpcao, dictionary: dictionary)
                                self.listaDeAvaliacoes?.append(avaliacao)
                            } catch {
                                print("Error when trying to decode Avaliação: \(error)")
                            }
                        }
                        self.tableView.reloadData()
                    } else {
                        return
                    }
                }
            }
        }
    }
    
    func addListenerRecuperarCriterios() {
        guard self.decisao != nil
        else { return }
        guard let idDecisao = self.decisao?.id
        else { return }
        criteriosListener = firestore.collection("criterios").whereField("idDecisao", isEqualTo: idDecisao).addSnapshotListener { [self] querySnapshot, erro in
            if erro == nil {
                self.listaDeCriterios.removeAll()
                guard let snapshot = querySnapshot
                else { return }
                for document in snapshot.documents {
                    do {
                        let dictionary = document.data()
                        let criterio = try Criterio(id: document.documentID, idDecisao: idDecisao, dictionary: dictionary)
                        self.listaDeCriterios.append(criterio)
                    } catch {
                        print("Error when trying to decode Critério: \(error)")
                    }
                }
                self.tableView.reloadData()
            } else {
                return
            }
        }
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
    
    func criaAvalicao() {
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.listaDeOpcoes.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listaDeCriterios.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let indice = section
        let dadosDaSecao = self.listaDeOpcoes[indice]
        return dadosDaSecao.descricao
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let celula = tableView.dequeueReusableCell(withIdentifier: "celulaAvaliacao", for: indexPath) as? CelulaTableViewCell
        else { return UITableViewCell() }
        let dadosCriterio = self.listaDeCriterios[indexPath.row]
        let dadosOpcao = self.listaDeOpcoes[indexPath.section]
        guard let idDecisao = self.decisao?.id
        else { return celula }
        celula.labelDescricao.text = dadosCriterio.descricao
        guard let dadosAvaliacao = self.listaDeAvaliacoes
        else { return celula }
        
        if dadosAvaliacao.count == 0 {
            celula.labelPeso.text = "1"
            return celula
            
        } else {
            
            for itemAvaliacao in dadosAvaliacao {
                
                if itemAvaliacao.idCriterio == dadosCriterio.id && itemAvaliacao.idOpcao == dadosOpcao.id && itemAvaliacao.idDecisao == idDecisao {
                    celula.labelPeso.text = itemAvaliacao.valor
                    return celula
                } else {
                    celula.labelPeso.text = "1"
                    return celula
                }
            }
        }
        return celula
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let viewDestino = EditaAvaliacaoViewController()
        self.criterioSelecionado = self.listaDeCriterios[indexPath.row]
        self.opcaoSelecionada = self.listaDeOpcoes[indexPath.section]
        
        if listaDeAvaliacoes?[indexPath.row] != nil {
            self.avaliacaoSelecionada = self.listaDeAvaliacoes?[indexPath.row]
        }
        
        viewDestino.opcao = self.opcaoSelecionada
        viewDestino.criterio = self.criterioSelecionado
        viewDestino.decisao = self.decisao
        viewDestino.avaliacao = self.avaliacaoSelecionada
        self.present(UINavigationController(rootViewController: viewDestino), animated: true)
    }
}
