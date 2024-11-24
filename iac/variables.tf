## tecent cloud ##
# export TF_VAR_secret_id="..."
# export TF_VAR_secret_key=".."
variable "secret_id" {
  default = ""
}

variable "secret_key" {
  default = ""
}

# cvm
variable "region" {
  default = "ap-hongkong"
}

variable "availability-zone" {
  default = "ap-hongkong-2"
}

variable "password" {
  default = "qwe123ewq"
}


## k3s ##
variable "server_name" {
  default = "k3s"
}


## cloudflare ##
# https://dash.cloudflare.com/
# https://developers.cloudflare.com/fundamentals/api/get-started/create-token/
# Permission:     Zone/Zone/Read, Zone/DNS/Edit
# Zone Resources: Include/All zones
variable "cloudflare_api_token" {
  default = ""
}

variable "cloudflare_email" {
  default = "hironwayj@gmail.com"
}

# free domain in https://register.us.kg/
variable "domain" {
  default = ""
}

variable "prefix" {
  default = "devsecops"
}

variable "ip" {
  default = ""
}

# *.prefix.domain
variable "records" {
  default = []
}


## github ##
variable "github_username" {
  default = ""
}

# https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens
variable "github_pat" {
  default = ""
}


## pwd ##
variable "harbor_pwd" {
  default = "admin"
}

variable "jenkins_pwd" {
  default = "admin"
}

variable "sonarqube_pwd" {
  default = "admin"
}

# -- Bcrypt hashed admin password
## Argo expects the password in the secret to be bcrypt hashed. You can create this hash with
## `htpasswd -nbBC 10 "" $ARGO_PWD | tr -d ':\n' | sed 's/$2y/$2a/'`
variable "argocd_pwd" {
  # admin
  default = "yB2XRMWBLSF1Yk2RzuLu.PjqY1ADJLGs0VCavou.QkmC6XgWVANC%"
}