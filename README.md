# Configuration repo for personal use

## Obsidian

Clone the notes repo and add it as an existing vault

[Link to repo](https://github.com/Lassebp7/obsidian-notes)

## Flow launcher

### Styling

Theme: Cyan Dark

Clock: hh:mm tt

Date: MM'/'dd ddd

### Shortcuts

dl - C:\Users\LasseBorringPetersen\Downloads\

## WSL

Install by running the following command in powershell, in administrator mode

`wsl --install`

By default installs Ubuntu distribution. Then follow [WSL setup](#wsl-setup).

### Terminal Styling

Color scheme: `One Half Dark`

Font face: `JetBrainsMonoNL Nerd Font`

[Link to font](https://www.nerdfonts.com/font-downloads)

Font size: 13

Line height: 1.2

Cell width: 0.6

Remember to set as default terminal as well.

## Rainmeter

Download rainmeter using winget, is also in mass install script

`winget install Rainmeter.Rainmeter`

Then install the `Mond` configuration for it

[Link to Mond](https://visualskins.com/skin/mond)

Make clock non-draggable, remove player, remove weather, remove bin

## WSL setup

On a fresh WSL install, run this with the profile for the machine:

```sh
curl -fsSL https://raw.githubusercontent.com/Lassebp7/configs/main/bootstrap.sh | bash -s -- --lego
```

It clones this repo to `~/code/configs` and runs `install.sh`. `install.sh` is safe to run again and does the following:

1. Installs apt packages: git, fish, curl, unzip, build-essential, stow.
2. Creates an SSH key if there is none, waits for you to add it to GitHub, and switches the repo remote to SSH.
3. Symlinks `home/` and `profiles/<profile>/home/` into `~` with stow. Anything in the way is moved to `~/.dotfiles-backup/<timestamp>/`.
4. Builds the AI instructions, skills and agents for OpenCode and Claude Code (see below).
5. Installs mise and the tools in `~/.config/mise/` (node, dotnet, starship, lazygit, zoxide, kubectl, ...).
6. Installs OpenCode and Claude Code.
7. Runs `profiles/<profile>/setup.sh`, if the profile has one.
8. Sets fish as the default shell.

The chosen profile is saved in `~/.config/dotfiles/profile`, so later runs can just use `./install.sh`. Use `./install.sh --links-only`, or `dotfiles-sync` in fish, after changing files in the repo. It relinks the dotfiles and rebuilds the AI config without installing anything.

## Profiles

Each machine uses one profile from `profiles/`. The flag is the folder name, so `--lego` uses `profiles/lego/`. A profile can contain any of:

- `home/`: dotfiles linked into `~` next to the shared ones. A file can't exist in both `home/` and a profile's `home/`. Files that differ per profile, such as `~/.config/opencode/opencode.jsonc`, therefore live only in the profiles. Use `~/.config/fish/conf.d/` and `~/.config/mise/conf.d/` for profile additions.
- `ai/`: extra `AGENTS.md` content, skills and agents
- `setup.sh`: profile-specific installs and prompts

To add a company, create `profiles/<company>/` and run `./install.sh --<company>`. Switching profiles removes the previous profile's links.

## AI instructions, skills and agents

OpenCode and Claude Code get the same instructions, skills and agents, built by `scripts/build-ai.sh` from `ai/` plus `profiles/<profile>/ai/`:

- `AGENTS.md`: the shared file followed by the profile's. Written to `~/.config/opencode/AGENTS.md` and `~/.claude/CLAUDE.md`.
- `skills/<name>/SKILL.md`: each skill folder is symlinked into `~/.config/opencode/skills/` and `~/.claude/skills/`.
- `agents/<name>/`:
  - `prompt.md` holds the shared frontmatter (`description`) and the prompt.
  - `opencode.yaml` and `claude.yaml` hold each tool's own frontmatter, such as OpenCode `mode`/`permissions` or Claude `tools`/`model`.
  - The agent is only installed in a tool if it has that tool's yaml file. The Claude `name` is set from the folder name.

Profile skills and agents replace shared ones with the same name. The generated files are overwritten on every build, so edit the repo instead.