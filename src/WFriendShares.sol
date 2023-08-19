pragma solidity 0.8.19;

import "solmate/tokens/ERC1155.sol";

interface IFriendShares {
    function buyShares(address, uint256) external payable;
    function sellShares(address, uint256) external payable;
}

contract WFriendShares is ERC1155 {
    IFriendShares immutable friendShares;

    constructor(address _friendShares) {
        friendShares = IFriendShares(_friendShares);
    }

    function uri(uint256 /* id */) public pure override returns (string memory) {
        return "https://friendlend.wtf";
    }     

    function wrap(address sharesSubject, uint256 amount) external payable {
        friendShares.buyShares{value: msg.value}(sharesSubject, amount);
        _mint(msg.sender, uint160(sharesSubject), amount, "");
    }

    function unwrap(address sharesSubject, uint256 amount) external payable {
        _burn(msg.sender, uint160(sharesSubject), amount);
        friendShares.sellShares(sharesSubject, amount);
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "failed transferring funds");
    }

    receive() external payable {}
}