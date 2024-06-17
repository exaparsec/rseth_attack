## rsETH depeg attack

## Resources

The [LRTConfig contract](https://etherscan.io/address/0x947Cb49334e6571ccBFEF1f1f1178d8469D65ec7#readProxyContract) contains the current configuration as well as
a registry of deployed contracts.

The [LRTOracle contract](https://etherscan.io/address/0x349A73444b1a310BAe67ef67973022020d70020d#code) contract points to the following price oracles: 
- [LiDo stETH oracle](https://etherscan.io/address/0x4cB8d6DCd56d6b371210E70837753F2a835160c4#readContract) 1-1 hardcoded
- [Stader ETHx oracle](https://etherscan.io/address/0x3D08ccb47ccCde84755924ED6B0642F9aB30dFd2#readProxyContract) protocol internal exchange rate
- [Frax sfrxETH oracle](https://etherscan.io/address/0x8546A7C8C3C537914C3De24811070334568eF427#readProxyContract) protocol internal exchange rate

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
