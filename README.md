# 🏛️ DAO Proposals & Voting Smart Contract

A complete decentralized autonomous organization (DAO) governance system built on Stacks blockchain using Clarity smart contracts. This contract enables democratic decision-making through proposal submission and weighted voting mechanisms.

## ✨ Features

- 📝 **Proposal Submission**: Members can create proposals with titles and descriptions
- 🗳️ **Weighted Voting**: Each member has configurable voting power
- ⏰ **Time-bound Voting**: Proposals have configurable voting periods
- 🔒 **Access Control**: Only members can participate in governance
- 📊 **Transparent Results**: Public proposal status and voting statistics
- ⚡ **Automatic Execution**: Proposals are marked as passed/failed after voting ends

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Basic understanding of Clarity smart contracts

### Installation

```bash
clarinet new dao-project
cd dao-project
```

Copy the contract code into `contracts/DAO-proposals-voting.clar`

### Testing

```bash
clarinet console
```

## 📖 Usage Guide

### 👥 Member Management

**Add a new member:**
```clarity
(contract-call? .DAO-proposals-voting add-member 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u50)
```

**Remove a member:**
```clarity
(contract-call? .DAO-proposals-voting remove-member 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

**Update voting power:**
```clarity
(contract-call? .DAO-proposals-voting update-voting-power 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u75)
```

### 📋 Proposal Lifecycle

**1. Submit a proposal:**
```clarity
(contract-call? .DAO-proposals-voting submit-proposal 
  "Increase Treasury Allocation" 
  "Proposal to allocate 10% more funds to the development treasury for Q4 initiatives" 
  u1000)
```

**2. Vote on proposal:**
```clarity
(contract-call? .DAO-proposals-voting vote-on-proposal u1 true)
```

**3. Execute proposal (after voting period ends):**
```clarity
(contract-call? .DAO-proposals-voting execute-proposal u1)
```

### 🔍 Query Functions

**Get proposal details:**
```clarity
(contract-call? .DAO-proposals-voting get-proposal u1)
```

**Check voting status:**
```clarity
(contract-call? .DAO-proposals-voting get-proposal-status u1)
```

**View member info:**
```clarity
(contract-call? .DAO-proposals-voting get-member-voting-power 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

**Get contract statistics:**
```clarity
(contract-call? .DAO-proposals-voting get-contract-info)
```

## ⚙️ Configuration

- **Minimum Voting Period**: 144 blocks (~24 hours)
- **Maximum Voting Period**: 4320 blocks (~30 days)
- **Contract Owner**: Deployer address (has admin privileges)

## 🔐 Security Features

- Only registered members can submit proposals and vote
- One vote per member per proposal
- Time-locked voting periods prevent manipulation
- Proposals cannot be executed during active voting
- Owner-only functions for member management

## 🏗️ Contract Architecture

### Data Structures
- **Members Map**: Tracks registered DAO members
- **Proposals Map**: Stores all proposal data and voting results
- **Votes Map**: Records individual votes with voting power
- **Member Voting Power**: Configurable weight for each member

### Key Functions
- `submit-proposal`: Create new governance proposals
- `vote-on-proposal`: Cast weighted votes
- `execute-proposal`: Finalize proposal results
- `add-member`/`remove-member`: Manage DAO membership

## 🎯 Use Cases

- 💰 **Treasury Management**: Vote on fund allocation
- 🔧 **Protocol Updates**: Decide on system changes  
- 👨‍💼 **Team Decisions**: Democratic hiring/firing
- 📈 **Strategic Planning**: Community-driven roadmap
- 🤝 **Partnership Approvals**: Collaborative agreements

## 🛠️ Development

### Running Tests
```bash
clarinet test
```

### Deployment
```bash
clarinet deploy --testnet
```

## 📄 License

MIT License - feel free to use this contract as a foundation for your DAO projects!

---

Built with ❤️ using Clarity and Stacks blockchain
```

**Git Commit Message:**
```
feat: implement DAO governance contract with proposal submission and weighted voting system
```

**GitHub Pull Request Title:**
```
🏛️ Add DAO Proposals & Voting Smart Contract MVP
```

**GitHub Pull Request Description:**
```
## 🎯 Overview
Implements a complete DAO governance system enabling democratic decision-making through proposal submission and weighted voting.

## ✅ Features Added
- **Member Management**: Add/remove members with configurable voting power
- **Proposal System**: Submit proposals with time-bound voting periods  
- **Weighted Voting**: Members vote with assigned voting power weights
- **Automatic Execution**: Proposals automatically marked as passed/failed
- **Access Control**: Member-only participation with owner admin functions
- **Query Interface**: Comprehensive read-only functions for transparency

## 🔧 Technical Details
- 150+ lines of production-ready Clarity code
- Comprehensive error handling with custom error codes
- Gas-optimized data structures and functions
- Time-based voting periods (24 hours - 30 days)
- Transparent voting results and statistics

## 📚 Documentation
- Complete README with usage examples
- Function documentation and configuration details
- Security features and use case examples

Ready for immediate deployment and testing on Stacks testnet.

