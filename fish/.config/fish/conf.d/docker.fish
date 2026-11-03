function dk_alias
    function dksh
        docker exec -it $argv /bin/sh
    end

    function dkstats
        if count $argv > /dev/null
            docker stats --no-stream | grep $argv
        else
            docker stats --no-stream
        end
    end
end

if type -q docker
    dk_alias
end
