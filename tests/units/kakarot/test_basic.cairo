// SPDX-License-Identifier: MIT

%lang starknet

// Starkware dependencies
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import split_felt
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_block_number


// Local dependencies
from kakarot.constants import Constants
from kakarot.model import model
from kakarot.stack import Stack
from kakarot.memory import Memory
from tests.units.kakarot.library import setup, prepare, Kakarot
from tests.model import EVMTestCase
from tests.utils import test_utils


// @title Basic EVM unit tests.
// @author @abdelhamidbakhta

@view
func __setup__{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    return setup();
}

@external
func test_arithmetic_operations{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;

    // Prepare Kakarot instance
    let (local context) = prepare();

    // Load test case
    let (evm_test_case: EVMTestCase) = test_utils.load_evm_test_case_from_file(
        './tests/cases/001.json'
    );

    // Run EVM execution
    let ctx: model.ExecutionContext* = Kakarot.execute(evm_test_case.code, evm_test_case.calldata);

    // Assert value on the top of the stack
    test_utils.assert_top_stack(ctx, Uint256(16, 0));

    return ();
}

func _assert_operation{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    filename: felt, assert_result: Uint256
) {
    // Load test case
    let (evm_test_case: EVMTestCase) = test_utils.load_evm_test_case_from_file(filename);

    // Run EVM execution
    let ctx: model.ExecutionContext* = Kakarot.execute(evm_test_case.code, evm_test_case.calldata);

    // Assert value on the top of the stack
    test_utils.assert_top_stack(ctx, assert_result);

    return ();
}

@external
func test_comparison_operations{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;

    // Prepare Kakarot instance
    let (local context) = prepare();

    // Test for LT
    _assert_operation('./tests/cases/003_lt.json', Uint256(0, 0));

    // Test for GT
    _assert_operation('./tests/cases/003_gt.json', Uint256(1, 0));

    // Test for SLT
    _assert_operation('./tests/cases/003_slt.json', Uint256(1, 0));

    // Test for SGT
    _assert_operation('./tests/cases/003_sgt.json', Uint256(0, 0));

    // Test for EQ
    _assert_operation('./tests/cases/003_eq.json', Uint256(0, 0));

    // Test for ISZERO
    _assert_operation('./tests/cases/003_iszero.json', Uint256(1, 0));

    return ();
}

@external
func test_bitwise_operations{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;

    // Prepare Kakarot instance
    let (local context) = prepare();

    // Test for SHL (from https://eips.ethereum.org/EIPS/eip-145)
    _assert_operation('./tests/cases/003/shl/1.json', Uint256(1, 0));
    _assert_operation('./tests/cases/003/shl/2.json', Uint256(2, 0));
    _assert_operation('./tests/cases/003/shl/3.json', Uint256(0, 0x80000000000000000000000000000000));
    _assert_operation('./tests/cases/003/shl/4.json', Uint256(0, 0));
    _assert_operation('./tests/cases/003/shl/5.json', Uint256(0, 0));
    _assert_operation('./tests/cases/003/shl/6.json', Uint256(0xffffffffffffffffffffffffffffffff, 0xffffffffffffffffffffffffffffffff));
    _assert_operation('./tests/cases/003/shl/7.json', Uint256(0xfffffffffffffffffffffffffffffffe, 0xffffffffffffffffffffffffffffffff));
    _assert_operation('./tests/cases/003/shl/8.json', Uint256(0, 0x80000000000000000000000000000000));
    _assert_operation('./tests/cases/003/shl/9.json', Uint256(0, 0));
    _assert_operation('./tests/cases/003/shl/10.json', Uint256(0, 0));
    _assert_operation('./tests/cases/003/shl/11.json', Uint256(0xfffffffffffffffffffffffffffffffe, 0xffffffffffffffffffffffffffffffff));

    // Test for SHR (from https://eips.ethereum.org/EIPS/eip-145)
    _assert_operation('./tests/cases/003/shr/1.json', Uint256(1, 0));
    _assert_operation('./tests/cases/003/shr/2.json', Uint256(0, 0));
    _assert_operation('./tests/cases/003/shr/3.json', Uint256(0, 0x40000000000000000000000000000000));
    _assert_operation('./tests/cases/003/shr/4.json', Uint256(1, 0));
    _assert_operation('./tests/cases/003/shr/5.json', Uint256(0, 0));
    _assert_operation('./tests/cases/003/shr/6.json', Uint256(0, 0));
    _assert_operation('./tests/cases/003/shr/7.json', Uint256(0xffffffffffffffffffffffffffffffff, 0xffffffffffffffffffffffffffffffff));
    _assert_operation('./tests/cases/003/shr/8.json', Uint256(0xffffffffffffffffffffffffffffffff, 0x7fffffffffffffffffffffffffffffff));
    _assert_operation('./tests/cases/003/shr/9.json', Uint256(1, 0));
    _assert_operation('./tests/cases/003/shr/10.json', Uint256(0, 0));
    _assert_operation('./tests/cases/003/shr/11.json', Uint256(0, 0));

    return ();
}

@external
func test_duplication_operations{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    ) {
    alloc_locals;

    // Prepare Kakarot instance
    let (local context) = prepare();

    // Load test case
    let (evm_test_case: EVMTestCase) = test_utils.load_evm_test_case_from_file(
        './tests/cases/002.json'
    );

    // Run EVM execution
    let ctx: model.ExecutionContext* = Kakarot.execute(evm_test_case.code, evm_test_case.calldata);

    // Assert value on the top of the stack
    test_utils.assert_top_stack(ctx, Uint256(3, 0));

    return ();
}

@external
func test_memory_operations{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;

    // Prepare Kakarot instance
    let (local context) = prepare();

    // Load test case
    let (evm_test_case: EVMTestCase) = test_utils.load_evm_test_case_from_file(
        './tests/cases/004.json'
    );

    // Run EVM execution
    let ctx: model.ExecutionContext* = Kakarot.execute(evm_test_case.code, evm_test_case.calldata);

    // Assert value on the top of the memory
    test_utils.assert_top_memory(ctx, Uint256(10, 0));

    return ();
}

@external
func test_exchange_operations{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;

    // Prepare Kakarot instance
    let (local context) = prepare();

    // Load test case
    let (evm_test_case: EVMTestCase) = test_utils.load_evm_test_case_from_file(
        './tests/cases/005.json'
    );

    // Run EVM execution
    let ctx: model.ExecutionContext* = Kakarot.execute(evm_test_case.code, evm_test_case.calldata);

    // Assert value on the top of the stack
    test_utils.assert_top_stack(ctx, Uint256(4, 0));

    return ();
}

@external
func test_environmental_information{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}() {
    alloc_locals;

    // Prepare Kakarot instance
    let (local context) = prepare();

    // Load test case
    let (evm_test_case: EVMTestCase) = test_utils.load_evm_test_case_from_file(
        './tests/cases/006.json'
    );

    // Run EVM execution
    let ctx: model.ExecutionContext* = Kakarot.execute(evm_test_case.code, evm_test_case.calldata);

    // Assert value on the top of the stack
    test_utils.assert_top_stack(ctx, Uint256(7, 0));

    return ();
}

@external
func test_block_information{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;

    // Prepare Kakarot instance
    let (local context) = prepare();

    // Load test case CHAINID
    let (evm_test_case: EVMTestCase) = test_utils.load_evm_test_case_from_file(
        './tests/cases/007.json'
    );

    // Run EVM execution
    let ctx: model.ExecutionContext* = Kakarot.execute(evm_test_case.code, evm_test_case.calldata);

    let (high, low) = split_felt(Constants.CHAIN_ID);
    let chain_id = Uint256(low, high);

    // Assert value on the top of the stack
    test_utils.assert_top_stack(ctx, chain_id);

    // Load test case COINBASE
    let (evm_test_case: EVMTestCase) = test_utils.load_evm_test_case_from_file(
        './tests/cases/008.json'
    );

    // Run EVM execution
    let ctx: model.ExecutionContext* = Kakarot.execute(evm_test_case.code, evm_test_case.calldata);

    let (high, low) = split_felt(Constants.COINBASE_ADDRESS);
    let coinbase_address = Uint256(low, high);

    // Assert value on the top of the stack
    test_utils.assert_top_stack(ctx, coinbase_address);

    // Load test case NUMBER
    let (evm_test_case: EVMTestCase) = test_utils.load_evm_test_case_from_file(
        './tests/cases/010.json'
    );

    // Run EVM execution
    let ctx: model.ExecutionContext* = Kakarot.execute(evm_test_case.code, evm_test_case.calldata);

    // Assert value on the top of the stack
    let (current_block) = get_block_number();
    let (high, low) = split_felt(current_block);
    let block_number = Uint256(low,high);

    test_utils.assert_top_stack(ctx, block_number);

    return ();
}

@external
func test_system_operations{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;

    // Prepare Kakarot instance
    let (local context) = prepare();

    // Load test case
    let (evm_test_case: EVMTestCase) = test_utils.load_evm_test_case_from_file(
        './tests/cases/009.json'
    );

    // Run EVM execution
    %{ expect_revert("TRANSACTION_FAILED", "Kakarot: 0xFE: Invalid Opcode") %}
    let ctx: model.ExecutionContext* = Kakarot.execute(evm_test_case.code, evm_test_case.calldata);

    return ();
}
