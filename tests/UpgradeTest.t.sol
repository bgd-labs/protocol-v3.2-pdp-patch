// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, IPool, IPoolDataProvider, IPoolAddressesProvider, IERC20} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {UpgradePayload} from '../src/contracts/UpgradePayload.sol';

abstract contract UpgradeTest is ProtocolV3TestBase {
  string public NETWORK;
  uint256 public immutable BLOCK_NUMBER;
  UpgradePayload public payload;

  constructor(string memory network, uint256 blocknumber) {
    NETWORK = network;
    BLOCK_NUMBER = blocknumber;
  }

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl(NETWORK), BLOCK_NUMBER);
    payload = UpgradePayload(_getPayload());
  }

  function test_execution() external {
    UpgradePayload payload = UpgradePayload(_getTestPayload());
    executePayload(vm, address(payload));
    IPoolAddressesProvider addressesProvider = UpgradePayload(payload).POOL_ADDRESSES_PROVIDER();
    address stableMock = addressesProvider.getAddress(bytes32('MOCK_STABLE_DEBT'));
    require(stableMock != address(0));
    // checking non revert
    IERC20(stableMock).totalSupply();
    IERC20(stableMock).balanceOf(address(0));
  }

  function test_outdatedPdp() external {
    UpgradePayload payload = UpgradePayload(_getTestPayload());
    IPoolAddressesProvider addressesProvider = payload.POOL_ADDRESSES_PROVIDER();
    IPool pool = IPool(addressesProvider.getPool());
    address[] memory reserves = pool.getReservesList();
    for (uint256 i = 0; i < reserves.length; i++) {
      IPoolDataProvider pdp = IPoolDataProvider(_getDeprecatedPDP());
      vm.expectRevert();
      pdp.getReserveData(reserves[i]);
      vm.expectRevert();
      pdp.getTotalDebt(reserves[i]);
      vm.expectRevert();
      pdp.getUserReserveData(reserves[i], address(0));
    }
    executePayload(vm, address(payload));
    for (uint256 i = 0; i < reserves.length; i++) {
      IPoolDataProvider pdp = IPoolDataProvider(_getDeprecatedPDP());
      pdp.getReserveData(reserves[i]);
      pdp.getTotalDebt(reserves[i]);
      pdp.getUserReserveData(reserves[i], address(0));
    }
  }

  function test_diff() external {
    UpgradePayload payload = UpgradePayload(_getTestPayload());
    IPoolAddressesProvider addressesProvider = payload.POOL_ADDRESSES_PROVIDER();
    IPool pool = IPool(addressesProvider.getPool());
    defaultTest(
      string(abi.encodePacked(vm.toString(block.chainid), '_', vm.toString(address(pool)))),
      pool,
      address(payload)
    );
  }

  function _getTestPayload() internal returns (address) {
    return _getDeployedPayload();
  }

  function _getPayload() internal virtual returns (address);

  function _getDeployedPayload() internal virtual returns (address);

  function _getDeprecatedPDP() internal virtual returns (address);
}
