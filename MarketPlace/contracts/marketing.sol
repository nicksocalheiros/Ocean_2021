pragma solidity >=0.4.22;
pragma experimental ABIEncoderV2;

//SPDX-License-Identifier: UNLICENSED;
//import "./strings.sol";

contract RBCContract {
    
    //uint produtoCont = 0;// ID associado a cada produto
    enum Status {Criado, Negociacao, Adquirido}
    uint productcode =0;
    uint public mostSent;
    uint transacaoId = 0 ;
    
    constructor () payable public {
        mostSent = msg.value;
    }
    
    struct Produto 
    {
        string nome;
        string tipo;
        uint preco;
        address dono;
        address fazendeiro;
        string plantacaoLoc;
        string plantacaoMet;
        string plantacaoData;
        string colheitaData;
        Status status;
    }

    struct Transacao {
        uint id;
        uint productId;
        address buyer;
        bool delivered;
    }
    
     /* EVENTOS 
     //Evento cadastro de produto
    event produtoInfo
    (
        string nome,
        string tipo,
        uint preco,
        string plantacaoData,
        string colheitaData
    );*/
    
    event alerta();

    Produto[] baseDeProdutos;
    Transacao[] transacoes;
    
    function inserirProduto(string memory  _nome, string memory _tipo, uint _preco, string memory _plantacaoLoc, string memory _plantacaoMet, string memory _plantacaoData, string memory _colheitaData) public
    {
        
        Produto memory produto;
        produto.nome = _nome;
        produto.tipo = _tipo;
        produto.preco = _preco;
        produto.dono = msg.sender;
        produto.fazendeiro = msg.sender;
        produto.plantacaoLoc = _plantacaoLoc;
        produto.plantacaoMet = _plantacaoMet;
        produto.plantacaoData = _plantacaoData;
        produto.colheitaData = _colheitaData;
        produto.status = Status.Criado;
        
        baseDeProdutos.push(produto);
        
        //emit produtoInfo(_nome, _tipo, _preco, _plantacaoData, _colheitaData); //momento que emitimos o evento
        emit alerta();

    }
    
    /*function getCliente(string memory cliente) public
    {
      address payable cliente
    }*/
    
    //atualiza estado
    function atualizarStatus(uint256 _id, uint _status) public {
        Produto storage produto = baseDeProdutos[_id];
        if(_status == 1){
            produto.status = Status.Negociacao;
        }if(_status == 2){
            produto.status = Status.Adquirido;
        }
     
    }
    
    function getProduct(uint productId) public view returns(Produto memory produto) {
         return baseDeProdutos[productId];
        
    }
    
    function getQtdCasos() public view returns (uint length)
    {
      return baseDeProdutos.length;
    }
    
    function getCasos() public view returns(Produto[] memory) {
        return baseDeProdutos;
    }
    
    function enviarTransacao(uint productId) public payable {
        Produto memory produto = getProduct(productId);
        atualizarStatus(productId, 1);
        require(produto.preco == msg.value);    
        mostSent += msg.value;
        historicoTransacao(productId, msg.sender, false);
        emit alerta();
    }
    
    function delivery(uint transacaoId) public {
        Transacao memory transacao = transacoes[uint(transacaoId)];
        Produto memory produto = baseDeProdutos[uint(transacao.productId)];
        require(msg.sender == produto.dono);
        atualizarStatus(transacao.productId, 2);
        setOrderDelivered(true, uint(transacaoId));
        setProductOwner(transacao.buyer, uint(transacao.productId));
        mostSent = mostSent - produto.preco;
        payable(produto.dono).transfer(produto.preco);
    }
    
    function setProductOwner(address newOwner, uint index) private {
        baseDeProdutos[index].dono = newOwner;
    }
    
    function historicoTransacao(uint productId, address buyer, bool delivered) public {
        Transacao memory transacao = Transacao(
            transacaoId,
            productId,
            buyer,
            delivered
        );
        transacoes.push(transacao);
        transacaoId++;
    }
    
    function setOrderDelivered(bool delivered, uint index) private {
        transacoes[index].delivered = delivered;
    }
    
    function getOrders() public view returns(Transacao[] memory){
        return transacoes;
    }
    
    function getOrder(uint transacaoId) public view returns(Transacao memory transacao) {
        for (uint index = 0; index < transacoes.length; index++){
            if (transacoes[index].id == transacaoId) {
                return transacoes[index];
            }
        }
    }
    
}     
