$(document).ready(function(){
    //connect to metamask wallet 
    $("#connectWallet,#connectWallet1").click(async function(e){
        e.preventDefault();
        if(window.ethereum){
            window.ethereum.enable();
            var isMobile = /iPhone|iPad|iPod|Android/i.test(navigator.userAgent);
            if (isMobile && window.ethereum.isMetaMask==true){
                    const accounts_ = await window.ethereum.request({ method: 'eth_requestAccounts' });
                    //alert(accounts_);
                
            }else{
                const accounts_ = await ethereum.request({ method: 'eth_accounts' });
                  console.log(accounts_);
            }
            //const accounts_ = await ethereum.request({ method: 'eth_accounts' });
            if(accounts_!=""){
                window.location.href = "";
            }
        }
    });
    function init(){
                
        contractInstance = new myweb3.eth.Contract(ABI, contractAddress, {
                from: myAccountAddress, // default from address
        });
        showtotalSupply();
        
        //checkuserBalance();
        
    }
    setTimeout(init,2000);
   
    async function checkuserBalance(){
       if(myAccountAddress==undefined){
            swal("Warning !", "Please connect wallet.", "warning");
           return false;
       }
        var balance = await contractInstance.methods.balanceOf(myAccountAddress).call();
        if(balance>0){
           $('.mint').css({'pointer-events' : ''});   
        }
        
    }
    
     async function showtotalSupply(){
         var isMobile = /iPhone|iPad|iPod|Android/i.test(navigator.userAgent);
        if (isMobile){
            const totalSupply = await contractInstance.methods.totalSupply().call();
            $('#totalSupply').html(totalSupply);
            
        }else{
            const totalSupply = await contractInstance.methods.totalSupply().call();
            
            $('#totalSupply').html(totalSupply);
            
        }
    }
    $(document).on("click", "#btnMintNFT",async function(e){
       
        e.preventDefault();
         var numberOfTokens = $('#tokenAmount').val();
         if(numberOfTokens==0 || numberOfTokens==""){
                 swal("Warning !", "Please enter quantity.", "warning");
                 return false;
            }
         if(numberOfTokens<0  || numberOfTokens>5){
                 swal("Warning !", "You can't mint more than 5 LoadOut NFT.", "warning");
                 return false;
            }
       // var balance = await contractInstance.methods.balanceOf(myAccountAddress).call();
        //if(balance<10){
            
        
       
        var tokenPrice = 60000000000000000; ///0.07*1e18;
        var gasLimit = 200000 * numberOfTokens;
        
        var payableAmount = tokenPrice *  numberOfTokens;
        var isMobile = /iPhone|iPad|iPod|Android/i.test(navigator.userAgent);
        if (isMobile && window.ethereum.isMetaMask==true) {
                const accountNonce = '0x' + (await myweb3.eth.getTransactionCount(myAccountAddress) + 1).toString(16);
                const fetchResponse =  await fetch(gasTrakerAPI);
                const edata = await fetchResponse.json();   
                var web3GasPrice = edata.result.ProposeGasPrice;
                web3GasPrice = web3GasPrice.toString();
                gasLimit = gasLimit.toString();
                payableAmount = payableAmount.toString();
                payableAmount =  myweb3.utils.toHex(payableAmount);
                web3GasPrice =  myweb3.utils.toHex(web3GasPrice);
                gasLimit =  myweb3.utils.toHex(gasLimit);
                var data =await contractInstance.methods.mint(numberOfTokens).encodeABI();
                const transactionParameters = {
                  //nonce: accountNonce, // ignored by MetaMask
                  gasPrice: web3GasPrice, // customizable by user during MetaMask confirmation.
                  gas: gasLimit, // customizable by user during MetaMask confirmation.
                  to: contractAddress, // Required except during contract publications.
                  from: myAccountAddress, // must match user's active address.
                  value: payableAmount, // Only required to send ether to the recipient from the initiating external account.
                  data: data, // Optional, but used for defining smart contract creation and interaction.
                  //chainId: '0x3', // Used to prevent transaction reuse across blockchains. Auto-filled by MetaMask.
                };
            
                // txHash is a hex string
                // As with any RPC call, it may throw an error
                const txHash = await ethereum.request({
                  method: 'eth_sendTransaction',
                  params: [transactionParameters],
                });
                if(txHash){
                        swal("Success !", "Successfully Minted LoadOut NFT.", "success");
                        //alert('Successfully Minted NFTs.');
                }
        }else{
                //const fetchResponse =  await fetch(gasTrakerAPI);
                //const edata = await fetchResponse.json();   
                //var web3GasPrice = edata.result.ProposeGasPrice;
            const web3GasPrice = await myweb3.eth.getGasPrice();
            var result = await contractInstance.methods.mint(numberOfTokens).send({
                from: myAccountAddress,
                to: contractAddress,
                //gasPrice: 100,
                gasPrice: web3GasPrice,
                gasLimit: gasLimit,
                value : payableAmount,       
            });
    
            if(result){
                swal("Success !", "Successfully Minted LoadOut NFT.", "success");
                //alert('Successfully Minted NFTs.');
            }
        }
        // }else{
        //     swal("Warning !", "You can't mint more than 10 Apes.", "warning");
        // }

    });
    
    $('#tokenAmount').on('keyup keydown change', function(e){
        if ($(this).val() > 5 
            && e.keyCode !== 46
            && e.keyCode !== 8
           ) {
           e.preventDefault();     
           $(this).val(5);
        }
        if($(this).val() < 0 ){
            $(this).val(1);
        } 
    });
   
});
