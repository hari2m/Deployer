#!/bin/bash
rm -r /home/Deployer/Smart/Code
echo "Current list of files in this folder"
ls /home/Deployer/Smart/
echo "Cloning Smart repository"
git clone https://github.com/hari2m/smart.git /home/Deployer/Smart/Code
echo "Clone completed. Below are the current list of files."
ls /home/Deployer/Smart/Code/
echo "Building the smart solution.....|"
build_error="$(dotnet build /home/Deployer/smart/smart.sln 2>&1 >/dev/null)"
if [ -z $build_error ]
	then
		echo "No Error Observed while building smart solution."
		echo "Stopping smart service in systemctl..."
		systemctl stop smart
		echo "publishing the code to target..."
		dotnet publish /home/Deployer/Smart/Code/SmartWeb/smart.csproj
		echo "Copying files to target location..."
		cp -r -v /home/Deployer/Smart/Code/SmartWeb/bin/Debug/netcoreapp2.0/publish/* /var/www/smart
		echo "Copying configuration files..."
		cp -r -v /home/Deployer/Smart/Config/* /var/www/smart
		chmod +x /var/www/smart/ServiceLoader.sh
		echo  "Stating back the smart service in systemctl"
		systemctl enable smart
		systemctl start smart
	else
		echo "Build failed. Please verify the code."
		echo "Exiting the deployer."
	fi
