pragma solidity ^0.4.15;

import "./AuthAdmin.sol";
import "./SingleTokenCoin.sol";

contract TokenHolderInfo {
    
    using SafeMath for uint256;

    address[] token_holders_array;

    uint numElements = 0;
    
    mapping (address => uint256) balances;


    uint public counter = 0;

    SingleTokenCoin token;
    AuthAdmin authAdmin;

    event SnapshotTaken();
    event SnapshotUpdated(address holder, uint256 oldBalance, uint256 newBalance, string details);

    modifier adminOnly {
        require (authAdmin.isCurrentAdmin(msg.sender));
        _;
    }
    modifier usersOnly {
        require (authAdmin.isCurrentUser(msg.sender));
        _;
    }

    function TokenHolderInfo(address token_address, address admin_address) public {
        token = SingleTokenCoin(token_address);
        authAdmin = AuthAdmin(admin_address);
    }

    //~100 token_holders max
    function snapshot() public adminOnly {
        if (counter != 0 && counter == token.count_token_holders()) {
            revert();
        }
       /* uint256 maxCount;
        uint256 length = token.count_token_holders();

        if (counter + 100 > length) {
            maxCount = length;
        } else {
            maxCount = counter + 100;
        }
        
        for (; counter < maxCount; counter++) {
            balances[token_holders_array[counter]] = 0;
            address addr = token.tokenHolder(counter);
            token_holders_array.push(addr);
            balances[addr] = token.balanceOf(addr);
        }
        SnapshotTaken();*/

        uint256 count = 0;

        for (uint256 i = counter; i < token.count_token_holders(); i++) {
            if (count >= 70) {
                break;
            }
            address addr = token.tokenHolder(counter);
            insertTokenHoldersArray(addr);
            balances[addr] = token.balanceOf(addr);
            count++;
            counter++;
        }
    }

    function counterReset () public adminOnly {
        counter = 0;
        numElements = 0;
    }

    function insertTokenHoldersArray (address token_holder_addr) private {
        if(numElements == token_holders_array.length) {
            token_holders_array.length += 1;
        }
        token_holders_array[numElements++] = token_holder_addr;
    }

    function snapshotUpdate(address _addr, uint256 _newBalance, string _details) public adminOnly {
        uint256 existingBalance = balances[_addr];
        if (existingBalance == _newBalance)
            return;
        if (!token.holders(_addr)) {
            //token_holders_array.push(_addr);
            insertTokenHoldersArray(_addr);
            //balances[_addr] = _newBalance;
        }
        balances[_addr] = _newBalance;



        /*else if (_newBalance > 0) {
            balances[_addr] = _newBalance;
        } else {
            balances[_addr] = 0;
            uint256 count_token_holders = token_holders_array.length;
            uint256 current_position = 0;
            bool found = false;
            uint256 i;
            for (i = 0; i < count_token_holders; i++)
                if (token_holders_array[i] == _addr) {
                    current_position = i;
                    found = true;
                    break;
                }
            require(found);
                for (i = current_position; i < count_token_holders - 1; i++)
                    token_holders_array[i] = token_holders_array[i + 1];
                token_holders_array.length--;
        }*/



        SnapshotUpdated(_addr, existingBalance, _newBalance, _details);
    }
                        /*--------------------------
                                  Getters
                        --------------------------*/
    function balanceOf(address addr) usersOnly public constant returns (uint256) {
        return balances[addr];
    }

    function count_token_holders() usersOnly public constant returns (uint256) {
        return numElements;
    }

    function tokenHolder(uint256 _index) usersOnly public constant returns (address) {
        if (_index >= numElements) {
            return address(0);
        }
        return token_holders_array[_index];
    }
}