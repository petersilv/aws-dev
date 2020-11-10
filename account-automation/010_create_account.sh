# SET VARIABLES ---------------------------------------------------------------

NEWACCOUNTNAME=""
ROLENAME=""

# CREATE ACCOUNT --------------------------------------------------------------

aws organizations create-account \
    --email p.silvester.94+$NEWACCOUNTNAME@gmail.com \
    --account-name $NEWACCOUNTNAME \
    --role-name $ROLENAME


# aws organizations describe-create-account-status \
#     --create-account-request-id $CREATENEWACCOUNTSTATUSID \