module.exports = function(deployer){
    deployer.deploy(CCToken, 1000000000, 'MyETH', 4, 'MY', 'Description test');
    //deployer.autolink();
    //deployer.deploy(EverTokenController);
};
