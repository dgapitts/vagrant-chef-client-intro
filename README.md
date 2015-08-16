# Getting started with Chef Client and Hosted Chef

After yesterday working on chef-solo, today I switched to the more standard chef client/server model using the 'chef cloud hosted service' for the server side i.e. https://manage.chef.io/.

Again I have loosely following one of the getting started tutorails: http://gettingstartedwithchef.com/introducing-chef-server.html. 

Although my focus was not on building another lamp stack, instead I wanted to install postgres.

This time, instead on the trusty64 (14.04) Ubuntu box image, I used an opscode box running centos 6.4 (opscode-centos-6.4), as this is pre-configured to make the chef-provisioning simpler ... this wasn't mentinoed in the above tutorial which is focused on clients in the cloud e.g. rackspace and not vagrant/virtualbox local VMs. However after some googling I found: http://selvakumar.me/opscode-chef-setup-and-sample-cookbook-reference/.

So how did it work, well the first steps are similar to chef-solo:
  - step01_setup_chef_and_download_postgres_cookbook.sh

although I'm now add both my personal and my organization keys:
```sh
cp /vagrant/dgapitts.pem /vagrant/chef-repo/.chef/
cp /vagrant/dgapitts_demo-validator.pem /vagrant/chef-repo/.chef/
```
There is also a node key which needs to be copied:
```sh
sudo cp /vagrant/chefclient01.pem /etc/chef/client.pem
```
Naturally all these keys most downloaded for yourself i.e. you have registered your user-id, organization-id and node-id, after you have registered these within https://manage.chef.io/.

Lastly at the end of this script, I use knife to download the postgresql cookbook:
```sh
#download postgres cookbook
cd /vagrant/chef-repo/cookbooks
knife cookbook site download postgresql
tar zxf postgresql-3.4.20.tar.gz
rm postgresql*tar.gz
```

The 2nd script (step02_knife_upload_cookbooks.sh) is simpler:

```sh
#download postgres cookbook
echo '*** upload pre-requisite cookbooks : [apt,build-essential, chef-sugar, openssl] ***'
cd /vagrant/chef-repo/cookbooks
knife cookbook upload apt
knife cookbook upload build-essential
knife cookbook upload chef-sugar
knife cookbook upload openssl
```

Now stepping carefully through the tutorial, I creates a pg_db role, adding to "recipe[postgresql::server]" to the run_list:

```sh
[vagrant@localhost vagrant]$ knife role create pg_db --editor vi
Created role[pg_db]
```

This role was uploaded to the cloud and can be inspected via the show command:

```sh
[vagrant@localhost chef-repo]$ knife role show pg_db -d -Fjson
{
  "name": "pg_db",
  "description": "",
  "json_class": "Chef::Role",
  "default_attributes": {

  },
  "override_attributes": {

  },
  "chef_type": "role",
  "run_list": [
    "recipe[postgresql::server]"
  ],
  "env_run_lists": {
  }
}
```

I also created a named copy under the chef-repo/roles directory:

```sh
knife role show pg_db -d -Fjson > roles/pg_db.json
```

The final step proved quite tricky (http://stackoverflow.com/questions/15373209/issue-with-chef-knife-bootstrapping-a-vagrant-vm), I fixed my issues via a small hack (i.e. setting a root password)

```sh
[vagrant@chefclient01 chef-repo]$ knife bootstrap --run-list "role[pg_db]" --json-attributes "{\"pg_db\": {\"server_name\": \"chefclient01\"}}" --sudo chefclient01
```

and here is the install log/details


```sh
Doing old-style registration with the validation key at /vagrant/chef-repo/.chef/dgapitts_demo-validator.pem...
Delete your validation key in order to use your user credentials instead

Connecting to chefclient01
root@chefclient01's password:
chefclient01 -----> Existing Chef installation detected
chefclient01 Starting first Chef Client run...
chefclient01 Starting Chef Client, version 12.4.1
chefclient01 resolving cookbooks for run list: ["postgresql::server"]
chefclient01 Synchronizing Cookbooks:
chefclient01   - build-essential
chefclient01   - apt
chefclient01   - chef-sugar
chefclient01   - openssl
chefclient01   - postgresql
chefclient01 Compiling Cookbooks...
chefclient01 Converging 12 resources
chefclient01 Recipe: postgresql::client
chefclient01   * yum_package[postgresql-devel] action install
chefclient01     - install version 8.4.20-3.el6_6 of package postgresql-devel
chefclient01 Recipe: postgresql::server_redhat
chefclient01   * group[postgres] action create
chefclient01     - create postgres
chefclient01   * user[postgres] action create
chefclient01     - create user postgres
chefclient01   * directory[/var/lib/pgsql/data] action create
chefclient01     - create new directory /var/lib/pgsql/data
chefclient01     - change owner from '' to 'postgres'
chefclient01     - change group from '' to 'postgres'
chefclient01   * yum_package[postgresql-server] action install
chefclient01     - install version 8.4.20-3.el6_6 of package postgresql-server
chefclient01   * directory[/etc/sysconfig/pgsql] action create
chefclient01     - change mode from '0755' to '0644'
chefclient01   * template[/etc/sysconfig/pgsql/postgresql] action create
chefclient01     - create new file /etc/sysconfig/pgsql/postgresql
chefclient01     - update content in file /etc/sysconfig/pgsql/postgresql from none to b2892e
chefclient01     --- /etc/sysconfig/pgsql/postgresql	2015-08-16 17:16:37.149369847 +0000
chefclient01     +++ /tmp/chef-rendered-template20150816-3283-f5ot82	2015-08-16 17:16:37.149369847 +0000
chefclient01     @@ -1 +1,3 @@
chefclient01     +PGDATA=/var/lib/pgsql/data
chefclient01     +PGPORT=5432
chefclient01     - change mode from '' to '0644'
chefclient01   * execute[/sbin/service postgresql initdb ] action run
chefclient01     - execute /sbin/service postgresql initdb
chefclient01 Recipe: postgresql::server_conf
chefclient01   * template[/var/lib/pgsql/data/postgresql.conf] action create
chefclient01     - update content in file /var/lib/pgsql/data/postgresql.conf from 7b00a2 to afb1b3
chefclient01     --- /var/lib/pgsql/data/postgresql.conf	2015-08-16 17:16:39.101393348 +0000
chefclient01     +++ /tmp/chef-rendered-template20150816-3283-vjaj49	2015-08-16 17:16:43.457214336 +0000
chefclient01     @@ -1,502 +1,23 @@
chefclient01     -# -----------------------------
chefclient01      # PostgreSQL configuration file
chefclient01     -# -----------------------------
chefclient01     -#
chefclient01     -# This file consists of lines of the form:
chefclient01     -#
chefclient01     -#   name = value
chefclient01     -#
chefclient01     -# (The "=" is optional.)  Whitespace may be used.  Comments are introduced with
chefclient01     -# "#" anywhere on a line.  The complete list of parameter names and allowed
chefclient01     -# values can be found in the PostgreSQL documentation.
chefclient01     -#
chefclient01     -# The commented-out settings shown in this file represent the default values.
chefclient01     -# Re-commenting a setting is NOT sufficient to revert it to the default value;
chefclient01     -# you need to reload the server.
chefclient01     -#
chefclient01     -# This file is read on server startup and when the server receives a SIGHUP
chefclient01     -# signal.  If you edit the file on a running system, you have to SIGHUP the
chefclient01     -# server for the changes to take effect, or use "pg_ctl reload".  Some
chefclient01     -# parameters, which are marked below, require a server shutdown and restart to
chefclient01     -# take effect.
chefclient01     -#
chefclient01     -# Any parameter can also be given as a command-line option to the server, e.g.,
chefclient01     -# "postgres -c log_connections=on".  Some parameters can be changed at run time
chefclient01     -# with the "SET" SQL command.
chefclient01     -#
chefclient01     -# Memory units:  kB = kilobytes        Time units:  ms  = milliseconds
chefclient01     -#                MB = megabytes                     s   = seconds
chefclient01     -#                GB = gigabytes                     min = minutes
chefclient01     -#                                                   h   = hours
chefclient01     -#                                                   d   = days
chefclient01     +# This file was automatically generated and dropped off by chef!
chefclient01     +# Please refer to the PostgreSQL documentation for details on
chefclient01     +# configuration settings.
chefclient01
chefclient01     -
chefclient01     -#------------------------------------------------------------------------------
chefclient01     -# FILE LOCATIONS
chefclient01     -#------------------------------------------------------------------------------
chefclient01     -
chefclient01     -# The default values of these variables are driven from the -D command-line
chefclient01     -# option or PGDATA environment variable, represented here as ConfigDir.
chefclient01     -
chefclient01     -#data_directory = 'ConfigDir'		# use data in another directory
chefclient01     -					# (change requires restart)
chefclient01     -#hba_file = 'ConfigDir/pg_hba.conf'	# host-based authentication file
chefclient01     -					# (change requires restart)
chefclient01     -#ident_file = 'ConfigDir/pg_ident.conf'	# ident configuration file
chefclient01     -					# (change requires restart)
chefclient01     -
chefclient01     -# If external_pid_file is not explicitly set, no extra PID file is written.
chefclient01     -#external_pid_file = '(none)'		# write an extra PID file
chefclient01     -					# (change requires restart)
chefclient01     -
chefclient01     -
chefclient01     -#------------------------------------------------------------------------------
chefclient01     -# CONNECTIONS AND AUTHENTICATION
chefclient01     -#------------------------------------------------------------------------------
chefclient01     -
chefclient01     -# - Connection Settings -
chefclient01     -
chefclient01     -#listen_addresses = 'localhost'		# what IP address(es) to listen on;
chefclient01     -					# comma-separated list of addresses;
chefclient01     -					# defaults to 'localhost', '*' = all
chefclient01     -					# (change requires restart)
chefclient01     -#port = 5432				# (change requires restart)
chefclient01     -max_connections = 100			# (change requires restart)
chefclient01     -# Note:  Increasing max_connections costs ~400 bytes of shared memory per
chefclient01     -# connection slot, plus lock space (see max_locks_per_transaction).
chefclient01     -#superuser_reserved_connections = 3	# (change requires restart)
chefclient01     -#unix_socket_directory = ''		# (change requires restart)
chefclient01     -#unix_socket_group = ''			# (change requires restart)
chefclient01     -#unix_socket_permissions = 0777		# begin with 0 to use octal notation
chefclient01     -					# (change requires restart)
chefclient01     -#bonjour_name = ''			# defaults to the computer name
chefclient01     -					# (change requires restart)
chefclient01     -
chefclient01     -# - Security and Authentication -
chefclient01     -
chefclient01     -#authentication_timeout = 1min		# 1s-600s
chefclient01     -#ssl = off				# (change requires restart)
chefclient01     -#ssl_ciphers = 'ALL:!ADH:!LOW:!EXP:!MD5:@STRENGTH'	# allowed SSL ciphers
chefclient01     -					# (change requires restart)
chefclient01     -#ssl_renegotiation_limit = 512MB	# amount of data between renegotiations
chefclient01     -#password_encryption = on
chefclient01     -#db_user_namespace = off
chefclient01     -
chefclient01     -# Kerberos and GSSAPI
chefclient01     -#krb_server_keyfile = ''
chefclient01     -#krb_srvname = 'postgres'		# (Kerberos only)
chefclient01     -#krb_caseins_users = off
chefclient01     -
chefclient01     -# - TCP Keepalives -
chefclient01     -# see "man 7 tcp" for details
chefclient01     -
chefclient01     -#tcp_keepalives_idle = 0		# TCP_KEEPIDLE, in seconds;
chefclient01     -					# 0 selects the system default
chefclient01     -#tcp_keepalives_interval = 0		# TCP_KEEPINTVL, in seconds;
chefclient01     -					# 0 selects the system default
chefclient01     -#tcp_keepalives_count = 0		# TCP_KEEPCNT;
chefclient01     -					# 0 selects the system default
chefclient01     -
chefclient01     -
chefclient01     -#------------------------------------------------------------------------------
chefclient01     -# RESOURCE USAGE (except WAL)
chefclient01     -#------------------------------------------------------------------------------
chefclient01     -
chefclient01     -# - Memory -
chefclient01     -
chefclient01     -shared_buffers = 32MB			# min 128kB
chefclient01     -					# (change requires restart)
chefclient01     -#temp_buffers = 8MB			# min 800kB
chefclient01     -#max_prepared_transactions = 0		# zero disables the feature
chefclient01     -					# (change requires restart)
chefclient01     -# Note:  Increasing max_prepared_transactions costs ~600 bytes of shared memory
chefclient01     -# per transaction slot, plus lock space (see max_locks_per_transaction).
chefclient01     -# It is not advisable to set max_prepared_transactions nonzero unless you
chefclient01     -# actively intend to use prepared transactions.
chefclient01     -#work_mem = 1MB				# min 64kB
chefclient01     -#maintenance_work_mem = 16MB		# min 1MB
chefclient01     -#max_stack_depth = 2MB			# min 100kB
chefclient01     -
chefclient01     -# - Kernel Resource Usage -
chefclient01     -
chefclient01     -#max_files_per_process = 1000		# min 25
chefclient01     -					# (change requires restart)
chefclient01     -#shared_preload_libraries = ''		# (change requires restart)
chefclient01     -
chefclient01     -# - Cost-Based Vacuum Delay -
chefclient01     -
chefclient01     -#vacuum_cost_delay = 0ms		# 0-100 milliseconds
chefclient01     -#vacuum_cost_page_hit = 1		# 0-10000 credits
chefclient01     -#vacuum_cost_page_miss = 10		# 0-10000 credits
chefclient01     -#vacuum_cost_page_dirty = 20		# 0-10000 credits
chefclient01     -#vacuum_cost_limit = 200		# 1-10000 credits
chefclient01     -
chefclient01     -# - Background Writer -
chefclient01     -
chefclient01     -#bgwriter_delay = 200ms			# 10-10000ms between rounds
chefclient01     -#bgwriter_lru_maxpages = 100		# 0-1000 max buffers written/round
chefclient01     -#bgwriter_lru_multiplier = 2.0		# 0-10.0 multipler on buffers scanned/round
chefclient01     -
chefclient01     -# - Asynchronous Behavior -
chefclient01     -
chefclient01     -#effective_io_concurrency = 1		# 1-1000. 0 disables prefetching
chefclient01     -
chefclient01     -
chefclient01     -#------------------------------------------------------------------------------
chefclient01     -# WRITE AHEAD LOG
chefclient01     -#------------------------------------------------------------------------------
chefclient01     -
chefclient01     -# - Settings -
chefclient01     -
chefclient01     -#fsync = on				# turns forced synchronization on or off
chefclient01     -#synchronous_commit = on		# immediate fsync at commit
chefclient01     -#wal_sync_method = fsync		# the default is the first option
chefclient01     -					# supported by the operating system:
chefclient01     -					#   open_datasync
chefclient01     -					#   fdatasync (default on Linux)
chefclient01     -					#   fsync
chefclient01     -					#   fsync_writethrough
chefclient01     -					#   open_sync
chefclient01     -#full_page_writes = on			# recover from partial page writes
chefclient01     -#wal_buffers = 64kB			# min 32kB
chefclient01     -					# (change requires restart)
chefclient01     -#wal_writer_delay = 200ms		# 1-10000 milliseconds
chefclient01     -
chefclient01     -#commit_delay = 0			# range 0-100000, in microseconds
chefclient01     -#commit_siblings = 5			# range 1-1000
chefclient01     -
chefclient01     -# - Checkpoints -
chefclient01     -
chefclient01     -#checkpoint_segments = 3		# in logfile segments, min 1, 16MB each
chefclient01     -#checkpoint_timeout = 5min		# range 30s-1h
chefclient01     -#checkpoint_completion_target = 0.5	# checkpoint target duration, 0.0 - 1.0
chefclient01     -#checkpoint_warning = 30s		# 0 disables
chefclient01     -
chefclient01     -# - Archiving -
chefclient01     -
chefclient01     -#archive_mode = off		# allows archiving to be done
chefclient01     -				# (change requires restart)
chefclient01     -#archive_command = ''		# command to use to archive a logfile segment
chefclient01     -#archive_timeout = 0		# force a logfile segment switch after this
chefclient01     -				# number of seconds; 0 disables
chefclient01     -
chefclient01     -
chefclient01     -#------------------------------------------------------------------------------
chefclient01     -# QUERY TUNING
chefclient01     -#------------------------------------------------------------------------------
chefclient01     -
chefclient01     -# - Planner Method Configuration -
chefclient01     -
chefclient01     -#enable_bitmapscan = on
chefclient01     -#enable_hashagg = on
chefclient01     -#enable_hashjoin = on
chefclient01     -#enable_indexscan = on
chefclient01     -#enable_mergejoin = on
chefclient01     -#enable_nestloop = on
chefclient01     -#enable_seqscan = on
chefclient01     -#enable_sort = on
chefclient01     -#enable_tidscan = on
chefclient01     -
chefclient01     -# - Planner Cost Constants -
chefclient01     -
chefclient01     -#seq_page_cost = 1.0			# measured on an arbitrary scale
chefclient01     -#random_page_cost = 4.0			# same scale as above
chefclient01     -#cpu_tuple_cost = 0.01			# same scale as above
chefclient01     -#cpu_index_tuple_cost = 0.005		# same scale as above
chefclient01     -#cpu_operator_cost = 0.0025		# same scale as above
chefclient01     -#effective_cache_size = 128MB
chefclient01     -
chefclient01     -# - Genetic Query Optimizer -
chefclient01     -
chefclient01     -#geqo = on
chefclient01     -#geqo_threshold = 12
chefclient01     -#geqo_effort = 5			# range 1-10
chefclient01     -#geqo_pool_size = 0			# selects default based on effort
chefclient01     -#geqo_generations = 0			# selects default based on effort
chefclient01     -#geqo_selection_bias = 2.0		# range 1.5-2.0
chefclient01     -
chefclient01     -# - Other Planner Options -
chefclient01     -
chefclient01     -#default_statistics_target = 100	# range 1-10000
chefclient01     -#constraint_exclusion = partition	# on, off, or partition
chefclient01     -#cursor_tuple_fraction = 0.1		# range 0.0-1.0
chefclient01     -#from_collapse_limit = 8
chefclient01     -#join_collapse_limit = 8		# 1 disables collapsing of explicit
chefclient01     -					# JOIN clauses
chefclient01     -
chefclient01     -
chefclient01     -#------------------------------------------------------------------------------
chefclient01     -# ERROR REPORTING AND LOGGING
chefclient01     -#------------------------------------------------------------------------------
chefclient01     -
chefclient01     -# - Where to Log -
chefclient01     -
chefclient01     -#log_destination = 'stderr'		# Valid values are combinations of
chefclient01     -					# stderr, csvlog, syslog and eventlog,
chefclient01     -					# depending on platform.  csvlog
chefclient01     -					# requires logging_collector to be on.
chefclient01     -
chefclient01     -# This is used when logging to stderr:
chefclient01     -logging_collector = on			# Enable capturing of stderr and csvlog
chefclient01     -					# into log files. Required to be on for
chefclient01     -					# csvlogs.
chefclient01     -					# (change requires restart)
chefclient01     -
chefclient01     -# These are only used if logging_collector is on:
chefclient01     -log_directory = 'pg_log'		# directory where log files are written,
chefclient01     -					# can be absolute or relative to PGDATA
chefclient01     -log_filename = 'postgresql-%a.log'	# log file name pattern,
chefclient01     -					# can include strftime() escapes
chefclient01     -log_truncate_on_rotation = on		# If on, an existing log file of the
chefclient01     -					# same name as the new log file will be
chefclient01     -					# truncated rather than appended to.
chefclient01     -					# But such truncation only occurs on
chefclient01     -					# time-driven rotation, not on restarts
chefclient01     -					# or size-driven rotation.  Default is
chefclient01     -					# off, meaning append to existing files
chefclient01     -					# in all cases.
chefclient01     -log_rotation_age = 1d			# Automatic rotation of logfiles will
chefclient01     -					# happen after that time.  0 disables.
chefclient01     -log_rotation_size = 0			# Automatic rotation of logfiles will
chefclient01     -					# happen after that much log output.
chefclient01     -					# 0 disables.
chefclient01     -
chefclient01     -# These are relevant when logging to syslog:
chefclient01     -#syslog_facility = 'LOCAL0'
chefclient01     -#syslog_ident = 'postgres'
chefclient01     -
chefclient01     -#silent_mode = off			# Run server silently.
chefclient01     -					# DO NOT USE without syslog or
chefclient01     -					# logging_collector
chefclient01     -					# (change requires restart)
chefclient01     -
chefclient01     -
chefclient01     -# - When to Log -
chefclient01     -
chefclient01     -#client_min_messages = notice		# values in order of decreasing detail:
chefclient01     -					#   debug5
chefclient01     -					#   debug4
chefclient01     -					#   debug3
chefclient01     -					#   debug2
chefclient01     -					#   debug1
chefclient01     -					#   log
chefclient01     -					#   notice
chefclient01     -					#   warning
chefclient01     -					#   error
chefclient01     -
chefclient01     -#log_min_messages = warning		# values in order of decreasing detail:
chefclient01     -					#   debug5
chefclient01     -					#   debug4
chefclient01     -					#   debug3
chefclient01     -					#   debug2
chefclient01     -					#   debug1
chefclient01     -					#   info
chefclient01     -					#   notice
chefclient01     -					#   warning
chefclient01     -					#   error
chefclient01     -					#   log
chefclient01     -					#   fatal
chefclient01     -					#   panic
chefclient01     -
chefclient01     -#log_error_verbosity = default		# terse, default, or verbose messages
chefclient01     -
chefclient01     -#log_min_error_statement = error	# values in order of decreasing detail:
chefclient01     -				 	#   debug5
chefclient01     -					#   debug4
chefclient01     -					#   debug3
chefclient01     -					#   debug2
chefclient01     -					#   debug1
chefclient01     -				 	#   info
chefclient01     -					#   notice
chefclient01     -					#   warning
chefclient01     -					#   error
chefclient01     -					#   log
chefclient01     -					#   fatal
chefclient01     -					#   panic (effectively off)
chefclient01     -
chefclient01     -#log_min_duration_statement = -1	# -1 is disabled, 0 logs all statements
chefclient01     -					# and their durations, > 0 logs only
chefclient01     -					# statements running at least this number
chefclient01     -					# of milliseconds
chefclient01     -
chefclient01     -
chefclient01     -# - What to Log -
chefclient01     -
chefclient01     -#debug_print_parse = off
chefclient01     -#debug_print_rewritten = off
chefclient01     -#debug_print_plan = off
chefclient01     -#debug_pretty_print = on
chefclient01     -#log_checkpoints = off
chefclient01     -#log_connections = off
chefclient01     -#log_disconnections = off
chefclient01     -#log_duration = off
chefclient01     -#log_hostname = off
chefclient01     -#log_line_prefix = ''			# special values:
chefclient01     -					#   %u = user name
chefclient01     -					#   %d = database name
chefclient01     -					#   %r = remote host and port
chefclient01     -					#   %h = remote host
chefclient01     -					#   %p = process ID
chefclient01     -					#   %t = timestamp without milliseconds
chefclient01     -					#   %m = timestamp with milliseconds
chefclient01     -					#   %i = command tag
chefclient01     -					#   %c = session ID
chefclient01     -					#   %l = session line number
chefclient01     -					#   %s = session start timestamp
chefclient01     -					#   %v = virtual transaction ID
chefclient01     -					#   %x = transaction ID (0 if none)
chefclient01     -					#   %q = stop here in non-session
chefclient01     -					#        processes
chefclient01     -					#   %% = '%'
chefclient01     -					# e.g. '<%u%%%d> '
chefclient01     -#log_lock_waits = off			# log lock waits >= deadlock_timeout
chefclient01     -#log_statement = 'none'			# none, ddl, mod, all
chefclient01     -#log_temp_files = -1			# log temporary files equal or larger
chefclient01     -					# than the specified size in kilobytes;
chefclient01     -					# -1 disables, 0 logs all temp files
chefclient01     -#log_timezone = unknown			# actually, defaults to TZ environment
chefclient01     -					# setting
chefclient01     -
chefclient01     -
chefclient01     -#------------------------------------------------------------------------------
chefclient01     -# RUNTIME STATISTICS
chefclient01     -#------------------------------------------------------------------------------
chefclient01     -
chefclient01     -# - Query/Index Statistics Collector -
chefclient01     -
chefclient01     -#track_activities = on
chefclient01     -#track_counts = on
chefclient01     -#track_functions = none			# none, pl, all
chefclient01     -#track_activity_query_size = 1024
chefclient01     -#update_process_title = on
chefclient01     -#stats_temp_directory = 'pg_stat_tmp'
chefclient01     -
chefclient01     -
chefclient01     -# - Statistics Monitoring -
chefclient01     -
chefclient01     -#log_parser_stats = off
chefclient01     -#log_planner_stats = off
chefclient01     -#log_executor_stats = off
chefclient01     -#log_statement_stats = off
chefclient01     -
chefclient01     -
chefclient01     -#------------------------------------------------------------------------------
chefclient01     -# AUTOVACUUM PARAMETERS
chefclient01     -#------------------------------------------------------------------------------
chefclient01     -
chefclient01     -#autovacuum = on			# Enable autovacuum subprocess?  'on'
chefclient01     -					# requires track_counts to also be on.
chefclient01     -#log_autovacuum_min_duration = -1	# -1 disables, 0 logs all actions and
chefclient01     -					# their durations, > 0 logs only
chefclient01     -					# actions running at least this number
chefclient01     -					# of milliseconds.
chefclient01     -#autovacuum_max_workers = 3		# max number of autovacuum subprocesses
chefclient01     -#autovacuum_naptime = 1min		# time between autovacuum runs
chefclient01     -#autovacuum_vacuum_threshold = 50	# min number of row updates before
chefclient01     -					# vacuum
chefclient01     -#autovacuum_analyze_threshold = 50	# min number of row updates before
chefclient01     -					# analyze
chefclient01     -#autovacuum_vacuum_scale_factor = 0.2	# fraction of table size before vacuum
chefclient01     -#autovacuum_analyze_scale_factor = 0.1	# fraction of table size before analyze
chefclient01     -#autovacuum_freeze_max_age = 200000000	# maximum XID age before forced vacuum
chefclient01     -					# (change requires restart)
chefclient01     -#autovacuum_vacuum_cost_delay = 20ms	# default vacuum cost delay for
chefclient01     -					# autovacuum, in milliseconds;
chefclient01     -					# -1 means use vacuum_cost_delay
chefclient01     -#autovacuum_vacuum_cost_limit = -1	# default vacuum cost limit for
chefclient01     -					# autovacuum, -1 means use
chefclient01     -					# vacuum_cost_limit
chefclient01     -
chefclient01     -
chefclient01     -#------------------------------------------------------------------------------
chefclient01     -# CLIENT CONNECTION DEFAULTS
chefclient01     -#------------------------------------------------------------------------------
chefclient01     -
chefclient01     -# - Statement Behavior -
chefclient01     -
chefclient01     -#search_path = '"$user",public'		# schema names
chefclient01     -#default_tablespace = ''		# a tablespace name, '' uses the default
chefclient01     -#temp_tablespaces = ''			# a list of tablespace names, '' uses
chefclient01     -					# only default tablespace
chefclient01     -#check_function_bodies = on
chefclient01     -#default_transaction_isolation = 'read committed'
chefclient01     -#default_transaction_read_only = off
chefclient01     -#session_replication_role = 'origin'
chefclient01     -#statement_timeout = 0			# in milliseconds, 0 is disabled
chefclient01     -#vacuum_freeze_min_age = 50000000
chefclient01     -#vacuum_freeze_table_age = 150000000
chefclient01     -#xmlbinary = 'base64'
chefclient01     -#xmloption = 'content'
chefclient01     -
chefclient01     -# - Locale and Formatting -
chefclient01     -
chefclient01     +data_directory = '/var/lib/pgsql/data'
chefclient01      datestyle = 'iso, mdy'
chefclient01     -#intervalstyle = 'postgres'
chefclient01     -#timezone = unknown			# actually, defaults to TZ environment
chefclient01     -					# setting
chefclient01     -#timezone_abbreviations = 'Default'     # Select the set of available time zone
chefclient01     -					# abbreviations.  Currently, there are
chefclient01     -					#   Default
chefclient01     -					#   Australia
chefclient01     -					#   India
chefclient01     -					# You can create your own file in
chefclient01     -					# share/timezonesets/.
chefclient01     -#extra_float_digits = 0			# min -15, max 2
chefclient01     -#client_encoding = sql_ascii		# actually, defaults to database
chefclient01     -					# encoding
chefclient01     -
chefclient01     -# These settings are initialized by initdb, but they can be changed.
chefclient01     -lc_messages = 'en_US.UTF-8'			# locale for system error message
chefclient01     -					# strings
chefclient01     -lc_monetary = 'en_US.UTF-8'			# locale for monetary formatting
chefclient01     -lc_numeric = 'en_US.UTF-8'			# locale for number formatting
chefclient01     -lc_time = 'en_US.UTF-8'				# locale for time formatting
chefclient01     -
chefclient01     -# default configuration for text search
chefclient01      default_text_search_config = 'pg_catalog.english'
chefclient01     -
chefclient01     -# - Other Defaults -
chefclient01     -
chefclient01     -#dynamic_library_path = '$libdir'
chefclient01     -#local_preload_libraries = ''
chefclient01     -
chefclient01     -
chefclient01     -#------------------------------------------------------------------------------
chefclient01     -# LOCK MANAGEMENT
chefclient01     -#------------------------------------------------------------------------------
chefclient01     -
chefclient01     -#deadlock_timeout = 1s
chefclient01     -#max_locks_per_transaction = 64		# min 10
chefclient01     -					# (change requires restart)
chefclient01     -# Note:  Each lock table slot uses ~270 bytes of shared memory, and there are
chefclient01     -# max_locks_per_transaction * (max_connections + max_prepared_transactions)
chefclient01     -# lock table slots.
chefclient01     -
chefclient01     -
chefclient01     -#------------------------------------------------------------------------------
chefclient01     -# VERSION/PLATFORM COMPATIBILITY
chefclient01     -#------------------------------------------------------------------------------
chefclient01     -
chefclient01     -# - Previous PostgreSQL Versions -
chefclient01     -
chefclient01     -#add_missing_from = off
chefclient01     -#array_nulls = on
chefclient01     -#backslash_quote = safe_encoding	# on, off, or safe_encoding
chefclient01     -#default_with_oids = off
chefclient01     -#escape_string_warning = on
chefclient01     -#regex_flavor = advanced		# advanced, extended, or basic
chefclient01     -#sql_inheritance = on
chefclient01     -#standard_conforming_strings = off
chefclient01     -#synchronize_seqscans = on
chefclient01     -
chefclient01     -# - Other Platforms and Clients -
chefclient01     -
chefclient01     -#transform_null_equals = off
chefclient01     -
chefclient01     -
chefclient01     -#------------------------------------------------------------------------------
chefclient01     -# CUSTOMIZED OPTIONS
chefclient01     -#------------------------------------------------------------------------------
chefclient01     -
chefclient01     -#custom_variable_classes = ''		# list of custom variable class names
chefclient01     +lc_messages = 'en_US.UTF-8'
chefclient01     +lc_monetary = 'en_US.UTF-8'
chefclient01     +lc_numeric = 'en_US.UTF-8'
chefclient01     +lc_time = 'en_US.UTF-8'
chefclient01     +listen_addresses = 'localhost'
chefclient01     +log_directory = 'pg_log'
chefclient01     +log_filename = 'postgresql-%a.log'
chefclient01     +log_rotation_age = '1d'
chefclient01     +log_rotation_size = 0
chefclient01     +log_truncate_on_rotation = on
chefclient01     +logging_collector = on
chefclient01     +max_connections = 100
chefclient01     +port = 5432
chefclient01     +shared_buffers = '32MB'
chefclient01 Recipe: postgresql::server_redhat
chefclient01   * service[postgresql] action restart
chefclient01     - restart service service[postgresql]
chefclient01 Recipe: postgresql::server_conf
chefclient01   * template[/var/lib/pgsql/data/pg_hba.conf] action create
chefclient01     - update content in file /var/lib/pgsql/data/pg_hba.conf from dd2143 to 1ac5b0
chefclient01     --- /var/lib/pgsql/data/pg_hba.conf	2015-08-16 17:16:39.109389331 +0000
chefclient01     +++ /tmp/chef-rendered-template20150816-3283-1anj69o	2015-08-16 17:16:45.791046833 +0000
chefclient01     @@ -1,75 +1,25 @@
chefclient01     +# This file was automatically generated and dropped off by Chef!
chefclient01     +
chefclient01      # PostgreSQL Client Authentication Configuration File
chefclient01      # ===================================================
chefclient01      #
chefclient01     -# Refer to the "Client Authentication" section in the
chefclient01     -# PostgreSQL documentation for a complete description
chefclient01     -# of this file.  A short synopsis follows.
chefclient01     -#
chefclient01     -# This file controls: which hosts are allowed to connect, how clients
chefclient01     -# are authenticated, which PostgreSQL user names they can use, which
chefclient01     -# databases they can access.  Records take one of these forms:
chefclient01     -#
chefclient01     -# local      DATABASE  USER  METHOD  [OPTIONS]
chefclient01     -# host       DATABASE  USER  CIDR-ADDRESS  METHOD  [OPTIONS]
chefclient01     -# hostssl    DATABASE  USER  CIDR-ADDRESS  METHOD  [OPTIONS]
chefclient01     -# hostnossl  DATABASE  USER  CIDR-ADDRESS  METHOD  [OPTIONS]
chefclient01     -#
chefclient01     -# (The uppercase items must be replaced by actual values.)
chefclient01     -#
chefclient01     -# The first field is the connection type: "local" is a Unix-domain socket,
chefclient01     -# "host" is either a plain or SSL-encrypted TCP/IP socket, "hostssl" is an
chefclient01     -# SSL-encrypted TCP/IP socket, and "hostnossl" is a plain TCP/IP socket.
chefclient01     -#
chefclient01     -# DATABASE can be "all", "sameuser", "samerole", a database name, or
chefclient01     -# a comma-separated list thereof.
chefclient01     -#
chefclient01     -# USER can be "all", a user name, a group name prefixed with "+", or
chefclient01     -# a comma-separated list thereof.  In both the DATABASE and USER fields
chefclient01     -# you can also write a file name prefixed with "@" to include names from
chefclient01     -# a separate file.
chefclient01     -#
chefclient01     -# CIDR-ADDRESS specifies the set of hosts the record matches.
chefclient01     -# It is made up of an IP address and a CIDR mask that is an integer
chefclient01     -# (between 0 and 32 (IPv4) or 128 (IPv6) inclusive) that specifies
chefclient01     -# the number of significant bits in the mask.  Alternatively, you can write
chefclient01     -# an IP address and netmask in separate columns to specify the set of hosts.
chefclient01     -#
chefclient01     -# METHOD can be "trust", "reject", "md5", "password", "gss", "sspi", "krb5",
chefclient01     -# "ident", "pam", "ldap" or "cert".  Note that "password" sends passwords
chefclient01     -# in clear text; "md5" is preferred since it sends encrypted passwords.
chefclient01     -#
chefclient01     -# OPTIONS are a set of options for the authentication in the format
chefclient01     -# NAME=VALUE. The available options depend on the different authentication
chefclient01     -# methods - refer to the "Client Authentication" section in the documentation
chefclient01     -# for a list of which options are available for which authentication methods.
chefclient01     -#
chefclient01     -# Database and user names containing spaces, commas, quotes and other special
chefclient01     -# characters must be quoted. Quoting one of the keywords "all", "sameuser" or
chefclient01     -# "samerole" makes the name lose its special character, and just match a
chefclient01     -# database or username with that name.
chefclient01     -#
chefclient01     -# This file is read on server startup and when the postmaster receives
chefclient01     -# a SIGHUP signal.  If you edit the file on a running system, you have
chefclient01     -# to SIGHUP the postmaster for the changes to take effect.  You can use
chefclient01     -# "pg_ctl reload" to do that.
chefclient01     +# Refer to the "Client Authentication" section in the PostgreSQL
chefclient01     +# documentation for a complete description of this file.
chefclient01
chefclient01     -# Put your actual configuration here
chefclient01     -# ----------------------------------
chefclient01     -#
chefclient01     -# If you want to allow non-local connections, you need to add more
chefclient01     -# "host" records. In that case you will also need to make PostgreSQL listen
chefclient01     -# on a non-local interface via the listen_addresses configuration parameter,
chefclient01     -# or via the -i or -h command line switches.
chefclient01     -#
chefclient01     +# TYPE  DATABASE        USER            CIDR-ADDRESS            METHOD
chefclient01
chefclient01     +###########
chefclient01     +# Other authentication configurations taken from chef node defaults:
chefclient01     +###########
chefclient01
chefclient01     +local   all             postgres                                ident
chefclient01
chefclient01     -# TYPE  DATABASE    USER        CIDR-ADDRESS          METHOD
chefclient01     +local   all             all                                     ident
chefclient01
chefclient01     +host    all             all             127.0.0.1/32            md5
chefclient01     +
chefclient01     +host    all             all             ::1/128                 md5
chefclient01     +
chefclient01      # "local" is for Unix domain socket connections only
chefclient01     -local   all         all                               ident
chefclient01     -# IPv4 local connections:
chefclient01     -host    all         all         127.0.0.1/32          ident
chefclient01     -# IPv6 local connections:
chefclient01     -host    all         all         ::1/128               ident
chefclient01     +local   all             all                                     ident
chefclient01 Recipe: postgresql::server_redhat
chefclient01   * service[postgresql] action restart
chefclient01     - restart service service[postgresql]
chefclient01   * service[postgresql] action enable
chefclient01     - enable service service[postgresql]
chefclient01   * service[postgresql] action start (up to date)
chefclient01 Recipe: postgresql::server
chefclient01   * bash[assign-postgres-password] action run
chefclient01     - execute "bash"  "/tmp/chef-script20150816-3283-18z0e52"
chefclient01 Recipe: postgresql::server_redhat
chefclient01   * service[postgresql] action restart
chefclient01     - restart service service[postgresql]
chefclient01
chefclient01 Running handlers:
chefclient01 Running handlers complete
chefclient01 Chef Client finished, 15/16 resources updated in 39.848145274 seconds
```
 
and finally some post install process details, showing my vanilla postgres instance running:

```sh
[vagrant@chefclient01 chef-repo]$  ps -ef|grep pos
root      1493     1  0 16:48 ?        00:00:00 /usr/libexec/postfix/master
postfix   1500  1493  0 16:48 ?        00:00:00 pickup -l -t fifo -u
postfix   1501  1493  0 16:48 ?        00:00:00 qmgr -l -t fifo -u
postgres  4032     1  0 17:16 ?        00:00:00 /usr/bin/postmaster -p 5432 -D /var/lib/pgsql/data
postgres  4034  4032  0 17:16 ?        00:00:00 postgres: logger process
postgres  4036  4032  0 17:16 ?        00:00:00 postgres: writer process
postgres  4037  4032  0 17:16 ?        00:00:00 postgres: wal writer process
postgres  4038  4032  0 17:16 ?        00:00:00 postgres: autovacuum launcher process
postgres  4039  4032  0 17:16 ?        00:00:00 postgres: stats collector process
vagrant   4051  2146  0 17:19 pts/0    00:00:00 grep pos
```



