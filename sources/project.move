module MyModule::VRLab {
    use aptos_framework::signer;
    use aptos_framework::timestamp;
    use std::vector;

    // Token resource that gates VR lab access
    struct Token has key {}

    // Session entry
    struct Session has store {
        assessment_id: u64,
        ts: u64,
        duration: u64,
    }

    // Per-account session log
    struct SessionLog has key {
        sessions: vector<Session>,
    }

    /// Mint an access token to caller
    public fun mint_token(user: &signer) {
        let token = Token {};
        move_to(user, token);
    }

    /// Record a session (caller must have Token). Appends to SessionLog.
    public fun record_session(user: &signer, assessment_id: u64, duration: u64)
        acquires SessionLog
    {
        let addr = signer::address_of(user);
        if (!exists<Token>(addr)) { abort 1; };

        let ts = timestamp::now_seconds();
        let s = Session {
            assessment_id: assessment_id,
            ts: ts,
            duration: duration,
        };

        if (exists<SessionLog>(addr)) {
            let log = borrow_global_mut<SessionLog>(addr);
            vector::push_back(&mut log.sessions, s);
        } else {
            let v = vector::empty<Session>();
            vector::push_back(&mut v, s);
            let log = SessionLog { sessions: v };
            move_to(user, log);
        }
    }
}
