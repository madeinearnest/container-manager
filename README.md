# Earnest Container Manager

Earnest Container Manager is an API for managaing OpenVZ Containers based on the awesome work by Andrew Hong with customisations to our own requirements.

# Features!

  - Installer

### It will also:
  - Keep itself up-to date

### Tech

ECM uses a number of open source projects to work properly:

* [https://github.com/FlamesRunner/natCP] - NatCP

And of course ECM itself is open source project on GitHub.

### Installation

ECM requires a fresh install of CentOS 6 or 7.

```sh
$ cd /tmp && wget https://raw.githubusercontent.com/madeinearnest/container-manager/master/slave/slaveInstall.sh --no-check-certificate 
$ bash /tmp/slaveInstall.sh
```

Copy the slave access key (this is only shown once) and is required to link it back up to the master server.

```sh
$ reboot
```

License
----

GNU General Public License v3.0

