// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract N11 is Ownable, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => uint256) _lastTime;

    uint256 private _interestAccrualPeriod;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor() Ownable() {
        _name = 'Number 11';
        _symbol = 'N11';
        _mint(msg.sender, 100 ether);
        setInterestAccrualPeriod(60);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function percentPerDay() public pure returns (uint8) {
        return 10;
    }

    function interestAccrualPeriod() public view returns (uint256) {
        return _interestAccrualPeriod;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account] + _earned(account);
    }

    function realBalanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function earned(address account) public view returns (uint256) {
        return _earned(account);
    }

    function lastTime(address account) public view returns (uint) {
        return _lastTime[account];
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "N11: decreased allowance below zero");
    unchecked {
        _approve(owner, spender, currentAllowance - subtractedValue);
    }
        return true;
    }

    function setInterestAccrualPeriod(uint256 timestamp) public returns (bool) {
        _checkOwner();
        require(msg.sender != address(0), "ERC20: burn from the zero address");
        _interestAccrualPeriod = timestamp;
        return true;
    }

    function burn(address account, uint256 amount) public returns (bool) {
        _checkOwner();
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account] + _earned(account);
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

    unchecked {
        _balances[account] = accountBalance - amount;
    }

        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "N11: transfer from the zero address");
        require(to != address(0), "N11: transfer to the zero address");

        uint256 fromEarned = _earned(from);
        uint256 toEarned = _earned(to);

        uint256 fromBalance = _balances[from] + fromEarned;
        uint256 toBalance = _balances[to] + toEarned;

        require(fromBalance >= amount, "N11: transfer amount exceeds balance");

    unchecked {
        _balances[from] = fromBalance - amount;
    }

        _balances[to] = toBalance + amount;

        _totalSupply += fromEarned + toEarned;

        _lastTime[from] = block.timestamp;
        _lastTime[to] = block.timestamp;

        emit Transfer(from, to, amount);
    }

    function _earned(address account) internal view returns (uint256) {
        uint256 differenceInTime = _lastTime[account] > 0 ? (block.timestamp - _lastTime[account]) / _interestAccrualPeriod : 0;
        return (((_balances[account] * 11) / 10) - _balances[account]) * differenceInTime;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "N11: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "N11: approve from the zero address");
        require(spender != address(0), "N11: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "N11: insufficient allowance");
        unchecked {
            _approve(owner, spender, currentAllowance - amount);
        }
        }
    }
}
