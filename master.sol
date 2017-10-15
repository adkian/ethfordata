pragma solidity ^0.4.13;

/* MASTER TODO */

contract ClientInterface {
  
  struct Datapoint{
    uint client_id;
    int timestamp;
    int lat;
    int long;
  }

  uint numClients;

  /* The following will be used during monthly data outputs */
  /* End data index will point to the last datapoint */
  /* Start data index will point to the first datapoint after a payout */
  uint start_data_index;
  uint end_data_index;
  
  uint numDatapoint;
  mapping (uint => Datapoint) datapoints;  

  /* called by the client when sending location data */
  function getData(uint ID, uint time, int lat, int long) external returns (bool){
    uint dp = numDatapoint++;
    end_data_point++;
    datapoints[dp] = Datapoint[ID, time, lat, long];
  }

  mapping (uint => address) clients;
  /* called by a new client during initialization */
  /* returns a unique ID to the client which is the identifier  */
  /* used to identify client during incoming data transactions */
 /* Roadmap: hashed unique ID */
  function getID() external returns (uint){
    clients[numClients] = msg.sender;
    return numClients++;
  }
}


contract Master is ClientInterface{

  function getBalance() constant returns (uint){
    return this.balance;
  }
  
  /* struct to hold funders data */
  struct Funder{
    address add;
    uint ID;
    uint amount;
    uint tier;    
  }

  uint numFunders;
  mapping (uint => Funder) funders;
 

  /* funder struct getter functions */
  function getFunderID(address add) constant returns (uint){
    for(int x=0;x<numFunders;x++){
      if(Funders[x].add == add)
	return x;
    }
    return -1;
  }  
  function getFunderAmount(uint ID) constant returns (uint){
    return Funders[ID].amount;
  }
  Function getFunderTier(uint ID) constant returns (uint){
    return Funders[ID].tier;
  }

  
  
  modifier onlyOwner(){
    if(msg.sender != owner)
      revert();	
    else
      _;
  }

  /***assign values based on Vlad's results** */
  /* return a requesting funder's current tier; */
  /* tier 1 (upper) cutoff: t1cutoff */
  /* tier 2 (upper) cutoff: t2cutoff */
  /* tier 3 (upper) cutoff: t3cutoff */
  function getTier(uint amount) returns (uint){
    uint t1cutoff;
    uint t2cutoff;
    uint t3cutoff;

    uint tier;

    if(amount<t3cutoff){
      tier = 0;
    }else if(amount>=t3cutoff && amount<t2cutoff){
      tier = 3;
    }else if(amount>=t2cutoff && amount<t1cutoff){
      tier = 2;
    }else if(amount>=t1){
      tier = 1;
    }

    return tier;
  }
  
  /* Fund the contract. Should also act as a funder registration function */
  function fund() payable returns (bool){


    int id = getFunderID(msg.sender);

    //if the funder is not in the system, add them
    if(id<0){
      address funderAddress = msg.sender;
      uint funderID = numFunders++;
      uint funderAmount = msg.value;
      uint funderTier = getTier(funderAmount);

      //add all this info into a new struct;   
      funders[funderID] = Funder(funderAddress, funderID, funderAmount, funderTier);
    }
    else{
      funders[id].amount+=msg.value;      
    }
        
    return true;      
  }

  /* function that sends data and payment to relevant parties */
  function payout() returns (bool){
    //format data
    string tx_data;
    string newlinechar = "\n";
    for(int d = start_data_index; d<end_data_index; d++){
      strConcat(txdata, datapoints[d].id, datapoints[d].timestamp, datapoints[d].lat, datapoints[d].long, newlinechar);
    }

    //TODO: different tiers of data based on granularity
    //TODO: if payout loop causes errors on the last client due to gas, run a seperate condition for the last client for now
    /* Send data as a tx data */
    /* Requires an external function on the client contract to send data to */
    for(int x=0; x<numFunders; x++){
      funders[x].address.call(tx_data);
    }

    //payouts to clients
    uint share = getBalance()/numClients;

    //may cause errors on the last one: gas costs are not considered yet
    for(int x=0; x<numClients; x++){
      clients[x].transfer(share); 
    }
  }

  //TODO: test this chunk of code before testrpc deployment
  /* format data */
  function strConcat(string base, string user_id, string timestamp, string lat, string long, string newlinechar) internal returns (string){
    
    bytes memory _base = bytes(base);
    bytes memory _ba = bytes(user_id);
    bytes memory _bb = bytes(timestamp);
    bytes memory _bc = bytes(lat);
    bytes memory _bd = bytes(_long);
    bytes memory _newlinechar = bytes(newlinechar);
    
    string memory formatted_data_point = new string(_base.length +_ba.length + _bb.length + _bc.length + _bd.length + _newlinechar.length);
    
    bytes memory data = bytes(formatted_data_point);
    
    uint k = 0;
    for (uint i = 0; i < _base.length; i++) data[k++] = _base[i];
    for (uint i = 0; i < _ba.length; i++) data[k++] = _ba[i];
    for (uint i = 0; i < _bb.length; i++) data[k++] = _bb[i];
    for (uint i = 0; i < _bc.length; i++) data[k++] = _bc[i];
    for (uint i = 0; i < _bd.length; i++) data[k++] = _bd[i];
    for (uint i = 0; i < _newlinechar.length; i++) data[k++] = _newlinechar[i];

    return string(data);
  }

}


