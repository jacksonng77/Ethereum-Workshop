import "../stylesheets/app.css";
import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract'

/*
	Reference: https://medium.com/@mvmurthy/full-stack-hello-world-voting-ethereum-dapp-tutorial-part-2-30b3d335aa1f
*/

import godutch_artifacts from '../../build/contracts/godutch.json'

var Godutch = contract(godutch_artifacts);

let friends = {"Jack": "friend-1", "Mark": "friend-2"}

//updates the contribution of each friend
function updateAllContributions(){
	let friendNames = Object.keys(friends);
  	for (var i = 0; i < friendNames.length; i++) {
   		let name = friendNames[i];
		Godutch.deployed().then(function(contractInstance) {
    		contractInstance.totalContrib(name).then(function(v) {
        		$("#" + friends[name]).html(parseFloat(v.toString())/100);
        	})
    	});
  	}
	//already updated, so we can clear this message
	$("#msg").html("");
}

//this updates the total amount of money there is in the kitty
function updateKitty(){
	Godutch.deployed().then(function(contractInstance) {
    	contractInstance.whatIsOurPool().then(function(v) {
        	$("#kitty").html(parseFloat(v.toString())/100);
			$("#msgspend").html("");
        })
    });
}

//records spending to the blockchain
window.Spend = function() {
	let spendamount = $("#spendamount").val();
  try {
    $("#msgspend").html("Money has been spent. Blockchain is now updating. Please wait.")
	$("#spendamount").val("");
  
	Godutch.deployed().then(function(contractInstance) {
    	contractInstance.spend(spendamount*100, {gas: 140000, from: web3.eth.accounts[0]}).then(function(v) {
			updateKitty();
       	})
    });
  } catch (err) {
    console.log(err);
  }
}

//records contribution to the blockchain
window.ContributeForFriend = function(friend) {
	let friendName = $("#friend").val();
	let contribution = $("#amount").val();
  try {
    $("#msg").html("Contribution has been made. It will be updated as soon as the contribution is recorded on the blockchain. Please wait.")
    $("#friend").val("");
	$("#amount").val("");
  
	Godutch.deployed().then(function(contractInstance) {
    	contractInstance.contribute(friendName, contribution*100, {gas: 140000, from: web3.eth.accounts[0]}).then(function(v) {
			updateAllContributions();
			updateKitty();
       	})
    });
  
  } catch (err) {
    console.log(err);
  }
}

$( document ).ready(function() {
  if (typeof web3 !== 'undefined') {
    console.warn("Using web3 detected from external source like Metamask")
    // Use Mist/Status/MetaMask's provider
    window.web3 = new Web3(web3.currentProvider);
  } else {
    console.warn("No web3 detected. Falling back to http://localhost:8545.");
     window.web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  }

Godutch.setProvider(web3.currentProvider);

updateAllContributions();
updateKitty();
});
