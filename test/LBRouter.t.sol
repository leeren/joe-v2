// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "./TestHelper.sol";

contract LiquidityBinRouterTest is TestHelper {
    function setUp() public {
        token6D = new ERC20MockDecimals(6);
        token18D = new ERC20MockDecimals(18);

        factory = new LBFactory(DEV);
        new LBFactoryHelper(factory);

        router = new LBRouter(factory, IJoeFactory(JOE_V1_FACTORY_ADDRESS), IWAVAX(WAVAX_AVALANCHE_ADDRESS));
    }

    function testConstructor() public {
        assertEq(address(router.factory()), address(factory));
        assertEq(address(router.oldFactory()), JOE_V1_FACTORY_ADDRESS);
        assertEq(address(router.wavax()), WAVAX_AVALANCHE_ADDRESS);
    }

    function testCreateLBPair() public {
        factory.setFactoryLocked(false);

        router.createLBPair(
            token6D,
            token18D,
            ID_ONE,
            DEFAULT_SAMPLE_LIFETIME,
            DEFAULT_MAX_ACCUMULATOR,
            DEFAULT_FILTER_PERIOD,
            DEFAULT_DECAY_PERIOD,
            DEFAULT_BIN_STEP,
            DEFAULT_BASE_FACTOR,
            DEFAULT_PROTOCOL_SHARE
        );

        assertEq(factory.allPairsLength(), 1);
        pair = LBPair(address(factory.getLBPair(token6D, token18D)));

        assertEq(address(pair.factory()), address(factory));
        assertEq(address(pair.tokenX()), address(token6D));
        assertEq(address(pair.tokenY()), address(token18D));

        FeeHelper.FeeParameters memory feeParameters = pair.feeParameters();
        assertEq(feeParameters.accumulator, 0);
        assertEq(feeParameters.time, 0);
        assertEq(feeParameters.maxAccumulator, DEFAULT_MAX_ACCUMULATOR);
        assertEq(feeParameters.filterPeriod, DEFAULT_FILTER_PERIOD);
        assertEq(feeParameters.decayPeriod, DEFAULT_DECAY_PERIOD);
        assertEq(feeParameters.binStep, DEFAULT_BIN_STEP);
        assertEq(feeParameters.baseFactor, DEFAULT_BASE_FACTOR);
        assertEq(feeParameters.protocolShare, DEFAULT_PROTOCOL_SHARE);
        assertEq(feeParameters.variableFeeDisabled, DEFAULT_VARIABLEFEE_STATE);
    }
}