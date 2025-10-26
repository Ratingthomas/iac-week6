# IAC Week 6

> [!IMPORTANT]  
> Deze automatic deployment slaat zijn `.tfstate` niet op. Hiervoor kan Azure Account Storage gebruikt voor worden. Voor Azure Account Storage had ik helaas geen toegang om app credentails aan te maken voor terraform. Ga naar hoofdstuk `Account Storage` toe om te lezen hoe dit ingesteld zou moeten worden.

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

## Account Storage
Deze automatic deployment slaat zijn `.tfstate` niet op. Hiervoor kan Azure Account Storage gebruikt voor worden. Voor Azure Account Storage had ik helaas geen toegang om app credentails aan te maken voor terraform. Als je hier wel toegang tot hebt moet de volgende wijziging doen:

*Let op* Deze uitleg is niet volledig getest wegens een toegangsfout bij het aanmaken van de credentials.

Pas `main.tf` aan naar het volgende:
```tf
terraform {
  required_providers {
    esxi = {
      source = "registry.terraform.io/josenk/esxi"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "<name>"
    storage_account_name = "<name>"
    container_name       = "<name>"
    key                  = "hybrid-infra.tfstate"
  }
}
```

Voeg het volgende stukje toe in de deploy job na de `Setup Terraform`. Doe dit in het bestand `.github/workflows/ci/yml`
```yml
- name: Login to Azure
    uses: azure/login@v2
    with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
```

Genereer je credentails met het volgende commando. Plak daarna de output json in een nieuwe secret genaamd `AZURE_CREDENTIALS` in github.
```bash
az ad sp create-for-rbac --name github-terraform --role="Contributor" --scopes="/subscriptions/<sub_id>" --sdk-auth
```

## Bronnen
- [https://hub.docker.com/r/strm/helloworld-http/](https://hub.docker.com/r/strm/helloworld-http/)
