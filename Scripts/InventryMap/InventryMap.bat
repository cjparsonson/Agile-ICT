REM net use I: \\networkShare\Test /u:domainname\username password

@echo Create new I: Drive Mapping
net use I: \\10.201.80.106\inventry\v4\console /u:10.201.80.106\Inventry Inventry1*** /persistent:yes
exit

