# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GIT_COMMIT="ce6716f" # Change this when you update the ebuild
EGO_PN="github.com/${PN}/${PN}"

inherit golang-vcs-snapshot systemd user

DESCRIPTION="The Prometheus monitoring system and time series database"
HOMEPAGE="https://prometheus.io"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="examples pie"

DOCS=( {README,CHANGELOG,CONTRIBUTING}.md )

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

QA_PRESTRIPPED="
	usr/bin/prometheus
	usr/bin/promtool
"

pkg_setup() {
	enewgroup prometheus
	enewuser prometheus -1 -1 /var/lib/prometheus prometheus
}

src_compile() {
	export GOPATH="${G}"
	export GOBIN="${S}"
	local PROMU="${EGO_PN}/vendor/${EGO_PN%/*}/common/version"
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
	go install "${mygoargs[@]}" ./cmd/{prometheus,promtool} || die
}

src_test() {
	# shellcheck disable=SC2046
	go test -v $(go list ./... | grep -v examples) || die
}

src_install() {
	dobin prometheus promtool
	einstalldocs

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"

	insinto /etc/prometheus
	newins documentation/examples/prometheus.yml prometheus.yml.example

	insinto /usr/share/prometheus
	doins -r console_libraries consoles

	dosym ../../usr/share/prometheus/console_libraries \
		/etc/prometheus/console_libraries
	dosym ../../usr/share/prometheus/consoles /etc/prometheus/consoles

	if use examples; then
		docinto examples
		dodoc -r examples/*
		docompress -x "/usr/share/doc/${PF}/examples"
	fi

	diropts -o prometheus -g prometheus -m 0750
	keepdir /var/log/prometheus
}

pkg_postinst() {
	if [[ $(stat -c %a "${EROOT%/}/var/lib/prometheus") != "750" ]]; then
		einfo "Fixing ${EROOT%/}/var/lib/prometheus permissions"
		chown prometheus:prometheus "${EROOT%/}/var/lib/prometheus" || die
		chmod 0750 "${EROOT%/}/var/lib/prometheus" || die
	fi

	if [[ ! -e "${EROOT%/}/etc/prometheus/prometheus.yml" ]]; then
		elog "No prometheus.yml found, copying the example over"
		cp "${EROOT%/}"/etc/prometheus/prometheus.yml{.example,} || die
	else
		elog "prometheus.yml found, please check example file for possible changes"
	fi
}
