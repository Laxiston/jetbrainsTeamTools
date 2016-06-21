# JetBrains team tools, installation scripts.
Coming soon :)

Software list:

1. Hub 2.0.244
2. YouTrack 6.5.17105
3. UpSource 3.0.4364
4. TeamCity 9.1.7

Running sequence: (Using is standard, clone, than run scripts in following sequence, recommend debian 8 ) 

1. installJDK.sh (if already installed skip)
2. fetchJetBrainsProducts.sh
3. buildInitD.sh
4. hubCron.sh
5. installNginx.sh

Then you have running apps on your host with specified ports and domains, so that you can connect it to proxy or other ...