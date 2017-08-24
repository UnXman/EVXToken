var EVXToken = artifacts.require("EVXToken");

module.exports = function(deployer){
    deployer.deploy(EVXToken);
};
