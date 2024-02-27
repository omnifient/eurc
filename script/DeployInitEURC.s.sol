pragma solidity 0.6.12;

import "forge-std/Script.sol";

import "../src/proxy/v1/FiatTokenProxy.sol";
import "../src/impl/v2/FiatTokenV2_2.sol";

contract DeployInitEURC is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);

        FiatTokenV2_2 impl = new FiatTokenV2_2();
        FiatTokenProxy proxy = new FiatTokenProxy(address(impl));

        // change the proxy admin so we can initialize with the deployer
        // proxy's fallback requires caller != admin
        address newAdmin = vm.envAddress("PROXY_ADMIN");
        proxy.changeAdmin(newAdmin);

        FiatTokenV2_2 eurc = FiatTokenV2_2(address(proxy));

        // default initializer
        eurc.initialize(
            "Euro Coin", "EURC", "EUR", 6, deployerAddress, deployerAddress, deployerAddress, deployerAddress
        );

        // initializer for V2
        eurc.initializeV2("Euro Coin");

        // initializer for V2.1
        eurc.initializeV2_1(address(0));

        // initializer for V2.2
        address[] memory accountsToBlacklist;
        eurc.initializeV2_2(accountsToBlacklist, "EURC");

        vm.stopBroadcast();
    }
}
