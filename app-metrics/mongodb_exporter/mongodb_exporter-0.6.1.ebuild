# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GIT_COMMIT="e5a3c61" # Change this when you update the ebuild
EGO_PN="github.com/percona/${PN}"
EGO_VENDOR=(
	"github.com/AlekSi/gocoverutil c7c9efd"
	"github.com/stretchr/testify f35b8ab"
	"golang.org/x/tools 16f8f9b github.com/golang/tools"
)

inherit golang-vcs-snapshot systemd user

DESCRIPTION="A Prometheus exporter for MongoDB"
HOMEPAGE="https://github.com/percona/mongodb_exporter"
SRC_URI="https://${EGO_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="pie test"

DEPEND="test? ( dev-db/mongodb )"

DOCS=( CHANGELOG.md README.md )
QA_PRESTRIPPED="usr/bin/mongodb_exporter"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	if use test; then
		ewarn ""
		ewarn "The test phase requires a local MongoDB server running on default port"
		ewarn ""
		# shellcheck disable=SC2086
		if has network-sandbox $FEATURES; then
			ewarn ""
			ewarn "The test phase requires 'network-sandbox' to be disabled in FEATURES"
			ewarn ""
			die "'network-sandbox' is enabled in FEATURES"
		fi
	fi

	enewgroup mongodb_exporter
	enewuser mongodb_exporter -1 -1 -1 mongodb_exporter
}

src_compile() {
	export GOPATH="${G}"
	local PROMU="${EGO_PN}/vendor/github.com/prometheus/common/version"
	local myldflags=( -s -w
		-X "${PROMU}.Version=${PV}"
		-X "${PROMU}.Revision=${GIT_COMMIT}"
		-X "${PROMU}.Branch=non-git"
		-X "${PROMU}.BuildUser=$(id -un)@$(hostname -f)"
		-X "${PROMU}.BuildDate=$(date -u '+%Y%m%d-%I:%M:%S')"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)
	go build "${mygoargs[@]}" || die

	if use test; then
		# Build gocoverutil locally
		go install ./vendor/github.com/AlekSi/gocoverutil || die
	fi
}

src_test() {
	local PATH="${G}/bin:$PATH"
	default
}

src_install() {
	dobin mongodb_exporter
	einstalldocs

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"

	diropts -o mongodb_exporter -g mongodb_exporter -m 0750
	keepdir /var/log/mongodb_exporter
}
