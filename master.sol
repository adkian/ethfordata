pragma solidity ^0.4.13;

/* MASTER TODO */

contract ClientInterface {
  
  struct Datapoint{
    uint client_id;
    uint timestamp;
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
    end_data_index++;
    datapoints[dp] = Datapoint(ID, time, lat, long);
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

contract FunderInterface{
  function sendData(string data){}
}

contract Master is ClientInterface, FunderInterface{

  /* Monthly subscription cost, currently held at 1 ETH */
  /* Ideally, this rate would be dynamic based on amount of data available  */
  uint subscription = 1;
  
  function getBalance() constant returns (uint){
    return this.balance;
  }
  
  /* struct to hold funders data */
  struct Funder{
    address add;
    int ID;
    uint amount;
  }

  int numFunders;
  mapping (int => Funder) funders;
 

  /* funder struct getter functions */
  function getFunderID(address add) constant returns (int){
    for(int x=0;x<numFunders;x++){
      if(funders[x].add == add)
	return x;
    }
    return -1;
  }  
  function getFunderAmount(int ID) constant returns (uint){
    return funders[ID].amount;
  }  
  
  /* Fund the contract. Should also act as a funder registration function */
  function fund() payable returns (bool){


    int id = getFunderID(msg.sender);

    //if the funder is not in the system, add them
    if(id<0){
      address funderAddress = msg.sender;
      int funderID = numFunders++;
      uint funderAmount = msg.value;

      //add all this info into a new struct;   
      funders[funderID] = Funder(funderAddress, funderID, funderAmount);
    }
    else{
      funders[id].amount+=msg.value;      
    }
        
    return true;      
  }

  //TODO: test this chunk of code before testrpc deployment
  /* format data */
  function strConcat(string base, string user_id, string timestamp, string lat, string long, string newlinechar) internal returns (string){
    
    bytes memory _base = bytes(base);
    bytes memory _ba = bytes(user_id);
    bytes memory _bb = bytes(timestamp);
    bytes memory _bc = bytes(lat);
    bytes memory _bd = bytes(long);
    bytes memory _newlinechar = bytes(newlinechar);
     
    string memory formatted_data_point = new string(_base.length +_ba.length + _bb.length + _bc.length + _bd.length + _newlinechar.length);
    
    bytes memory data = bytes(formatted_data_point);
    
    uint k = 0;
    for (uint i = 0; i < _base.length; i++) data[k++] = _base[i];
    for (uint i2 = 0; i2 < _ba.length; i2++) data[k++] = _ba[i2];
    for (uint i3 = 0; i3 < _bb.length; i3++) data[k++] = _bb[i3];
    for (uint i4 = 0; i4 < _bc.length; i4++) data[k++] = _bc[i4];
    for (uint i5 = 0; i5 < _bd.length; i5++) data[k++] = _bd[i5];
    for (uint i6 = 0; i6 < _newlinechar.length; i6++) data[k++] = _newlinechar[i6];

    return string(data);
  }


  /* function that sends data and payment to relevant parties */
  function payout() returns (bool){
    //format data
    string tx_data;
    
    string newlinechar;
    
    for(uint d = start_data_index; d<end_data_index; d++){
        
      //TODO: convert each datapoint elements to strings
	strConcat(tx_data, uintToString(datapoints[d].client_id), uintToString(datapoints[d].timestamp), getCoordString(datapoints[d].lat), getCoordString(datapoints[d].long), "\n");
    }
    
    //TODO: Different tiers of data based on granularity
    //TODO: if payout loop causes errors on the last client due to gas, run a seperate condition for the last client for now
    /* Send data as a tx data */
    /* Requires an external function on the client contract to send data to */    
    uint totalcharge=0;
    for(int x=0; x<numFunders; x++){
      if(funders[x].amount>=subscription){
        FunderInterface f = FunderInterface(funders[x].add);
        f.sendData(tx_data);
	//funders[x].call(tx_data);
	
	funders[x].amount -= subscription;
	totalcharge += subscription;
      }	      
    }
    
    //payouts to clients
    uint share = totalcharge/numClients;

    //may cause errors on the last one: gas costs are not considered yet
    for(uint curr_client=0; curr_client<numClients; curr_client++){
      clients[curr_client].transfer(share); 
    }
  }
  
  function uintToString(uint v) constant returns (string str) {
    uint maxlength = 100;
    bytes memory reversed = new bytes(maxlength);
    uint i = 0;
    while (v != 0) {
      uint remainder = v % 10;
      v = v / 10;
      reversed[i++] = byte(48 + remainder);
    }
    bytes memory s = new bytes(i + 1);
    for (uint j = 0; j <= i; j++) {
      s[j] = reversed[i - j];
    }
    str = string(s);
  }

  /* ... */
  function getCoordString(int coord) returns (string){
    string neg;
    if(coord<0){
      coord*=-1;
      return getNegCoordString("-", uintToString(uint(coord)));   
    }
    else{
      return uintToString(uint(coord));
    }
  }
  
  /* O_O */
  function getNegCoordString(string base, string user_id) internal returns (string){
    
    bytes memory _base = bytes(base);
    bytes memory _ba = bytes(user_id);

     
    string memory formatted_data_point = new string(_base.length +_ba.length);
    
    bytes memory data = bytes(formatted_data_point);
    
    uint k = 0;
    for (uint i = 0; i < _base.length; i++) data[k++] = _base[i];
    for (uint i2 = 0; i2 < _ba.length; i2++) data[k++] = _ba[i2];

    return string(data);
  }
}


