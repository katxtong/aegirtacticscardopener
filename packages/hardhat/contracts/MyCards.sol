// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./MyPacks.sol";

contract MyCards is ERC1155, AccessControlEnumerable {
	using Strings for uint256;

	address private _owner;
	// uint256 public constant CARD = 0;

	bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

	MyPacks private tokenPackContract;

	mapping(uint256 => uint256) private tokenSupply;
	mapping(address => mapping(uint256 => uint256)) private _balances;

	// to map integer to string for minting
	mapping(uint256 => string) public integerToStringMapping;

	// Function to add a key-value pair to the mapping
	function addMappingValue(uint256 key, string memory value) public {
		integerToStringMapping[1] = "Name";
	}

	// can be https://ipfs.io/ipfs/HASH_HERE/{id}.json
	// palpacas are "https://ipfs.io/ipfs/QmRsErR16gbdRjGPqoRLCkBftgrVi4PfDZRkfvZmvtaR6Y/{id}.json"
	constructor(
		address packAddress
	)
		ERC1155(
			"https://ipfs.io/ipfs/QmcaLa9ZhrWk1S9Aue4piEvVgEJ3GXDbmSHGGEgkK54XJ9/{id}.json"
		)
	{
		_owner = msg.sender;
		_grantRole(MINTER_ROLE, packAddress);
		tokenPackContract = MyPacks(packAddress);
	}

	// Override the URI function to provide token-specific metadata
	function uri(
		uint256 _tokenId
	) public pure override returns (string memory) {
		return
			string(
				abi.encodePacked(
					"https://ipfs.io/ipfs/QmcaLa9ZhrWk1S9Aue4piEvVgEJ3GXDbmSHGGEgkK54XJ9/",
					_tokenId.toString(),
					".json"
				)
			);
	}

	function contractURI() public pure returns (string memory) {
		return
			"https://ipfs.io/ipfs/QmcaLa9ZhrWk1S9Aue4piEvVgEJ3GXDbmSHGGEgkK54XJ9/collection.json";
	}

	// allows transfer of contracts
	// check that user owns the nft, then allow transffer?
	function transferCard(
		// return 5 erc1155 that we minted
		address to,
		uint256 cardTokenId,
		uint256 cardAmount
	) public virtual {
		require(
			hasRole(MINTER_ROLE, _msgSender()),
			"ERROR_UNAUTHORIZED_MINTER"
		);

		// Increment the tokenSupply for the given card
		tokenSupply[cardTokenId] += cardAmount;

		_mint(to, cardTokenId, cardAmount, "");

		_balances[to][cardTokenId] += cardAmount;
		// safeTransferFrom(_owner, to, cardTokenId, cardAmount, "");
	}

	function getTokenSupply(uint256 cardTokenId) public view returns (uint256) {
		return tokenSupply[cardTokenId];
	}

	function supportsInterface(
		bytes4 interfaceId
	)
		public
		view
		virtual
		override(AccessControlEnumerable, ERC1155)
		returns (bool)
	{
		return super.supportsInterface(interfaceId);
	}

	function balanceOf(
		address account,
		uint256 id
	) public view override returns (uint256) {
		return _balances[account][id];
	}

	function safeTransferFrom(
		address from,
		address to,
		uint256 id,
		uint256 amount
	) public virtual {
		require(
			_msgSender() == from || isApprovedForAll(from, _msgSender()),
			"ERC1155: caller is not owner nor approved"
		);
		require(to != address(0), "ERC1155: transfer to the zero address");

		uint256 fromBalance = _balances[from][id];
		require(
			fromBalance >= amount,
			"ERC1155: insufficient balance for transfer"
		);
		_balances[from][id] = fromBalance - amount;
		_balances[to][id] += amount;

		emit TransferSingle(_msgSender(), from, to, id, amount);
	}

	function safeBatchTransferFrom(
		address from,
		address to,
		uint256[] memory ids,
		uint256[] memory amounts
	) public virtual {
		require(
			_msgSender() == from || isApprovedForAll(from, _msgSender()),
			"ERC1155: caller is not owner nor approved"
		);
		require(to != address(0), "ERC1155: transfer to the zero address");
		require(
			ids.length == amounts.length,
			"ERC1155: ids and amounts length mismatch"
		);

		for (uint256 i = 0; i < ids.length; ++i) {
			uint256 id = ids[i];
			uint256 amount = amounts[i];

			uint256 fromBalance = _balances[from][id];
			require(
				fromBalance >= amount,
				"ERC1155: insufficient balance for transfer"
			);
			_balances[from][id] = fromBalance - amount;
			_balances[to][id] += amount;
		}

		emit TransferBatch(_msgSender(), from, to, ids, amounts);
	}
}
