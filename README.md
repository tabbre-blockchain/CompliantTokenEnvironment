# Compliant Token Environment (CTE)

Smart Contracts for applying regulatory compliance to tokenized securities issuance and trading

## Description

CTE is a permissioned token on the Ethereum blockchain, enabling token transfers to occur if and only if they are approved by an on-chain Compliance Service. The Compliance Service can be configured to meet relevant securities regulations, Know Your Customer (KYC) policies, Anti-Money Laundering (AML) requirements, tax laws, and more. Implemented with the correct configurations, the CTE standard makes compliant transfers possible, both on exchanges and person to person, in ICOs and secondary trades, and across jurisdictions. CTE enables ERC-20 tokens to be used for regulated securities.

## How It Works

CTE implements ERC-20 methods `transfer()` and `transferFrom()` with an additional check to determine whether or not a transfer should be allowed to proceed. The implementation of `check()` can take many forms, but a default whitelist approach is implemented by `ComplianceService`. Token and participant-level permissions, when used in different combinations, can be used to satisfy multiple regulatory exemptions. The `ServiceRegistry` is included as a mechanism to facilitate upgrading the CTE check logic as rules change over time.

## Components

* CompliantToken
  * Permissioned ERC-20 smart contract representing ownership of securities
  * Compatible with existing wallets and exchanges that support the ERC-20 token standard
  * Overrides the existing ERC-20 transfer method to check with an on-chain Compliance Service for trade approval
* ComplianceService
  * Contains the permissions necessary for regulatory compliance
  * Relies on off-chain trade approver to set and update permissions
* ServiceRegistry
  * Accounts for regulatory requirement changes over time
  * Routes the CTE to the correct version of the Compliance Service

<p align="center">
  <img src="https://raw.githubusercontent.com/tabbre-blockchain/CompliantTokenEnvironment/main/documents/component-diagram.jpg" width="500">
</p>




## Features

Upgradable, token-level trade permission and participant-level trade permissions.

* Configurable without code modification and need for more security auditing
* Upgradable so an owner/admin can change business logic as rules evolve over time
* An owner/admin can lock/unlock trading for a period of time
* An owner/admin can whitelist/blacklist partial token transfers
* An owner/admin can qualify/disqualify a trade participant from sending tokens
* An owner/admin can qualify/disqualify a trade participant from receiving tokens

### Upgradable

The `ServiceRegistry` is used to point many `CompliantToken` smart contracts to a single `ComplianceService`. This setup is recommended so that rules and logic implemented by the `ComplianceService` can be upgraded by changing a single `ComplianceService` address held by the `ServiceRegistry`.

<p align="center">
  <img src="https://raw.githubusercontent.com/tabbre-blockchain/CompliantTokenEnvironment/main/documents/Upgrade.jpg" width="500">
</p>



When `ComplianceService` logic needs to be updated, the migration path resembles a process like this:

1. Deploy new ComplianceService (V2)
2. Copy required state from Regulator Service V1 to ComplianceService V2
3. Call `replaceService()` on `ServiceRegistry` with address pointing to ComplianceService V2

### Token/Participant Level Permissions

In the `TokenComplianceService` implementation of the `ComplianceService` interface, there are token level permissions and participant level permissions. These permissions should be updated by an off-chain process like shown below:

<p align="center">
  <img src="https://raw.githubusercontent.com/tabbre-blockchain/CompliantTokenEnvironment/main/documents/Permissions.jpg" width="500">
</p>


Token-level permissions include:

* `locked` - controls locking and unlocking of all token trades for a particular token
* `partialAmounts` - allows or disallows transfers of partial token amounts

Participant-level permissions include:

* `PERM_SEND` - permission for a participant to send a token to another account
* `PERM_RECV` - permission for a participant to receive a token from another account

## Administrative Roles / Contract Ownership

Administrative privileges on R-Token smart contracts are divided into two roles: `Owner` and `Admin`. We will continue to decentralize administration in future versions.

The privileges for each role are defined below:

|       | CompliantToken | ServiceRegistry                  | ComplianceService                                            |
| :---- | :------------- | :------------------------------- | :----------------------------------------------------------- |
| Owner | Can Mint       | Transfer Owner / Replace Service | Update Token-Level Settings / Transfer Ownership / Transfer Admin |
| Admin | N/A            | N/A                              | Update Participant-Level Settings                            |

