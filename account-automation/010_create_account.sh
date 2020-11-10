# SET VARIABLES ---------------------------------------------------------------

NEWACCOUNTNAME=""
EMAIL="aws+${NEWACCOUNTNAME}@gmail.com"
ROLENAME=""

# CREATE ACCOUNT --------------------------------------------------------------

aws organizations create-account \
    --email $EMAIL \
    --account-name $NEWACCOUNTNAME \
    --role-name $ROLENAME

