#!/bin/bash

cd /home/USERNAME/PROJECTNAME/src
source /home/USERNAME/PROJECTNAME/venv/bin/activate
exec gunicorn -c "/home/USERNAME/PROJECTNAME/src/gunicorn_config.py" PROJECTNAME.wsgi
