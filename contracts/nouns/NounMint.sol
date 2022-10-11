// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import { Strings } from '@openzeppelin/contracts/utils/Strings.sol';
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./NounBank.sol";
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
                                                                                                                          
// TODO: governance tax
contract NounMint is Nounish, ERC721 {

    IERC20 private _cash;
    NounData private _data;
    NounBank private _bank;
    address private _game;

    function cash() external view returns (IERC20) {
        return _cash;
    }

    function data() external view returns (NounData) {
        return _data;
    }

    function bank() external view returns (NounBank) { 
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

    uint private _noteCount;

    mapping(uint => Note) private _notes;

    function noteCount() external view returns (uint) {
        return _noteCount;
    }

    function getNote(uint noteId) external view returns (Note memory) {
        return _requireNote(noteId);
    }

    function _requireNote(uint noteId) internal view returns (Note memory) {
        require(noteId <= _noteCount, "Note not found");
        return _notes[noteId];
    }

    function tokenURI(uint noteId) public view virtual override returns (string memory) {
        Note memory note = _requireNote(noteId);
        return string(_noteURI(note));
    }

    function tokenData(uint noteId) external view returns (string memory) {
        Note memory note = _requireNote(noteId);
        return string(_noteJSON(note));
    }
    
    function _noteURI(Note memory note) internal view returns (bytes memory) {
        return abi.encodePacked(
            'data:application/json;base64,',
            Base64.encode(_noteJSON(note))
        );
    }

    function _noteJSON(Note memory note) internal view returns (bytes memory) {
        Noun memory noun = _data.getNoun(note.nounId); 
        return abi.encodePacked(
            '{',
                '"id":', note.id.toString(), ',',
                '"name":"FOUND ', noun.name, '",',
                '"description":"', noun.name, ' is FOUND.",',
                '"noun":[', _data.tokenData(note.nounId), '],',
                '"image":"', _data.tokenImage(note.nounId), '"',
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
    
    function getShares(uint noteId) external view returns (uint) {
        return _shares[noteId];
    }

    function totalShares() external view returns (uint) {
        return _totalShares;
    }

    function calculatePayout(uint noteId, uint timestamp) external view returns (uint, uint) {
        Note memory note = _requireNote(noteId);
        
        uint earnings = _calculateEarnings(noteId);
        uint penalty = _calculatePenalty(note, timestamp);

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

    function _calculateEarnings(uint noteId) internal view returns (uint) {
        uint balance = _cash.balanceOf(address(this));
        uint earnings = balance * _shares[noteId] / _totalShares;
        return earnings;
    }

    function _calculatePenalty(Note memory note, uint timestamp) internal pure returns (uint) {
        if (timestamp > note.expiresAt + 2 weeks) {
            uint late = (timestamp - note.expiresAt - 2 weeks) / 1 days;
            return late * note.amount / 14;
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
                                                                                                                          
    event Vote(
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
        _bank.mint(minter, coinId, minted);

        emit Vote(
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
                                                                                
    event Mint(
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
        _bank.mint(minter, coinId, minted);

        emit Mint(
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

    event Stake(
        uint id,
        uint idea,
        uint amount,
        uint expiresAt,
        uint startedAt
    );

    function stake(address minter, NoteParams memory params) external {
        Note memory note = _createNote(params);

        _mint(minter, note.id);

        emit Stake(
            note.id, 
            note.nounId,
            note.amount,
            note.expiresAt,
            note.startedAt
        );
    }

    function _createNote(NoteParams memory params) internal returns (Note memory) {
        require(
            params.amount > 0, 
            "Note more than 0"
        );

        require(
            params.expiresAt > block.timestamp  + 1 days, 
            "Must expire further in the future"
        );

        Note storage note = _notes[++_noteCount];
        note.id = _noteCount;
        note.nounId = params.nounId;
        note.amount = params.amount;
        note.expiresAt = params.expiresAt;
        note.startedAt = block.timestamp;

        uint day = _data.currentDay();
        uint shares = calculateShares(day, params.amount);
    
        _shares[note.id] = shares;
        _totalShares += shares;

        return note;
    }
                                                                                                                     
     /*$$$$$$  /$$   /$$ /$$$$$$$  /$$   /$$                                                                                  
    | $$__  $$| $$  | $$| $$__  $$| $$$ | $$                                                                                  
    | $$  \ $$| $$  | $$| $$  \ $$| $$$$| $$                                                                                  
    | $$$$$$$ | $$  | $$| $$$$$$$/| $$ $$ $$                                                                                  
    | $$__  $$| $$  | $$| $$__  $$| $$  $$$$                                                                                  
    | $$  \ $$| $$  | $$| $$  \ $$| $$\  $$$                                                                                  
    | $$$$$$$/|  $$$$$$/| $$  | $$| $$ \  $$                                                                                  
    |_______/  \______/ |__/  |__/|__/  \_*/         
                                               
    event Burn(
        uint id,
        uint idea,
        uint amount,
        uint endedAt
    );

    function burn(address payee, uint noteId) internal {
        Note memory note = _requireNote(noteId);
        uint payout = _burnNote(note);

        _cash.transferFrom(address(this), payee, payout);

        emit Burn(note.id, note.nounId, note.amount, note.endedAt);
    }

    function _burnNote(Note memory note) internal returns (uint payout) {
        address owner = ownerOf(note.id);
        require(owner == msg.sender, "You are not the owner");

        require(note.endedAt == 0, "Note already ended");
        note.endedAt = block.timestamp;

        _burn(note.id);

        uint earnings = _calculateEarnings(note.id);
        uint penalty = _calculatePenalty(note, block.timestamp);

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
                                                           
    event Claim(
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
        _bank.mint(minter, coinId, amount);
        
        emit Claim(
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

    constructor(
        IERC20 cash_, 
        NounData data_,
        string memory baseURI_
    ) ERC721("FOUND NOUN", "FOUND NOUN") {
        _data = data_;
        _cash = cash_;

        Nounish _base = Nounish(address(this));
        _bank = new NounBank(data_, _base, baseURI_);
        _cash.approve(address(this), type(uint).max);
    }  
}
