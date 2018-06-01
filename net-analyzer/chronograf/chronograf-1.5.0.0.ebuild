# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/influxdata/${PN}"
EGO_VENDOR=( "github.com/kevinburke/go-bindata 95df019" )
GIT_COMMIT="2315266" # Change this when you update the ebuild

inherit golang-vcs-snapshot systemd user

DESCRIPTION="Open source monitoring and visualization UI for the TICK stack"
HOMEPAGE="https://www.influxdata.com"
SRC_URI="https://${EGO_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="AGPL-3+"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="<=net-libs/nodejs-9
	sys-apps/yarn"

DOCS=( CHANGELOG.md )
QA_PRESTRIPPED="usr/bin/chronoctl
	usr/bin/chronograf"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	has network-sandbox $FEATURES && \
		die "www-apps/chronograf requires 'network-sandbox' to be disabled in FEATURES"

	enewgroup chronograf
	enewuser chronograf -1 -1 /var/lib/chronograf chronograf
}

src_prepare() {
	sed -i \
		-e "/VERSION ?=/d" \
		-e "/COMMIT ?=/d" \
		Makefile || die

	emake .jsdep
	touch .godep || die
	default
}

src_compile() {
	export GOPATH="${G}"
	local PATH="${G}/bin:$PATH"

	# Build go-bindata locally
	go install ./vendor/github.com/kevinburke/go-bindata/go-bindata || die

	make \
		VERSION="${PV}" \
		COMMIT="${GIT_COMMIT}" \
		build || die
}

src_install() {
	dobin {chronoctl,chronograf}
	einstalldocs

	newinitd "${FILESDIR}"/${PN}.initd-r3 ${PN}
	newconfd "${FILESDIR}"/${PN}.confd-r2 ${PN}
	systemd_dounit etc/scripts/${PN}.service
	systemd_newtmpfilesd "${FILESDIR}"/${PN}.tmpfilesd-r1 ${PN}.conf

	dodir /usr/share/chronograf/resources
	insinto /usr/share/chronograf/canned
	doins canned/*.json

	insinto /etc/logrotate.d
	newins etc/scripts/logrotate chronograf

	diropts -o chronograf -g chronograf -m 0750
	keepdir /var/{lib,log}/chronograf
}
