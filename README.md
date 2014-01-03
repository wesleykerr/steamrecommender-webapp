

After deploying the app to the website, you need to touch the tmp/restart.txt file
in order to force a restart.

Backup the couchbase server

    /opt/couchbase/bin/cbbackup http://<admin>:<password>@192.168.0.8:8091 /tmp/backup-12022013
    rsync -e ssh -av backup-12022013 b418667@hanjin.dreamhost.com:recommender 

Backup the database

    mysqldump -u recommender_etl -h mysql.seekerr.com -p --databases game_recommender > dreamhost_08172013.sql
