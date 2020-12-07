#!/bin/bash

token=$(curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2020-06-01&resource=https%3A%2F%2Fstorage.azure.com%2F' -H Metadata:true | jq -r .access_token)
echo "Token is $token"

curl "https://cuongdevcontainersa.blob.core.windows.net/macos/basic.sh" -H "x-ms-version: 2019-12-12" -H "Authorization: Bearer $token"
