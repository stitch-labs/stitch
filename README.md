> Stitch 

Incredibly fast EVM runtime emulator, bundler, test runner, and package manager – all in one

> zig build
> zig run src/stitch

> stitch bytecode-bindings-abi example/stitch_abi.json
```bash
f((uint256,uint256[],(uint256,uint256)[]),(uint256,uint256),uint256)
```

```json
{
	"magic_number": "Example",
	"major_version": 0,
	"minor_version": 8,
	"revision": 0,
	"contract_abi": [
		{
			"name": "f",
			"type": 0,
			"inputs": [
				{
					"name": "s",
					"type": 16,
					"components": [
						{
							"name": "a",
							"type": 17,
							"components": []
						},
						{
							"name": "b",
							"type": 18,
							"components": []
						},
						{
							"name": "c",
							"type": 19,
							"components": [
								{
									"name": "x",
									"type": 17,
									"components": []
								},
								{
									"name": "y",
									"type": 17,
									"components": []
								}
							]
						}
					]
				},
				{
					"name": "t",
					"type": 16,
					"components": [
						{
							"name": "x",
							"type": 17,
							"components": []
						},
						{
							"name": "y",
							"type": 17,
							"components": []
						}
					]
				},
				{
					"name": "a",
					"type": 17,
					"components": []
				}
			],
			"outputs": []
		}
	]
}
```