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
    var opcoesListener: ListenerRegistration?
    var listaDeOpcoes: [Opcao] = []
    var listaDeCriterios: [Criterio] = []
    var avaliacaoListener: ListenerRegistration?
    var avaliacoesExistentes: [Avaliacao]? = []
    var avaliacaoSelecionada: Avaliacao?
    var alertaRecuperarAvaliacoes = UIAlertController(title: "Atenção!", message: "Um erro ocorreu ao recuperar a lista de Avaliações", preferredStyle: .alert)
    var alertaRecuperarOpcoes = UIAlertController(title: "Atenção!", message: "Um erro ocorreu ao recuperar a lista de Opções", preferredStyle: .alert)
    var alertaRecuperarCriterios = UIAlertController(title: "Atenção!", message: "Um erro ocorreu ao recuperar a lista de Critérios", preferredStyle: .alert)
    
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
        viewDestino.listaDeOpcoes = self.listaDeOpcoes
        viewDestino.listaDeCriterios = self.listaDeCriterios
        viewDestino.listaDeAvaliacoes = self.avaliacoesExistentes
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
        self.tableView.register(CelulaAvaliacaoTableViewCell.self, forCellReuseIdentifier: "celulaAvaliacao")
        addListenerRecuperarAvaliacao()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addListenerRecuperarOpcoes()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        opcoesListener?.remove()
        avaliacaoListener?.remove()
    }
    
    func addListenerRecuperarAvaliacao() {
        guard
            self.decisao != nil,
            let idDecisao = self.decisao?.id
        else { return }
        
        avaliacaoListener = firestore.collection("avaliacoes").whereField("idDecisao", isEqualTo: idDecisao).addSnapshotListener { [self] querySnapshot, erro in
            
            if erro != nil {
                self.alertaRecuperarAvaliacoes.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "tente novamente"), style: .default, handler: nil))
                return
            }
            
            self.avaliacoesExistentes?.removeAll()
            
            guard let snapshot = querySnapshot
            else { return }
            
            for document in snapshot.documents {
                
                do {
                    let dictionary = document.data()
                    let avaliacao = try Avaliacao(id: document.documentID, idDecisao: idDecisao, dictionary: dictionary)
                    self.avaliacoesExistentes?.append(avaliacao)
                } catch {
                    print("Error when trying to decode Avaliação: \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
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
                } catch {
                    print("Error when trying to decode Opção: \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
    }
    
    func ordenaListaDeOpcoesPorOrdemAlfabetica() {
        listaDeOpcoes.sort(by: { opcaoEsquerda, opcaoDireita in
            return opcaoEsquerda.descricao < opcaoDireita.descricao
        })
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
        guard
            let celula = tableView.dequeueReusableCell(withIdentifier: "celulaAvaliacao", for: indexPath) as? CelulaAvaliacaoTableViewCell,
            let decisao = self.decisao
        else { return UITableViewCell() }
        let dadosCriterio = self.listaDeCriterios[indexPath.row]
        let dadosOpcao = self.listaDeOpcoes[indexPath.section]
        
        celula.labelDescricao.text = dadosCriterio.descricao
        celula.accessoryType = .disclosureIndicator
        
        guard let booleano = avaliacoesExistentes?.contains(where: { avaliacao in
            return avaliacao.idCriterio == dadosCriterio.id && avaliacao.idOpcao == dadosOpcao.id
        }) else { return celula }
        
        //Mostra avaliações existentes
        if (booleano) {
            guard
                let dadosAvaliacao = self.avaliacoesExistentes?[indexPath.row],
                let idAvaliacao = dadosAvaliacao.id
            else { return celula }
            
            celula.labelNota.text = dadosAvaliacao.valor
            celula.atualizaDadosAvaliacao = { [unowned self] in
                
                firestore.collection("avaliacoes").document(idAvaliacao).setData([
                    "idDecisao" : decisao.id as Any,
                    "idCriterio" : dadosCriterio.id as Any,
                    "idOpcao" : dadosOpcao.id as Any,
                    "valor" : celula.labelNota.text as Any
                ])
            }
            
        //Salva novas avaliações
        } else {
            firestore.collection("avaliacoes").document().setData([
                "idDecisao" : decisao.id as Any,
                "idCriterio" : dadosCriterio.id as Any,
                "idOpcao" : dadosOpcao.id as Any,
                "valor" : celula.labelNota.text as Any
            ])
        }
        
        return celula
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.avaliacaoSelecionada = self.avaliacoesExistentes?[indexPath.row]
        let viewDestino = EditaAvalicacaoViewController()
        viewDestino.avaliacao = self.avaliacaoSelecionada
        viewDestino.decisao = self.decisao
        self.present(UINavigationController(rootViewController: viewDestino), animated: true)
    }
}
