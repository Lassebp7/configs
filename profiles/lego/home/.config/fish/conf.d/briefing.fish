# Starts the morning briefing in the background the first time a terminal is opened on a weekday.
# Linked into ~/.config/fish/conf.d/ so fish loads it on startup.

status is-interactive; or return
test (date +%u) -le 5; or return

set -l state_dir ~/.cache/briefing
set -l today (date +%F)
set -l marker $state_dir/last-start

if test -f $marker; and test (cat $marker) = $today
    return
end

mkdir -p $state_dir
echo $today >$marker

# conf.d loads before config.fish, so the provider key isn't set yet; the briefing starts the shared OpenCode service, which needs it
source ~/.config/opencode/.env

nohup briefing >$state_dir/$today.log 2>&1 &
disown
echo "Morning briefing started in the background (log: $state_dir/$today.log)"
