REM Users cert util to deploy new certificates from a network share

@echo deploying new certificates

certutil -enterprise -addstore -f "root" "\\%userdomain%\dfs$\Scripts\HCCCertDeploy\3334561877.crt"

certutil -enterprise -addstore -f "root" "\\%userdomain%\dfs$\Scripts\HCCCertDeploy\3334561878.crt"

certutil -enterprise -addstore -f "root" "\\%userdomain%\dfs$\Scripts\HCCCertDeploy\3334561879.crt"

