/* global ethers */
/* eslint prefer-const: "off" */

const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')

async function deployDiamond () {
  const accounts = await ethers.getSigners()
  const contractOwner = accounts[0]
  console.log("Contract owner = ", contractOwner.address);

  // deploy DiamondCutFacet
  const DiamondCutFacet = await ethers.getContractFactory('DiamondCutFacet')
  const diamondCutFacet = await DiamondCutFacet.deploy()
  await diamondCutFacet.deployed()
  console.log('DiamondCutFacet deployed:', diamondCutFacet.address)

  // deploy Diamond
  const Diamond = await ethers.getContractFactory('Diamond')
  const diamond = await Diamond.deploy(contractOwner.address, diamondCutFacet.address)
  await diamond.deployed()
  console.log('Diamond deployed:', diamond.address)

  // deploy DiamondInit
  // DiamondInit provides a function that is called when the diamond is upgraded to initialize state variables
  // Read about how the diamondCut function works here: https://eips.ethereum.org/EIPS/eip-2535#addingreplacingremoving-functions
  const DiamondInit = await ethers.getContractFactory('DiamondInit')
  const diamondInit = await DiamondInit.deploy()
  await diamondInit.deployed()
  console.log('DiamondInit deployed:', diamondInit.address)

  // deploy facets
  console.log('')
  console.log('Deploying facets')
  const FacetNames = [
    'DiamondLoupeFacet',
    'OwnershipFacet',
    'ERC20Facet',
    // 'ERC20BatchFacet'
  ]
  const cut = []
  for (const FacetName of FacetNames) {
    const Facet = await ethers.getContractFactory(FacetName)
    const facet = await Facet.deploy()
    await facet.deployed()
    console.log(`${FacetName} deployed: ${facet.address}`)
    cut.push({
      facetAddress: facet.address,
      action: FacetCutAction.Add,
      functionSelectors: getSelectors(facet)
    });

    await verifyContract(facet, FacetName);
  }

  // upgrade diamond with facets
  console.log('')
  console.log('Diamond Cut:', cut)
  const diamondCut = await ethers.getContractAt('IDiamondCut', diamond.address)
  let tx
  let receipt
  // call to init function
  let functionCall = diamondInit.interface.encodeFunctionData('init', [
    'OmniKingdoms',
    'OKG',
    18,
    '10000000000000000000000000',
    contractOwner.address,
    contractOwner.address
  ]);
  tx = await diamondCut.diamondCut(cut, diamondInit.address, functionCall)
  console.log('Diamond cut tx: ', tx.hash)
  receipt = await tx.wait()
  if (!receipt.status) {
    throw Error(`Diamond upgrade failed: ${tx.hash}`)
  }
  console.log('Completed diamond cut')

  return diamond.address
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
  deployDiamond()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

exports.deployDiamond = deployDiamond

async function verifyContract(facet, FacetName, constructorArguments = []) {
  const liveNetworks = [
    "mainnet",
    "goerli",
    "mumbai",
    "scroll",
    "scroll_sepolia",
    "arbg",
    "fuji",
    "mantle"
  ];
  if (!liveNetworks.includes(hre.network.name)) {
    return; // Don't verify on test networks
  }

  try {
    console.log("Waiting for 10 blocks to be mined...");
    await facet.deployTransaction.wait(10);
    console.log("Running verification");
    await hre.run("verify:verify", {
      address: facet.address,
      contract: `contracts/facets/${FacetName}.sol:${FacetName}`,
      network: hardhatArguments.network,
      arguments: constructorArguments ? constructorArguments : [],
    });
  } catch (e) {
    console.log("Verification failed: ", JSON.stringify(e, null, 2));
    console.log(e);
  }
}