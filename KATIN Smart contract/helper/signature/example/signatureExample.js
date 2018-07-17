// var msg = 'Change Mint Manager to 0x7ff0F1919424F0D2B6A109E3139ae0f1d836D468 Expired 1527916874'
var msg = "Change Mint Manager to" + "0x7ff0F1919424F0D2B6A109E3139ae0f1d836D468" +"expired" + "123";
var hexFunc = web3_1.utils.sha3
// var hexFunc = web3.toHex

web3_1.eth.personal.sign(msg, USER_ADDRESS).then(sig => {
	output = sig;
    console.log(output);
    
    r = sig.slice(0, 66)
    s = '0x' + sig.slice(66, 130)
    v = '0x' + sig.slice(130, 132)
    v = web3.toDecimal(v)

    console.log('r: ' + r)
    console.log('s: ' + s)
    console.log('v: ' + v)
    var ethereumMsg = "\x19Ethereum Signed Message:\n" + msg.length + msg;
    console.log('msg hash: ' + hexFunc(ethereumMsg))
    web3_1.eth.personal.ecRecover(hexFunc(msg), sig).then( addr => {
        console.log('recover addr: ' + addr)
    });
})
