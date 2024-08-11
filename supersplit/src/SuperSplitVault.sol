// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/interfaces/IERC4626.sol";
import "./IYieldStrategy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Interface for the yield strategy

contract SuperSplitVault is ERC20, IERC4626, Ownable {
    using SafeERC20 for IERC20;
    using Math for uint256;

    IERC20 private immutable _asset;
    IYieldStrategy public yieldStrategy;
    uint8 private immutable _underlyingDecimals;

    struct DebtEntry {
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => DebtEntry[]) public memberDebts;
    address[] private _members;

    constructor(IERC20 asset_, IYieldStrategy yieldStrategy_) ERC20("SuperSplitVault Shares", "SSVS") {
        (bool success, uint8 assetDecimals) = _tryGetAssetDecimals(asset_);
        _underlyingDecimals = success ? assetDecimals : 18;
        _asset = asset_;
        yieldStrategy = yieldStrategy_;
    }

    // Deposit assets and mint shares
    function deposit(uint256 assets, address receiver) public virtual returns (uint256) {
        uint256 shares = previewDeposit(assets);
        _deposit(_msgSender(), receiver, assets, shares);
        _addMember(receiver);
        return shares;
    }

    // Mint shares by depositing assets
    function mint(uint256 shares, address receiver) public virtual returns (uint256) {
        uint256 assets = previewMint(shares);
        _deposit(_msgSender(), receiver, assets, shares);
        _addMember(receiver);
        return assets;
    }

    // Withdraw assets by burning shares
    function withdraw(uint256 assets, address receiver, address owner) public virtual returns (uint256) {
        uint256 shares = previewWithdraw(assets);
        _withdraw(_msgSender(), receiver, owner, assets, shares);
        return shares;
    }

    // Redeem shares for assets
    function redeem(uint256 shares, address receiver, address owner) public virtual returns (uint256) {
        uint256 assets = previewRedeem(shares);
        _withdraw(_msgSender(), receiver, owner, assets, shares);
        return assets;
    }

    // Issue a new debt entry for a member
    function issueDebt(address member, uint256 amount) external onlyOwner {
        DebtEntry memory debt = DebtEntry({
            amount: amount,
            timestamp: block.timestamp
        });
        memberDebts[member].push(debt);
        // Mint corresponding debt shares
        _mint(member, convertToShares(amount));
        _addMember(member);
    }

    // Handle FIFO settlement of debts
    function settleDebts(address member) external onlyOwner {
        DebtEntry[] storage debts = memberDebts[member];
        uint256 totalDebt = 0;

        for (uint256 i = 0; i < debts.length; i++) {
            if (debts[i].amount > 0) {
                uint256 sharesToBurn = convertToShares(debts[i].amount);
                _burn(member, sharesToBurn);

                totalDebt += debts[i].amount;
                debts[i].amount = 0;
            }
        }

        SafeERC20.safeTransfer(_asset, member, totalDebt);
    }

    // Distribute excess liquidity after settlement
    function distributeExcessLiquidity() external onlyOwner {
        uint256 assetsTotal = totalAssets();
        for (uint256 i = 0; i < _members.length; i++) {
            address member = accountAtIndex(i);
            uint256 positiveBalance = balanceOf(member);
            if (positiveBalance > 0) {
                uint256 returnAmount = convertToAssets(positiveBalance);
                SafeERC20.safeTransfer(_asset, member, returnAmount);
            }
        }
    }

    // Helpers for conversions and total assets
    function convertToShares(uint256 assets) public view virtual returns (uint256) {
        return assets.mulDiv(totalSupply() + 10 ** _underlyingDecimals, totalAssets() + 1, Math.Rounding.Floor);
    }

    function convertToAssets(uint256 shares) public view virtual returns (uint256) {
        return shares.mulDiv(totalAssets() + 1, totalSupply() + 10 ** _underlyingDecimals, Math.Rounding.Floor);
    }

    function totalAssets() public view virtual returns (uint256) {
        return yieldStrategy.totalAssets() + _asset.balanceOf(address(this));
    }

    function accountAtIndex(uint256 index) internal view returns (address) {
        return _members[index];
    }

    function _tryGetAssetDecimals(IERC20 asset_) private view returns (bool, uint8) {
        (bool success, bytes memory encodedDecimals) = address(asset_).staticcall(
            abi.encodeCall(IERC20Metadata.decimals, ())
        );
        if (success && encodedDecimals.length >= 32) {
            uint256 returnedDecimals = abi.decode(encodedDecimals, (uint256));
            if (returnedDecimals <= type(uint8).max) {
                return (true, uint8(returnedDecimals));
            }
        }
        return (false, 0);
    }

    function _deposit(address caller, address receiver, uint256 assets, uint256 shares) internal virtual {
        SafeERC20.safeTransferFrom(_asset, caller, address(this), assets);
        yieldStrategy.deposit(assets); // Deposit into the yield strategy
        _mint(receiver, shares);
        emit Deposit(caller, receiver, assets, shares);
    }

    function _withdraw(address caller, address receiver, address owner, uint256 assets, uint256 shares) internal virtual {
        if (caller != owner) {
            _spendAllowance(owner, caller, shares);
        }
        yieldStrategy.withdraw(assets); // Withdraw from the yield strategy
        _burn(owner, shares);
        SafeERC20.safeTransfer(_asset, receiver, assets);
        emit Withdraw(caller, receiver, owner, assets, shares);
    }

    function _addMember(address member) internal {
        if (!_isMember(member)) {
            _members.push(member);
        }
    }

    function _isMember(address member) internal view returns (bool) {
        for (uint256 i = 0; i < _members.length; i++) {
            if (_members[i] == member) {
                return true;
            }
        }
        return false;
    }
}
