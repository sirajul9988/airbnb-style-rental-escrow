const hre = require("hardhat");

async function main() {
  const Rental = await hre.ethers.getContractFactory("RentalMarketplace");
  const rental = await Rental.deploy();

  await rental.waitForDeployment();
  console.log("Rental Marketplace deployed to:", await rental.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
