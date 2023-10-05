> Stitch 

Incredibly fast EVM runtime emulator, bundler, test runner, and package manager – all in one

> zig build
> zig run src/stitch

> stitch bytecode-bindings-abi example/stitch_abi.json
```bash
f((uint256,uint256[],(uint256,uint256)[]),(uint256,uint256),uint256)
```

> > zig test src/tools/contract/lexer.zig
```bash
Test [1/6] test.Lexer... 
(( SPDX-License-Identifier: GPL-3.0,  SPDX-License-Identifier: GPL-3.0), (4, 4)), ((pragma, pragma), (23, 23)), ((solidity, solidity), (26, 26)), ((^, ^), (19, 19)), ((0, 0), (3, 3)), ((., .), (20, 20)), ((8, 8), (3, 3)), ((., .), (20, 20)), ((0, 0), (3, 3)), ((;, ;), (14, 14)), ((pragma, pragma), (23, 23)), ((experimental, experimental), (28, 28)), ((ABIEncoderV2, ABIEncoderV2), (2, 2)), ((;, ;), (14, 14)), ((struct, struct), (25, 25)), ((S, S), (2, 2)), (({, {), (17, 17)), ((uint, uint), (29, 29)), ((a, a), (2, 2)), ((;, ;), (14, 14)), ((uint, uint), (29, 29)), (([, [), (21, 21)), ((], ]), (22, 22)), ((b, b), (2, 2)), ((;, ;), (14, 14)), ((T, T), (2, 2)), (([, [), (21, 21)), ((], ]), (22, 22)), ((c, c), (2, 2)), ((;, ;), (14, 1Test [2/6] test.Lexer - =+(){},;... 
((=, =), (5, 5)), ((+, +), (6, 6)), (((, (), (15, 15)), ((), )), (16, 16)), (({, {), (17, 17)), ((}, }), (18, 18)), ((,, ,), (13, 13)), Test [3/6] test.Lexer - pragma solidity ^0.8.0;... 
((pragma, pragma), (23, 23)), ((solidity, solidity), (26, 26)), ((^, ^), (19, 19)), ((0, 0), (3, 3)), ((., .), (20, 20)), ((8, 8), (3, 3)), ((., .)Test [4/6] test.Lexer - // SPDX-License-Identifier: GPL-3.0... 
(( SPDX-License-IdeTest [5/6] test.Lexer - contract Example {... 
((contract, contract), (27, 27)), ((ExTest [6/6] test.Lexer - struct S { uint a; uint[] b; T[] c; }... 
((struct, struct), (25, 25)), ((S, S), (2, 2)), (({, {), (17, 17)), ((uint, uint), (29, 29)), ((a, a), (2, 2)), ((;, ;), (14, 14)), ((uint, uint), (29, 29)), (([, [), (21, 21)), ((], ]), (22, 22)), ((b, b), (2, 2)), ((;, ;), (14, 14)), ((T, T), (2, 2)), (([, [), (21, 21)), ((], ]), (22, 22
All 6 tests passed.
```