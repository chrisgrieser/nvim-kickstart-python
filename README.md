<!-- LTeX: enabled=false -->
# nvim-kickstart-python <!-- LTeX: enabled=true -->

A launch point for your nvim config for python.

Similar to [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), but
specifically for python.

<!-- toc -->

- [Motivation](#motivation)
- [Philosophy & Features](#philosophy--features)
- [Recommendation](#recommendation)
- [Download](#download)
- [Syntax Highlighting](#syntax-highlighting)
- [Additional plugins of interest](#additional-plugins-of-interest)
- [Recommended Citation](#recommended-citation)
- [Credits](#credits)

<!-- tocstop -->

## Motivation
<!-- vale Google.FirstPerson = NO -->
While there are quite a few great nvim distros and nvim starter configs out
there, one thing I somewhat missed was a base config for specific languages. I
recently started to learn python and was missing a minimal example what the
state-of-the-art nvim setup specifically for python is.

After figuring most of it out, I decided to publish this config for others to
use. It is intended as a launch point for python devs switching to nvim, or as a
reference for nvim users who want to start doing python development.
<!-- vale Google.FirstPerson = NO -->

## Philosophy & Features
- This is not a nvim-distro, this is a *minimal* nvim config specifically for
  python. It's intended as a starting point for creating your own config.
- Requirement: nvim 0.10.
- ~20 plugins, ~400 lines, everything in one single `init.lua`.
- Includes detailed comments explaining what the config does.
- The config can be fully bootstrapped: all plugins and tools are automatically
  installed on startup.
- Uses the current state-of-the-art of the nvim plugin ecosystem.
- Includes some common tooling for python development:
    + LSP (Completion, Typing): `pyright`
    + Linting (Diagnostics): `ruff`
    + Formatting: `black` & `isort`
    + Debugger: `debugpy`
    + Embedded REPL: `ipython` (if not installed, falls back to `python3`)
- In addition, this config includes editing utilities specifically for python,
  like for example docstrings creation, selecting virtual environments, or
  auto-converting f-strings.

## Recommendation
Go though the [kickstart-python.lua](./kickstart-python.lua), it is commented in
detail.

You can copypaste the config into you current `init.lua` to use it as a starting
point for your regular config, or you can copypaste parts of it into your
existing config.

## Download
`kickstart-python` requires at least nvim 0.10.

Download the [kickstart-python.lua](./kickstart-python.lua) file and run neovim
with it:

```bash
# download the config
curl --remote-name "https://raw.githubusercontent.com/chrisgrieser/nvim-kickstart-python/main/kickstart-python.lua"

# start neovim with the config, opening a file `foobar.py`
# (any existing config you are using remains untouched)
nvim -u kickstart-python.lua foobar.py
```

The config automatically installs all the plugins and tooling needed.
<!-- vale Google.FirstPerson = NO -->

## Syntax Highlighting
Is provided by the [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
plugin and/or the [semshi](https://github.com/numirias/semshi) plugin. The later
requires `pynvim` (`python3 -m pip install pynvim`) to be installed.

Both provide better highlighting, treesitter is considered the more "modern"
approach. Treesitter covers some cases semshi does not and vice versa. Have a
[look at the comparison](./treesitter-or-semshi.md) to decide for yourself which
one to use. (You can use both, of course.)

## Additional plugins of interest
These plugins are not included in the config, but they are worth mentioning, as
some people might be interested in them:
- [nvim-various-textobjs](https://github.com/chrisgrieser/nvim-various-textobjs):
  various indentation-based text objects
- [NotebookNavigator](https://github.com/GCBallesteros/NotebookNavigator.nvim):
  Jupyter Notebook emulation
- [magma.nvim](https://github.com/dccsillag/magma-nvim): Jupyter Notebook integration
- [ropify.nvim](https://github.com/niqodea/ropify): ropify integration
- [nvim-conda](https://github.com/kmontocam/nvim-conda): conda environment selector
- [nvim-lspimport](https://github.com/stevanmilic/nvim-lspimport): Automatically
  resolves imports for `pyright`.
- [jupytext.nvim](https://github.com/GCBallesteros/jupytext.nvim): Convert
  Jupyter Notebooks to code and back.
- [py-requirements.nvim](https://github.com/MeanderingProgrammer/py-requirements.nvim): : Helps manage python requirements.

## Recommended Citation
You can cite this software project as:

```txt
Grieser, C. (2023). nvim-kickstart-python [Computer software]. 
https://github.com/chrisgrieser/nvim-kickstart-python
```

For other citation styles, use the following metadata:
- [Citation File Format](./CITATION.cff)
- [BibTeX](./CITATION.bib)

## Credits
__Thanks__  
[kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) as an example how
to do this.

__About Me__  
In my day job, I am a sociologist studying the social mechanisms underlying the
digital economy. For my PhD project, I investigate the governance of the app
economy and how software ecosystems manage the tension between innovation and
compatibility. If you are interested in this subject, feel free to get in touch.

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

<a href='https://ko-fi.com/Y8Y86SQ91' target='_blank'>
<img
	height='36'
	style='border:0px;height:36px;'
	src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3'
	border='0'
	alt='Buy Me a Coffee at ko-fi.com'
/></a>
