## ChaosLab: Overlay for Gentoo Linux

![packages 181](https://img.shields.io/badge/packages-181-yellow.svg?style=flat-square)
![ebuilds 235](https://img.shields.io/badge/ebuilds-235-orange.svg?style=flat-square)

The scope of this overlay is to host ebuilds for packages related to secure communication,
cryptocurrency, server-side applications, and many other things that I'm interested in. It
also include full support for `libressl` USE flag and **OpenRC**. You can visit a
[user-friendly](LISTING.md) list of packages, where I hope that you find it useful.

**If you find any bugs, please report them!** You can use the
[GibLab issue tracker](https://gitlab.com/chaoslab/chaoslab-overlay/issues) to report bugs, ask
questions or suggest new features. I am also happy to accept merge requests from anyone. If you
prefer private communication, feel free to contact by [e-mail](overlay.xml#L9)
([PGP Public Key](#signature)).

**DISCLAIMER:** As I don't have the resources, nor the time to make stable ebuilds
in the same way Gentoo developers do, all ebuilds are permanently kept in the _testing
branch¹_. Thus, you should probably consider it to be _unsafe_ and treat it as such.
Nevertheless, I try my best to follow Gentoo's QA standards and keep everything up to date,
as I use many of these packages in a production environment.

> ¹ *If a package is in testing, it means that the developers feel that it is functional,
but has not been thoroughly tested. Users using the testing branch might very well be the
first to discover a bug in the package in which case they should file a bug report to let
the developers know about it.* —
[Gentoo's Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Portage#Testing) ↩

## How to install the overlay
You can use it by adding this in `/etc/portage/repos.conf/chaoslab.conf` (recommended):

```ini
[chaoslab]
priority = 50
location = /usr/local/overlay/chaoslab
sync-type = git
sync-uri = https://gitlab.com/chaoslab/chaoslab-overlay.git
auto-sync = Yes
```

Alternatively, for automatic install, you must have
[`app-eselect/eselect-repository`](https://packages.gentoo.org/packages/app-eselect/eselect-repository)
or [`app-portage/layman`](https://packages.gentoo.org/packages/app-portage/layman)
installed on your system for this to work.

#### With `eselect-repository`:
```console
eselect repository enable chaoslab
```

#### With `layman`:
```console
layman -fa chaoslab
```

> **Note:** To use the testing branch for particular packages, you must add the package
category and name (e.g., foo-bar/xyz) in `/etc/portage/package.accept_keywords`. It is
also possible to create a directory (with the same name) and list the package in the
files under that directory. Please see the [Gentoo Wiki](https://wiki.gentoo.org/wiki/Ebuild_repository)
for an expanded overview of ebuilds and unofficial repositories for Gentoo.

## Signature
All commits and manifests on the first parent (at least) are signed by me.
* Signing key: `0x5010AD684AB2A4EE` @ _your favorite public key server_
* Fingerprint: `46D2 70C0 8BAA 08C2 3250  16B4 4B7D 696C 954F 8EDD`

## Donations are welcome 🖤
* Bitcoin _Cash_: `qpgh64feure4a42073wxz3v867t45ht3csxlsx693d`
* Dash: `Xg8AVx7YLSpTagR5DSzHk9Na1oDMUwb2hk`
* Ether: `0x002e7A11013BF05D418FD3FbdA4f3381E82e5A23`
* Zcash: `zcX1qbN2YJKARPmFcrU3HgpQfYbWe9yy4YsogDA4gpwJ6NGk2bXZ6nyNDo3HLBkAKizRPkASSEduGeVtzj3VfixFey9y1Yx`
* Monero: ↴
`4KseVC8hDgP27ata3RuhyFbr1YMYn24hKDQixKTiQTufGX6Fn9vYTsvNY3uaZwivEQXXeewBk6d8eFymEGCU8pArN5m8JxkAcAu5CQRwat`

