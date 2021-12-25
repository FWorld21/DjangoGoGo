#!/bin/bash

function finish() {
	clear
	echo -e "\033[0;32m[!] Installation and configuration your server for project $PROJECTNAME , successfully completed!"
	echo -e "\n\n\033[0m[!] Now you should paste all files from your project to /home/$USER/src/ and restart your server"
}

function configure_server() {
	PYTHONPATH="/home/$USER/.python"
	CONFIGSPATH="$(pwd)/configs"
        mkdir /home/$USER/$PROJECTNAME/ && mkdir /home/$USER/$PROJECTNAME/src/ && mkdir /home/$USER/$PROJECTNAME/bin/
	sudo apt-get install -y zsh tree redis-server nginx zlib1g-dev libbz2-dev libreadline-dev llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev liblzma-dev python3-dev python-imageio python3-lxml libxslt-dev python-libxml2 python-libxslt1 libffi-dev libssl-dev python-dev gnumeric libsqlite3-dev libpq-dev libxml2-dev libxslt1-dev libjpeg-dev libfreetype6-dev libcurl4-openssl-dev supervisor
	cd /tmp
	wget https://www.python.org/ftp/python/3.9.6/Python-3.9.6.tgz
	tar xvf Python-3.9.6.tgz
	cd /tmp/Python-3.9.6/
	./configure --enable-optimizations --prefix=$PYTHONPATH
	make -j8 && sudo make altinstall
	/home/$USER/.python/bin/python3.9 -m venv /home/$USER/$PROJECTNAME/venv
	source /home/$USER/$PROJECTNAME/venv/bin/activate
	pip install django
	pip install django-admin-interface
	pip install pyTelegramBotAPI
	pip install gunicorn
	pip install --upgrade pip
	sudo systemctl enable nginx
	sudo systemctl enable supervisor

	cd "$CONFIGSPATH/nginx"
	sudo rm /etc/nginx/sites-enabled/default
	sed "s/PROJECTNAME/$PROJECTNAME/g" default > def
	sed -i "s/USERNAME/$USER/g" def
	sudo mv def /etc/nginx/sites-enabled/default

	cd "$CONFIGSPATH/supervisor"
	sed "s/PROJECTNAME/$PROJECTNAME/g" default.conf > def
	sed -i "s/USERNAME/$USER/g" def
	sudo mv def /etc/supervisor/conf.d/default.conf

	cd "$CONFIGSPATH/binfolder"
	sed "s/USERNAME/$USER/g" start_gunicorn.sh > start
	sed -i "s/PROJECTNAME/$PROJECTNAME/g" start
	mv start /home/$USER/$PROJECTNAME/bin/start_gunicorn.sh
	chmod +x /home/$USER/$PROJECTNAME/bin/start_gunicorn.sh

	cd "$CONFIGSPATH/gunicorn"
	sed "s/USERNAME/$USER/g" gunicorn_config.py > gunicorn
	sed -i "s/PROJECTNAME/$PROJECTNAME/g" gunicorn
	mv gunicorn /home/$USER/$PROJECTNAME/src/gunicorn_config.py

	sudo systemctl start nginx
	sudo systemctl start supervisor
}

function check_os_type() {
        APT_GET_CMD=$(which apt-get)
        if [[ "$OSTYPE" == "linux-gnu" ]] && [[ ! -z $APT_GET_CMD ]]; then
                echo 1
        else
                echo 0
        fi
}

res=$(check_os_type)

if [[ $res == "0" ]]
then
        clear
        echo -e "\033[0;31m[!] You need a debian based OS for using this script!"
else
	clear
        echo -e "\n\033[0;32m[!] Your OS is good for script"
        if [[ "$USER" == "root" ]]
	then
		echo -e "\033[0;31m[!] You should launch this script from non-superuser"
		echo -e "\033[0m"
	else
		sleep 2
	        clear

		echo -e "\033[0;33m[?] Enter your project name"
		echo -e "\033[0m"
                read PROJECTNAME
		clear
		for i in 5 4 3 2 1
	        do
        		echo -e "\033[0;33m[!] Installation and configuration will start in ${i} second"
                	sleep 1
                        clear
               	done
		echo -e "\033[0m"
		configure_server
		finish
	fi
fi

