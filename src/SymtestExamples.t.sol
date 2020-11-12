pragma solidity ^0.6.7;

import "ds-test/test.sol";

import "./SymtestExamples.sol";

contract SymtestExamplesTest is DSTest {
    SymtestExamples examples;

    function setUp() public {
        examples = new SymtestExamples();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
