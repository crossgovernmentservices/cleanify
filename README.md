# Cleanify

Cleanify is a shell script which removes a user from a local [`notifications-api`](https://github.com/alphagov/notifications-api) database based on their email address.

This is a useful thing to have if you want to run Notify locally and go through the user registration process a whole load of times from scratch. Which is what we need to do.

## Usage

```
./cleanify.sh -e some.email@some.domain.gov.uk
```

### Flags

```
 -e | --email      Email address of user to remove from local notifications-api database
 -l | --logfile    File to log errors to
```

## Assumptions

Cleanify assumes you've got a standard local Postgres install containing a `notification_api` database. If it doesn't then it will blow up (figuratively speaking).

## Logging

Cleanify isn't very clever, but if it thinks there is something unusual about the database output then it will log it to `error_log.txt` in the current directory. If you want it to log somewhere else pass the flag `-l /wherever/you/want/the_log.txt`.

## Why does the user need to be logged out?

Cleanify will ask you to confirm that a user is logged out before removing them from the DB. If they aren't logged out then the session cookies from when the user existed will cause problems. If you end up in this situation then clear your cookies.
