# Sympa for Yunohost

Attempt to package Sympa for Yunohost....

:warning: THIS IS UNDER HEAVY DEVELOPMENT. DO NO INSTALL IN PRODUCTION :warning:

## To-do / roadmap

#### Basic install/remove

- [X] Understand and install dependencies
- [X] Undertsand and install sources 
- [X] Configure sympa (at least the wizard part looks okay)
- [X] Properly handle postfix configuration (using hooks on regen-conf postfix ?)
- [X] Nginx configuration (cf. proposition from Julien on pad ?)
- [ ] Make sure remove script remove everyting that needs to be removed

#### Tests

- [ ] Test that creating a mailing list and sending mail actually works...
- [ ] Test install on an Internet Cube or Raspberry Pi

#### Important features

- [ ] LDAP integration (!!)
- [ ] Have a clean package
     - [ ] Use proper helpers
     - [ ] (Bonus quest) Be level 7 lol
- [ ] Language / locale management
- [ ] Public / private option in manifest
- [ ] Check DKIM / DMARC ? (cf. [this doc](https://www.sympa.org/doc/formation/sympa_avance))

#### Moar scripts

- [ ] Backup / restore
    - [ ] Probably need to think about what we want to backup exactly
- [ ] Upgrade
- [ ] (Change url)
