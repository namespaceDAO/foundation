// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import { Strings } from '@openzeppelin/contracts/utils/Strings.sol';
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./NounMint.sol";
import "./NounData.sol";
import "./shared.sol";

 /*$$$$$$   /$$$$$$  /$$   /$$ /$$   /$$        /$$$$$$  /$$$$$$$$       /$$   /$$  /$$$$$$  /$$   /$$ /$$   /$$  /$$$$$$ 
| $$__  $$ /$$__  $$| $$$ | $$| $$  /$$/       /$$__  $$| $$_____/      | $$$ | $$ /$$__  $$| $$  | $$| $$$ | $$ /$$__  $$
| $$  \ $$| $$  \ $$| $$$$| $$| $$ /$$/       | $$  \ $$| $$            | $$$$| $$| $$  \ $$| $$  | $$| $$$$| $$| $$  \__/
| $$$$$$$ | $$$$$$$$| $$ $$ $$| $$$$$/        | $$  | $$| $$$$$         | $$ $$ $$| $$  | $$| $$  | $$| $$ $$ $$|  $$$$$$ 
| $$__  $$| $$__  $$| $$  $$$$| $$  $$        | $$  | $$| $$__/         | $$  $$$$| $$  | $$| $$  | $$| $$  $$$$ \____  $$
| $$  \ $$| $$  | $$| $$\  $$$| $$\  $$       | $$  | $$| $$            | $$\  $$$| $$  | $$| $$  | $$| $$\  $$$ /$$  \ $$
| $$$$$$$/| $$  | $$| $$ \  $$| $$ \  $$      |  $$$$$$/| $$            | $$ \  $$|  $$$$$$/|  $$$$$$/| $$ \  $$|  $$$$$$/
|_______/ |__/  |__/|__/  \__/|__/  \__/       \______/ |__/            |__/  \__/ \______/  \______/ |__/  \__/ \_____*/ 
                                                                                                                          
contract NounBank is NounBase, ERC721 {
    IERC20 private _cash;
    NounData private _data;
    NounMint private _bank;
    address private _game;

    function cash() external view returns (IERC20) {
        return _cash;
    }

    function data() external view returns (NounData) {
        return _data;
    }

    function bank() external view returns (NounMint) { 
        return _bank; 
    }

    function game() external view returns (address) { 
        return _game; 
    }

    mapping(uint => uint) private _nounToCoin;
    mapping(uint => uint) private _coinToNoun;
    mapping(uint => uint) private _cashOnNoun;
    mapping(uint => uint) private _cashOnCoin;

    function nounToCoin(uint nounId) external view returns (uint coinId) {
        return _nounToCoin[nounId];
    }

    function coinToNoun(uint coinId) external view returns (uint nounId) {
        return _coinToNoun[coinId];
    }

    function cashOnNoun(uint nounId) external view returns (uint amount) {
        return _cashOnNoun[nounId];
    }
    
    function cashOnCoin(uint nounId) external view returns (uint amount) {
        return _cashOnCoin[nounId];
    }
    
     /*$$$$$$$ /$$$$$$  /$$   /$$ /$$$$$$$$ /$$   /$$
    |__  $$__//$$__  $$| $$  /$$/| $$_____/| $$$ | $$
       | $$  | $$  \ $$| $$ /$$/ | $$      | $$$$| $$
       | $$  | $$  | $$| $$$$$/  | $$$$$   | $$ $$ $$
       | $$  | $$  | $$| $$  $$  | $$__/   | $$  $$$$
       | $$  | $$  | $$| $$\  $$ | $$      | $$\  $$$
       | $$  |  $$$$$$/| $$ \  $$| $$$$$$$$| $$ \  $$
       |__/   \______/ |__/  \__/|________/|__/  \_*/
                                                            
    using Strings for uint;

    uint private _stakeCount;

    mapping(uint => Stake) private _stakes;

    function stakeCount() external view returns (uint) {
        return _stakeCount;
    }

    function getStake(uint stakeId) external view returns (Stake memory) {
        return _requireStake(stakeId);
    }

    function _requireStake(uint stakeId) internal view returns (Stake memory) {
        require(stakeId <= _stakeCount, "Stake not found");
        return _stakes[stakeId];
    }

    function tokenURI(uint stakeId) public view virtual override returns (string memory) {
        return string(_stakeURI(_requireStake(stakeId)));
    }

    function tokenData(uint stakeId) external view returns (string memory) {
        return string(_stakeJSON(_requireStake(stakeId)));
    }
    
    function _stakeURI(Stake memory token) internal view returns (bytes memory) {
        return abi.encodePacked(
            'data:application/json;base64,',
            Base64.encode(_stakeJSON(token))
        );
    }

    function _stakeJSON(Stake memory token) internal view returns (bytes memory) {
        Noun memory noun = _data.getNoun(token.nounId); 
        return abi.encodePacked(
            '{',
                '"id":', token.id.toString(), ',',
                '"name":"FOUND ', noun.name, '",',
                '"description":"', noun.name, ' is FOUND.",',
                '"noun":[', _data.tokenData(token.nounId), '],',
                '"image":"', _data.tokenImage(token.nounId), '"',
            '}'
        );
    }

      /*$$$$$  /$$   /$$  /$$$$$$  /$$$$$$$  /$$$$$$$$
     /$$__  $$| $$  | $$ /$$__  $$| $$__  $$| $$_____/
    | $$  \__/| $$  | $$| $$  \ $$| $$  \ $$| $$      
    |  $$$$$$ | $$$$$$$$| $$$$$$$$| $$$$$$$/| $$$$$   
     \____  $$| $$__  $$| $$__  $$| $$__  $$| $$__/   
     /$$  \ $$| $$  | $$| $$  | $$| $$  \ $$| $$      
    |  $$$$$$/| $$  | $$| $$  | $$| $$  | $$| $$$$$$$$
     \______/ |__/  |__/|__/  |__/|__/  |__/|_______*/
                                                                
    uint private _totalShares;

    mapping(uint => uint) private _shares;
    
    function getShares(uint stakeId) external view returns (uint) {
        return _shares[stakeId];
    }

    function totalShares() external view returns (uint) {
        return _totalShares;
    }

    function calculatePayout(uint stakeId, uint timestamp) external view returns (uint, uint) {
        uint earnings = _calculateEarnings(stakeId);
        uint penalty = _calculatePenalty(_requireStake(stakeId), timestamp);

        return (earnings, penalty);
    }

    function calculateShares(uint day, uint amount) public view returns (uint) {
        uint last = _cashOnCoin[day - 1];
        uint ampl = 10;

        if (last == 0) {
            return amount;
        }

        if (last > amount * ampl) {
            return amount / ampl;
        }

        if (last < amount / ampl) {
            return amount * ampl;
        }

        return amount * amount / last;
    }

    function _calculateEarnings(uint stakeId) internal view returns (uint) {
        uint balance = _cash.balanceOf(address(this));
        uint earnings = balance * _shares[stakeId] / _totalShares;
        return earnings;
    }

    function _calculatePenalty(Stake memory token, uint timestamp) internal pure returns (uint) {
        if (timestamp > token.expiresAt + 2 weeks) {
            uint late = (timestamp - token.expiresAt - 2 weeks) / 1 days;
            return late * token.amount / 14;
        }

        return 0;
    }
                                                                                                                              
     /*$    /$$  /$$$$$$  /$$$$$$$$ /$$$$$$$$                                                                                 
    | $$   | $$ /$$__  $$|__  $$__/| $$_____/                                                                                 
    | $$   | $$| $$  \ $$   | $$   | $$                                                                                       
    |  $$ / $$/| $$  | $$   | $$   | $$$$$                                                                                    
     \  $$ $$/ | $$  | $$   | $$   | $$__/                                                                                    
      \  $$$/  | $$  | $$   | $$   | $$                                                                                       
       \  $/   |  $$$$$$/   | $$   | $$$$$$$$                                                                                 
        \_/     \______/    |__/   |_______*/                                                                                 
                                                                                                                          
    event Voted(
        address payer,
        address minter,
        uint coinId,
        uint nounId,
        uint found,
        uint coins
    );
    
    function vote(
        address payer, 
        address minter, 
        uint nounId, 
        uint found
    ) external {
        uint minted = found * _bank.difficulty();
        uint coinId = _collectVote(nounId, minted);

        _cash.transferFrom(payer, address(this), found);
        _bank.mintCoin(minter, coinId, minted);

        emit Voted(
            payer,
            minter, 
            coinId,
            nounId, 
            found,
            minted
        );
    }

    function _collectVote(uint nounId, uint amount) internal returns (uint) {
        uint coinId = _requireFreshNoun(nounId);
        uint minimum = _cashOnCoin[coinId] * 101 / 100;
        
        _cashOnNoun[nounId] += amount;
        
        if (_cashOnNoun[nounId] > minimum || minimum == 0) {
            _coinToNoun[coinId] = nounId;
            _nounToCoin[nounId] = coinId;
            _cashOnCoin[coinId] = _cashOnNoun[nounId];
        }

        return coinId;
    }

    function _requireFreshNoun(uint nounId) internal view returns (uint) {
        require(nounId <= _data.nounCount(), "Noun not found");
        
        uint coinId = _data.currentDay();
        uint existing = _nounToCoin[nounId];
        
        require(
            existing == 0 || existing == coinId, 
            "Noun has been minted"
        );
        
        return coinId;
    }                              

     /*$      /$$ /$$$$$$ /$$   /$$ /$$$$$$$$                                                                                 
    | $$$    /$$$|_  $$_/| $$$ | $$|__  $$__/                                                                                 
    | $$$$  /$$$$  | $$  | $$$$| $$   | $$                                                                                    
    | $$ $$/$$ $$  | $$  | $$ $$ $$   | $$                                                                                    
    | $$  $$$| $$  | $$  | $$  $$$$   | $$                                                                                    
    | $$\  $ | $$  | $$  | $$\  $$$   | $$                                                                                    
    | $$ \/  | $$ /$$$$$$| $$ \  $$   | $$                                                                                    
    |__/     |__/|______/|__/  \__/   |_*/                                                                                    
                                                                                
    event Minted(
        address payer,
        address minter,
        uint coinId,
        uint nounId,
        uint found,
        uint coins
    );

    function mint(
        address payer, 
        address minter, 
        uint coinId, 
        uint found
    ) external {
        uint nounId = _collectMint(coinId, found);
        uint minted = _bank.convertCoin(coinId, found);

        _cash.transferFrom(payer, address(this), found);
        _bank.mintCoin(minter, coinId, minted);

        emit Minted(
            payer, 
            minter, 
            coinId, 
            nounId,
            found, 
            minted
        );
    }

    function _collectMint(uint coinId, uint amount) internal returns (uint) {
        uint nounId = _requireFoundNoun(coinId);
        
        require(amount > 0, "Must mint some Nouns");
        _cashOnNoun[nounId] += amount;

        return _coinToNoun[coinId];
    }

    function _requireFoundNoun(uint coinId) internal view returns (uint nounId) {
        require(
            coinId > 0 && coinId <= _data.currentDay(), 
            "Coin has not been minted"
        );

        return _coinToNoun[coinId];
    }                                       

      /*$$$$$  /$$$$$$$$ /$$$$$$  /$$   /$$ /$$$$$$$$                                                                         
     /$$__  $$|__  $$__//$$__  $$| $$  /$$/| $$_____/                                                                         
    | $$  \__/   | $$  | $$  \ $$| $$ /$$/ | $$                                                                               
    |  $$$$$$    | $$  | $$$$$$$$| $$$$$/  | $$$$$                                                                            
     \____  $$   | $$  | $$__  $$| $$  $$  | $$__/                                                                            
     /$$  \ $$   | $$  | $$  | $$| $$\  $$ | $$                                                                               
    |  $$$$$$/   | $$  | $$  | $$| $$ \  $$| $$$$$$$$                                                                         
     \______/    |__/  |__/  |__/|__/  \__/|_______*/                                                                                     

    event Staked(
        uint id,
        uint idea,
        uint amount,
        uint expiresAt,
        uint startedAt
    );

    struct StakeParams {
        address to;
        uint nounId;
        uint amount;
        uint expiresAt;
    }

    function stake(StakeParams memory params) external {
        require(params.amount > 0, "Stake more than 0");
        require(
            params.expiresAt >= block.timestamp + 1 days, 
            "Stake at least 1 day in the future"
        );

        Stake storage token = _stakes[++_stakeCount];
        token.id = _stakeCount;
        token.nounId = params.nounId;
        token.amount = params.amount;
        token.expiresAt = params.expiresAt;
        token.startedAt = block.timestamp;

        uint day = _data.currentDay();
        uint shares = calculateShares(day, params.amount);
    
        _shares[token.id] = shares;
        _totalShares += shares;

        _mint(params.to, token.id);

        emit Staked(
            token.id, 
            token.nounId,
            token.amount,
            token.expiresAt,
            token.startedAt
        );
    }
                                                                                                                     
     /*$$$$$$  /$$   /$$ /$$$$$$$  /$$   /$$                                                                                  
    | $$__  $$| $$  | $$| $$__  $$| $$$ | $$                                                                                  
    | $$  \ $$| $$  | $$| $$  \ $$| $$$$| $$                                                                                  
    | $$$$$$$ | $$  | $$| $$$$$$$/| $$ $$ $$                                                                                  
    | $$__  $$| $$  | $$| $$__  $$| $$  $$$$                                                                                  
    | $$  \ $$| $$  | $$| $$  \ $$| $$\  $$$                                                                                  
    | $$$$$$$/|  $$$$$$/| $$  | $$| $$ \  $$                                                                                  
    |_______/  \______/ |__/  |__/|__/  \_*/         
                                               
    event Burned(
        uint id,
        uint idea,
        uint amount,
        uint endedAt
    );

    function burn(address payee, uint stakeId) external {
        Stake memory s = _requireStake(stakeId);
        uint payout = _burnStake(s);

        _cash.transferFrom(address(this), payee, payout);
        emit Burned(s.id, s.nounId, s.amount, s.endedAt);
    }

    function _burnStake(Stake memory token) internal returns (uint payout) {
        address owner = ownerOf(token.id);
        require(owner == msg.sender, "You are not the owner");

        require(token.endedAt == 0, "Stake already ended");
        token.endedAt = block.timestamp;

        _burn(token.id);

        uint earnings = _calculateEarnings(token.id);
        uint penalty = _calculatePenalty(token, block.timestamp);

        return earnings - penalty;
    }                
                                                                                                                          
      /*$$$$$  /$$        /$$$$$$  /$$$$$$ /$$      /$$                                                                       
     /$$__  $$| $$       /$$__  $$|_  $$_/| $$$    /$$$                                                                       
    | $$  \__/| $$      | $$  \ $$  | $$  | $$$$  /$$$$                                                                       
    | $$      | $$      | $$$$$$$$  | $$  | $$ $$/$$ $$                                                                       
    | $$      | $$      | $$__  $$  | $$  | $$  $$$| $$                                                                       
    | $$    $$| $$      | $$  | $$  | $$  | $$\  $ | $$                                                                       
    |  $$$$$$/| $$$$$$$$| $$  | $$ /$$$$$$| $$ \/  | $$                                                                       
     \______/ |________/|__/  |__/|______/|__/     |_*/                                                                       
                                                           
    event Claimed(
        address creator,
        address minter,
        uint coinId,
        uint nounId,
        uint coins
    );

    mapping(uint => uint) private _claims;

    function getClaims(uint coinId) external view returns (uint) {
        return _claims[coinId];
    }

    function claim(
        address minter, 
        uint coinId, 
        uint amount
    ) external {
        uint nounId = _requireFoundNoun(coinId);
        address owner = _verifyClaim(nounId, coinId, amount);

        _claims[coinId] += amount;
        _bank.mintCoin(minter, coinId, amount);
        
        emit Claimed(
            owner,
            minter,
            coinId, 
            nounId,
            amount
        );
    }

    function _verifyClaim(
        uint nounId, 
        uint coinId, 
        uint amount
    ) internal view returns (address) {
        address owner = _data.ownerOf(nounId);

        require(
            msg.sender == owner, 
            "Caller is not the Noun owner"
        );

        uint claimed = _claims[coinId];
        uint minted = _bank.totalSupplyOf(coinId) - claimed;

        bool claimable = minted / 10 >= amount + claimed;
        require(claimable, "Claim too large");

        return owner;
    }

        /*$       /$$       /$$   
      /$$$$$$   /$$$$$$   /$$$$$$ 
     /$$__  $$ /$$__  $$ /$$__  $$
    | $$  \__/| $$  \__/| $$  \__/
    |  $$$$$$ |  $$$$$$ |  $$$$$$ 
     \____  $$ \____  $$ \____  $$
     /$$  \ $$ /$$  \ $$ /$$  \ $$
    |  $$$$$$/|  $$$$$$/|  $$$$$$/
     \_  $$_/  \_  $$_/  \_  $$_/ 
       \__/      \__/      \_*/   

    function fund() external {
        // TODO: fund the game if it exists
    }

    constructor(IERC20 cash_, NounData data_) 
    ERC721("FOUND NOUN", "FOUND NOUN") {
        _data = data_;
        _cash = cash_;

        NounBase _base = NounBase(address(this));
        _bank = new NounMint(data_, _base);
        _cash.approve(address(this), type(uint).max);
    }  
}
