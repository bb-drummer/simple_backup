#!/bin/bash
##
#
# simple backup shell script to run via cron and/or cli
#
# (c)2009 dragon-projects.net <info@dragon-projects.net>
#
##

# mysql configuration
MYSQLDBNAME='dbname'
MYSQLUSER='dbuser'
MYSQLPASSWD='dbpassword'
MYSQLDUMPFILE='db_save.sql'

# file backup configuration
# - what should be copied
BACKUPSOURCE='/path/to/source/directory'
# - filename to generate gzipped tar file
BACKUPTARGET='targetfile_prefix__'
# - directory to store tar file
BACKUPDIR='/path/to/save/directory'
# - temp directory
BACKUPTEMP='/path/to/tmp/directory'

# ftp configuration
FTPHOST='ftp.example.com'
FTPUSER='ftpuser'
FTPPASSWD='ftppassword'

# define current date
DATUM=`date +%Y-%m-%d`

# create mysql DB dump
mysqldump -f -Q --user=$MYSQLUSER --password=$MYSQLPASSWD $MYSQLDBNAME > $BACKUPTEMP$MYSQLDUMPFILE

# copy games data/files directories
cp -r $BACKUPSOURCE $BACKUPTEMP/

# tar and gzip savings
TARFILE=$BACKUPDIR/$BACKUPTARGET.tar
GZIPFILE=$TARFILE.gz
tar -c -p -f $TARFILE $BACKUPTEMP
gzip -r -9 -f $TARFILE

# submit tar file via ssh....
# scp /home/buchop/backup/sweepstakes_data.tar.gz backup@server.tld://backup/thalia/sweepstakes/

# clear local backup directory
rm -rf $BACKUPTEMP/*

# copy gzipped tar file and copy/put to ftp-server
ftp -n -v $FTPHOST << EOT
ascii
user $FTPUSER $FTPPASSWD
prompt
put $GZIPFILE $BACKUPTARGET$DATUM.tar.gz
bye
bye
EOT

# wait a little bit in case something has not been finished quite yet
sleep 5

# finally remove generated gzipped tar file
rm -rf $GZIPFILE
