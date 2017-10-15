pragma solidity ^0.4.13;

contract MasterInterface{
  function getID() returns (uint) {}
  function getData(uint, uint, int, int) {}
}

contract Client is MasterInterface{
   
  int lat;
  int long;
  uint time;
  uint public ID;
  MasterInterface m;
  address owner;
  
  //the address below would be used by this contract to transact with the master contract
  address public master_address;
  
  event IncomingData(
		     address client,
		     uint time,
		     int lat,
		     int long
		     );

  modifier onlyClient(){
    if(msg.sender != owner)
      revert();
    else
      _;
  }

  function Client(){
    owner = msg.sender;
    
    //this transaction should act as registration with the master contract
    m = MasterInterface(master_address);
    ID =  m.getID();
  }

  
  
  function forawardLoc(int _lat, int _long, uint _time) external returns (bool){

    lat = _lat;
    long = _long;
    time = _time;      
    
    IncomingData(msg.sender, time, lat, long);
    
    m.getData(ID, time, lat, long);
    return true;
  }    
}

