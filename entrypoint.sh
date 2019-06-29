#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /myapp/tmp/pids/server.pid

until nc -z -v -w30 $POSTGRES_HOST 5432
do
  >&2 echo "PostgreSQL is unavailable - sleeping"
  # wait for 5 seconds before check again
  sleep 5
done

>&2 echo "PostgreSQL is up - executing command"

bundle exec rake db:create --trace && bundle exec rake db:migrate --trace

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
