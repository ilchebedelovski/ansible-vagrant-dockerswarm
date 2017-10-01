#!/bin/bash

# Declare variables
MASTER_CN=dockerswarm.ibedelovski.com

# Generate a CA certificate
openssl genrsa -out ca-key.pem 4096
openssl req -new -x509 -nodes -days 10000 -subj "/CN=${MASTER_CN}" -key ca-key.pem -sha256 -out ca.pem

# Generate a server certificate for dockerswarm
openssl genrsa -out server-key.pem 4096
openssl req -subj "/CN=${MASTER_CN}" -sha256 -new -key server-key.pem -out server.csr

echo subjectAltName = DNS:${MASTER_CN},IP:172.16.10.71,IP:127.0.0.1 > extfile.cnf
echo extendedKeyUsage = serverAuth >> extfile.cnf

# Generating the server key
openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -extfile extfile.cnf

# Generating client key
openssl genrsa -out key.pem 4096
openssl req -subj '/CN=client' -new -key key.pem -out client.csr

echo extendedKeyUsage = clientAuth >> extfile.cnf

# Signing the private key
openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out cert.pem -extfile extfile.cnf

# Removing the client and server requests
rm -v client.csr server.csr

# Setting up permissions for the certs
chmod -v 0400 ca-key.pem key.pem server-key.pem
chmod -v 0444 ca.pem server-cert.pem cert.pem
