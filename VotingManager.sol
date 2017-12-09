pragma solidity ^0.4.15;

import "./AuthAdmin.sol";
//import "./SafeMath.sol";
import "./VotingContract.sol";

contract VotingManager {
    
    using SafeMath for uint256;
    
    uint256 public time_voting_begins;
    uint256 public time_voting_ends;
    uint256 public votersCount;
    
    address[] public currentVotings;
    VotingContract public lastVoting;

    address[] public voters;

    mapping (address => uint256) public voteNum;

    AuthAdmin internal authAdmin;

    modifier adminOnly {
        require (authAdmin.isCurrentAdmin(msg.sender));
        _;
    }
    
    function VotingManager (address _auth_address) public {
        authAdmin = AuthAdmin(_auth_address);
    }

    function count_voters (uint256 quantity) public adminOnly {
        votersCount = lastVoting.getVoters();
    }

    //the result is not saved,
    //in the future it is difficult to find the address of a new vote
    function create_new_voting (
        uint256 voting_begins,
        uint256 voting_ends,
        address symm_token_address) public adminOnly 
    {
        lastVoting = new VotingContract(voting_begins, voting_ends, symm_token_address);
        currentVotings.push(lastVoting);
    }
}
