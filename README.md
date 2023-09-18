<!-- LTeX: enabled=false -->
# nvim-kickstart-python <!-- LTeX: enabled=true -->

A launch point for your nvim config for python.

Like to [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), but specifically python development.

## Motivation
<!-- vale Google.FirstPerson = NO -->
While there are quite a few great nvim distros and nvim starter configs out there, one thing I somewhat missed was a base config for specific languages. I recently started to learn python and was missing a minimal example what the state-of-the-art nvim setup specifically for python is.

After figuring most of it out, I decided to publish this config for others to use. It is intended as a launch point for python devs switching to nvim, or as a reference for nvim users who want to start doing python development.
<!-- vale Google.FirstPerson = NO -->

## Philosophy
- This is not a nvim-distro, this is a *minimal* nvim config specifically for python. It's intended as a starting point for creating your own config.
- ~300 lines, 20 plugins, single file
- Commented in detail, so it is clear what each line does.
- The config can be fully bootstrapped: all plugins and tools are automatically installed on startup.
- Uses the state-of-the-art plugins of the current nvim-ecosystem.
- The setup includes the common tooling for python development:
    - LSP (Completion, Typing): `pyright`
    - Linting: `ruff`
    - Formatting: `black` & `isort`
    - Debugger: `debugpy`
- In addition, this config includes editing utilities specifically for python, like docstrings creation, selecting virtual environments, or auto-converting f-strings.

## Recommendation
Go though the [kickstart-python.lua](./kickstart-python.lua), it is commented in detail.

You can copypaste the config into you current `init.lua` to use it starting point for your regular config, or you can copypaste parts of it into your existing config.

## Download
Download the [kickstart-python.lua](./kickstart-python.lua) file and run neovim with it:

```bash
# download the config
curl --remote-name "https://raw.githubusercontent.com/chrisgrieser/nvim-kickstart-python/main/kickstart-python.lua"

# start neovim with the config, opening a file `foobar.py`
# (any existing config you are using remains untouched)
nvim -u kickstart-python.lua foobar.py
```

The config automatically installs all the plugins and tooling needed.
<!-- vale Google.FirstPerson = NO -->

## Contributions
Though I am experienced with nvim, I am quite new to python. So if I missed something important, contributions are welcome.

## About me
__About Me__  
In my day job, I am a sociologist studying the social mechanisms underlying the digital economy. For my PhD project, I investigate the governance of the app economy and how software ecosystems manage the tension between innovation and compatibility. If you are interested in this subject, feel free to get in touch.

__Blog__  
I also occasionally blog about vim: [Nano Tips for Vim](https://nanotipsforvim.prose.sh)

__Profiles__  
- [reddit](https://www.reddit.com/user/pseudometapseudo/)
- [Discord](https://discordapp.com/users/462774483044794368/)
- [Academic Website](https://chris-grieser.de/)
- [GitHub](https://github.com/chrisgrieser/)
- [Twitter](https://twitter.com/pseudo_meta)
- [ResearchGate](https://www.researchgate.net/profile/Christopher-Grieser)
- [LinkedIn](https://www.linkedin.com/in/christopher-grieser-ba693b17a/)

__Buy Me a Coffee__  
<br>
<a href='https://ko-fi.com/Y8Y86SQ91' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>
