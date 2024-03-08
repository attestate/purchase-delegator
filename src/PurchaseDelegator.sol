// SPDX-License-Identifier: AGPL-3.0
// GitHub: https://github.com/attestate/checkout-portal
pragma solidity ^0.8.13;

address constant collectionLocation = 0x66747bdC903d17C586fA09eE5D6b54CC85bBEA45;
interface IERC721Drop {
  struct SaleDetails {
    bool publicSaleActive;
    bool presaleActive;
    uint256 publicSalePrice;
    uint64 publicSaleStart;
    uint64 publicSaleEnd;
    uint64 presaleStart;
    uint64 presaleEnd;
    bytes32 presaleMerkleRoot;
    uint256 maxSalePurchasePerAddress;
    uint256 totalMinted;
    uint256 maxSupply;
  }
  function adminMint(address recipient, uint256 quantity) external returns (uint256);
  function saleDetails() external view returns (SaleDetails memory);
}
address constant delegator2Location = 0x08b7ECFac2c5754ABafb789c84F8fa37c9f088B0;
interface Delegator2 {
  function etch(bytes32[3] calldata data) external;
}

address constant kiwiTreasury = 0x1337E2624ffEC537087c6774e9A18031CFEAf0a9;
contract PurchaseDelegator {
  error ErrValue();
  function getPrice() view internal returns (uint256 price) {
    IERC721Drop collection = IERC721Drop(collectionLocation);
    return collection.saleDetails().publicSalePrice;
  }
  function setup(
    uint256 quantity,
    bytes32[3] calldata data,
    string calldata comment,
    address referral
  ) external payable {
    uint256 price = getPrice();
    if (price != msg.value) revert ErrValue();

    IERC721Drop collection = IERC721Drop(collectionLocation);
    Delegator2 delegator2 = Delegator2(delegator2Location);
    collection.adminMint(msg.sender, quantity);
    delegator2.etch(data);
    kiwiTreasury.call{value: price}("");
  }
}
