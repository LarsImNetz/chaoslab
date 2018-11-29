ChaosLab: Overlay for Gentoo/Funtoo Linux
-----------------------------------------

[![packages 203](https://img.shields.io/badge/packages-203-4472c0.svg)](https://gitlab.com/chaoslab/chaoslab-overlay)
[![ebuilds 264](https://img.shields.io/badge/ebuilds-264-8c71cc.svg)](https://gitlab.com/chaoslab/chaoslab-overlay)
[![pipeline status](https://gitlab.com/chaoslab/chaoslab-overlay/badges/master/pipeline.svg)](https://gitlab.com/chaoslab/chaoslab-overlay/commits/master)
[![pipeline status](https://gitlab.com/chaoslab/chaoslab-overlay/badges/develop/pipeline.svg)](https://gitlab.com/chaoslab/chaoslab-overlay/commits/develop)

The scope of this overlay is to maintain ebuilds for packages related to secure
communication, cryptography, cryptocurrency, server-side applications, and other
things that I'm interested in. You may check [LISTING.md](LISTING.md) to see a
list of available packages and their associated description.

This overlay also includes full support for `libressl` USE flag and **OpenRC**,
but unfortunately the support for **systemd** has been less than stellar because
I don't have any machines to test its _unit_ files. If you have spare time and
would like to improve it, please [contribute](CONTRIBUTING.md).

**DISCLAIMER:** As I don't have the resources, nor the time to make stable
ebuilds in the same way Gentoo developers do, all ebuilds are permanently kept
in the _testing branch¹_. Thus, you should probably consider it to be _unsafe_
and treat it as such. Nevertheless, I try my best to follow Gentoo's QA
standards and keep everything up to date, as I use many of these packages in a
production environment.

> ¹ *If a package is in testing, it means that the developers feel that it is
functional, but has not been thoroughly tested. Users using the testing branch
might very well be the first to discover a bug in the package in which case they
should file a bug report to let the developers know about it.* —
[Gentoo's Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Portage#Testing)

> **Note:** To use the testing branch for particular packages, you must add the
package category and name (e.g., foo-bar/xyz) in `/etc/portage/package.accept_keywords`.
It is also possible to create a directory (with the same name) and list the
package in the files under that directory. Please see the
[Gentoo Wiki](https://wiki.gentoo.org/wiki/Ebuild_repository) for an expanded
overview of ebuilds and unofficial repositories for Gentoo.

## How to install the overlay

You can clone the repository and create `/etc/portage/repos.conf/chaoslab.conf`
with the following contents:

```ini
[chaoslab]
priority = 50
location = /path/to/local/chaoslab-overlay
sync-type = git
sync-uri = https://gitlab.com/chaoslab/chaoslab-overlay.git
```

For automatic install, you must have
[app-eselect/eselect-repository](https://packages.gentoo.org/packages/app-eselect/eselect-repository)
or [app-portage/layman](https://packages.gentoo.org/packages/app-portage/layman)
installed on your system for this to work.

#### Using [eselect-repository](https://wiki.gentoo.org/wiki/Eselect/Repository)

```
eselect repository enable chaoslab
```

#### Using [layman](https://wiki.gentoo.org/wiki/Layman)

```
layman -fa chaoslab
```

#### Loner's MO

Alternatively, if you really don't want to install the overlay, but are
interested in some package(s) (want to keep outdated versions, customize things,
other reasons), that's also fine. You can keep such ebuilds in your _local_
repository.

Here is a complete example of creating minimal local repository:

```shell
MY_REPO="/path/to/local/repository"

mkdir -p "${MY_REPO}"/{metadata,profiles}
echo "localrepo" > "${MY_REPO}"/profiles/repo_name
printf "masters = gentoo\nauto-sync = false\n" > "${MY_REPO}"/metadata/layout.conf
# Register your local overlay in /etc/portage/repos.conf:
printf "[localrepo]\nlocation = ${MY_REPO}\n" > /etc/portage/repos.conf/localrepo.conf

# Now copy the desired directories (category/package-name) into your ${MY_REPO}
```

## Signature

All manifests and commits on the first parent (at least) are signed by me.
* Signing key: `0x5010AD684AB2A4EE`
* Fingerprint: `46D2 70C0 8BAA 08C2 3250 16B4 4B7D 696C 954F 8EDD`

Also, you can easily do full-tree verification
([GLEP-74](https://www.gentoo.org/glep/glep-0074.html)) with
[app-portage/gemato](https://packages.gentoo.org/packages/app-portage/gemato):

```shell
find */* -maxdepth 2 -type d ! -path 'profiles*' -exec gemato verify -k -s {} +
```

## Contributing

Anyone and everyone is welcome to contribute. Please take a moment to review the
[contribution guidelines](CONTRIBUTING.md).
