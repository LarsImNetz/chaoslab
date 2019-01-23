# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit systemd tmpfiles toolchain-funcs user

KNOT_MODULES=(
	+module-cookies +module-dnsproxy module-dnstap
	+module-geoip +module-noudp +module-onlinesign
	+module-queryacl +module-rrl +module-stats
	+module-synthrecord +module-whoami
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

for mod in "${KNOT_MODULES[@]}"; do
	IUSE+=" ${mod}"
	REQUIRED_USE+=" ${mod#+}? ( daemon )"
done

RDEPEND="
	dev-db/lmdb
	dev-libs/userspace-rcu:=
	net-libs/gnutls
	caps? ( sys-libs/libcap-ng )
	daemon? (
		dev-libs/libedit
		dev-python/lmdb
	)
	idn? (
		!libidn2? ( net-dns/libidn:0 )
		libidn2? ( >=net-dns/libidn2-2 )
	)
	module-dnstap? (
		dev-libs/fstrm
		dev-libs/protobuf-c
	)
	module-geoip? ( dev-libs/libmaxminddb )
	utils? ( dev-libs/libedit )
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

src_configure() {
	local myconf=""
	if use fastparser; then
		if tc-is-clang && has_version '>=sys-devel/clang-5.0.0'; then
			myconf+=( "--enable-fastparser=force" )
		else
			myconf+=( "--enable-fastparser" )
		fi
	fi

	use daemon && myconf+=(
		"--with-storage=${EPREFIX}/var/lib/knot"
		"--with-rundir=${EPREFIX}/var/run/knot"
	)

	local mod
	for mod in "${KNOT_MODULES[@]#+}"; do
		if [[ "${mod}" == module-dnsproxy ]] || \
			[[ "${mod}" == module-onlinesign ]]; then
			myconf+=( "$(use_with "${mod}")" )
		else
			myconf+=( "--with-${mod}=$(usex "${mod}" 'shared')" )
		fi
	done

	myconf+=(
		"--enable-systemd=$(usex systemd)"
		"$(use_enable daemon)"
		"$(use_enable module-dnstap dnstap)"
		"$(use_enable module-geoip maxminddb)"
		"$(use_enable doc documentation)"
		"$(use_enable static-libs static)"
		"$(use_enable utils utilities)"
		"$(use_with idn libidn)"
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

		# Remove empty directories
		rmdir "${D%/}"/var/{run/knot,run} "${D%/}"/var/{lib/knot,lib} || die
	fi

	find "${D%/}" -name '*.la' -delete || die
}

pkg_postinst() {
	# Trigger cache dir creation to allow immediate use of knot
	use daemon && tmpfiles_process "${PN}.conf"
}
