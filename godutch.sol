pragma solidity ^0.4.16;

contract godutch {
	/*
		The friend structure keeps the address of this friend,
		the total amount of contributions he has made,
		and how much he has made on behalf of another friend
		
		Reference: https://medium.com/@mvmurthy/full-stack-hello-world-voting-ethereum-dapp-tutorial-part-3-331c2712c9df
	*/
	struct friend {
		address friendAddress; 
		uint contribution;    
		uint[] contributionPerFriend; 
	}
	
	//friendInfo is a struct of friend 
	mapping (address => friend) public friendInfo;
	
	//totalContributions for each friend 
	mapping (bytes32 => uint) public totalContributions;
	
	//what's in the whole pool
	uint public pool; 

	//a list of friends 	
	bytes32[] public friendList;

	/*
		when the contract is deployed, a list of friends names are provided.
		In this deployment, it is ['Jack', 'Mark']
	*/
	function godutch(bytes32[] friendsNames) public {
		friendList = friendsNames;
	}

	/* 
		you tell me who this friend is, 
		and I will tell you how much contribution he made.
	*/
	function totalContrib(bytes32 thefriend) public constant returns (uint) {
		return totalContributions[thefriend];
	}

	/*
		tell me who this friend is and how much he is contributing
	*/
	function contribute(bytes32 thefriend, uint amount) public {
		uint index = indexOfFriend(thefriend);
		if (index == uint(-1)) revert(); //friend doesn't exist

		//No contributions yet? set contributionPerFriend to nothing
		if (friendInfo[msg.sender].contributionPerFriend.length == 0) {
			for(uint i = 0; i < friendList.length; i++) {
				friendInfo[msg.sender].contributionPerFriend.push(0);
			}
		}
	
		totalContributions[thefriend] += amount;	//total contribution made by this friend 
		friendInfo[msg.sender].contributionPerFriend[index] += amount; //total contribution made by this sender for this friend
		friendInfo[msg.sender].contribution += amount;	//total contribution made by this sender
		pool += amount; //add funds to pool
	}
  
	/*
		spend some money
	*/
	function spend(uint amount) public {
		if (pool < amount){
			revert();
		}
		else {
			pool -= amount;    
		}
	}
	
	/*
		tell me the address of this account
		and I will tell you his contributions
	*/
	function friendDetails(address user) public constant returns (uint, uint[]) {
		return (friendInfo[user].contribution, friendInfo[user].contributionPerFriend);
	}

	/*
		tell me who the friend is
		and I will tell you where he is in the array
	*/
	function indexOfFriend(bytes32 thefriend) public constant returns (uint) {
		for(uint i = 0; i < friendList.length; i++) {
		if (friendList[i] == thefriend) {
			return i; //found!
		}
    }
		return uint(-1); //oops, can't find!
	}

	/*
		return what's left in the pool of funds
	*/
	function whatIsOurPool() public constant returns (uint) {
		return pool;
	}
  
	function allFriends() public constant returns (bytes32[]) {
		return friendList;
	}
}
