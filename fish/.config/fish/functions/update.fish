function update
    switch (uname)
        case Linux
            sudo apt update
            sudo apt upgrade -y
            sudo apt autoremove
        case Darwin
            # macOS: skip apt
    end

    brew update
    brew upgrade
    brew cleanup
end
