pragma solidity ^0.8.5;

import "./ICrud.sol";

contract Crud is ICrud {

    User[] users;
    uint256 index = 1; //this index is used as userId,incremental


    function create(address wallet, string memory username, string memory password) public override {
        User memory newUser = User(index, wallet, username, password);
        users.push(newUser);
        index++;
    }

    //Since each user has userId==users's index,this works
    function read(uint256 userId) public view override returns (User memory){
        return users[userId];
    }


    function update(uint256 userId, address newWallet, string memory newUsername, string memory newPassword) public override {
        User storage user = users[userId];
        user.wallet = newWallet;
        user.username = newUsername;
        user.password = newPassword;
    }

    function destroy(uint256 userId) public override {
        delete users[userId];
        //deletes element in array by replacing it with default value,for struct default value is (All fields default since solidity dosen't have null | nil)
    }


    function find(uint256 userId) public view override returns (uint256){
        for (uint256 i = 0; i < users.length; i++) {
            if (users[i].userId == userId) {
                return userId;
            }
        }

        revert('User does not exist!');
    }


    function findAll() public view override returns (User[] memory){
        return users;
    }


}