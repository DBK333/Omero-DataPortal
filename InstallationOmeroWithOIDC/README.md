git clone https://github.com/DBK333/Omero-DataPortal
cd Omero-DataPortal/InstallationOmeroWithOIDC


echo "NGROK_AUTH_TOKEN=your_token_here" > .env


chmod +x setup.sh
sudo ./setup.sh