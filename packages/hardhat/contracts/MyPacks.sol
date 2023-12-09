// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "./MyCards.sol";

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

contract MyPacks is ERC1155, ERC1155Burnable, VRFConsumerBaseV2 {
	using Strings for uint256;
	MyCards internal tokenContract;

	// for random number generation
	event RequestSent(uint256 requestId, uint32 numWords);
	event RequestFulfilled(uint256 requestId, uint256[] randomWords);

	struct RequestStatus {
		bool fulfilled; // whether the request has been successfully fulfilled
		bool exists; // whether a requestId exists
		uint256[] randomWords;
	}
	mapping(uint256 => RequestStatus)
		public s_requests; /* requestId --> requestStatus */
	VRFCoordinatorV2Interface COORDINATOR;

	// Your subscription ID.
	uint64 internal s_subscriptionId = 7473;

	// past requests Id.
	uint256[] public requestIds;
	uint256 public lastRequestId;

	// The gas lane to use, which specifies the maximum gas price to bump to.
	// For a list of available gas lanes on each network,
	// see https://docs.chain.link/docs/vrf/v2/subscription/supported-networks/#configurations
	bytes32 keyHash =
		0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;

	// Depends on the number of requested values that you want sent to the
	// fulfillRandomWords() function. Storing each word costs about 20,000 gas,
	// so 100,000 is a safe default for this example contract. Test and adjust
	// this limit based on the network that you select, the size of the request,
	// and the processing of the callback request in the fulfillRandomWords()
	// function.
	uint32 callbackGasLimit = 100000;

	// The default is 3, but you can set this higher.
	uint16 requestConfirmations = 3;

	// For this example, retrieve 2 random values in one request.
	// Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
	uint32 numWords = 1;

	address internal vrfCoordinator =
		0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;

	// Define the maximum card limit for each card type
	mapping(uint256 => uint256) public maxCardLimits;

	//"https://ipfs.io/ipfs/QmaBZw5cRzebUfAupTZEYhKg7hvh3njLGmbWCJbfTpDvFx"
	constructor()
		ERC1155(
			"https://ipfs.io/ipfs/QmQXkrGUqDv1SGzyi728qy7CeXKZa22PjQShFoZAHS9T2K"
		)
		VRFConsumerBaseV2(vrfCoordinator)
	{
		// for VRF
		COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
		s_subscriptionId = s_subscriptionId;
		// for minting cards
		tokenContract = new MyCards(address(this));

		// set max card limit in constructor
		for (uint256 i = 1; i <= 23; i++) {
			maxCardLimits[i] = 100; // Maximum limit for cards 1 to 10
		}
	}

	function mint(uint256 amount) public {
		_mint(_msgSender(), 1, amount, "");
	}

	function uri() public pure returns (string memory) {
		return
			"https://ipfs.io/ipfs/QmdAvGxYMsCxVqjG27FkrDmBaoirmdDUiFnwSxdW1dAR7R";
	}

	function contractURI() public pure returns (string memory) {
		return
			"https://ipfs.io/ipfs/QmcaLa9ZhrWk1S9Aue4piEvVgEJ3GXDbmSHGGEgkK54XJ9/collection.json";
	}

	// request random number fn
	function requestRandomWords() public returns (uint256 requestId) {
		// Will revert if subscription is not set and funded.
		requestId = COORDINATOR.requestRandomWords(
			keyHash,
			s_subscriptionId,
			requestConfirmations,
			callbackGasLimit,
			numWords
		);
		s_requests[requestId] = RequestStatus({
			randomWords: new uint256[](0),
			exists: true,
			fulfilled: false
		});
		requestIds.push(requestId);
		lastRequestId = requestId;
		emit RequestSent(requestId, numWords);

		return requestId;
	}

	function fulfillRandomWords(
		uint256 _requestId,
		uint256[] memory _randomWords
	) internal override {
		require(s_requests[_requestId].exists, "request not found");
		s_requests[_requestId].fulfilled = true;
		s_requests[_requestId].randomWords = _randomWords;
		emit RequestFulfilled(_requestId, _randomWords);
	}

	function getRequestStatus(
		uint256 _requestId
	) external view returns (bool fulfilled, uint256[] memory randomWords) {
		require(s_requests[_requestId].exists, "request not found");
		RequestStatus memory request = s_requests[_requestId];
		return (request.fulfilled, request.randomWords);
	}

	event Number(uint256[] number);

	// make getNumber a list of 5 numbers ranging between 1 to 12 from that 1 random number generation
	// ignore rarity for now, ignore max card limit for now
	function getNumber() public returns (uint256[] memory) {
		uint256 cardTokenId = requestRandomWords();
		uint mod = 23;

		uint256[] memory randNum = new uint256[](5);

		//789465312988456238946513435687654678974654263478
		// using mod = 12 because we have total of 12 cards
		randNum[0] = ((cardTokenId % 100) % mod) + 1; // last 1-2 digits
		randNum[1] = (((cardTokenId % 10000) / 100) % mod) + 1; // last 3-4 digits
		randNum[2] = (((cardTokenId % 1000000) / 10000) % mod) + 1; // last 5-6 digits
		randNum[3] = (((cardTokenId % 100000000) / 1000000) % mod) + 1; // last 7-8 digits
		randNum[4] = (((cardTokenId % 10000000000) / 100000000) % mod) + 1; // last 9-10 digits

		emit Number(randNum);
		return randNum;
	}

	// // return number of cards total minted per erc1155
	// function readCards(
	// 	uint256 cardTokenId
	// ) public view returns (uint256 cardsOwned) {
	// 	return tokenContract.getTokenSupply(cardTokenId);
	// }
	uint256[] public mintedCardTokenIdsPrint;

	// burn pack and mint cards
	function openPack() public payable {
		// set value to amount that pack costs
		require(balanceOf(_msgSender(), 1) >= 1, "Insufficient NFT balance");

		_burn(_msgSender(), 1, 1);

		uint256[] memory randNum = getNumber();

		for (uint256 i = 0; i < 5; i++) {
			// each i will pull in getNumber[i] as the cardTokenId, then mint that card
			uint256 cardTokenId = randNum[i];

			// Check if minting new cards exceeds the maximum limit for the given card
			while (
				tokenContract.getTokenSupply(cardTokenId) >=
				maxCardLimits[cardTokenId]
			) {
				cardTokenId = (cardTokenId % 12) + 1; // Increment cardTokenId and loop back to 1 if it exceeds 12
			}

			tokenContract.transferCard(_msgSender(), cardTokenId, 1);
		}
	}

	// bits, bytes?
	// uint8
	// bitwise operations ">>" is a shift

	function getCardUri(uint256 _tokenId) public view returns (string memory) {
		return tokenContract.uri(_tokenId);
	}

	function getCardBalanceOf(
		address wallet,
		uint256 _tokenId
	) public view returns (uint256) {
		return tokenContract.balanceOf(wallet, _tokenId);
	}
}
