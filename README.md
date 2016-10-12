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

Cleanify assumes you've got a standard local Postgres install containing a `notification\_api` database. If it doesn't then it will blow up (figuratively speaking).

## Logging

Cleanify isn't very clever, but if it thinks there is something unusual about the database output then it will log it to `error\_log.txt` in the current directory. If you want it to log somewhere else pass the flag `-l /wherever/you/want/the\_log.txt`.

