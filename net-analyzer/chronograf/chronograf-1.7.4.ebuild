# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Change this when you update the ebuild
GIT_COMMIT="49fd1ec13ca31a79ed17580491ab66ea0506e0da"
EGO_PN="github.com/influxdata/${PN}"
EGO_VENDOR=( "github.com/kevinburke/go-bindata v3.12.0" )

inherit golang-vcs-snapshot-r1 systemd user

DESCRIPTION="Open source monitoring and visualization UI for the TICK stack"
HOMEPAGE="https://www.influxdata.com"
ARCHIVE_URI="https://${EGO_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="${ARCHIVE_URI} ${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="AGPL-3+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug pie"

DEPEND="
	<=net-libs/nodejs-11
	>net-libs/nodejs-6
	sys-apps/yarn
"

DOCS=( CHANGELOG.md )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_pretend() {
	# shellcheck disable=SC2086
	if has network-sandbox ${FEATURES} && [[ "${MERGE_TYPE}" != binary ]]; then
		ewarn
		ewarn "${CATEGORY}/${PN} requires 'network-sandbox' to be disabled in FEATURES"
		ewarn
		die "[network-sandbox] is enabled in FEATURES"
	fi
}

pkg_setup() {
	enewgroup chronograf
	enewuser chronograf -1 -1 /var/lib/chronograf chronograf
}

src_prepare() {
	# Remove git calls, as the tarball isn't a proper git repository
	sed -i "/COMMIT ?=/d" Makefile || die
	sed -i "s:GIT_SHA=\$(git rev-parse HEAD):GIT_SHA=${GIT_COMMIT}:" \
		ui/package.json || die

	default
}

src_compile() {
	export GOPATH="${G}"
	export GOBIN="${S}/bin"
	local PATH="${GOBIN}:$PATH"
	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "main.version=${PV}"
		-X "main.commit=${GIT_COMMIT:0:8}"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie exe)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)

	# Build go-bindata locally
	go install ./vendor/github.com/kevinburke/go-bindata/go-bindata || die

	emake .jsdep
	touch .godep || die
	emake .jssrc
	emake .bindata

	go install "${mygoargs[@]}" ./cmd/{chronograf,chronoctl} || die
}

src_install() {
	dobin bin/{chronoctl,chronograf}
	use debug && dostrip -x /usr/bin/{chronoctl,chronograf}

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

	einstalldocs
}
