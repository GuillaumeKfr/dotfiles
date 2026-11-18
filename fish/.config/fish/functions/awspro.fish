# awspro: Set AWS_PROFILE interactively and display the selected profile's credentials.
function awspro
    # Present a menu of AWS profiles from ~/.saml2aws
    set account (sed -n 's/^\[\(.*\)\]/\1/p' ~/.saml2aws | fzf)
    set -gx AWS_PROFILE $account
    echo "Active AWS Profile : $AWS_PROFILE"
end
