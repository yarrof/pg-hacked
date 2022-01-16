# pgHacked

## Story

Russian hackers destroyed your files! Have you made a DB dump?

Hope you've been a good boy and done so, otherwise ... kittens might die a terrible death!

## What are you going to learn?

* How to create an empty database and populate it with data using an SQL script
* How to make a database dump/snapshot of a database for backup purposes with `pg_dump`
* What a database dump/snapshot is
* How to identify/diagnose corrupted databases
* Learn how to find database logs and how to read them
* How to configure logging in PostgreSQL using `syslog`
* How to restore a database from a dump/snapshot with `pg_restore`

## Tasks

1. Start and configure a VM with PostgreSQL, create an empty database and import the sample database script.
    - Started a VM loaded and configured with an SSH server and PostgreSQL
    - Setup a shared folder betweeh host and guest to access the project's repository
    - Logged in as `ubuntu` via SSH
    - Created a database called `chinook` and imported the `chinook_data.sql` script

2. Verify that queries work against the sample database.
    - Running the following queries work on the `chinook` database

```sql
SELECT * FROM genre;
SELECT * FROM album;
SELECT * FROM customer;
```

3. Create a database dump/snapshot.
    - Used `pg_dump` to create a dump/snapshot of the `chinook` database
    - The dump is created using `tar` format
    - The dump is saved in a file using the following format `chinook-2020-11-22-04-22-32.tar` (but use the current timestamp)

4. Execute the `pghack.sh` script that simulates the scenario where Russian hackers corrupt your database files.
    - Executed `./pghack.sh` (the script will ask for your `sudo` password)
    - Running the following queries _fail_ on the `chinook` database

```sql
SELECT * FROM genre;
SELECT * FROM album;
SELECT * FROM customer;
```

5. Diagnosing problems starts with digging into log files, sometimes though you need to tell a tool to start logging at all.
    - Verified that `/var/log/syslog` doesn't contain errors related to failed queries
    - Enabled logging to `syslog` by configuring the database (make sure to restart the database server after changing its configuration)
    - Running the `SELECT * FROM genre` query on the `chinook` database fails and generates a log entry in `/var/log/syslog`

6. Fixing a corrupted database, when files are missing is possible if you have a fresh database dump. Let's use ours to fix this mess.
    - The current `chinook` database is dropped and recreated as a new, empty database with the same name
    - Running the following queries _work again_ on the `chinook` database

```sql
SELECT * FROM genre;
SELECT * FROM album;
SELECT * FROM customer;
```
    - Verified that running the queries doesn't create log entry in `/var/log/syslog`

## General requirements

None

## Hints

- You can use `tail` to see the last 10 lines of a file, to see more, like the last 20 use something like `tail -20`
- Use PostgreSQL's `SHOW` command to see the active value of configuration settings like `config_file` and `log_destination` by these as you would do with regular SQL queries
  - `SHOW config_file`
  - `SHOW log_destination`
- `pghack.sh` finds and corrupts the files PostgreSQL uses to store the contents of tables, however this is only a simulation, in the real world you'd rarely see missing table files, but would deal with other kinds of corruptions :)
- When reading about [the casues of DB corruption](https://wiki.postgresql.org/wiki/Corruption#Causes) don't go too far, this is a topic for database administrators, however it's good to know that most of the time hardware failure is the main culprit (like a full disk which accepts no writes, no new files)
- We ask you to turn on logging to `syslog` here, but in a real, production environment this can hog up resources as logging _everything_ to file is expensive, so do it only when really necessary :)

## Background materials

- <i class="far fa-exclamation"></i> [Step by step solution](project/curriculum/materials/pages/guides/pg-hacked--shell.md)
- <i class="far fa-video"></i> [`syslog` explained](https://www.youtube.com/watch?v=k0_gdh_wuAw)
- [`pg_dump`](https://www.postgresql.org/docs/10/backup-dump.html)
- [`pg_restore`](https://www.postgresql.org/docs/10/app-pgrestore.html)
- [PostgreSQL `SHOW`](https://www.postgresql.org/docs/10/sql-show.html)
- [PostgreSQL `log_destination`](https://www.postgresql.org/docs/10/runtime-config-logging.html#RUNTIME-CONFIG-LOGGING-WHERE)
- [Causes of DB corruption](https://wiki.postgresql.org/wiki/Corruption#Causes)
