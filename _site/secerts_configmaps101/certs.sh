#!/bin/bash

openssl req \
  -x509 -newkey rsa:2048 -nodes -days 365 \
  -keyout tls.key -out tls.crt -subj '/CN=*.example.com'

echo "...Done."
