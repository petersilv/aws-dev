#!/bin/bash

# WRITE LOG TO FILE -----------------------------------------------------------

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>account_automation_$(date +"%Y-%m-%d_%H-%M-%S").log 2>&1


# SET VARIABLES ---------------------------------------------------------------

USERNAME=""

NEWACCOUNTNAME=""
EMAIL="aws+${NEWACCOUNTNAME}@gmail.com"
ROLENAME="OrganizationAccountAccessRole"

echo "$(date) - Variable - USERNAME = $USERNAME"
echo "$(date) - Variable - NEWACCOUNTNAME = $NEWACCOUNTNAME"
echo "$(date) - Variable - EMAIL = $EMAIL"
echo "$(date) - Variable - ROLENAME = $ROLENAME"

# CREATE ACCOUNT --------------------------------------------------------------

echo "$(date) - Create Account - Started"

export CREATENEWACCOUNTSTATUSID=$(
aws organizations create-account \
    --email $EMAIL \
    --account-name $NEWACCOUNTNAME \
    --role-name $ROLENAME \
    --query "CreateAccountStatus.{ID:Id}" \
    --output text 
)

echo "$(date) - Create Account - Completed"

echo "$(date) - Variable - CREATENEWACCOUNTSTATUSID = $CREATENEWACCOUNTSTATUSID"

echo "$(date) - Sleep 30s - Waiting for account to be created"
sleep 30

echo "$(date) - Get Account ID - Started"

export NEWACCOUNTID=$(
    aws organizations describe-create-account-status \
        --create-account-request-id $CREATENEWACCOUNTSTATUSID \
        --query "CreateAccountStatus.{ID:AccountId}" \
        --output text 
)

echo "$(date) - Get Account ID - Completed"

[[ -z "$NEWACCOUNTID" ]] && { echo "$(date) - Error - Variable NEWACCOUNTID is empty" ; exit 1; }


echo "$(date) - Variable - NEWACCOUNTID = $NEWACCOUNTID"


# CREATE IAM POLICY -----------------------------------------------------------

echo "$(date) - Create Policy - Started"

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

echo "$(date) - Create Policy - Completed"

echo "$(date) - Sleep 120s - Waiting for policy to be attachable"
sleep 120


# ATTACH POLICY TO IAM USER ---------------------------------------------------

echo "$(date) - Attach Policy - Started"

aws iam attach-user-policy \
    --user-name $USERNAME \
    --policy-arn $POLICYARN

echo "$(date) - Attach Policy - Completed"


# UPDATE LOCAL CONFIG ---------------------------------------------------------

echo "$(date) - Update Local Config - Started"

aws configure set \
    profile.$NEWACCOUNTNAME.role_arn arn:aws:iam::$NEWACCOUNTID:role/$ROLENAME

aws configure set \
    profile.$NEWACCOUNTNAME.source_profile default

echo "$(date) - Update Local Config - Completed"


# CREATE KEY PAIR -------------------------------------------------------------

echo "$(date) - Create Key Pair - Started"

aws ec2 create-key-pair \
    --key-name $NEWACCOUNTNAME-key-pair \
    --query 'KeyMaterial' \
    --output text > $NEWACCOUNTNAME-key-pair.pem \
    --profile $NEWACCOUNTNAME \
    --region eu-west-2

echo "$(date) - Create Key Pair - Completed"


# STORE IN SECRETS MANAGER ----------------------------------------------------

echo "$(date) - Store Key Pair in Secrets Manager - Started"

aws secretsmanager create-secret \
    --name $NEWACCOUNTNAME-key-pair \
    --secret-string file://$NEWACCOUNTNAME-key-pair.pem \
    --profile $NEWACCOUNTNAME \
    --region eu-west-2

echo "$(date) - Store Key Pair in Secrets Manager - Completed"


# REMOVE LOCAL FILE -----------------------------------------------------------

rm $NEWACCOUNTNAME-key-pair.pem
