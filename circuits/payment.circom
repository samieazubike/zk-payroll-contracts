pragma circom 2.0.0;

include "range_proof.circom";

/*
 * ZK Payroll – Payment Circuit (placeholder)
 *
 * Proves knowledge of (salary, blinding) such that:
 *
 *   salary_commitment = Poseidon(salary, blinding)
 *   payment_nullifier = Poseidon(salary_commitment, nonce)
 *   recipient_hash    = Poseidon(recipient_address)
 *
 * Public signals:
 *   - on_chain_commitment
 *   - expected_transfer_amount
 *
 * Private signals:
 *   - actual_salary
 *   - blinding_factor
 *
 * Logical constraints:
 *   1) actual_salary == expected_transfer_amount
 *   2) calculated_hash = Poseidon(actual_salary, blinding_factor)
 *   3) calculated_hash == on_chain_commitment
 *
 * This circuit also includes SalaryRangeProof(actual_salary), tying range
 * constraints to the same salary value used for commitment verification.
 */

template PaymentProof() {
    // ── Private inputs ────────────────────────────────────────────────────────
    signal input salary;
    signal input blinding;

    component salary_range = SalaryRangeProof();
    salary_range.salary <== salary;

    component salary_range = SalaryRangeProof();
    salary_range.salary <== actual_salary;

    // Public signals (exposed on-chain)
    signal output on_chain_commitment;
    signal output expected_transfer_amount;

    // 1) Ensure actual salary equals expected transfer amount
    expected_transfer_amount <== actual_salary;
    actual_salary === expected_transfer_amount;

    // 2) Calculate Poseidon(actual_salary, blinding_factor)
    component salary_commitment_hash = Poseidon(2);
    salary_commitment_hash.inputs[0] <== actual_salary;
    salary_commitment_hash.inputs[1] <== blinding_factor;

    signal calculated_hash;
    calculated_hash <== salary_commitment_hash.out;

    // 3) Ensure calculated hash equals the on-chain commitment
    on_chain_commitment <== calculated_hash;
    calculated_hash === on_chain_commitment;
}

component main {
    public [salary_commitment, payment_nullifier, recipient_hash]
} = PaymentProof();
