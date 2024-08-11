Overview
The SuperSplitVault contract is designed to manage a shared liquidity pool with automated yield strategies, allowing users to deposit funds, issue and settle debts, and withdraw assets. It incorporates the ERC4626 standard for tokenized vaults and provides additional functionalities tailored to group-based financial management.

Contract Features
Deposits and Withdrawals: Users can deposit USDC (or other ERC20 tokens) into the vault and receive shares representing their portion of the vault's assets. Similarly, they can redeem these shares to withdraw their funds.
Yield Strategy Integration: Deposited assets are automatically invested in a yield strategy contract to generate returns, maximizing the efficiency of the pooled funds.
Debt Management: The contract allows the issuance of debts for members, tracking the amount and time of debt issuance. Debts can be settled in a FIFO (First In, First Out) manner.
Excess Liquidity Distribution: After debts are settled, any excess liquidity in the vault can be distributed back to members with positive balances.
Interacting with the Contract
1. Deposit Funds
To deposit funds into the vault, call the deposit function.

solidity
Copy code
function deposit(uint256 assets, address receiver) public returns (uint256 shares)
assets: The amount of USDC (or other ERC20 tokens) to deposit.
receiver: The address that will receive the shares.
2. Withdraw Funds
To withdraw your assets from the vault, call the withdraw function.

solidity
Copy code
function withdraw(uint256 assets, address receiver, address owner) public returns (uint256 shares)
assets: The amount of assets to withdraw.
receiver: The address that will receive the withdrawn assets.
owner: The address that owns the shares being redeemed.
3. Issue Debt
The contract owner can issue debt to a member using the issueDebt function.

solidity
Copy code
function issueDebt(address member, uint256 amount) external onlyOwner
member: The address of the member receiving the debt.
amount: The amount of debt to issue.
4. Settle Debts
To settle a member's debt, the contract owner can call the settleDebts function.

solidity
Copy code
function settleDebts(address member) external onlyOwner
member: The address of the member whose debts will be settled.
5. Distribute Excess Liquidity
The contract owner can distribute any excess liquidity to members with positive balances by calling the distributeExcessLiquidity function.

solidity
Copy code
function distributeExcessLiquidity() external onlyOwner
Deployment and Configuration
Asset: The vault is configured to work with a specific ERC20 token (e.g., USDC).
Yield Strategy: The contract integrates with an external yield strategy, which must be specified at deployment.
Example Usage
Deposit Example
To deposit 100 USDC into the vault and receive shares:

solidity
Copy code
uint256 amount = 100 * 10**6; // USDC uses 6 decimal places
vault.deposit(amount, msg.sender);
Withdraw Example
To withdraw 50 USDC from the vault:

solidity
Copy code
uint256 amount = 50 * 10**6; // USDC uses 6 decimal places
vault.withdraw(amount, msg.sender, msg.sender);
Issuing Debt Example
To issue a debt of 200 USDC to a member:

solidity
Copy code
vault.issueDebt(memberAddress, 200 * 10**6);
Settling Debts Example
To settle all debts for a member:

solidity
Copy code
vault.settleDebts(memberAddress);
Notes
The deposit and withdraw functions interact with the underlying yield strategy, ensuring that assets are optimally managed.
All debt-related functions are restricted to the contract owner, ensuring controlled issuance and settlement.
Ensure you have a proper understanding of ERC4626 and the associated yield strategy to fully utilize this contract.
