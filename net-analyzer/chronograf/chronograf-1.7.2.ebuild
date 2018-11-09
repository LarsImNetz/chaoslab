# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/influxdata/${PN}"
EGO_VENDOR=( "github.com/kevinburke/go-bindata 06af60a" )
GIT_COMMIT="62ecf3b038" # Change this when you update the ebuild

inherit golang-vcs-snapshot systemd user

DESCRIPTION="Open source monitoring and visualization UI for the TICK stack"
HOMEPAGE="https://www.influxdata.com"
SRC_URI="https://${EGO_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="AGPL-3+"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	<=net-libs/nodejs-11
	sys-apps/yarn
"

DOCS=( CHANGELOG.md )
QA_PRESTRIPPED="
	usr/bin/chronoctl
	usr/bin/chronograf
"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	# shellcheck disable=SC2086
	if has network-sandbox $FEATURES && [[ "${MERGE_TYPE}" != binary ]]; then
		ewarn
		ewarn "${CATEGORY}/${PN} requires 'network-sandbox' to be disabled in FEATURES"
		ewarn
		die "[network-sandbox] is enabled in FEATURES"
	fi

	enewgroup chronograf
	enewuser chronograf -1 -1 /var/lib/chronograf chronograf
}

src_prepare() {
	# The tarball isn't a proper git repository,
	# so let's silence the "fatal" error message.
	sed -i -e "/VERSION ?=/d" -e "/COMMIT ?=/d" Makefile || die
	sed -i "s:GIT_SHA=\$(git rev-parse HEAD):GIT_SHA=${GIT_COMMIT}:" \
		ui/package.json || die

	default
}

src_compile() {
	export GOPATH="${G}"
	local PATH="${G}/bin:$PATH"

	# Build go-bindata locally
	go install ./vendor/github.com/kevinburke/go-bindata/go-bindata || die
	emake .jsdep
	touch .godep || die

	make VERSION="${PV}" COMMIT="${GIT_COMMIT}" build || die
}

src_install() {
	dobin chronoctl chronograf
	einstalldocs

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	systemd_dounit "etc/scripts/${PN}.service"

	insinto /usr/share/chronograf/canned
	doins canned/*.json
	insinto /usr/share/chronograf/protoboards
	doins protoboards/*.json
	dodir /usr/share/chronograf/resources

	insinto /etc/logrotate.d
	newins etc/scripts/logrotate chronograf

	diropts -o chronograf -g chronograf -m 0750
	keepdir /var/log/chronograf
}
