test -f ~/.config/opencode/.env; and source ~/.config/opencode/.env

fish_add_path ~/code/lego/b2b-am-frontend/tools/am-dev-tools/bin

# Claude Code through the LEGO GenAI gateway
set -gx ANTHROPIC_AUTH_TOKEN $LEGO_GENAI_KEY
set -gx ANTHROPIC_BASE_URL "https://api.genai.thelegogroup.com/claude"
set -gx ANTHROPIC_DEFAULT_SONNET_MODEL "eu.anthropic.claude-sonnet-5-5"
set -gx ANTHROPIC_DEFAULT_OPUS_MODEL "eu.anthropic.claude-opus-5-5"
set -gx ENABLE_CLAUDEAI_MCP_SERVERS "0"

# AWS & SAML Environment Variables
set -gx AWS_PROFILE default
set -gx AWS_DEFAULT_REGION eu-west-1
set -gx AWS_REGION $AWS_DEFAULT_REGION
set -gx SAML2AWS_REGION $AWS_DEFAULT_REGION

# SAML2AWS
function create_saml2aws_aliases
    set -l config_file "$HOME/.saml2aws"
    if test -f "$config_file"
        for line in (cat "$config_file" | string match -r '^\[.*\]$')
            set -l config_name (string trim -c '[]' "$line")
            alias "saml2aws-$config_name"="saml2aws login -a $config_name --force --skip-prompt"
        end
    end
end
create_saml2aws_aliases

# Core login helper
function _saml_login
    env SAML2AWS_PASSWORD=(cat "$HOME/.aws/pass") saml2aws login --force -a $argv[1] $argv[2..-1]
end

# Profile shortcuts
function amdev   ; _saml_login am-dev $argv ; end
function amqa    ; _saml_login am-qa $argv ; end
function amprod  ; _saml_login am-prod $argv ; end
function spa-dev ; _saml_login spa-dev $argv ; end
function spa-qa  ; _saml_login spa-qa $argv ; end
function spa-prod ; _saml_login spa-prod $argv ; end

# Lego CLI. conf.d loads before config.fish, so brew's PATH may not be set up yet
if test -x /home/linuxbrew/.linuxbrew/bin/lego
    /home/linuxbrew/.linuxbrew/bin/lego completion fish | source
end
