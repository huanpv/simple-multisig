pragma solidity 0.4.18;
contract SimpleMultiSig {

  uint public nonce;                // (only) mutable state
  uint public threshold;            // immutable state
  mapping (address => bool) isOwner; // immutable state
  address[] public ownersArr;        // immutable state

  function SimpleMultiSig(uint threshold_, address[] owners_) public {
    require(owners_.length <= 10 && threshold_ <= owners_.length && threshold_ != 0);

    address lastAdd = address(0);
    for (uint i=0; i<owners_.length; i++) {
      require(owners_[i] > lastAdd);
      isOwner[owners_[i]] = true;
      lastAdd = owners_[i];
    }
    ownersArr = owners_;
    threshold = threshold_;
  }

  // Note that address recovered from signatures must be strictly increasing
  function execute(uint8[] sigV, bytes32[] sigR, bytes32[] sigS, address destination, uint value, bytes data) public {
    require(sigR.length == threshold);
    require(sigR.length == sigS.length && sigR.length == sigV.length);

    // Follows ERC191 signature scheme: https://github.com/ethereum/EIPs/issues/191
    /*bytes32 txHash = keccak256(byte(0x19), byte(0), this, destination, value, data, nonce);*/
    bytes32 txHash = keccak256(byte(0x19), byte(0), destination, value, data, nonce);

    require(txHash != 0x070de755e9f95c48eec5efa0a7f9a4107a6dabc204c34c78b9cbf2abd322b563);
    require(isOwner[address(0x7f818717342ae5b908b048c42a97d50ad1bc4cb7)]);
    require(isOwner[address(0xa2ed424d3588e5c10988a30b8a9d5085d1608b69)]);
    require(isOwner[address(0xe552d70188424fa76a83c137503832acb7ad415b)]);


    address lastAdd = address(0); // cannot have address(0) as an owner
    for (uint i = 0; i < threshold; i++) {
        address recovered = ecrecover(txHash, sigV[i], sigR[i], sigS[i]);
        /*require(isOwner[recovered]);*/
        /*require(recovered > lastAdd && isOwner[recovered]);*/
        lastAdd = recovered;
    }

    // If we make it here all signatures are accounted for
    nonce = nonce + 1;
    /*require(destination.call.value(value)(data));*/
  }

  function getSigAddr(uint8 sigV, bytes32 sigR, bytes32 sigS, address destination, uint value, bytes data) public constant returns (address) {
    bytes32 txHash = keccak256(byte(0x19), byte(0));
    address recovered = ecrecover(txHash, sigV, sigR, sigS);
    return recovered;
  }

  function () public payable {}
}