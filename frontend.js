$(document).ready(function(){
  
  //googleAPI
  const geoApi = "https://www.googleapis.com/geolocation/v1/geolocate?key=AIzaSyCcVgktbOCwVgcN1coYggrDPmM3Se3b-1k";
  
  //web3 instance
  //const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  
  //const contractAddress = "";
  
  //const ABI = [{"constant":false,"inputs":[{"name":"_lat","type":"int256"},{"name":"_long","type":"int256"},{"name":"_time","type":"uint256"}],"name":"forawardLoc","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"master_address","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"getID","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"ID","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"","type":"uint256"},{"name":"","type":"uint256"},{"name":"","type":"int256"},{"name":"","type":"int256"}],"name":"getData","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"name":"client","type":"address"},{"indexed":false,"name":"time","type":"uint256"},{"indexed":false,"name":"lat","type":"int256"},{"indexed":false,"name":"long","type":"int256"}],"name":"IncomingData","type":"event"}];
  
  //const contract = web3.eth.contract(ABI).at(contractAddress);
  
  $("#exeBtn").click(function(){
    
    if (($('#loco').is(':checked')) & ($('#terms').is(':checked'))){
      
      console.log("Terms and Location Checked; Form Submitted");
      
      //const id = contract.ID;
      
      //console.log(id);
      
      setInterval(function(){
        $.post(geoApi, function(location_data){
          var time = Date.now();
          console.log(time, location_data.location.lat, location_data.location.lng);
          //contract.getData(id, time, location_data.location.lat, location_data.location.lng).call();
        })
      }, 2000);
      
      $("form").toggle();
      $("#box").html("<br><br><br><br><h3>Thank you, your data has been submitted.</h3>")
      
    }
    
  })
  
});