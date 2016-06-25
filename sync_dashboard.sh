date >> /tmp/sync_log.out
aws s3 sync /home/rpopat/AdzunaDataBot/dashboard/ s3://adzunadata/dashboard/ --acl public-read >> /tmp/sync_log.out
