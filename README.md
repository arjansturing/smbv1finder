# SMBv1 Finder
This script returns the SMBv1 status and FileShare information of the servers within a AD environment.
Make sure that you run the script in "Administrator" mode.

When using the script for external servers that the "PSRemoting" is enabled on the regarding servers.
You can enable "PSRemoting" on a single server by executing the following PS command: Enable-PSRemoting -Force

You can enable PSRemoting on mulitple servers within a AD environment by using GPO.
A guide for enabling PSRemoting can be find here: https://www.techrepublic.com/article/how-to-enable-powershell-remoting-via-group-policy/
