<!-- ABOUT THE PROJECT -->

## About The Project 🚀

ERC721N: Revolutionizing NFTs with Built-in Treasury Management! 💎

Imagine NFTs that don't just sit in your wallet, but actively manage funds and allow redemptions. That's ERC721N for you!

🔥 Key Features:
- IERC721 implementation with a twist
- ERC20 Treasury Management
- Token Redemption capabilities
- Regular updates & best practices adherence

Created by the innovative [NoRamp](https://twitter.com/NoRampLabs) team, ERC721N takes the ERC721 standard to the next level. It's not just an NFT; it's your gateway to USDC onboarding with on-chain treasury management of ERC20s.

🎨 Mint NFT | 🔥 Burn NFT | 💰 Claim Tokens

![NoRamp Labs](https://imgur.com/1QsnGEE.png)

🧠 Want to dive deeper? Check out our [in-depth blog post](https://medium.com/@NoRamp).
🌐 Discover projects leveraging ERC721N at [erc721n.org](https://www.erc721n.org)

⚠️ **Disclaimer:** NoRamp Labs is not liable for any outcomes resulting from using ERC721N. Always DYOR (Do Your Own Research).

<!-- Docs -->

## 📚 Documentation

Get started in minutes with our comprehensive docs:
[https://docs.noramp.io/erc721n/quickstart](https://docs.noramp.io/erc721n/quickstart)

<!-- Installation -->

## 🛠 Installation

Choose your preferred package manager:

```sh
npm install --save-dev erc721n
```

or

```sh
yarn add -D erc721n
```

<!-- USAGE EXAMPLES -->

## 💻 Usage

Integrating ERC721N is a breeze! Here's a quick example:

```solidity
pragma solidity ^0.8.2;

import "erc721n/contracts/ERC721N.sol";

contract ERC721NTest is ERC721N {
    constructor(IERC20 _erc20Token) ERC721N(_erc20Token) {
        reserveTokenAddress = _erc20Token;
    }

    function mint(address to, uint256 amount) external {
        safeMint(to, amount);
    }
}
```

<!-- ROADMAP -->

## 🗺 Roadmap

We're constantly improving! Here's what's coming:

- [ ] 🏗 Enhance repo structure and code quality
- [ ] 📝 Expand documentation on ERC721N benefits
- [ ] 🧪 Maintain 100% test coverage

Check out our [open issues](https://github.com/noramp/ERC721N/issues) for a complete list of planned features and known issues.

<!-- CONTRIBUTING -->

## 🤝 Contributing

We love our contributors! Here's how you can join the revolution:

1. 🍴 Fork the Project
2. 🌿 Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. 💾 Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. 🚀 Push to the Branch (`git push origin feature/AmazingFeature`)
5. 🔃 Open a Pull Request

Don't forget to give us a star! ⭐️

<!-- ROADMAP -->

### 🧪 Running tests locally

1. `npm install`
2. `npm run test`

<!-- LICENSE -->

## 📜 License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<!-- CONTACT -->

## 👥 Contributors

Meet the minds behind ERC721N:

- 🧙‍♂️ rarepepi (owner) - [@rarepepi](https://twitter.com/rarepepi)
- 🦊 0xinuarashi (maintainer) - [@0xinuarashi](https://twitter.com/0xinuarashi)
- 🧑‍💻 vectorized.eth (maintainer) - [@optimizoor](https://twitter.com/optimizoor)

🔗 Project Link: [https://github.com/noramp/ERC721N](https://github.com/noramp/ERC721N)
