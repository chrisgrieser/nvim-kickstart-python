<!-- LTeX: enabled=false -->
# nvim-kickstart-python <!-- LTeX: enabled=true -->
A launch point for your nvim configuration for python. Like to [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), but specific setup for python.

## Philosophy
- This is not a nvim-distro, this is a *minimal* nvim config specifically for python.
- The config can be fully bootstrapped, all plugins and tooling are installed are automatically installed on startup.
- The setup includes all tooling for modern python development:
    - LSP (Completion, Typing): `pyright`
    - Linting: `ruff`
    - Formatting: `black` and `isort`
    - Debugging: `debugpy`
- In addition, it includes some small editing utilities specifically for python.

## Usage
The recommended way is to download the [init.lua](./init.lua) file and run neovim with it:

```bash
nvim -u kickstart-python.lua foobar.py
```

The config automatically installs all the plugins and tooling needed.
