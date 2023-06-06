function dk_alias
    alias dk="docker"
    alias dkl="docker logs"
    alias dklf="docker logs -f"
    alias dki="docker images"
    alias dkc="docker container"
    alias dkrm="docker rm"

    alias dke="docker exec"

# alias dksh="docker exec -it $argv /bin/sh"

    alias dkps="docker ps --format '{{.ID}} ~ {{.Names}} ~ {{.Status}} ~ {{.Image}}'"
    alias dktop="docker stats --format 'table {{.Container}}\t{{.Name}}\t{{.CPUPerc}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}'"

# dkstats() {
#     if [[ $# -eq 0 ]]; then
#         docker stats --no-stream
#     else
#         docker stats --no-stream | grep $1
#     fi
# }

    alias dkprune="docker system prune -af"
end

if type -q docker
    dk_alias
end
