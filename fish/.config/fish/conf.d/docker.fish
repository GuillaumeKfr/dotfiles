function dk_alias
    abbr --add dk docker
    abbr --add dkl docker logs
    abbr --add dklf docker logs -f
    abbr --add dki docker images
    abbr --add dkc docker container
    abbr --add dkrm docker rm

    abbr --add dke docker exec

    function dksh
        docker exec -it $argv /bin/sh
    end

    alias dkps="docker ps --format '{{.ID}} ~ {{.Names}} ~ {{.Status}} ~ {{.Image}}'"
    alias dktop="docker stats --format 'table {{.Container}}\t{{.Name}}\t{{.CPUPerc}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}'"

    function dkstats
        if count $argv > /dev/null
            docker stats --no-stream | grep $argv
        else
            docker stats --no-stream
        end
    end

    abbr --add dkprune docker system prune -af
end

if type -q docker
    dk_alias
end
