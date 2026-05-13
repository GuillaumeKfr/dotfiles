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
    set account (grep '\[.*\]' ~/.aws/credentials | tr -d '[]' | fzf)
    or return

    # Skip saml2aws login if the profile already has valid credentials
    if aws sts get-caller-identity --profile $account >/dev/null 2>&1
        echo "Already authenticated as $account; skipping saml2aws login."
    else
        saml2aws login -a $account -p $account --force $skip_prompt
        or return
    end

    set -gx AWS_PROFILE $account
end
