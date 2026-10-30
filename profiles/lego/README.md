# LEGO profile

Installed with `./install.sh --lego`. On top of the shared config it adds:

- `home/.config/fish/conf.d/lego.fish`: saml2aws login helpers, AWS environment, Claude Code through the LEGO GenAI gateway, `lego` completions
- `home/.config/mise/conf.d/lego.toml`: saml2aws and the AWS CLI
- `home/.config/opencode/opencode.jsonc`: LEGO GenAI providers and the Atlassian MCP server
- `home/.claude/settings.json`: Claude Code settings for the gateway
- `ai/`: Git and PR conventions, the `jira-ticket` skill and the `morning-briefing` agent
- `setup.sh`: creates `~/.config/opencode/.env` with `LEGO_GENAI_KEY`, installs Homebrew and the LEGO CLI

## Morning briefing

Runs the `morning-briefing` agent (`ai/agents/morning-briefing/`) on the Jira tickets assigned to me. For each ticket it reads Jira, Confluence and the repositories in `~/code/lego`, then summarizes what is needed to complete it.

`home/.local/bin/briefing` starts the OpenCode service and waits for it before running the agent, and stops a run that takes longer than 30 minutes.

The fish hook (`home/.config/fish/conf.d/briefing.fish`) starts `briefing` in the background the first time a terminal is opened on a weekday. It logs to `~/.cache/briefing/<date>.log`. To start it again the same day, run `briefing` manually.

```sh
briefing          # create today's briefing
briefing --force  # regenerate it
```

The briefing is saved to `Lego/Briefings/<date>.md` in the Obsidian vault (`C:\Users\LasseBorringPetersen\Notes\obsidian-notes`) and as the `Briefing <date>` session, so it can also be read and continued in the web UI (`opencode pair`). Each run deletes briefing files and `Briefing <date>` sessions more than two weeks old.
