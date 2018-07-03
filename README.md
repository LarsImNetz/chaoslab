ChaosLab: Overlay for Gentoo Linux
----------------------------------

[![packages 200](https://img.shields.io/badge/packages-200-4472c0.svg)](https://gitlab.com/chaoslab/chaoslab-overlay)
[![ebuilds 277](https://img.shields.io/badge/ebuilds-277-8c71cc.svg)](https://gitlab.com/chaoslab/chaoslab-overlay)
[![pipeline status](https://gitlab.com/chaoslab/chaoslab-overlay/badges/master/pipeline.svg)](https://gitlab.com/chaoslab/chaoslab-overlay/commits/master)
[![pipeline status](https://gitlab.com/chaoslab/chaoslab-overlay/badges/develop/pipeline.svg)](https://gitlab.com/chaoslab/chaoslab-overlay/commits/develop)

The scope of this overlay is to maintain ebuilds for packages related to secure
communication, cryptography, cryptocurrency, server-side applications, and other
things that I'm interested in. It also include full support for `libressl` USE
flag and **OpenRC**. The support for **systemd** has been less-than-stellar
because I don't have any machines to test its unit files. If you have spare time
and would like to improve it, please contribute.

You may visit [LISTING.md](LISTING.md) to see a comprehensive list of available
packages and its descriptions. **If you find any bugs, please report them!** You
can use the [GitLab issue tracker](https://gitlab.com/chaoslab/chaoslab-overlay/issues)
or [e-mail](overlay.xml#L9) ([PGP Public Key](#signature)) to report bugs, ask
questions or suggest new features. Needless to say, MR are welcomed.

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

## How to install the overlay
You can clone the repository and create `/etc/portage/repos.conf/chaoslab.conf`
with the following contents:

```ini
[chaoslab]
priority = 50
location = /path/to/local/chaoslab-overlay
auto-sync = yes
sync-type = git
sync-uri = https://gitlab.com/chaoslab/chaoslab-overlay.git
```

> **Note:** I recommend that you manually install the overlay, as obviously you
will be pulling directly from the original source. If you use the automatic
installation described below, you will be pulling from
[gentoo's mirror](https://github.com/gentoo-mirror) service, in which from time
to time have [sync issues](https://bugs.gentoo.org/653472).

Alternatively, for automatic install, you must have
[app-eselect/eselect-repository](https://packages.gentoo.org/packages/app-eselect/eselect-repository)
or [app-portage/layman](https://packages.gentoo.org/packages/app-portage/layman)
installed on your system for this to work.

#### Using `eselect-repository`:
```
eselect repository enable chaoslab
```

#### Using `layman`:
```
layman -fa chaoslab
```

> **Note:** To use the testing branch for particular packages, you must add the
package category and name (e.g., foo-bar/xyz) in `/etc/portage/package.accept_keywords`.
It is also possible to create a directory (with the same name) and list the
package in the files under that directory. Please see the
[Gentoo Wiki](https://wiki.gentoo.org/wiki/Ebuild_repository) for an expanded
overview of ebuilds and unofficial repositories for Gentoo.

## Signature
All commits and manifests on the first parent (at least) are signed by me.
* Signing key: `0x5010AD684AB2A4EE` @ _your favorite public key server_
* Fingerprint: `46D2 70C0 8BAA 08C2 3250  16B4 4B7D 696C 954F 8EDD`

You can easily do full-tree verification
([GLEP-74](https://www.gentoo.org/glep/glep-0074.html)) with
[app-portage/gemato](https://packages.gentoo.org/packages/app-portage/gemato):

```shell
find */* -maxdepth 2 -type d ! -path 'profiles*' -exec gemato verify -k -s {} +
```

## Want to buy me a cup of coffee?
* Bitcoin _Cash_: `qpgh64feure4a42073wxz3v867t45ht3csxlsx693d`
* Dash: `Xg8AVx7YLSpTagR5DSzHk9Na1oDMUwb2hk`
* Ether: `0x002e7A11013BF05D418FD3FbdA4f3381E82e5A23`
* Monero: `88FJacypy5kiY1FuHoowEeEpAThvM9pd5CF4U6GZvAJ3Jgfh4oZ3GdUBwkkaonjAJAFnzgFVkFXZVd38w4EdYxsWGYuzSri`
* Zcash: `zcX1qbN2YJKARPmFcrU3HgpQfYbWe9yy4YsogDA4gpwJ6NGk2bXZ6nyNDo3HLBkAKizRPkASSEduGeVtzj3VfixFey9y1Yx`

