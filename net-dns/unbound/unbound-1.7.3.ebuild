# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python2_7 )

inherit eutils flag-o-matic python-single-r1 systemd user

DESCRIPTION="A validating, recursive and caching DNS resolver"
HOMEPAGE="https://unbound.net"
SRC_URI="https://unbound.net/downloads/${P}.tar.gz"
RESTRICT="mirror"

LICENSE="BSD GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="debug dnscrypt dnstap +ecdsa gost libressl python redis selinux static-libs test threads"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

CDEPEND=">=dev-libs/expat-2.1.0-r3
	>=dev-libs/libevent-2.0.21:0=
	dnscrypt? ( dev-libs/libsodium )
	dnstap? (
		dev-libs/fstrm
		>=dev-libs/protobuf-c-1.0.2-r1
	)
	ecdsa? (
		!libressl? ( dev-libs/openssl:0[-bindist] )
	)
	libressl? ( dev-libs/libressl:0= )
	!libressl? ( dev-libs/openssl:0= )
	python? ( ${PYTHON_DEPS} )
	redis? ( dev-libs/hiredis )"
DEPEND="${CDEPEND}
	python? ( dev-lang/swig )
	test? (
		net-dns/ldns-utils[examples]
		dev-util/splint
		app-text/wdiff
	)"
RDEPEND="${CDEPEND}
	net-dns/dnssec-root
	selinux? ( sec-policy/selinux-bind )"

# To avoid below error messages, set 'trust-anchor-file' to same value in
# 'auto-trust-anchor-file'.
# [23109:0] error: Could not open autotrust file for writing,
# /etc/dnssec/root-anchors.txt: Permission denied
PATCHES=( "${FILESDIR}/${PN}-1.5.7-trust-anchor-file.patch" )

pkg_setup() {
	enewgroup unbound
	enewuser unbound -1 -1 /etc/unbound unbound
	# improve security on existing installs (bug #641042)
	# as well as new installs where unbound homedir has just been created
	if [[ -d "${ROOT%/}/etc/unbound" ]]; then
		chown --no-dereference --from=unbound root "${ROOT%/}/etc/unbound" || die
	fi

	use python && python-single-r1_pkg_setup
}

src_configure() {
	append-ldflags -Wl,-z,noexecstack
	# shellcheck disable=SC2207,SC2191
	local myeconf=(
		$(use_enable debug)
		$(use_enable dnscrypt)
		$(use_enable dnstap)
		$(use_enable ecdsa)
		$(use_enable gost)
		$(use_enable redis cachedb)
		$(use_enable static-libs static)
		$(use_with python pythonmodule)
		$(use_with python pyunbound)
		$(use_with threads pthreads)
		$(use_with redis libhiredis)
		--disable-flto
		--disable-rpath
		--with-libevent="${EPREFIX}"/usr
		--with-pidfile="${EPREFIX}"/var/run/unbound.pid
		--with-rootkey-file="${EPREFIX}"/etc/dnssec/root-anchors.txt
		--with-ssl="${EPREFIX}"/usr
		--with-libexpat="${EPREFIX}"/usr
	)
	econf "${myeconf[@]}"

		# http://unbound.nlnetlabs.nl/pipermail/unbound-users/2011-April/001801.html
		# $(use_enable debug lock-checks) \
		# $(use_enable debug alloc-checks) \
		# $(use_enable debug alloc-lite) \
		# $(use_enable debug alloc-nonregional) \
}

src_install() {
	default
	prune_libtool_files --modules
	use python && python_optimize

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"

	systemd_dounit "${FILESDIR}/${PN}.service"
	systemd_newunit "${FILESDIR}/${PN}_at.service" "unbound@.service"
	systemd_dounit "${FILESDIR}/${PN}-anchor.service"

	dodoc doc/{README,CREDITS,TODO,Changelog,FEATURES}
	dodoc contrib/unbound_munin_

	if use selinux; then
		docinto selinux
		dodoc contrib/selinux/*
	fi

	exeinto /usr/share/unbound
	doexe contrib/update-anchor.sh

	# create space for auto-trust-anchor-file...
	keepdir /etc/unbound/var
	# ... and point example config to it
	sed -i '/# auto-trust-anchor-file:/s,/etc/dnssec/root-anchors.txt,/etc/unbound/var/root-anchors.txt,' \
		"${ED%/}/etc/unbound/unbound.conf" || die
}

pkg_postinst() {
	# make var/ writable by unbound
	if [[ -d "${ROOT%/}/etc/unbound/var" ]]; then
		chown --no-dereference --from=root unbound: "${ROOT%/}/etc/unbound/var" || die
	fi
	einfo ""
	einfo "If you want unbound to automatically update the root-anchor file for DNSSEC validation"
	einfo "set 'auto-trust-anchor-file: /etc/unbound/var/root-anchors.txt' in /etc/unbound/unbound.conf"
	einfo "and run"
	einfo ""
	einfo "  su -s /bin/sh -c '/usr/sbin/unbound-anchor -a /etc/unbound/var/root-anchors.txt' unbound"
	einfo ""
	einfo "as root to create it initially before starting unbound for the first time after enabling this."
	einfo ""
}
