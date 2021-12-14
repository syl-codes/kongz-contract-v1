pragma solidity ^0.5.0;

contract BurnNMint {

  address private _oldKongzContract;
  address private _newKongzContract;

  event MigrateKongz(address kongz, uint256 count);

  constructor (address oldKongzContract, address newKongzContract) public {
    _oldKongzContract = oldKongzContract;
    _newKongzContract = newKongzContract;
  }

  function migrateKongz(uint kongzId) public {

    bool success = true;
    bytes memory data = "";

    //Check Owner
    (success, data) = _oldKongzContract.call(abi.encodeWithSignature("ownerOf(uint256)", kongzId));
    if(!success){
      revert();
    }
    address holder = abi.decode(data, (address));

    require(msg.sender == holder, "Not allowed");

    //Mint First
    string memory metadata = string(abi.encodePacked("https://themetakongz.com/kongz/metadata/", uint2str(kongzId),".json"));
    (success, data) = _newKongzContract.call(
        abi.encodeWithSignature(
          "mintWithTokenURI(address,uint256,string)", msg.sender, kongzId, metadata));
    if(!success){
      revert();
    }

    //Burn Later
    (success, data) = _oldKongzContract.call(abi.encodeWithSignature("burn(uint256)", kongzId));
    if(!success){
      revert();
    }

    emit MigrateKongz(msg.sender, kongzId);
  }

  function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
    if (_i == 0) {
      return "0";
    }
    uint j = _i;
    uint len;
    while (j != 0) {
      len++;
      j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint k = len - 1;
    while (_i != 0) {
      bstr[k--] = byte(uint8(48 + _i % 10));
      _i /= 10;
    }
    return string(bstr);
  }
}
