pragma solidity ^0.8.5;

contract ProxyContract {

    //Check : ERC1967
    bytes32 private constant _ADMIN = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;
    bytes32 private constant _IMPL = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6102; //_ADMIN!=_IMPL because of bug ,after upgradeImplementation call.
    //if _ADMIN==_IMPL point to same memory slot.



    constructor(){

        bytes32 slot = _ADMIN;
        address _admin = msg.sender;

        assembly{
        //store a value in storage of smart contract.
            sstore(slot, _admin)
        }
    }



    function admin() public view returns (address adm){
        bytes32 slot = _ADMIN;
        assembly{
            adm := sload(slot)
        }
    }


    function implementation() public view returns (address impl){
        bytes32 slot = _IMPL;
        assembly{
            impl := sload(slot)
        }
    }


    function upgradeImplementation(address newImpl) external {
        require(msg.sender == admin(), 'Admin only');

        bytes32 slot = _IMPL;
        assembly{

            sstore(slot, newImpl)

        }
    }

    //fallback : By default is called whenever caller calls a function dosen't exist on callable
    //fallback : Doesn't have function keyword but only f(x) name;
    //delegatecall : executes SC in context of another,also storage of proxy is changed not storage of V1 or V2.V1 & V2 only needed for code.

    fallback() external payable {
        assembly{
            let _target := sload(_IMPL)
            calldatacopy(0x0, 0x0, calldatasize())

        //forward call to implementation
        //State change is done on proxy SC
            let result := delegatecall(gas(), _target, 0x0, calldatasize(), 0x0, 0)
            returndatacopy(0x0, 0x0, returndatasize())

            switch result
            case 0 {revert(0, 0)}
            default {return (0, returndatasize())}
        }
    }

}
