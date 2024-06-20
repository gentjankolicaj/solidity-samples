pragma solidity ^0.8.5;

interface ICrud {
    struct User {
        uint256 userId;
        address wallet;
        string username;
        string password;
    }

    function create(address wallet, string memory username, string memory password) external;

    function read(uint256 userId) external view returns (User memory);

    function update(uint256 userId, address newWallet, string memory newUsername, string memory newPassword) external;

    function destroy(uint256 userId) external; //destroy name because delete is reseved keyword

    function find(uint256 userId) external view returns (uint256);

    function findAll() external view returns (User[] memory);


}
