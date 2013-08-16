

After deploying the app to the website, you need to touch the tmp/restart.txt file
in order to force a restart.

Backup the database

    mysqldump -u recommender_etl -h mysql.seekerr.com -p --databases game_recommender > dreamhost_08172013.sql
