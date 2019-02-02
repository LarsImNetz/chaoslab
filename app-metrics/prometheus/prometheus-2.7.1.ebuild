# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/${PN}/${PN}"
MY_PV="${PV/_rc/-rc.}"

inherit golang-vcs-snapshot-r1 systemd user

DESCRIPTION="The Prometheus monitoring system and time series database"
HOMEPAGE="https://prometheus.io"
SRC_URI="https://${EGO_PN}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug examples pie static"

DOCS=( {README,CHANGELOG,CONTRIBUTING}.md )

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

QA_PRESTRIPPED="usr/bin/.*"

pkg_setup() {
	enewgroup prometheus
	enewuser prometheus -1 -1 /var/lib/prometheus prometheus
}

src_compile() {
	export GOPATH="${G}"
	export GOBIN="${S}"
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"
	(use static && ! use pie) && export CGO_ENABLED=0
	(use static && use pie) && CGO_LDFLAGS+=" -static"

	local PROMU="${EGO_PN}/vendor/${EGO_PN%/*}/common/version"
	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "${PROMU}.Branch=non-git"
		-X "${PROMU}.BuildDate=$(date -u '+%Y%m%d-%I:%M:%S')"
		-X "${PROMU}.BuildUser=$(id -un)@$(hostname -f)"
		-X "${PROMU}.Revision=non-git"
		-X "${PROMU}.Version=${MY_PV}"
	)

	local mygoargs=(
		-v -work -x
		-buildmode "$(usex pie pie exe)"
		-asmflags "all=-trimpath=${S}"
		-gcflags "all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
		-tags "$(usex static 'netgo' '')"
		-installsuffix "$(usex static 'netgo' '')"
	)

	go install "${mygoargs[@]}" ./cmd/{prometheus,promtool} || die
}

src_test() {
	# shellcheck disable=SC2046
	go test -v $(go list ./... | grep -v examples) || die
}

src_install() {
	dobin {prometheus,promtool}
	use debug && dostrip -x /usr/bin/{prometheus,promtool}
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
	if [[ ! -e "${EROOT}/etc/prometheus/prometheus.yml" ]]; then
		elog "No prometheus.yml found, copying the example over"
		cp "${EROOT}"/etc/prometheus/prometheus.yml{.example,} || die
	else
		elog "prometheus.yml found, please check example file for possible changes"
	fi
}
