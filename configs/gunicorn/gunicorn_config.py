command = '/home/USERNAME/PROJECTNAME/venv/bin/gunicorn'
pythonpath = '/home/USERNAME/PROJECTNAME/src'
bind = '127.0.0.1:8001'
workers = 5
user = 'USERNAME'
limit_request_fields = 32000
limit_request_field_size = 0
raw_env = 'DJANGO_SETTINGS_MODULE=PROJECTNAME.settings'
