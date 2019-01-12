# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic user

DESCRIPTION="A caching full DNS resolver implementation written in C and LuaJIT"
HOMEPAGE="https://www.knot-resolver.cz"
SRC_URI="https://secure.nic.cz/files/${PN}/${P}.tar.xz"
RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="dnstap go +pie test"

RDEPEND="
	>=net-dns/knot-2.7.2
	>=dev-libs/libuv-1.7.0
	dev-lang/luajit:2
	dev-lua/luasocket
	dev-lua/luasec
	net-libs/libnsl
	net-libs/gnutls
	dnstap? (
		>=dev-libs/protobuf-3.0
		dev-libs/protobuf-c
		dev-libs/fstrm
	)
	go? ( >=dev-lang/go-1.5.0 )
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	test? ( dev-util/cmocka )
"

pkg_setup() {
	enewgroup kresd
	enewuser kresd -1 -1 /var/lib/knot-resolver kresd
}

src_prepare() {
	# fix compiling with multilib-strict feature enabled
	sed -i "s:^LIBDIR.*:LIBDIR ?= \$(PREFIX)/$(get_libdir):" \
		./config.mk || die

	sed -i \
		-e "s:'knot-resolver':'kresd':g" \
		-e "s:root.keys:${EPREFIX}/var/lib/knot-resolver/root.keys:g" \
		etc/config.{cluster,isp,personal,splitview} || die

	sed -i "s:-- net:net:" etc/config.personal || die

	default
}

src_compile() {
	append-cflags -DNDEBUG
	# shellcheck disable=SC2046
	emake \
		LDFLAGS="${LDFLAGS}" \
		PREFIX="${EPREFIX}/usr" \
		ETCDIR="${EPREFIX}/etc/knot-resolver" \
		ENABLE_DNSTAP=$(usex dnstap) \
		HARDENING=$(usex pie) \
		HAS_cmocka=$(usex test) \
		HAS_go=$(usex go) \
		HAS_libsystemd=no
}

src_test() {
	emake check
	use dnstap && emake ckeck-dnstap
}

src_install() {
	emake \
		PREFIX="${EPREFIX}"/usr \
		ETCDIR="${EPREFIX}"/etc/knot-resolver \
		DESTDIR="${D}" install

	newinitd "${FILESDIR}/${PN}.initd" kresd
	newconfd "${FILESDIR}/${PN}.confd" kresd

	insinto /etc/logrotate.d
	newins "${FILESDIR}/${PN}.logrotate-r1" "${PN}"

	diropts -o kresd -g kresd -m 0750
	keepdir /var/log/knot-resolver
}

pkg_postinst() {
	if [[ ! -e "${EROOT}/etc/knot-resolver/config" ]]; then
		elog "No config found, copying the example over"
		cp "${EROOT}"/etc/knot-resolver/config{.personal,} || die
	fi
}
