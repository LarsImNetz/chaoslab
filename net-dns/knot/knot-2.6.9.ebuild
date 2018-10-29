# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit systemd tmpfiles user

KNOT_MODULES=(
	+module-dnsproxy module-dnstap +module-noudp
	+module-onlinesign module-rosedb +module-rrl
	+module-stats +module-synthrecord +module-whoami
)

DESCRIPTION="High-performance authoritative-only DNS server"
HOMEPAGE="https://www.knot-dns.cz"
SRC_URI="https://secure.nic.cz/files/knot-dns/${P}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="caps +daemon doc +fastparser idn libidn2 static-libs systemd +utils"
REQUIRED_USE="
	caps? ( daemon )
	idn? ( daemon )
	systemd? ( daemon )
"

for X in "${KNOT_MODULES[@]}"; do
	IUSE+=" ${X}"
	REQUIRED_USE+=" ${X#+}? ( daemon )"
done
unset X

RDEPEND="
	dev-db/lmdb
	dev-libs/libedit
	dev-libs/userspace-rcu:=
	net-libs/gnutls
	caps? ( sys-libs/libcap-ng )
	daemon? ( dev-python/lmdb )
	idn? (
		!libidn2? ( net-dns/libidn:0 )
		libidn2? ( >=net-dns/libidn2-2 )
	)
	module-dnstap? (
		dev-libs/fstrm
		dev-libs/protobuf-c
	)
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? ( dev-python/sphinx )
"

pkg_setup() {
	if use daemon; then
		enewgroup knot 53
		enewuser knot 53 -1 /var/lib/knot knot
	fi
}

# shellcheck disable=SC2191,SC2206,SC2207,SC2086
src_configure() {
	local myconf X

	use daemon && myconf+=(
		--with-storage="${EPREFIX}"/var/lib/knot
		--with-rundir="${EPREFIX}"/var/run/knot
	)

	for X in "${KNOT_MODULES[@]#+}"; do
		myconf+=( --with-${X}=$(usex ${X} 'shared') )
	done

	myconf+=(
		--enable-systemd=$(usex systemd)
		$(use_enable daemon)
		$(use_enable fastparser)
		$(use_enable module-dnstap dnstap)
		$(use_enable doc documentation)
		$(use_enable static-libs static)
		$(use_enable utils utilities)
		$(use_with idn libidn)
	)
	econf "${myconf[@]}" || die "econf failed"
}

src_compile() {
	default

	if use doc; then
		emake -C doc html
		HTML_DOCS=( doc/_build/html/{*.html,*.js,_sources,_static} )
	fi
}

src_install() {
	default

	if use daemon; then
		newinitd "${FILESDIR}/${PN}.initd" "${PN}"
		systemd_dounit "${FILESDIR}/${PN}.service"
		newtmpfiles "${FILESDIR}/${PN}.tmpfilesd" "${PN}.conf"

		rmdir "${D%/}"/var/run/knot "${D%/}"/var/run || die
	fi
}

pkg_postinst() {
	# Trigger cache dir creation to allow immediate use of knot
	use daemon && tmpfiles_process "${PN}.conf"
}
