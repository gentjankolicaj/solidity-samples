pragma solidity ^0.8.5;

interface IAdminable {

    struct Admin {
        address adminAddr;
        bool active;
        uint256 activationTime;
        address activator;
        bool expelled;
        uint256 expelledTime;
        address expeller;
    }


    function isAdmin(address account) external view returns (bool);

    function isAdminExpelled(address account) external view returns (bool);

    function isAdminActive(address account) external view returns (bool);

    function getAdminDetails(address account) external view returns (Admin memory);

    function getAdminsList(bool expelled) external view returns (address[] memory);

    function expellAdmin(address account) external returns (bool);

    function includeAdmin(address account) external returns (bool);


}