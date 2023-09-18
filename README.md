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
# down load the config
curl -O "https://raw.githubusercontent.com/chrisgrieser/nvim-kickstart-python/main/kickstart-python.lua"

# start neovim with the config, opening a file `foobar.py`
# (any existing config you are using remains untouched)
nvim -u kickstart-python.lua foobar.py

# replace your configh with kickstart-python.lua
cp -f kickstart-python.lua ~/.config/nvim
```

The config automatically installs all the plugins and tooling needed.
