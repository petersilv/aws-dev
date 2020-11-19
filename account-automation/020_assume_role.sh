# SET VARIABLES ---------------------------------------------------------------

USERNAME=""

NEWACCOUNTID=""

NEWACCOUNTNAME=""
ROLENAME=""


# CREATE IAM POLICY -----------------------------------------------------------

cat > assume_role_policy.json <<- EOM
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "arn:aws:iam::$NEWACCOUNTID:role/$ROLENAME"
    }
}
EOM

export POLICYARN=$( 
    aws iam create-policy \
        --policy-name account-access-$NEWACCOUNTNAME \
        --policy-document file://./assume_role_policy.json \
        --query 'Policy.{ARN:Arn}' \
        --output text 
)

rm assume_role_policy.json
sleep 120


# ATTACH POLICY TO IAM USER ---------------------------------------------------

aws iam attach-user-policy \
    --user-name $USERNAME \
    --policy-arn $POLICYARN

sleep 120


# CHECK POLICY IS ATTACHED -----------------------------------------------------

export ATTACHEDPOLICY=$( 
    aws iam list-attached-user-policies \
        --user-name account-automation \
        --profile programmatic_admin \
        --query "AttachedPolicies[?PolicyArn=='$POLICYARN'].{PolicyArn:PolicyArn}" \
        --output text 
)

[[ -z "$ATTACHEDPOLICY" ]] && { exit 1; }


# UPDATE LOCAL CONFIG ---------------------------------------------------------

aws configure set \
    profile.$NEWACCOUNTNAME.role_arn arn:aws:iam::$NEWACCOUNTID:role/$ROLENAME

aws configure set \
    profile.$NEWACCOUNTNAME.source_profile default
