# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 python3_{4,5,6,7} )

inherit flag-o-matic python-single-r1 user

DESCRIPTION="A validating, recursive and caching DNS resolver"
HOMEPAGE="https://unbound.net/ https://nlnetlabs.nl/projects/unbound/about/"
SRC_URI="https://nlnetlabs.nl/downloads/unbound/${P}.tar.gz"
RESTRICT="mirror"

LICENSE="BSD GPL-2"
SLOT="0/8" # ABI version of libunbound.so
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="debug dnscrypt dnstap +ecdsa ecs gost libressl python redis selinux static-libs test threads"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

CDEPEND="
	>=dev-libs/expat-2.1.0-r3
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
	redis? ( dev-libs/hiredis:= )
"
DEPEND="${CDEPEND}
	python? ( dev-lang/swig )
	test? (
		net-dns/ldns-utils[examples]
		dev-util/splint
		app-text/wdiff
	)
"
RDEPEND="${CDEPEND}
	net-dns/dnssec-root
	selinux? ( sec-policy/selinux-bind )
"

PATCHES=( "${FILESDIR}/${PN}-1.5.7-trust-anchor-file.patch" )

pkg_setup() {
	enewgroup unbound
	enewuser unbound -1 -1 /etc/unbound unbound
	# improve security on existing installs (bug #641042)
	# as well as new installs where unbound homedir has just been created
	if [[ -d "${EROOT}/etc/unbound" ]]; then
		chown --no-dereference --from=unbound root "${ROOT}/etc/unbound" || die
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
		$(use_enable ecs subnet)
		$(use_enable gost)
		$(use_enable redis cachedb)
		$(use_enable static-libs static)
		$(use_with python pythonmodule)
		$(use_with python pyunbound)
		$(use_with threads pthreads)
		$(use_with redis libhiredis)
		--disable-flto
		--disable-rpath
		--enable-ipsecmod
		--enable-tfo-client
		--enable-tfo-server
		--with-libevent="${EPREFIX}"/usr
		--with-pidfile="${EPREFIX}"/run/unbound.pid
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
	use python && python_optimize

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"

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
		"${ED}/etc/unbound/unbound.conf" || die

	# Used to store cache data
	keepdir /var/lib/unbound
	fowners root:unbound /var/lib/unbound
	fperms 0750 /var/lib/unbound

	find "${ED}" -name '*.la' -delete || die
	if ! use static-libs ; then
		find "${ED}" -name "*.a" -delete || die
	fi
}

pkg_postinst() {
	# make var/ writable by unbound
	if [[ -d "${EROOT}/etc/unbound/var" ]]; then
		chown --no-dereference --from=root unbound: "${EROOT}/etc/unbound/var" || die
	fi

	einfo
	einfo "If you want unbound to automatically update the root-anchor file for DNSSEC validation"
	einfo "set 'auto-trust-anchor-file: ${EROOT}/etc/unbound/var/root-anchors.txt' in ${EROOT}/etc/unbound/unbound.conf"
	einfo "and run"
	einfo
	einfo "  su -s /bin/sh -c '${EROOT}/usr/sbin/unbound-anchor -a ${EROOT}/etc/unbound/var/root-anchors.txt' unbound"
	einfo
	einfo "as root to create it initially before starting unbound for the first time after enabling this."
	einfo
}
