# mwaalog: Open a one-time login link to the MWAA Airflow UI (token valid 60s).
# Assumes a dedicated UI role, since the SSO role can't call mwaa. Site-specific naming lives in two git-ignored helpers
# next to this file: `_mwaalog_role_arn ACCOUNT PREFIX ROLE STAGE` and `_mwaalog_url PREFIX STAGE ACCOUNT REGION TOKEN`.
# Usage: mwaalog [admin|op]   (uses the current AWS_PROFILE, named <prefix>-<dev|test|prod>; run awslog first)
function mwaalog
    set -l role admin
    set -q argv[1]; and set role $argv[1]
    set -l stage (string match -r '[^-]+$' -- $AWS_PROFILE)
    contains -- "$stage" dev test prod; and contains -- "$role" op admin
    or begin
        echo "Usage: mwaalog [admin|op] with AWS_PROFILE=<prefix>-<dev|test|prod> (current: '$AWS_PROFILE')" >&2
        return 1
    end

    set -l prefix (string replace -r -- "-$stage\$" "" $AWS_PROFILE)
    set -l region (aws configure get region)
    or return
    set -l id (string split \t -- (aws sts get-caller-identity --query '[Account,Arn]' --output text))
    or return
    set -l session (string replace -r '.*/' '' -- $id[2])

    set -l c (string split \t -- (aws sts assume-role \
        --role-arn (_mwaalog_role_arn $id[1] $prefix $role $stage) \
        --role-session-name $session \
        --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' --output text))
    or return

    # Token-role credentials apply to this call only.
    set -l token (env -u AWS_PROFILE AWS_ACCESS_KEY_ID=$c[1] AWS_SECRET_ACCESS_KEY=$c[2] AWS_SESSION_TOKEN=$c[3] \
        aws --region $region mwaa create-web-login-token --name $prefix-mwaa-$stage --query WebToken --output text)
    or return

    open (_mwaalog_url $prefix $stage $id[1] $region $token)
end
