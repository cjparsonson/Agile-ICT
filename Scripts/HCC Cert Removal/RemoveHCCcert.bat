REM Uses certutil to remove cert, should be run as a logon script under computer configuration

@echo Removing HCC Certificate

certutil -delstore Root "44afb080d6a327ba893039862ef8406b"
certutil -delstore AuthRoot "44afb080d6a327ba893039862ef8406b"

certutil -delstore -user Root "44afb080d6a327ba893039862ef8406b"
certutil -delstore -user AuthRoot "44afb080d6a327ba893039862ef8406b"

certutil -delstore -enterprise Root "44afb080d6a327ba893039862ef8406b"
certutil -delstore -enterprise AuthRoot "44afb080d6a327ba893039862ef8406b"

certutil -delstore -grouppolicy Root "44afb080d6a327ba893039862ef8406b"
certutil -delstore -grouppolicy AuthRoot "44afb080d6a327ba893039862ef8406b"


exit