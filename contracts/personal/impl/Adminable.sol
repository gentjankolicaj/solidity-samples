pragma solidity ^0.8.5;

import "../interfaces/IAdminable.sol";

contract Adminable is IAdminable {

    Admin[] admins;

    //Admin max number
    uint256 adminNumber = 56;

    //Interval during which admin is allowed to expell another admin.
    uint256 adminExpellInterval = 5;

    //interval during which admin is allowed to add another admin.
    uint256 adminIncludeInterval = 5;

    //24*60*60 a normal day,but can also be adjusted for testing
    uint256 dayToSeconds = 5;


    event AdminAdded(address indexed activator, address indexed account);
    event AdminRemoved(address indexed expeller, address indexed account);



    constructor () {

        //First admin is the admin that creates the contract
        address admin = msg.sender;

        //Create new admin details
        Admin memory newAdmin = Admin(admin, true, block.timestamp, admin, false, 0, address(0));

        //Store new admin details
        admins.push(newAdmin);

        emit AdminAdded(admin, admin);
    }

    //===========================================================================
    //Admin functions
    //===========================================================================

    /**
     * @dev
     * Check if account passed is in admins array
     *
     */
    function isAdmin(address account) public view override returns (bool){
        for (uint256 i = 0; i < admins.length; i++) {
            Admin memory tmp = admins[i];
            if (tmp.adminAddr == account) {
                return true;
            }
        }
        return false;
    }

    /**
     *
     * @dev
     *
     * Checks if admin is expelled
     *
     */
    function isAdminExpelled(address account) public view override returns (bool){
        for (uint256 i = 0; i < admins.length; i++) {
            Admin memory tmp = admins[i];
            if (tmp.adminAddr == account && tmp.expelled == true) {
                return true;
            }
        }
        return false;
    }

    /**
     *
     * @dev
     *
     * Checks if admin is active
     *
     */
    function isAdminActive(address account) public view override returns (bool){
        for (uint256 i = 0; i < admins.length; i++) {
            Admin memory tmp = admins[i];
            if (tmp.adminAddr == account && tmp.active == true) {
                return true;
            }
        }
        return false;
    }

    /**
     *
     * If address is an admin ,get admin details
     */
    function getAdminDetails(address account) public view override returns (Admin memory){
        Admin memory adminDetails;
        for (uint256 i = 0; i < admins.length; i++) {
            Admin memory tmp = admins[i];
            if (tmp.adminAddr == account) {
                adminDetails = tmp;
            }
        }
        return adminDetails;
    }

    /**
      *
      * Returns an array of admin addresses based on the flag.
      *
      */
    function getAdminsList(bool expelled) public view override returns (address[] memory){
        address[] memory array = new address[](admins.length);

        if (expelled) {
            uint256 lastIndex = 0;
            for (uint256 i = 0; i < admins.length; i++) {
                Admin memory tmp = admins[i];
                if (tmp.expelled == true) {
                    array[lastIndex] = tmp.adminAddr;
                    lastIndex++;
                }
            }
        } else {
            uint256 lastIndex = 0;
            for (uint256 i = 0; i < admins.length; i++) {
                Admin memory tmp = admins[i];
                if (tmp.expelled == false) {
                    array[lastIndex] = tmp.adminAddr;
                    lastIndex++;
                }
            }
        }
        return array;
    }

    /**
    * Converts passed seconds to days
    */
    function _getDaysPassed(uint256 startTime) internal view returns (uint256){
        uint256 passedSeconds = block.timestamp - startTime;
        return passedSeconds / dayToSeconds;
    }

    /**
     *
     * @dev & all
     *
     * Since new admins are to be included(added) from other active admins,we can't be totally sure of their intentions.
     * Based on this, current admins must have the tool to remove these malicious admins.
     * Active admins are allowed to expell other admins (once in 5 days).
     * In order to avoid any abuse with expell, an active admin can expell 1 admin in adminExpellInterval.
     * adminExpellInterval  delay gives other existing admins time to check the intention of the admin that performed the expell.
     *
     */
    function _isAdminActiveAndAllowedToExpell(address account) internal view returns (bool){
        bool isActive = false;
        bool isAllowed = false;
        for (uint256 i = 0; i < admins.length; i++) {
            Admin memory tmp = admins[i];
            if (tmp.adminAddr == account && tmp.active == true) {
                isActive = true;
                break;
            }
        }

        require(isActive, "Admin: admin must be active in order to perform expell.");


        uint256 lastExpelledTime = 0;
        for (uint256 i = 0; i < admins.length; i++) {
            Admin memory tmp = admins[i];
            if ((tmp.expeller == account) && (lastExpelledTime < tmp.expelledTime)) {
                lastExpelledTime = tmp.expelledTime;
            }
        }

        uint256 daysPassed = _getDaysPassed(lastExpelledTime);
        require(daysPassed >= adminExpellInterval, "Admin: admin can't perform expell because time interval has not passed.");
        isAllowed = true;

        return isAllowed;
    }

    /**
      *
      * @dev & all
      *
      * Since new admins are to be included(added) from other active admins,we can't be totally sure of their intentions.
      * Based on this, current admins must be restrinced with intervals.
      * Active admins are allowed to include other admins (once in 5 days).
      * In order to avoid any abuse with include, an active admin can include 1 admin in adminIncludeInterval.
      * adminIncludeInterval delay gives other existing admins time to check the intention of the admin that performed the include.
      *
      */
    function _isAdminActiveAndAllowedToInclude(address account) internal view returns (bool){
        bool isActive = false;
        bool isAllowed = false;
        for (uint256 i = 0; i < admins.length; i++) {
            Admin memory tmp = admins[i];
            if (tmp.adminAddr == account && tmp.active == true) {
                isActive = true;
                break;
            }
        }

        require(isActive, "Admin: admin must be active in order to perform include.");


        uint256 lastIncludedTime = 0;
        for (uint256 i = 0; i < admins.length; i++) {
            Admin memory tmp = admins[i];
            if ((tmp.activator == account) && (lastIncludedTime < tmp.activationTime)) {
                lastIncludedTime = tmp.activationTime;
            }
        }

        uint256 daysPassed = _getDaysPassed(lastIncludedTime);
        require(daysPassed >= adminIncludeInterval, "Admin: admin can't perform include because time interval has not passed.");
        isAllowed = true;

        return isAllowed;
    }

    /**
     *
     * This function adds an admin.
     *
     */
    function includeAdmin(address account) public onlyAdminsAllowedToInclude override returns (bool){

        //Checks if it is allowed to add more admins
        uint256 adminCounter = admins.length;
        require(adminCounter <= adminNumber, "Admin: Can not have more than admin number.");

        //Check if new admin exists
        bool existsAdmin = isAdmin(account);
        require(existsAdmin == false, "Admin: Can not add new admin because it already exists.");

        address activator = msg.sender;

        //Create new admin details
        Admin memory newAdmin = Admin(account, true, block.timestamp, activator, false, 0, address(0));

        //Store new admin details
        admins.push(newAdmin);

        emit AdminAdded(activator, account);

        return true;
    }

    /**
     *
     *
     * This function expells admins.
     *
     */
    function expellAdmin(address account) public onlyAdminsAllowedToExpelll override returns (bool){
        bool foundAdmin = false;
        address expeller = msg.sender;

        for (uint256 i = 0; i < admins.length; i++) {
            Admin storage tmp = admins[i];
            if (tmp.adminAddr == account) {
                if (tmp.active == true) {
                    tmp.active = false;
                    tmp.expelled = true;
                    tmp.expelledTime = block.timestamp;
                    tmp.expeller = expeller;
                    foundAdmin = true;
                }
                break;
            }
        }


        require(foundAdmin, 'Admin: address can not be expelled because is not part of admins');

        emit AdminRemoved(expeller, account);
        return foundAdmin;
    }





    modifier onlyAdminsAllowedToExpelll{
        bool isAdminActiveAndAllowedToExpell_ = _isAdminActiveAndAllowedToExpell(msg.sender);
        require(isAdminActiveAndAllowedToExpell_, "Admin: The calling address is active admin allowed to expell.");
        _;

    }


    modifier onlyAdminsAllowedToInclude{
        bool isAdminActiveAndAllowedToInclude_ = _isAdminActiveAndAllowedToInclude(msg.sender);
        require(isAdminActiveAndAllowedToInclude_, "Admin: The calling address is active admin allowed to include.");
        _;

    }


}


