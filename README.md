## Introduction
This repository contains code and documentation for understanding and implementing different types of nodes in a blockchain network for the purpose of participating in airdrop projects. A node is a fundamental unit within a blockchain network, primarily responsible for distributing data among other nodes in the network. Nodes store a copy of the entire blockchain data and add blocks with new transactions based on the consensus mechanism. By setting up nodes, participants can be eligible to receive airdrops distributed by blockchain projects.

## Types of Nodes

### 1. Full Nodes (Masternodes)
Full nodes are fully synchronized with the blockchain network and store the complete history of the network since its inception. They play a crucial role in maintaining the security and integrity of the blockchain. If the consensus rules are violated in a transaction or block, a full node rejects the operation, even if all other nodes accept it.

#### Subtypes of Full Nodes:
- **Pruned Nodes:** These nodes store only a partial history of the blockchain (e.g., the last 20 GB). They serve as a compromise between light nodes and full nodes, balancing storage requirements and network participation.
- **Archive Full Nodes:** These nodes store the complete transaction history of the network for its entire existence. They can launch other nodes, such as mining nodes for PoW or staking nodes for PoS.

### 2. Light Nodes
Light nodes do not store the entire network history but only the data necessary to verify the authenticity of transactions. Their main advantage is their low technical requirements and ease of setup. However, they rely on full nodes to independently verify blocks.

### 3. Lightning Nodes
Lightning nodes are used in the Lightning Network solution for Bitcoin (BTC). They support payment channels between addresses in the BTC network and create a separate Bitcoin consensus. This allows for faster and more scalable transactions.
