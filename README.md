# About The Project
This project is a pack opening tool for a decentralized card game. It uses cards from ERC1155 token standard, VRF and scaffold-eth to bring together a tool that can open packs and mint randomized cards from a new collection. 

## Inspiration
Aegir Tactic is a next generation digital card game designed to bring fairness and balance back to competitive play. The pack opener tool allows a new collection to be distributed to users at random. Users are able to buy packs and open them for the new collection's cards, this tool will be a crucial part for future deck expansion. 

My personal inspirations below also contributed to taking on this project,
1) Having been a big fan of Hearthstone, I always wanted to play a decentralized version of it and have control of my own card assets.
2) I have been invested in the NFT space and hoped to build my own collection one day by learning how to work with IPFS and smart contracts to build creative use cases. 
3) I started learning Chainlink's VRF function and hoped to work on a practical usecase with them. 

## Steps in Building Project

### Part 1 - Generate Card Pack Collection
First step, I created two contracts using OpenZeppelin wizard and gradually added custom functions. 

The two contracts MyPacks() and MyCards():
- MyPacks() contain the card packs that are minted. It currently has 1 unique token, is an ERC1155 and is burnable upon pack opening.
- MyCards() contain the cards to be minted at random when packs are opened. There are currently 23 unique tokens taken from the existing Aegir Tactic collection. These are ERC1155 and are not burnable. 

ERC1155 Packs contracts created at: https://sepolia.etherscan.io/address/0xa5d0cc939f081ac6831da23a6c12250f893989f2

Cards Collection On Opensea: https://testnets.opensea.io/collection/aegir-tactics-7

### Part 2 - Contract for Pack to Cards Exchange
After creating the two contracts, I built a function openPack() that allows users to interact with MyCards() from MyPacks() to burn a pack token and mint 5 cards into user's address. This required AccessControlEnumerable to be added and MinterRole to be given to the address calling openPack().

### Part 3 - Add Randomness in card Generation
I used subscription method for VRF to add a randum number component into pack opening to pick all 5 cards at random, allowing repeats. This was done by taking digits from the random number with mod(total number of cards) to get the list of 5 cards. In actual implementation, the team will be setting rarity and max mints per card into the logic. 

### Part 4 - Build Frontend UI
For the frontend, I chose to use scaffold-eth becase it provided a good boilerplate that did what I needed it to do. I also took elements to build the Open Pack page from SpeedRunEthereum's Challenge 0 in Minting NFTs to build the NFT display portion. Last step was adding official Aegir imaging and branding and then deploying onto Vercel. 

## Lessons Learned and Challenges Faced
This was the first NFT app that I build, I ran into many problems but also learned so much from this process. Below are a few big challenges I faced and how I overcame them. 

### Interaction Between Contracts
For the first few weeks I could not figure out how to mint or transfer a card by calling a function in MyPacks(). I tried minting all the cards first, then transfering them into MyPacks, which worked when I called the function from MyCards() but did not work outside of the contract in remix. Then I tried to mint a card from MyPacks(), which also did not work. In the end, I figured out the issue was not setting setApprovalForAll when calling from another contract, I was not aware of adding Access Control or ERC1155Receiver. I read a ton of OpenZeppelin docs, talked to various mentors, and asked/read questions on open forums which were great help in finding the solution.

### Displaying NFT Gallery
Having never coded frontend before, I did not know where to start in modifying the JS and React code from scaffold-eth template to modify the UI into what I wanted it to do. Looking through SpeedRunEthereum's nft pages, syntax and existing nft gallery examples helped me eventually figure out how I can get the address's card IDs, Json and Metadata to display on the page. Through a lot of trial and error I managed to make the Open Pack page work.

Through building this project, I feel more confident in building an end-to-end app using Solidity and how to debug issues that arise. I'm more familiar with the structure of how a contract should be set up, and how to customize a template UI to work with a specific contract. I will be working on this further for the Aegir team in the hopes this app can be used in production for future card packs!

Github link: https://github.com/katxtong/aegirtactics
Demo link: https://aegirtacticscardopener.vercel.app/
Video link: