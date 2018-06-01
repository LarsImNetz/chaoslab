# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit systemd

DESCRIPTION="A small SSH server with state-of-the-art cryptography"
HOMEPAGE="https://tinyssh.org"
SRC_URI="https://github.com/janmojzis/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="sys-apps/ucspi-tcp"

src_prepare() {
	# Leave optimization level to user CFLAGS
	sed -i 's/-O3 -fomit-frame-pointer -funroll-loops//g' \
		./conf-cc || die "sed fix failed!"

	# Use make-tinysshcc.sh script, which has
	# no tests and doesn't execute binaries
	# https://github.com/janmojzis/tinyssh/issues/2
	sed -i 's/tinyssh/tinysshcc/g' ./Makefile || die

	default
}

src_compile() {
	emake compile
}

src_install() {
	dosbin build/bin/${PN}d{,-makekey}
	dobin build/bin/${PN}d-printkey
	doman man/*

	newinitd "${FILESDIR}"/${PN}.initd-r1 ${PN}
	newconfd "${FILESDIR}"/${PN}.confd ${PN}

	systemd_newunit "${FILESDIR}"/${PN}.service "${PN}@.service"
	systemd_newunit "${FILESDIR}"/${PN}.socket "${PN}@.socket"
	systemd_dounit "${FILESDIR}"/${PN}-makekey.service
}

pkg_postinst() {
	einfo
	einfo "TinySSH is in beta stage, and ready for production use."
	einfo
	einfo "See https://tinyssh.org for more information."
	einfo
}
