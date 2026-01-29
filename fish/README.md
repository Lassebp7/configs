# Fish shell

## Config

Clone config from

[Link to repo](https://github.com/Lassebp7/configs)

Copy into `.config` folder

`cp -r fish/.config/* ~/.config/`

Consider maybe using a symlink instead?

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

### Global mise installations

Should already be defined in `fish/.config/mise/config.toml`

Otherwise copy these

```toml
[tools]
dotnet = "9"
node = "latest"
npm = "latest"
bun = "latest"
pnpm = "latest"
github-cli = "latest"
usage = "latest"

[settings]
verbose = false
```
