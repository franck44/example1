
This repo contains a simple example of swap profits detection in Solidity contracts using [Halmos](https://github.com/a16z/halmos).

# Getting Started

Install [Halmos](https://github.com/a16z/halmos) and [Foundry](https://github.com/foundry-rs/foundry).

Clone this repository.

# Reproducing the experiments

Run the following command to reproduce the experiments:

```bash
halmos --contract SimplifiedBalancerV2SymTest --function check_ExactOutRounding --print-full-model --solver cvc5
```

This command will run the `check_ExactOutRounding` function in the `SimplifiedBalancerV2SymTest` contract and print the full model of the detected swap profit.
It uses the `cvc5` solver to find the solution.
If the solver is not installed, you should be prompted to install it. You can also use other solvers like `z3` or `cvc4` by changing the `--solver` flag.


