# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/joohoi/${PN}"

inherit fcaps golang-vcs-snapshot user

DESCRIPTION="A simplified DNS server with a RESTful HTTP API to provide ACME DNS challenges"
HOMEPAGE="https://github.com/joohoi/acme-dns"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="pie postgres +sqlite"
REQUIRED_USE="|| ( postgres sqlite )"

RDEPEND="
	postgres? ( dev-db/postgresql )
	sqlite? ( dev-db/sqlite:3 )
"

DOCS=( README.md )
FILECAPS=( cap_net_bind_service+ep usr/bin/acme-dns )
QA_PRESTRIPPED="usr/bin/acme-dns"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup acme-dns
	enewuser acme-dns -1 -1 /var/lib/acme-dns acme-dns
}

src_compile() {
	export GOPATH="${G}"

	# build up optional flags
	use postgres && opts+=" postgres"
	use sqlite && opts+=" sqlite3"

	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w"
		-tags "${opts/ /}"
	)
	go build "${mygoargs[@]}" || die
}

src_install() {
	dobin acme-dns
	einstalldocs

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"

	insinto /var/lib/acme-dns
	newins config.cfg config.cfg.example

	diropts -o acme-dns -g acme-dns -m 0750
	keepdir /var/log/acme-dns
}

pkg_postinst() {
	fcaps_pkg_postinst

	if [[ $(stat -c %a "${EROOT%/}/var/lib/acme-dns") != "750" ]]; then
		einfo "Fixing ${EROOT%/}/var/lib/acme-dns permissions"
		chown -R acme-dns:acme-dns "${EROOT%/}/var/lib/acme-dns" || die
		chmod 0750 "${EROOT%/}/var/lib/acme-dns" || die
	fi

	if ! use filecaps; then
		ewarn
		ewarn "'filecaps' USE flag is disabled"
		ewarn "${PN} will fail to listen on port 53"
		ewarn "please either change port to > 1024 or re-enable 'filecaps'"
		ewarn
	fi
}
