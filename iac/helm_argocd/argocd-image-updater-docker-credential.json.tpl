{
    "auths": {
        "harbor.${prefix}.${domain}": {
            "username": "admin",
            "password": "${harbor_pwd}",
            "auth": "${harbor_pwd_base64}"
        }
    }
}