/bin/bash -l -c 'cd $OPENSHIFT_REPO_DIR && bundle exec script/rails runner -e production '\''Vehicle.lalala'\'' >> log/cron_log.log 2>> log/cron_error_log.log'


