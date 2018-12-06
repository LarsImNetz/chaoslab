# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

GIT_COMMIT="d4a7697cc9" # Change this when you update the ebuild
EGO_PN="github.com/prometheus/${PN}"

inherit golang-vcs-snapshot-r1 systemd user

DESCRIPTION="Handles alerts sent by client applications such as the Prometheus"
HOMEPAGE="https://prometheus.io"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug pie"

DOCS=( NOTICE CHANGELOG.md README.md )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup alertmanager
	enewuser alertmanager -1 -1 /var/lib/alertmanager alertmanager
}

src_compile() {
	export GOPATH="${G}"
	export GOBIN="${S}"
	local PROMU="${EGO_PN}/vendor/${EGO_PN%/*}/common/version"
	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "${PROMU}.Version=${PV}"
		-X "${PROMU}.Revision=${GIT_COMMIT}"
		-X "${PROMU}.Branch=non-git"
		-X "${PROMU}.BuildUser=$(id -un)@$(hostname -f)"
		-X "${PROMU}.BuildDate=$(date -u '+%Y%m%d-%I:%M:%S')"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie exe)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)
	go install "${mygoargs[@]}" ./cmd/{alertmanager,amtool} || die
}

src_test() {
	# shellcheck disable=SC2046
	go test -v $(go list ./... | grep -v /test) || die
}

src_install() {
	dobin {alertmanager,amtool}
	use debug && dostrip -x /usr/bin/{alertmanager,amtool}

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	systemd_newunit "${FILESDIR}/${PN}.service" "${PN}.service"

	insinto /etc/alertmanager
	newins doc/examples/simple.yml alertmanager.yml.example

	diropts -o alertmanager -g alertmanager -m 0750
	keepdir /var/log/alertmanager

	einstalldocs
}

pkg_postinst() {
	if [[ ! -e "${EROOT}/etc/alertmanager/alertmanager.yml" ]]; then
		elog "No alertmanager.yml found, copying the example over"
		cp "${EROOT}"/etc/alertmanager/alertmanager.yml{.example,} || die
	else
		elog "alertmanager.yml found, please check example file for possible changes"
	fi
}
