# SET VARIABLES ---------------------------------------------------------------

NEWACCOUNTNAME=""


# CREATE KEY PAIR -------------------------------------------------------------

aws ec2 create-key-pair \
    --key-name $NEWACCOUNTNAME-key-pair \
    --query 'KeyMaterial' \
    --output text > $NEWACCOUNTNAME-key-pair.pem
    --profile $NEWACCOUNTNAME


# STORE IN SECRETS MANAGER ----------------------------------------------------

aws secretsmanager create-secret \
    --name $NEWACCOUNTNAME-key-pair \
    --secret-string file://$NEWACCOUNTNAME-key-pair.pem
    --profile $NEWACCOUNTNAME


# REMOVE LOCAL FILE -----------------------------------------------------------

rm $NEWACCOUNTNAME-key-pair.pem
