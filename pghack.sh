#!/bin/bash
hack() {
  data_dir="$(psql "$db" -Atc 'SHOW data_directory')"
  base_dir="$data_dir/base"
  db_oid="$(psql "$db" -Atc 'SELECT oid FROM pg_database WHERE datname = current_database()')"
  db_dir="$base_dir/$db_oid"
  table_oids=$(psql "$db" -At <<EOF
SELECT
  c.relfilenode
FROM
  pg_class AS c
JOIN
  pg_namespace AS n ON c.relnamespace = n.oid
WHERE
  n.nspname = 'public'
AND
  c.relkind = 'r'
AND
  c.relname IN ('album', 'genre', 'customer')
EOF
)

  for table_oid in $table_oids
  do
    table_file="$db_dir/$table_oid"
    size=$(sudo stat -c '%s' "$table_file")
    sudo dd bs=1 count=$size if=/dev/urandom of="$table_file" 2> /dev/null
  done

  sync

  sudo systemctl restart postgresql
}

db="${1:-chinook}"
if [ -z "$db" ]
then
  echo "A database name must be specified as the first argument!"
  exit 1
fi

# Forces entering sudo password at the script's start
sudo -i -u postgres logout

echo 'H4ck1ng 1n pr0gr3$$!'
hack
echo 'C0rrupt1ng d4t4b4$3$!'
# Need to run hack twice for some reason
# otherwise queries will still work ...
hack

psql "$db" -c 'SELECT * FROM genre' &> /dev/null
psql "$db" -c 'SELECT * FROM album' &> /dev/null
psql "$db" -c 'SELECT * FROM customer' &> /dev/null

echo '4ll y0ur d4t4 4r3 b3l0ng t0 u$!'
