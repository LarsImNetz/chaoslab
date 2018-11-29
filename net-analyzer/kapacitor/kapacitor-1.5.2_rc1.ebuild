# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PV="${PV/_/-}"
GIT_COMMIT="a06351a5de" # Change this when you update the ebuild
EGO_PN="github.com/influxdata/${PN}"

inherit bash-completion-r1 golang-vcs-snapshot-r1 systemd user

DESCRIPTION="A framework for processing, monitoring, and alerting on time series data"
HOMEPAGE="https://influxdata.com"
SRC_URI="https://${EGO_PN}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror test" # Some tests are failing, need more time to investigate

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug examples pie"

QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup kapacitor
	enewuser kapacitor -1 -1 /var/lib/kapacitor kapacitor
}

src_compile() {
	export GOPATH="${G}"
	export GOBIN="${S}"
	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "main.version=${MY_PV}"
		-X "main.branch=${MY_PV}"
		-X "main.commit=${GIT_COMMIT}"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie exe)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)
	go install "${mygoargs[@]}" ./cmd/kapacitor{,d} || die
}

src_test() {
	go test -short ./... || die
}

src_install() {
	dobin kapacitor{,d}
	use debug && dostrip -x /usr/bin/kapacitor{,d}

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	systemd_dounit "scripts/${PN}.service"

	insinto /etc/kapacitor
	newins etc/kapacitor/kapacitor.conf kapacitor.conf.example

	insinto /etc/logrotate.d
	doins etc/logrotate.d/kapacitor

	dobashcomp usr/share/bash-completion/completions/kapacitor

	if use examples; then
		docinto examples
		dodoc -r examples/*
		docompress -x "/usr/share/doc/${PF}/examples"
	fi

	diropts -o kapacitor -g kapacitor -m 0750
	keepdir /var/log/kapacitor
}

pkg_postinst() {
	if [[ ! -e "${EROOT}/etc/kapacitor/kapacitor.conf" ]]; then
		elog "No kapacitor.conf found, copying the example over"
		cp "${EROOT}"/etc/kapacitor/kapacitor.conf{.example,} || die
	else
		elog "kapacitor.conf found, please check example file for possible changes"
	fi
}
