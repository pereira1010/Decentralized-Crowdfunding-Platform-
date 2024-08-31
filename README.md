# Decentralized-Crowdfunding-Platform-

## Decentralized crowdfunding platform on Ethereum using Solidity, featuring campaign creation, milestone-based funding, ETH contributions, and refunds.

## Introduction

Welcome to the **Decentralized Crowdfunding Platform** project, built on the **Ethereum Sepolia testnet** using **Solidity**. This project showcases the power of **smart contracts** by enabling users to create and manage crowdfunding campaigns directly on the blockchain. Designed with transparency, security, and flexibility in mind, this platform is ideal for anyone looking to explore decentralized finance (DeFi) and blockchain-based fundraising. Below are the key features of this project:

### Key Features:
- **Campaign Creation**: Easily create crowdfunding campaigns with defined goals, deadlines, and milestones.
- **Milestone-Based Funding**: Funds are released incrementally based on contributor approval, ensuring accountability.
- **ETH Contributions**: Support campaigns by contributing ETH, with secure tracking of all donations.
- **Refund Mechanism**: Contributors can claim refunds if the campaign fails to meet its goals.
- **Transparent Operations**: All interactions are recorded on the blockchain, with comprehensive view functions for tracking progress.

This platform is perfect for learning how to develop, deploy, and interact with decentralized applications (dApps) on the Ethereum blockchain.

## Check out the project overview, goals and functions below :
https://quicknode.notion.site/Session-6-70a6a1528f02492aa157e305eaf909ce

## How to view contract
- **Verified contract link**: https://sepolia.etherscan.io/address/0x144be09e6ddd31946696a23bc20a76f45c91807a#code
- **Contract Address**: 0x13c30555F0C3f3708CA3FfA696Ab66f5995758e0
- **Block number**: 6507360

## How to code with solidity and Metamask:
Use the open source Remix website to start coding in solidity 

Accessing Remix (https://remix.ethereum.org/)
Solidity Documentation: https://docs.soliditylang.org/
Ethereum Whitepaper: https://ethereum.org/en/whitepaper/

### Setting Up MetaMask

1. **Install MetaMask:**
    - Go to the [MetaMask website](https://metamask.io/) and install the extension for your preferred browser (Chrome, Firefox, Brave, etc.).
2. **Create a Wallet:**
    - After installation, click the MetaMask icon in your browser.
    - Click "Get Started" and choose "Create a Wallet."
    - Create a strong password.
3. **Backup Your Seed Phrase:**
    - MetaMask will provide a 12-word seed phrase. Write it down and keep it safe.
    - This phrase is crucial for recovering your wallet if you lose access.
4. **Account Overview:**
    - After setup, you'll see your account balance and address.
    - You can switch between networks (e.g., Mainnet, Ropsten Testnet).

### Using MetaMask

- **Sending and Receiving Ether:**
    - To receive Ether, share your public address.
    - To send Ether, click "Send," enter the recipient's address and amount, then confirm the transaction.
- **Interacting with dApps:**
    - When visiting a dApp, MetaMask will prompt you to connect your wallet.
    - Once connected, you can interact with the dApp using your Ethereum account.
 
### **Distributing Test Ether**

To interact with Ethereum test networks, you'll need test ether. Here's how to get it:

1. **Select a test network**: Open MetaMask and switch to a test network - Sepolia
2. **Get test ether**: You can use Alchemy faucet for free test ether at https://www.alchemy.com/faucets/ethereum-sepolia

###**Using MetaMask**

MetaMask enables interaction with smart contracts. For these experiments, you will use Remix, an online Solidity IDE.

1. **Open Remix**: Remix IDE
2. **Connect MetaMask**: Click the MetaMask icon in Remix to connect your wallet.
3. **Deploy and interact with smart contracts**: Use Remix to write, compile, deploy, and interact with smart contracts.

## How to tweak this project for your own uses
I encourage you to clone and rename this project for your own use, it's a good outline to follow

## Found a bug?
If you come across a bug, please submit an issue using the issue tab above. To submit a PR with a fix please reference the issue you created.

## Known Issues
- Gas Costs: High gas fees may occur during peak network times, especially for transactions involving multiple milestones.
- Limited Error Handling: The current implementation may not handle all edge cases, particularly around campaign finalization and refunds.
- No Frontend: Interaction with the platform requires direct use of Etherscan, as no frontend interface is provided.
- Milestone Voting: Voting power is not weighted by contribution amount, which may affect decision fairness.
- Proper Functions: Failure to implement proper require statements in smart contracts can lead to unexpected behaviors, such as allowing unauthorized actions, approving non-existent milestones, or processing invalid transactions, which can compromise the security and functionality of the contract.

