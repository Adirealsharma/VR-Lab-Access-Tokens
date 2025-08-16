# VR Lab Access Tokens — README

## Overview!


<img width="1920" height="1080" alt="Screenshot (29)" src="https://github.com/user-attachments/assets/98f7552b-87e0-403c-8cf3-7491a37cc90a" />

This repository contains a minimal Move module for the Aptos blockchain that implements **token-gated VR lab access** and **session logging tied to assessments**. The contract intentionally exposes exactly **two public functions** and aims to be small and easy to audit.

## Features

* Mint a per-account `Token` resource to gate access to virtual labs.
* Record VR lab sessions (assessment ID, timestamp, duration) into a per-account `SessionLog`.
* Minimal error handling and a very small surface area (only two public functions).

## Module summary

The Move module defines three resources and one stored struct:

* `Token` (resource, `has key`) — possession gates access.
* `Session` (store) — a struct containing `assessment_id`, `ts`, and `duration`.
* `SessionLog` (resource, `has key`) — per-account vector of `Session` entries.

### Public functions (2)

1. `mint_token(user: &signer)` — mints a `Token` resource into the caller's account.
2. `record_session(user: &signer, assessment_id: u64, duration: u64)` — requires the caller to own the `Token`, then appends a `Session` entry with the current timestamp to the caller's `SessionLog` (creates the log if missing).

## Usage

1. **Compile & deploy** the module using Aptos Move tooling (e.g., `aptos move compile` and `aptos move publish`).
2. Call `mint_token` from the account that should receive access.
3. To log sessions, call `record_session` with an `assessment_id` and session `duration` in seconds; the caller must own the token.

Example flow (high level):

* Admin or user publishes the module.
* A student account calls `mint_token` to obtain access.
* While using the VR lab, the student calls `record_session` to log the session and tie it to an assessment ID.

## Error handling

* `record_session` aborts with code `1` when the caller does not own a `Token` resource. You can extend this with named constants or additional checks if needed.

## Extensibility ideas

* Add `revoke_token` or time-limited tokens.
* Add a read-only view function (off-chain indexer recommended) to list sessions per account.
* Cap `SessionLog` length or compress older entries.
* Integrate with an on-chain assessment contract for stronger ties between sessions and graded assessments.

## Testing & tips

* Use local Aptos node or testnet for quick iteration.
* Write small Move transactions to call `mint_token` and `record_session` and assert the existence of `SessionLog` and contents.
* For production, consider gas costs for storing many sessions and whether you want session aggregation off-chain.

## License

MIT

---

If you want, I can add example Move transaction payloads and `aptos` CLI commands to the README, or convert this into a `README.md` with code snippets. Tell me which you prefer.
