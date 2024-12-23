// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";

contract GenerateInput is Script {
    uint256 private constant AMOUNT = 25 * 1e18;
    string[] types = new string[](3);
    uint256 count;
    string[] whitelist = new string[](4);
    string private constant INPUT_PATH = "/script/target/input.json";

    function run() public {
        types[0] = "uint";
        types[1] = "address";
        types[2] = "uint";

        whitelist[0] = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
        whitelist[1] = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8";
        whitelist[2] = "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC";
        whitelist[3] = "0x90F79bf6EB2c4f870365E785982E1f101E93b906";

        count = whitelist.length;
        string memory input = _createJSON();

        vm.writeFile(string.concat(vm.projectRoot(), INPUT_PATH), input);
        console2.log("DONE: The output is found at ", INPUT_PATH);
    }

    function _createJSON() internal view returns (string memory) {
        string memory countString = vm.toString(count); // convert count to string
        string memory amountString = vm.toString(AMOUNT); // convert amount to string

        // create the types array string dynamically
        string memory typesArrayString = "[";
        for (uint256 i = 0; i < types.length; i++) {
            typesArrayString = string.concat(typesArrayString, '"', types[i], '"');
            if (i < types.length - 1) {
                typesArrayString = string.concat(typesArrayString, ",");
            }
        }
        typesArrayString = string.concat(typesArrayString, "]");

        string memory json = string.concat('{"types":', typesArrayString, ', "count":', countString, ',"values": {');

        for (uint256 i = 0; i < whitelist.length; i++) {
            if (i == whitelist.length - 1) {
                json = string.concat(
                    json,
                    '"',
                    vm.toString(i),
                    '"',
                    ': { "0":',
                    '"',
                    vm.toString(i),
                    '"',
                    ', "1":',
                    '"',
                    whitelist[i],
                    '"',
                    ', "2":',
                    '"',
                    amountString,
                    '"',
                    " }"
                );
            } else {
                json = string.concat(
                    json,
                    '"',
                    vm.toString(i),
                    '"',
                    ': { "0":',
                    '"',
                    vm.toString(i),
                    '"',
                    ', "1":',
                    '"',
                    whitelist[i],
                    '"',
                    ', "2":',
                    '"',
                    amountString,
                    '"',
                    " },"
                );
            }
        }
        json = string.concat(json, "} }");

        return json;
    }
}
