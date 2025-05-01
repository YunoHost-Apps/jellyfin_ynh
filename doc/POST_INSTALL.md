The app has its discovery ports (1900 and 7359) opened by default.
They help Jellyfin clients to detect the server if it is on the same network.
***However***, if your server only has a direct connection to the Internet (like a VPS), you should close these two ports and `Ignore` the corresponding warnings shown by the Diagnosis.
