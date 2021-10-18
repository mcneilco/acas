SERVER_FQDN=
PYTHON=/usr/local/bin/python
virtualenv -p $PYTHON venv && source venv/bin/activate
pip install https://$SERVER_FQDN/livedesign/ldclient.tar.gz