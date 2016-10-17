#!/bin/bash

LOGFILE="error_log.txt"

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -e|--email)
    EMAIL="$2"
    shift
    ;;
    -l|--logfile)
    LOGFILE="$2"
    shift
    ;;
    *)
    # unknown
    ;;
esac
shift
done

if [ -z "$EMAIL" ]; then
    echo "
The --email (-e) flag is required. For example:
$ ./cleanify.sh -e joe.bloggs@gov.uk
"
fi

read -p "Are you sure you want to remove user $EMAIL?" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

read -p "And are you sure user $EMAIL is signed out of the service?" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

echo "Cleaning up user: $EMAIL"
PSQL_OUTPUT=$(psql notification_api << EOF
    delete from notification_history;
    delete from notifications;
    delete from jobs;
    delete from api_keys a where a.service_id in (select s.id from services s where s.created_by_id in (select u.id from users u where u.email_address like '$EMAIL%'));
    delete from templates_history t where t.service_id in (select s.id from services s where s.created_by_id in (select u.id from users u where u.email_address like '$EMAIL%'));
    delete from templates t where t.service_id in (select s.id from services s where s.created_by_id in (select u.id from users u where u.email_address like '$EMAIL%'));
    delete from user_to_service p where p.user_id in (select u.id from users u where u.email_address like '$EMAIL%');
    delete from permissions p where p.user_id in (select u.id from users u where u.email_address like '$EMAIL%');
    delete from services_history s where s.created_by_id in (select u.id from users u where u.email_address like '$EMAIL%');
    delete from services s where s.created_by_id in (select u.id from users u where u.email_address like '$EMAIL%');
    delete from verify_codes p where p.user_id in (select u.id from users u where u.email_address like '$EMAIL%');
    delete from users where email_address like '$EMAIL%';
EOF)

# If the DB output ends in "DELETE 1" that suggests the user deleted successfully
if [[ $PSQL_OUTPUT =~ "DELETE 1"$ ]]; then
    echo "All done"
    exit 1;
fi

if [[ $PSQL_OUTPUT =~ "DELETE 0"$ ]]; then
    echo "No user deleted. Does $EMAIL really exist in the system?"
    echo "$(date "+%Y-%m-%d %H:%M:%S") - Unexpected database output for user: $EMAIL
$PSQL_OUTPUT
" >> $LOGFILE
    echo "Database output logged to $LOGFILE"
fi
