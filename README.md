<!-- ANNOUNCEMENT -->

_We highly recommend reading the our guide_, **especially** \_the part on [`safeMint`](https://medium.com/@NoRamp)

<!-- ABOUT THE PROJECT -->

## About The Project

The goal of ERC721N is to provide a fully compliant implementation of IERC721 with additional features like a ERC20 Treasury Management and Redeemption system. This project and implementation will be updated regularly and will continue to stay up to date with best practices.

The [NoRamp](https://twitter.com/NoRampLabs) team created ERC721N for its sale on 3/13/24. There was significant demand for KYC-less purchases of digital assets requested by the public, and all existing options are not good enough. We took it upon ourselves to create the ERC721N NFT Standard to solve the onboarding problems in crypto. Using an innovative NFT pass through system alongside ERC20 treasury management and secure redemption system we were able to create the experience we should learn to expect from crypto not the one we are used to.

![NoRamp Labs](https://i.imgur.com/BBRVn7o.png)

For more information on how ERC721N works under the hood, please visit our [blog](https://medium.com/@NoRamp). To find other projects that are using ERC721N, please visit [erc721n.org](https://www.erc721n.org)

**NoRamp Labs is not liable for any outcomes as a result of using ERC721N.** DYOR.

<!-- Docs -->

## Docs

https://docs.noramp.io/ERC721N/

<!-- Installation -->

## Installation

```sh

npm install --save-dev erc721n

```

<!-- USAGE EXAMPLES -->

## Usage

Once installed, you can use the contracts in the library by importing them:

```solidity
pragma solidity ^0.8.2;

import "erc721n/contracts/ERC721N.sol";

contract ERC721NTest is ERC721N {
    constructor(IERC20 _erc20Token) ERC721N(_erc20Token) {
        reserveTokenAddress = _erc20Token;
    }

    function mint(address to, uint256 amount) external {
        _safeMint(to, amount);
    }
}


```

<!-- ROADMAP -->

## Roadmap

- [ ] Improve general repo and code quality (workflows, comments, etc.)
- [ ] Add more documentation on benefits of using ERC721N
- [ ] Maintain full test coverage

See the [open issues](https://github.com/noramp/ERC721N/issues) for a full list of proposed features (and known issues).

<!-- CONTRIBUTING -->

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<!-- ROADMAP -->

### Running tests locally

1. `npm install`
2. `npm run test`

<!-- LICENSE -->

## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<!-- CONTACT -->

## Contact

- rarepepi (owner) - [@rarepepi](https://twitter.com/rarepepi)
- cygaar (maintainer) - [@0xCygaar](https://twitter.com/0xCygaar)
- vectorized.eth (maintainer) - [@optimizoor](https://twitter.com/optimizoor)

Project Link: [https://github.com/noramp/ERC721N](https://github.com/noramp/ERC721N)
