# awslog: Login to AWS using saml2aws and set AWS_PROFILE.
# Usage: awslog [-s|--skip-prompt]
function awslog
    # Parse arguments passed to the function
    argparse 's/skip-prompt' -- $argv
    or return

    # Handle optional s/skip_prompt flag
    set -l skip_prompt
    if set -ql _flag_s
        set skip_prompt --skip-prompt
    end

    # Present a menu of AWS profiles from ~/.aws/credentials
    set account $(grep '\[.*\]' ~/.aws/credentials | tr -d '[]' | fzf)

    # Login using saml2aws and set AWS_PROFILE
    saml2aws login -a $account -p $account --force $skip_prompt
    set -gx AWS_PROFILE $account
end
