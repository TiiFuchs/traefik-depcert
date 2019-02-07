# traefik-depcert
Deploys traefik certificates to other locations. For example for docker containers that serve additional ports via SSL.

This script compares the NotValidBefore timestamps from the deployed certificates in your container and the one in your acme.json by traefik. If it differs the certificates get exported from traefik to your specified location and the corresponding Docker container get restarted.

This is useful for Docker services that are also reachable via different ports, like IMAP, SMTP or IRC Bouncer.

## Installation
Clone the repository and create a `config.json`. If you want, create a symlink for the deploy.sh for extra comfort.
Then add the script to your crontab to execute it every night.

## Configuration

For an full example have a look at the `config.json.example`
The configuration has two root level elements:

| Variable     | Description                                                 |
|--------------|-------------------------------------------------------------|
| AcmeFile     | Path to acme.json from traefik                              |
| Certificates | An array of objects. See section Configuration/Certificates |

### Certificates

You can list as many certificates to deploy as you like. Every certifiate entry has these options:

| Variable      | Description                                                                                                |
|---------------|------------------------------------------------------------------------------------------------------------|
| Domain        | The main domain from the certificate. This will be used to find the corresponding certificate in acme.json |
| KeyFile       | Path to keyfile.                                                                                           |
| CertFile      | Path to certification file. (Can be the same as keyfile, in this case it gets concatenated.)               |
| RestartDocker | An array of container names that should be restarted.                                                      |

