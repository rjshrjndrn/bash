This is a script to upload your tomcat .war file to production server
you have the option of having backup, by default it'll the first time for everyday.
and then it'll be moved to storage.

the main script is code_upload.sh it is client part
it'll call backup_helper and conf_changer, which will be residing in server

for accessibility i keep these codes in /usr/local/bin
