const Bike = artifacts.require("BikeShare");
module.exports = async function (deployer) {;
  await deployer.deploy(Bike);
  const instance2 = await Bike.deployed();

  
};
