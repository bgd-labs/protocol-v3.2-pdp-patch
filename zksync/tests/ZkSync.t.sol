// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {UpgradeTest} from './UpgradeTest.t.sol';
import {DeploymentLibrary} from '../scripts/Deploy.s.sol';
import {Payloads} from '../../tests/Payloads.sol';

contract ZkSyncTest is UpgradeTest('zksync', 46219715) {
  function _getPayload() internal virtual override returns (address) {
    return DeploymentLibrary._deployZKSync();
  }

  function _getDeployedPayload() internal virtual override returns (address) {
    return Payloads.ZKSYNC;
  }

  function _getDeprecatedPDP() internal virtual override returns (address) {
    return address(0x48B96565291d1B23a014bb9f68E07F4B2bb3Cd6D);
  }
}
