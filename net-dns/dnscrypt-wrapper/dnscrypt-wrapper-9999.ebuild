# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3 systemd user

DESCRIPTION="A server-side DNSCrypt proxy"
HOMEPAGE="https://github.com/cofyc/dnscrypt-wrapper"
EGIT_REPO_URI="https://github.com/cofyc/${PN}.git"

LICENSE="BSD"
SLOT="0"
KEYWORDS=""
IUSE="examples"

DEPEND="dev-libs/libsodium[-minimal]
	>=dev-libs/libevent-2.1.8"
RDEPEND="${DEPEND}"

DOCS=( README.md )

pkg_setup() {
	enewgroup dnscrypt-wrapper
	enewuser dnscrypt-wrapper -1 -1 -1 dnscrypt-wrapper
}

src_install() {
	emake PREFIX="${EPREFIX}/usr" \
		DESTDIR="${D%/}" install

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	systemd_newunit "${FILESDIR}/${PN}.service-r1" "${PN}.service"

	insinto /etc/default
	newins "${FILESDIR}/${PN}.confd" "${PN}"

	diropts -o dnscrypt-wrapper -g dnscrypt-wrapper -m750
	dodir /etc/dnscrypt-wrapper

	einstalldocs

	if use examples; then
		docinto examples
		dodoc -r example/*
		docompress -x "/usr/share/doc/${PF}/examples"
	fi
}
