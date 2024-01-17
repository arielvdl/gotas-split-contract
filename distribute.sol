CONTRATO VALENDO! O SPLIT DO GOTAS INDIVIDUAL

// SPDX-License-Identifier: MIT
// by gotas.social 
pragma solidity ^0.8.17;

contract RecebimentoDistribuicao {
    address payable private immutable wallet1;
    address payable private immutable wallet2;
    address private owner;
    
    uint256 private wallet1Percent;
    uint256 private wallet2Percent;
    
    bool private locked;  // Reentrancy Guard
    
    event PercentagesChanged(uint256 newWallet1Percent, uint256 newWallet2Percent);
    event FundsDistributed(uint256 wallet1Amount, uint256 wallet2Amount);

    constructor(address payable _wallet1, address payable _wallet2) {
        wallet1 = _wallet1; 
        wallet2 = _wallet2;
        owner = msg.sender;
        wallet1Percent = 80;
        wallet2Percent = 20;
    }

    modifier noReentrancy() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Somente o dono pode chamar isso.");
        _;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function getPercentages() public view returns (uint256, uint256) {
        return (wallet1Percent, wallet2Percent);
    }

    function getWallet1Address() public view returns (address) {
        return wallet1;
    }

    function getWallet2Address() public view returns (address) {
        return wallet2;
    }

    function changePercentages(uint256 _newWallet1Percent, uint256 _newWallet2Percent) external onlyOwner {
        require(_newWallet1Percent + _newWallet2Percent == 100, "A soma das porcentagens deve ser 100");
        wallet1Percent = _newWallet1Percent;
        wallet2Percent = _newWallet2Percent;
        emit PercentagesChanged(_newWallet1Percent, _newWallet2Percent);
    }

    receive() external payable noReentrancy {
        require(msg.value > 0, "Valor deve ser maior que 0");
        uint256 amount = msg.value;
        uint256 wallet1Amount = (amount * wallet1Percent) / 100;    
        uint256 wallet2Amount = (amount * wallet2Percent) / 100;

        (bool success,) = wallet1.call{value: wallet1Amount}("");
        require(success, "Transferencia para wallet1 falhou");

        (success,) = wallet2.call{value: wallet2Amount}("");
        require(success, "Transferencia para wallet2 falhou"); 

        emit FundsDistributed(wallet1Amount, wallet2Amount);
    }
}
