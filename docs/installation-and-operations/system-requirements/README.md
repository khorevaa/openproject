---
sidebar_navigation:
  title: System requirements
  priority: 1000
---

# System requirements

__Note__: The configurations described below are what we use and test against.
This means that other configurations might also work but we do not
provide any official support for them.

## Server

### Hardware

* __Memory:__ 4096 MB
* __Free disk space:__ 2 GB

### Operating system

The [package-based installation](../installation/packaged) requires one of the following Linux distributions:

| Distribution (**64 bits only**) |
| ------------------------------- |
| Ubuntu 20.04 Focal              |
| Ubuntu 18.04 Bionic Beaver      |
| Ubuntu 16.04 Xenial Xerus       |
| Debian 10 Buster                |
| Debian 9 Stretch                |
| CentOS/RHEL 8.x                 |
| CentOS/RHEL 7.x                 |
| Suse Linux Enterprise Server 12 |

The [docker-based installation](../installation/docker) requires a system with Docker installed. Please see the [official Docker page](https://docs.docker.com/install/) for the list of supported systems.

### Overview of dependencies

Both the package and docker based installations will install and setup the following dependencies that are required by OpenProject to run:

* __Runtime:__ [Ruby](https://www.ruby-lang.org/en/) Version = 2.7.x
* __Webserver:__ [Apache](http://httpd.apache.org/)
  or [nginx](http://nginx.org/en/docs/)
* __Application server:__ [Puma](https://puma.io/)
* __Database__: [PostgreSQL](http://www.postgresql.org/) Version >= 9.5

## Client

OpenProject supports the latest versions of the major browsers. 

* [Mozilla Firefox](https://www.mozilla.org/en-US/firefox/products/) (at least ESR version 78.3.1)
* [Microsoft Edge](https://www.microsoft.com/de-de/windows/microsoft-edge)
* [Google Chrome](https://www.google.com/chrome/browser/desktop/)
* [Apple Safari](https://www.apple.com/safari/)

## Frequently asked questions (FAQ)

### Can I run OpenProject on Windows?

At the moment this is not officially supported, although the docker image might work. Check above regarding the system requirements.
