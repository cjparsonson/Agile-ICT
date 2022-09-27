REM net use I: \\networkShare\Test /u:domainname\username password

@echo Create new I: Drive Mapping
net use I: \\10.201.80.106 /u:10.201.80.106\Inventry Inventry1983 /persistent:yes
exit

