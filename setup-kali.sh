#!/bin/sh

# git clone https://github.com/zoeyg/cptc.git ~/tools 
# chmod +x ~/tools/setup-kali.sh
# sudo ~/tools/setup-kali.sh $(whoami)
# . ~/.zshrc

user="$1"

GREEN='\033[1;32m'
NC='\033[0m'
# for bloodhound prereqs and yarn
echo "${GREEN}Setting up keys and repos${NC}"
echo "deb http://httpredir.debian.org/debian stretch-backports main" | tee -a /etc/apt/sources.list.d/stretch-backports.list
wget -O - https://debian.neo4j.com/neotechnology.gpg.key | apt-key add -
echo 'deb https://debian.neo4j.com stable 4.0' > /etc/apt/sources.list.d/neo4j.list
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# nodejs install script, runs apt-get update
echo "${GREEN}Installing node.js${NC}"
curl -sL https://deb.nodesource.com/setup_lts.x | bash -
apt-get install -y nodejs

# yarn
echo "${GREEN}Installing yarn${NC}"
apt-get install -y yarn

# exfil server and some tools
echo "${GREEN}Installing dependencies/tools for exfil/tools server${NC}"
cd /home/$user/tools
yarn
wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy64
git clone https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite
ln -s privilege-escalation-awesome-scripts-suite/linPEAS/linpeas.sh linpeas.sh
ln -s privilege-escalation-awesome-scripts-suite/winPEAS/winPEASbat/winPEAS.bat winpeas.bat
ln -s privilege-escalation-awesome-scripts-suite/winPEAS/winPEASexe/winPEAS/bin/x64/Release/winPEAS.exe winpeas.exe
git clone https://github.com/PowerShellMafia/PowerSploit.git
ln -s PowerSploit/Recon/PowerView.ps1 powerview.ps1
zip win-recon.zip PowerSploit/Recon/*
zip win-privesc.zip PowerSploit/Privesc/*
echo "alias tools=node ~/tools/exfil-tools-server.sh 8080 ~/tools" >> /home/$user/.zshrc
echo "alias smb=sudo impacket-smbserver tools /home/$user/tools" >> /home/$user/.zshrc

# docker
echo "${GREEN}Installing docker${NC}"
apt install -y docker.io
systemctl enable docker --now
usermod -aG docker $user

# crackmapexec via docker
echo "${GREEN}Installing crackmapexec${NC}"
docker pull byt3bl33d3r/crackmapexec
echo "alias cme=docker run -it --entrypoint=/bin/sh --name crackmapexec -v ~/.cme:/root/.cme byt3bl33d3r/crackmapexec" >> /home/$user/.zshrc

# impacket
echo "${GREEN}Installing impacket - use impacket-[cmd]${NC}"
apt-get install -y python3-impacket

# vscode
echo "${GREEN}Installing visual studio code${NC}"
curl -L 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' --output /tmp/vscode.deb
dpkg -i /tmp/vscode.deb

# go
echo "${GREEN}Installing golang${NC}"
apt-get install -y golang
echo 'export GOROOT=/usr/lib/go' >> /home/$user/.zshrc
echo 'export GOPATH=$HOME/go' >> /home/$user/.zshrc
echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' >> /home/$user/.zshrc

# kerbrute
echo "${GREEN}Installing Kerbrute${NC}"
curl -L https://github.com/ropnop/kerbrute/releases/download/v1.0.3/kerbrute_linux_amd64 --output /usr/bin/kerbrute
chmod +x /usr/bin/kerbrute

# gobuster
echo "${GREEN}Installing gobuster${NC}"
apt-get install -y gobuster

# autorecon and prerequisites
echo "${GREEN}Installing AutoRecon prerequisites${NC}"
apt install -y seclists curl enum4linux gobuster nbtscan nikto nmap onesixtyone oscanner smbclient smbmap smtp-user-enum snmp sslscan sipvicious tnscmd10g whatweb wkhtmltopdf
echo "${GREEN}Installing AutoRecon${NC}"
pip install git+https://github.com/Tib3rius/AutoRecon.git

# bloodhound
echo "${GREEN}Installing Bloodhound Prerequisites${NC}"
apt-get install -y apt-transport-https
apt-get install -y neo4j
systemctl start neo4j
echo "${GREEN}Installing Bloodhound GUI${NC}"
curl -L "https://github.com/BloodHoundAD/BloodHound/releases/download/4.0.1/BloodHound-linux-x64.zip" --output /tmp/bloodhound.zip
unzip /tmp/bloodhound.zip -d /opt
chmod 4755 /opt/BloodHound-linux-x64/chrome-sandbox
echo 'alias bloodhound=/opt/BloodHound-linux-x64/BloodHound --no-sandbox' >> /home/$user/.zshrc
echo "${GREEN}Goto http://localhost:7474/ in a browser and login with neo4j:neo4j and change the password"
echo "Aliases added:"
echo "\t'bloodhound' to start the GUI$"
echo "\t'cme' to start the crackmapexec docker container"
echo "\t'tools' to start the tools/exfil http server"
echo "\t'smb' to start smbshare 'tools' for ~/tools directory"
echo "Start a new terminal or source ~/.zshrc to load new env variables and aliases${NC}"