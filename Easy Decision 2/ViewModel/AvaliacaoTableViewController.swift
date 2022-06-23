//
//  AvaliacaoTableViewController.swift
//  Easy Decision 2
//
//  Created by Angélica Andrade de Meira on 28/03/22.
//

import UIKit
import FirebaseFirestore

class AvaliacaoTableViewController: UITableViewController, AvaliacaoTableViewControllerDelegate {
    
    var decisao: Decisao?
    var firestore: Firestore!
    var opcoesListener: ListenerRegistration?
    var listaDeOpcoes: [Opcao] = []
    var listaDeCriterios: [Criterio] = []
    var avaliacaoListener: ListenerRegistration?
    var avaliacoesExistentes: [Avaliacao]? = []
    var avaliacaoSelecionada: Avaliacao?
    var alertaRecuperarAvaliacoes = UIAlertController(title: "Atenção!", message: "Um erro ocorreu ao recuperar a lista de avaliações", preferredStyle: .alert)
    var alertaRecuperarOpcoes = UIAlertController(title: "Atenção!", message: "Um erro ocorreu ao recuperar a lista de opções", preferredStyle: .alert)
    
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
        addListenerRecuperarOpcoes()
        addListenerRecuperarAvaliacao()
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
        
        avaliacaoListener = firestore.collection("avaliacoes").whereField("idDecisao", isEqualTo: idDecisao).addSnapshotListener { [weak self] querySnapshot, erro in
            guard let self = self
            else { return }
            
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
                } catch let erro {
                    self.alertaRecuperarAvaliacoes.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "tente novamente"), style: .default, handler: nil))
                    print("Error when trying to decode Avaliação:" + erro.localizedDescription)
                }
            }
            
           // print(self.avaliacoesExistentes)
            if self.avaliacoesExistentes?.count == 0 {
                self.criaNovaAvaliacao()
            } else {
                self.tableView.reloadData()
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
        
        opcoesListener = firestore.collection("opcoes").whereField("idDecisao", isEqualTo: idDecisao).addSnapshotListener { [weak self] querySnapshot, erro in
            
            guard let self = self
            else { return }
            
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
    
    func criaNovaAvaliacao() {
        guard
            let decisao = self.decisao,
            let idDecisao = self.decisao?.id,
            !listaDeOpcoes.isEmpty
        else { return }
        
        for dadosOpcao in listaDeOpcoes {
            guard let idOpcao = dadosOpcao.id
            else { return }
            for dadosCriterio in listaDeCriterios {
                guard let idCriterio = dadosCriterio.id
                else { return }
                
                firestore.collection("avaliacoes").document().setData([
                    "idCriterio" : dadosCriterio.id as Any,
                    "idDecisao" : decisao.id as Any,
                    "idOpcao" : dadosOpcao.id as Any,
                    "valor" : "1" as Any
                ])
                
                do {
                    let novaAvaliacao = try Avaliacao(idDecisao: idDecisao, idCriterio: idCriterio, idOpcao: idOpcao, valor: "1")
                    self.avaliacoesExistentes?.append(novaAvaliacao)
                } catch {
                    print("Error when trying to decode Resultado: \(error)")
                }
            }
        }
        self.tableView.reloadData()
    }
    
    func atualizaDadosAvaliacao(celula: UITableViewCell, valor: String) {
        guard
            let indexPath = self.tableView.indexPath(for: celula),
            let dadosAvaliacao = self.avaliacoesExistentes?[indexPath.row],
            let idAvaliacao = dadosAvaliacao.id
        else { return }
        
        self.firestore.collection("avaliacoes").document(idAvaliacao).setData([
            "idCriterio" : dadosAvaliacao.idCriterio as Any,
            "idDecisao" : dadosAvaliacao.idDecisao as Any,
            "idOpcao" : dadosAvaliacao.idOpcao as Any,
            "valor" : valor as Any
        ])
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
            !self.listaDeCriterios.isEmpty,
            !self.listaDeOpcoes.isEmpty
        else { return UITableViewCell() }
        
        celula.delegate = self
    
        let dadosCriterio = self.listaDeCriterios[indexPath.row]
        let dadosAvaliacao = self.avaliacoesExistentes?[indexPath.row]
        
        celula.labelDescricao.text = dadosCriterio.descricao
        celula.labelNota.text = dadosAvaliacao?.valor
        
        return celula
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

protocol AvaliacaoTableViewControllerDelegate: AnyObject {
    func atualizaDadosAvaliacao(celula: UITableViewCell, valor: String)
}
