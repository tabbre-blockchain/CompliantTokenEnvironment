pragma solidity ^0.4.18;

import './ComplianceService.sol';

/**
 * TestComplianceService is a ComplianceService meant for testing purposes.
 * It returns check() reason codes based on the amount of the transaction.
 */
contract TestComplianceService is ComplianceService  {
  uint8 constant private SUCCESS = 0;  /* 0 <= AMOUNT < 10 */
  uint8 constant private ELOCKED = 1;  /* 10 <= AMOUNT < 20 */
  uint8 constant private EDIVIS = 2;   /* 20 <= AMOUNT < 30 */
  uint8 constant private ESEND = 3;    /* 30 <= AMOUNT < 40 */
  uint8 constant private ERECV = 4;    /* 40 <= AMOUNT < 50 */

  /**
   * @notice Checks whether or not a trade should be approved by checking the trade amount
   *
   * @param  _token The address of the token to be transfered
   * @param  _spender The address of the spender of the token (unused in this implementation)
   * @param  _from The address of the sender account
   * @param  _to The address of the receiver account
   * @param  _amount The quantity of the token to trade
   *
   * @return `true` if the trade should be approved and `false` if the trade should not be approved
   */
  function check(address _token, address _spender, address _from, address _to, uint256 _amount) public returns (uint8) {
    if (_amount >= 10 && _amount < 20) {
      return ELOCKED;
    }
    else if (_amount >= 20 && _amount < 30) {
      return EDIVIS;
    }
    else if (_amount >= 30 && _amount < 40) {
      return ESEND;
    }
    else if (_amount >= 40 && _amount < 50) {
      return ERECV;
    }
    return SUCCESS;
  }
}
