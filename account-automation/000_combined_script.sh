# SET VARIABLES ---------------------------------------------------------------

USERNAME=""

NEWACCOUNTNAME=""
EMAIL="aws+${NEWACCOUNTNAME}@gmail.com"
ROLENAME=""


# CREATE ACCOUNT --------------------------------------------------------------

export CREATENEWACCOUNTSTATUSID=$(
aws organizations create-account \
    --email $EMAIL \
    --account-name $NEWACCOUNTNAME \
    --role-name $ROLENAME \
    --query "CreateAccountStatus.{ID:Id}" \
    --output text 
)

sleep 30

export NEWACCOUNTID=$(
    aws organizations describe-create-account-status \
        --create-account-request-id $CREATENEWACCOUNTSTATUSID \
        --query "CreateAccountStatus.{ID:AccountId}" \
        --output text 
)

[[ -z "$NEWACCOUNTID" ]] && { echo "Variable NEWACCOUNTID is empty" ; exit 1; }


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


# UPDATE LOCAL CONFIG ---------------------------------------------------------

aws configure set \
    profile.$NEWACCOUNTNAME.role_arn arn:aws:iam::$NEWACCOUNTID:role/$ROLENAME

aws configure set \
    profile.$NEWACCOUNTNAME.source_profile default


# CREATE KEY PAIR -------------------------------------------------------------

aws ec2 create-key-pair \
    --key-name $NEWACCOUNTNAME-key-pair \
    --query 'KeyMaterial' \
    --output text > $NEWACCOUNTNAME-key-pair.pem \
    --profile $NEWACCOUNTNAME


# STORE IN SECRETS MANAGER ----------------------------------------------------

aws secretsmanager create-secret \
    --name $NEWACCOUNTNAME-key-pair \
    --secret-string file://$NEWACCOUNTNAME-key-pair.pem \
    --profile $NEWACCOUNTNAME


# REMOVE LOCAL FILE -----------------------------------------------------------

rm $NEWACCOUNTNAME-key-pair.pem
