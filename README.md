# Sympa for Yunohost

[![Integration level](https://dash.yunohost.org/integration/sympa.svg)](https://dash.yunohost.org/appci/app/sympa) ![](https://ci-apps.yunohost.org/ci/badges/sympa.status.svg) ![](https://ci-apps.yunohost.org/ci/badges/sympa.maintain.svg)

![](http://www.sympa.org/_media/logo_sympa.png)

**Sympa is a mailing-list manager**

[Example of live interface](https://listes.renater.fr/sympa/info/noustestons)



## Status

:warning: This app is ~kinda working but using it in production is at your own risk... The app hasnt been tested in details, is not entirely integrated with YunoHost, and is unmaintained.

:warning: Also, DO NOT INSTALL ON A SERVER WITH LOW RAM (<1 GB). Sympa takes *FIVE HUNDRED MEGABYTES OF RAM* constantly, c.f. : https://github.com/sympa-community/sympa/issues/24

If you want a lightweight mailing list manager, have a look at the Mailman2 package : https://github.com/YunoHost-Apps/mailman_ynh (yes it's ugly but it does the job)

## To-do / roadmap

#### Basic install/remove

- [X] Understand and install dependencies
- [X] Undertsand and install sources 
- [X] Configure sympa (at least the wizard part looks okay)
- [X] Properly handle postfix configuration (using hooks on regen-conf postfix ?)
- [X] Nginx configuration (cf. proposition from Julien on pad ?)
- [ ] Make sure remove script remove everyting that needs to be removed

#### Tests

- [X] Test that creating a mailing list and sending mail actually works...
- [ ] Test install on an Internet Cube or Raspberry Pi

#### Important features

- [X] LDAP integration (!!)
- [X] Language / locale management
- [ ] SSO integration (auto login in Sympa when logged in the SSO..)
- [ ] Check DKIM / DMARC ? (cf. [this doc](https://www.sympa.org/doc/formation/sympa_avance))

#### Moar scripts / improvements

- [ ] Public / private option in manifest (should be easy to do)
- [ ] Use proper helpers
- [ ] Backup / restore
- [ ] Upgrade
- [ ] (Bonus quest) Be level >= 7 lol

## Special thanks

Many thanks to framasky, fmenade, ljf and the Sympa team for their help during the [Sympa hackaton in April 2017](https://framablog.org/2017/03/30/un-hackathon-pour-sympa/) !

Also thanks to Sandhose and Jean B. for the helpful hand with Postfix config.
