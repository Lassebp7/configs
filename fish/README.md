# Fish shell

## Config repo

First, you need git

`sudo apt install git`

And then you need a shh-key to clone it

`ssh-keygen -t ed25519 -C "your_email@example.com"`

That you then view by running 

`cat ./.ssh/id_ed25519.pub`

Which you then use on Github to create a new SSH key [here](https://github.com/settings/keys)

Then you can clone the config repo from

[Link to repo](https://github.com/Lassebp7/configs)

### Symlink

Link your personal config to the one in the repo to get automatic updates.

First, the `~/.config/fish` folder must be empty, so run

`rm -rf ~/.config/fish`

Then create the link, remember to make the paths match. Will likely be the following:

`ln -s ~/code/configs/fish/.config/fish ~/.config/fish`

And of course check if it worked:

`ls -la ~/.config | grep fish`

If it prints something like

`lrwxrwxrwx fish -> ~/code/configs/fish/.config/fish`

Then its successful, and any change made to either the `~/.config/fish` folder, or to the folder in the repo, with automatically update the other.

## Mise

Installing mise on ubuntu

```sh
sudo apt update -y && sudo apt install -y curl
sudo install -dm 755 /etc/apt/keyrings
curl -fSs https://mise.jdx.dev/gpg-key.pub | sudo tee /etc/apt/keyrings/mise-archive-keyring.asc 1> /dev/null
echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.asc] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
sudo apt update -y
sudo apt install -y mise
```

Activation should be automatic after reloading the shell.

You also need to go to the config folder and run `mise trust`

### Global mise installations

Should already be defined in `fish/.config/mise/config.toml`

Otherwise copy these

```toml
[tools]
dotnet = "latest"
node = "latest"
npm = "latest"
bun = "latest"
pnpm = "latest"
github-cli = "latest"
usage = "latest"

[settings]
verbose = false
```

## Install Starship

`curl -sS https://starship.rs/install.sh | sh` 

## Setting fish shell as default shell
Run this command in WSL

`chsh -s /usr/bin/fish` 