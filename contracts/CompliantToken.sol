pragma solidity ^0.4.18;

import 'zeppelin-solidity/DetailedERC20.sol';
import 'zeppelin-solidity/MintableToken.sol';
import './ServiceRegistry.sol';
import './ComplianceService.sol';

/// @notice An ERC-20 token that has the ability to check for trade validity
contract CompliantToken is DetailedERC20, MintableToken {

  /**
   * @notice R-Token decimals setting (used when constructing DetailedERC20)
   */
  uint8 constant public CTE_DECIMALS = 18;

  /**
   * @notice Triggered when regulator checks pass or fail
   */
  event CheckStatus(uint8 reason, address indexed spender, address indexed from, address indexed to, uint256 value);

  /**
   * @notice Address of the `ServiceRegistry` that has the location of the
   *         `RegulatorService` contract responsible for checking trade
   *         permissions.
   */
  ServiceRegistry public registry;

  /**
   * @notice Constructor
   *
   * @param _registry Address of `ServiceRegistry` contract
   * @param _name Name of the token: See DetailedERC20
   * @param _symbol Symbol of the token: See DetailedERC20
   */
  function CompliantToken(ServiceRegistry _registry, string _name, string _symbol) public
    DetailedERC20(_name, _symbol, CTE_DECIMALS)
  {
    require(_registry != address(0));

    registry = _registry;
  }

  /**
   * @notice ERC-20 overridden function that include logic to check for trade validity.
   *
   * @param _to The address of the receiver
   * @param _value The number of tokens to transfer
   *
   * @return `true` if successful and `false` if unsuccessful
   */
  function transfer(address _to, uint256 _value) public returns (bool) {
    if (_check(msg.sender, _to, _value)) {
      return super.transfer(_to, _value);
    } else {
      return false;
    }
  }

  /**
   * @notice ERC-20 overridden function that include logic to check for trade validity.
   *
   * @param _from The address of the sender
   * @param _to The address of the receiver
   * @param _value The number of tokens to transfer
   *
   * @return `true` if successful and `false` if unsuccessful
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    if (_check(_from, _to, _value)) {
      return super.transferFrom(_from, _to, _value);
    } else {
      return false;
    }
  }

  /**
   * @notice Performs the regulator check
   *
   * @dev This method raises a CheckStatus event indicating success or failure of the check
   *
   * @param _from The address of the sender
   * @param _to The address of the receiver
   * @param _value The number of tokens to transfer
   *
   * @return `true` if the check was successful and `false` if unsuccessful
   */
  function _check(address _from, address _to, uint256 _value) private returns (bool) {
    var reason = _service().check(this, msg.sender, _from, _to, _value);

    CheckStatus(reason, msg.sender, _from, _to, _value);

    return reason == 0;
  }

  /**
   * @notice Retreives the address of the `RegulatorService` that manages this token.
   *
   * @dev This function *MUST NOT* memoize the `RegulatorService` address.  This would
   *      break the ability to upgrade the `RegulatorService`.
   *
   * @return The `RegulatorService` that manages this token.
   */
  function _service() constant public returns (RegulatorService) {
    return ComlianceService(registry.service());
  }
}
