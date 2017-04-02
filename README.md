# Sympa for Yunohost

Attempt to package Sympa for Yunohost....

:warning: THIS IS UNDER HEAVY DEVELOPMENT. DO NO INSTALL IN PRODUCTION :warning:

## To-do / roadmap

#### Basic install/remove

- [X] Understand and install dependencies
- [X] Undertsand and install sources 
- [X] Configure sympa (at least the wizard part looks okay)
- [ ] Properly handle postfix configuration (using hooks on regen-conf postfix ?)
- [ ] Nginx configuration (cf. proposition from Julien on pad ?)
- [ ] (Configure sympa : web part ? Don't even know what's supposed to happen there)
    - [ ] Probably need to think about which default values we want

#### Important features

- [ ] LDAP integration (!!)
- [ ] Have a clean package
     - [ ] Use proper helpers
     - [ ] (Bonus quest) Be level 7 lol
- [ ] Language / locale management
- [ ] Public / private option in manifest

#### Moar scripts

- [ ] Backup / restore
    - [ ] Probably need to think about what we want to backup exactly
- [ ] Upgrade
- [ ] (Change url)
