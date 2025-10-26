# IAC Week 6

Deze repository deployed een hypride cloud stack met de volgende vm's:
| Host  | Beschrijving                |
|-------|-----------------------------|
| ESXI  | Mariadb Database            |
| ESXI  | Hello world web application |
| ESXI  | phpmyadmin                  |
| Azure | Hello world web application |
| Azure | Mariadb Database            |

Deze hele repository is geautomatiseerd door `Github Actions`, daarom is het handmatig deployen van deze repository niet nodig. Indien je dit wel wilt doen gaan dan naar hoofdstuk 2 `Handmatige Deployment`

## Automatische Deployment
1. Maak een wijziging.
2. Push deze wijziging naar `dev` branch.
3. Maak een pull request van `dev` naar `main`
4. Merge de pull request. Nu begint de Github Action workflow automatisch te lopen. Indien er errors ontstaan kunnen deze actions tabblad.

## Handmatige Deployment
Installeer eerst de volgende packages:
- Terrafrom
- Ansible
- Setup SSH keys

Update nu je config variables in `terraform/variables.tf`

Draai nu de volgende commando's om de deployment op te zetten.
```bash
cd terraform
terraform init
terraform fmt -check -diff
terraform validate
cd ../
ansible-galaxy collection install community.docker community.general
ansible-lint ansible/main.yml
```

Wanneer al deze commando's goed zijn verlopen, kun je alles gaan deployen
```bash
cd terraform
terraform apply
cd ../
ansible-playbook ansible/main.yml
```

## Bronnen
- [https://hub.docker.com/r/strm/helloworld-http/](https://hub.docker.com/r/strm/helloworld-http/)