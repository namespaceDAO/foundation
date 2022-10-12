// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import { Strings } from '@openzeppelin/contracts/utils/Strings.sol';
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./NounMint.sol";
import "./NounData.sol";

 /*$$$$$$   /$$$$$$  /$$   /$$ /$$   /$$        /$$$$$$  /$$$$$$$$       /$$   /$$  /$$$$$$  /$$   /$$ /$$   /$$  /$$$$$$ 
| $$__  $$ /$$__  $$| $$$ | $$| $$  /$$/       /$$__  $$| $$_____/      | $$$ | $$ /$$__  $$| $$  | $$| $$$ | $$ /$$__  $$
| $$  \ $$| $$  \ $$| $$$$| $$| $$ /$$/       | $$  \ $$| $$            | $$$$| $$| $$  \ $$| $$  | $$| $$$$| $$| $$  \__/
| $$$$$$$ | $$$$$$$$| $$ $$ $$| $$$$$/        | $$  | $$| $$$$$         | $$ $$ $$| $$  | $$| $$  | $$| $$ $$ $$|  $$$$$$ 
| $$__  $$| $$__  $$| $$  $$$$| $$  $$        | $$  | $$| $$__/         | $$  $$$$| $$  | $$| $$  | $$| $$  $$$$ \____  $$
| $$  \ $$| $$  | $$| $$\  $$$| $$\  $$       | $$  | $$| $$            | $$\  $$$| $$  | $$| $$  | $$| $$\  $$$ /$$  \ $$
| $$$$$$$/| $$  | $$| $$ \  $$| $$ \  $$      |  $$$$$$/| $$            | $$ \  $$|  $$$$$$/|  $$$$$$/| $$ \  $$|  $$$$$$/
|_______/ |__/  |__/|__/  \__/|__/  \__/       \______/ |__/            |__/  \__/ \______/  \______/ |__/  \__/ \_____*/ 

struct Stake {
    uint id;
    uint tax;
    uint noun;
    uint found;
    uint expiresAt;
    uint startedAt;
    uint burnedAt;
    address govt;
}

contract NounBank is NounBase, ERC721 {
    using Strings for uint;

    IERC20 private _cash;
    NounData private _data;
    NounMint private _bank;
    NounGovt private _govt;

    uint private _start;
    uint private _stakeCount;
    uint private _totalShares;

    mapping(uint => uint) private _nounToCoin;
    mapping(uint => uint) private _coinToNoun;
    mapping(uint => uint) private _cashOnNoun;
    mapping(uint => uint) private _cashOnCoin;

    mapping(uint => uint) private _shares;
    mapping(uint => Stake) private _stakes;

    function cash() external view returns (IERC20) {
        return _cash;
    }

    function data() external view returns (NounData) {
        return _data;
    }

    function bank() external view returns (NounMint) { 
        return _bank; 
    }

    function govt() external view returns (NounGovt) {
        return _govt;
    }

    function stakeCount() external view returns (uint) {
        return _stakeCount;
    }

    function totalShares() external view returns (uint) {
        return _totalShares;
    }

    function currentDay() external view returns (uint) {
        return _currentDay();
    }

    function _currentDay() internal view returns (uint) {
        return (block.timestamp - _start) / 1 days + 1;
    }

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
    
    constructor(IERC20 cash_, NounData data_) 
    ERC721("FOUND NOUN", "FOUND NOUN") {
        _data = data_;
        _cash = cash_;

        uint time = block.timestamp;
        uint mountainous = 7 hours;
        _start = time - mountainous;
        NounBase _base = NounBase(address(this));

        _bank = new NounMint(data_, _base);
        _govt = new NounGovt();
        _cash.approve(address(this), type(uint).max);
    }   

      /*$$$$$  /$$$$$$$  /$$$$$$$$  /$$$$$$  /$$$$$$$$ /$$$$$$$$  /$$$$$$                      
     /$$__  $$| $$__  $$| $$_____/ /$$__  $$|__  $$__/| $$_____/ /$$__  $$                     
    | $$  \__/| $$  \ $$| $$      | $$  \ $$   | $$   | $$      | $$  \__/                     
    | $$      | $$$$$$$/| $$$$$   | $$$$$$$$   | $$   | $$$$$   |  $$$$$$                      
    | $$      | $$__  $$| $$__/   | $$__  $$   | $$   | $$__/    \____  $$                     
    | $$    $$| $$  \ $$| $$      | $$  | $$   | $$   | $$       /$$  \ $$                     
    |  $$$$$$/| $$  | $$| $$$$$$$$| $$  | $$   | $$   | $$$$$$$$|  $$$$$$/                     
     \______/ |__/  |__/|________/|__/  |__/   |__/   |________/ \_____*/

    function getShares(uint stakeId) external view returns (uint) {
        return _shares[stakeId];
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
        Noun memory noun = _data.getNoun(token.noun); 
        return abi.encodePacked(
            '{',
                '"id":', token.id.toString(), ',',
                '"name":"FOUND ', noun.name, '",',
                '"description":"', noun.name, ' is FOUND.",',
                '"noun":[', _data.tokenData(token.noun), '],',
                '"image":"', _data.tokenImage(token.noun), '"',
            '}'
        );
    }        
                                                                                   
     /*$      /$$ /$$$$$$ /$$   /$$ /$$$$$$$$ /$$$$$$  /$$$$$$$  /$$       /$$$$$$$$           
    | $$$    /$$$|_  $$_/| $$$ | $$|__  $$__//$$__  $$| $$__  $$| $$      | $$_____/           
    | $$$$  /$$$$  | $$  | $$$$| $$   | $$  | $$  \ $$| $$  \ $$| $$      | $$                 
    | $$ $$/$$ $$  | $$  | $$ $$ $$   | $$  | $$$$$$$$| $$$$$$$ | $$      | $$$$$              
    | $$  $$$| $$  | $$  | $$  $$$$   | $$  | $$__  $$| $$__  $$| $$      | $$__/              
    | $$\  $ | $$  | $$  | $$\  $$$   | $$  | $$  | $$| $$  \ $$| $$      | $$                 
    | $$ \/  | $$ /$$$$$$| $$ \  $$   | $$  | $$  | $$| $$$$$$$/| $$$$$$$$| $$$$$$$$           
    |__/     |__/|______/|__/  \__/   |__/  |__/  |__/|_______/ |________/|_______*/                                                             
                                                                                                                          
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
        
        uint coinId = _currentDay();
        uint existing = _nounToCoin[nounId];
        
        require(
            existing == 0 || existing == coinId, 
            "Noun has been minted"
        );
        
        return coinId;
    }                   
                                                                             
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
            coinId > 0 && coinId <= _currentDay(), 
            "Coin has not been minted"
        );

        return _coinToNoun[coinId];
    }          
                        
      /*$$$$$  /$$        /$$$$$$  /$$$$$$ /$$      /$$  /$$$$$$  /$$$$$$$  /$$       /$$$$$$$$
     /$$__  $$| $$       /$$__  $$|_  $$_/| $$$    /$$$ /$$__  $$| $$__  $$| $$      | $$_____/
    | $$  \__/| $$      | $$  \ $$  | $$  | $$$$  /$$$$| $$  \ $$| $$  \ $$| $$      | $$      
    | $$      | $$      | $$$$$$$$  | $$  | $$ $$/$$ $$| $$$$$$$$| $$$$$$$ | $$      | $$$$$   
    | $$      | $$      | $$__  $$  | $$  | $$  $$$| $$| $$__  $$| $$__  $$| $$      | $$__/   
    | $$    $$| $$      | $$  | $$  | $$  | $$\  $ | $$| $$  | $$| $$  \ $$| $$      | $$      
    |  $$$$$$/| $$$$$$$$| $$  | $$ /$$$$$$| $$ \/  | $$| $$  | $$| $$$$$$$/| $$$$$$$$| $$$$$$$$
     \______/ |________/|__/  |__/|______/|__/     |__/|__/  |__/|_______/ |________/|_______*/
                                                      
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
        require(coinId < _currentDay(), "Coin is not claimable yet");

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

      /*$$$$$  /$$   /$$ /$$$$$$$  /$$$$$$$  /$$$$$$$$ /$$   /$$  /$$$$$$  /$$     /$$
     /$$__  $$| $$  | $$| $$__  $$| $$__  $$| $$_____/| $$$ | $$ /$$__  $$|  $$   /$$/
    | $$  \__/| $$  | $$| $$  \ $$| $$  \ $$| $$      | $$$$| $$| $$  \__/ \  $$ /$$/ 
    | $$      | $$  | $$| $$$$$$$/| $$$$$$$/| $$$$$   | $$ $$ $$| $$        \  $$$$/  
    | $$      | $$  | $$| $$__  $$| $$__  $$| $$__/   | $$  $$$$| $$         \  $$/   
    | $$    $$| $$  | $$| $$  \ $$| $$  \ $$| $$      | $$\  $$$| $$    $$    | $$    
    |  $$$$$$/|  $$$$$$/| $$  | $$| $$  | $$| $$$$$$$$| $$ \  $$|  $$$$$$/    | $$    
     \______/  \______/ |__/  |__/|__/  |__/|________/|__/  \__/ \______/     |_*/    
                                                                                                                                                                    
    event Staked(
        uint id,
        uint tax,
        uint noun,
        uint found,
        uint expiresAt,
        uint startedAt,
        address govt
    );

    struct StakeParams {
        address to;
        uint noun;
        uint found;
        uint expiresAt;
        address govt;
    }

    function getStake(uint stakeId) external view returns (Stake memory) {
        return _requireStake(stakeId);
    }

    function stake(StakeParams memory params) external {
        require(params.found > 0, "Stake more than 0");
        require(
            params.expiresAt >= block.timestamp + 1 days, 
            "Stake at least 1 day in the future"
        );

        Stake storage token = _stakes[++_stakeCount];
        token.id = _stakeCount;
        token.tax = _govt.tax();
        token.noun = params.noun;
        token.found = params.found;
        token.expiresAt = params.expiresAt;
        token.startedAt = block.timestamp;

        if (token.tax > 0) {
            require(_govt.isGovernment(params.govt), "Government is not active");
            token.govt = params.govt;
        }

        uint day = _currentDay();
        uint shares = calculateShares(day, params.found);

        _shares[token.id] = shares;
        _totalShares += shares;

        _mint(params.to, token.id);

        emit Staked(
            token.id, 
            token.tax,
            token.noun,
            token.found,
            token.expiresAt,
            token.startedAt,
            token.govt
        );
    }

    function _requireStake(uint stakeId) internal view returns (Stake memory) {
        require(stakeId <= _stakeCount, "Stake not found");
        return _stakes[stakeId];
    }

    event Burned(
        uint id,
        uint idea,
        uint amount,
        uint burnedAt
    );

    function currentBalance() public view returns (uint) {
        return _cash.balanceOf(address(this));
    }

    function burn(address payee, uint stakeId) external {
        address owner = ownerOf(stakeId);
        require(owner == msg.sender, "You are not the owner");

        Stake memory token = _requireStake(stakeId);

        require(token.burnedAt == 0, "Token already burned");
        token.burnedAt = block.timestamp;

        uint shares;
        uint penalty; 
        uint revenue;
        uint taxes;

        (shares, penalty, revenue, taxes) = calculatePayout(
            stakeId, 
            block.timestamp
        );

        _totalShares -= shares;
        _burn(token.id);

        if (revenue > 0) {
            _cash.transferFrom(address(this), payee, revenue);
        }

        if (taxes > 0 && _govt.isGovernment(token.govt)) {
            _cash.transferFrom(address(this), token.govt, taxes);
        }

        emit Burned(token.id, token.noun, token.found, token.burnedAt);
    }

    function calculatePayout(
        uint stakeId, 
        uint timestamp
    ) public view returns (
        uint shares, 
        uint penalty, 
        uint revenue,
        uint taxes
    ) {
        Stake memory token = _requireStake(stakeId);

        uint shares_ = _shares[stakeId];
        
        uint penalty_ = _calculatePenalty(token, timestamp);
        uint portion_ = currentBalance() * shares_ / _totalShares;

        uint revenue_ = portion_ - penalty_; 
        uint taxes_ = revenue_ * token.tax / 10000;

        return (shares_, penalty_, revenue_, taxes_);
    }

    function _calculatePenalty(Stake memory token, uint timestamp) internal pure returns (uint) {
        if (timestamp > token.expiresAt + 2 weeks) {
            uint late = (timestamp - token.expiresAt - 2 weeks) / 1 days;
            return late * token.found / 14;
        }

        return 0;
    }       
}
