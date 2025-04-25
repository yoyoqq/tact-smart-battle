contract Proposal {
    
    // === INIT ===
    init(init: Init) {
        self.proposalId = init.proposalId;
        self.votingEndingAt = init.votingEndingAt;
        self.yesCount = 0;
        self.noCount = 0;
        self.voted = map();
    }

    // === STRUCTS ===
    struct Init {
        proposalId: Int as uint32;
        votingEndingAt: Int as uint32;
    }

    struct Vote {
        value: Bool;
    }

    struct ProposalState {
        yesCount: Int as uint32;
        noCount: Int as uint32;
    }

    // === STATE VARIABLES ===
    proposalId: Int as uint32;
    votingEndingAt: Int as uint32;
    yesCount: Int as uint32;
    noCount: Int as uint32;
    voted: Map<Address, Bool>;

    // === EMPTY DEPLOY RECEIVER ===
    receive() {}

    // === VOTE RECEIVER ===
    receive(msg: Vote) {
        // Check voting deadline
        if (now() > self.votingEndingAt) {
            reject(101); // Voting expired
        }

        // Check if already voted
        if (self.voted.exists(sender())) {
            reject(102); // Already voted
        }

        // Check if 100 votes reached
        let totalVotes = self.yesCount + self.noCount;
        if (totalVotes >= 100) {
            reject(103); // Max votes reached
        }

        // Count the vote
        if (msg.value) {
            self.yesCount += 1;
        } else {
            self.noCount += 1;
        }

        // Mark address as voted
        self.voted.set(sender(), true);

        // Reimburse unused gas
        send(sender(), 0); // refund remaining TONs
    }

    // === GETTER FOR STATE ===
    get fun proposalState(): ProposalState {
        return ProposalState {
            yesCount: self.yesCount,
            noCount: self.noCount
        };
    }
}
