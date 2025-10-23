# awslog: Login to AWS using saml2aws and set AWS_PROFILE.
function awslog
    # Present a menu of AWS profiles from ~/.aws/credentials
    set account  $(grep '\[.*\]' ~/.aws/credentials | tr -d '[]' | fzf)
    # Login using saml2aws and set AWS_PROFILE
	saml2aws login -a $account -p $account --force $skip_prompt
	set -gx AWS_PROFILE $account
end
