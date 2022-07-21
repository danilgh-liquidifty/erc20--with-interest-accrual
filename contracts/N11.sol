// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract N11 is Context, IERC20, IERC20Metadata {
    uint256 public percentPerDay = 10;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => uint256) _lastTime;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor() {
        _name = 'N11';
        _symbol = 'N11';
        _mint(msg.sender, 100000);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account] + _earned(account);
    }

    function lastTime(address account) external view returns (uint) {
        return _lastTime[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "N11: decreased allowance below zero");
    unchecked {
        _approve(owner, spender, currentAllowance - subtractedValue);
    }
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "N11: transfer from the zero address");
        require(to != address(0), "N11: transfer to the zero address");

        uint256 fromBalance = _balances[from] + _earned(from);
        uint256 toBalance = _balances[to] + _earned(to);

        require(fromBalance >= amount, "N11: transfer amount exceeds balance");
    unchecked {
        _balances[from] = fromBalance - amount;
    }
        _balances[to] = toBalance + amount;

        _lastTime[from] = block.timestamp;
        _lastTime[to] = block.timestamp;

        emit Transfer(from, to, amount);
    }

    function _calculatePercent(uint balance) internal view returns (uint256){
        uint256 result = 0;
        if (balance > 100) {
            uint256 remainder = balance % 100;
            uint256 onePercent = (balance - remainder) / 100;
            result = onePercent * percentPerDay;
        }
        return result;
    }

    function _earned(address account) internal view returns (uint256){
        uint256 balance = _balances[account];
        uint256 secondInDay = 3600 * 24;
        if (_lastTime[account] > 0) {
            uint256 differenceInSeconds = (block.timestamp - _lastTime[account]);
            uint256 remainder = differenceInSeconds % secondInDay;
            uint256 differenceInDays = uint256((differenceInSeconds - remainder) / secondInDay);
            for (uint256 i = 0; i < differenceInDays; i++) {
                balance = balance + _calculatePercent(balance);
            }
        }
        return balance - _balances[account];
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "N11: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "N11: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "N11: burn amount exceeds balance");
    unchecked {
        _balances[account] = accountBalance - amount;
    }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
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
