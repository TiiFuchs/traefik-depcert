#!/bin/bash

CONFIG=$(dirname `realpath $0`)/config.json

acme_file=$(jq -r '.AcmeFile' $CONFIG)

for row in $(jq -r '.Certificates[] | @base64' $CONFIG); do

  obj=$(echo $row | base64 -d)

  domain=$(echo $obj | jq -r '.Domain')
  keyfile=$(echo $obj | jq -r '.KeyFile')
  certfile=$(echo $obj | jq -r '.CertFile')
  restartdocker=$(echo $obj | jq -r '.RestartDocker[]')

  # Get Certificate from acme.json
  latest_cert=$(jq -r '.letsencrypt.Certificates[] | select(.domain.main == "'$domain'").certificate' $acme_file | base64 -d | openssl x509 -noout -dates | grep notAfter)
  current_cert=$(openssl x509 -in $certfile -noout -dates | grep notAfter)

  if [[ "$latest_cert" != "$current_cert" ]]; then

    echo "Deploying new certificate for '$domain'..."
    > $keyfile
    > $certfile
    jq -r '.letsencrypt.Certificates[] | select(.domain.main == "'$domain'").key' $acme_file \
      | base64 -d > $keyfile

    jq -r '.letsencrypt.Certificates[] | select(.domain.main == "'$domain'").certificate' $acme_file \
      | base64 -d >> $certfile

    if [[ -n $restartdocker ]]; then
      
      echo "Restarting Docker container..."
      for docker_name in $restartdocker; do
        docker_c=$(docker ps -qaf name=$docker_name)
        docker restart $docker_c
      done

    fi

    echo "Certificate for '$domain' was deployed successfully."

  else

    echo "Certificate for '$domain' is still valid."

  fi

done
