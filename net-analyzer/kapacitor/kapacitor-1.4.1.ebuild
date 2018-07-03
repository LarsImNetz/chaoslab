# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_PV="${PV/_/-}"
GIT_COMMIT="b05bb0f"
EGO_PN="github.com/influxdata/kapacitor"

inherit bash-completion-r1 golang-vcs-snapshot systemd user

DESCRIPTION="A framework for processing, monitoring, and alerting on time series data"
HOMEPAGE="https://influxdata.com"
SRC_URI="https://${EGO_PN}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror test"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="bash-completion examples pie"

QA_PRESTRIPPED="usr/bin/kapacitor
	usr/bin/kapacitord"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup kapacitor
	enewuser kapacitor -1 -1 /var/lib/kapacitor kapacitor
}

src_compile() {
	export GOPATH="${G}"
	export GOBIN="${S}"
	local myldflags=( -s -w
		-X "main.version=${MY_PV}"
		-X "main.branch=${MY_PV}"
		-X "main.commit=${GIT_COMMIT}"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)
	go install "${mygoargs[@]}" ./cmd/kapacitor{,d} || die
}

src_test() {
	go test -short ./... || die
}

src_install() {
	dobin kapacitor{,d}

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	systemd_dounit "scripts/${PN}.service"

	insinto /etc/kapacitor
	newins etc/kapacitor/kapacitor.conf kapacitor.conf.example

	insinto /etc/logrotate.d
	doins etc/logrotate.d/kapacitor

	if use bash-completion; then
		dobashcomp usr/share/bash-completion/completions/kapacitor
	fi

	if use examples; then
		docinto examples
		dodoc -r examples/*
		docompress -x "/usr/share/doc/${PF}/examples"
	fi

	diropts -o kapacitor -g kapacitor -m 0750
	keepdir /var/log/kapacitor
}

pkg_postinst() {
	if [[ $(stat -c %a "${EROOT%/}/var/lib/kapacitor") != "750" ]]; then
		einfo "Fixing ${EROOT%/}/var/lib/kapacitor permissions"
		chown kapacitor:kapacitor "${EROOT%/}/var/lib/kapacitor" || die
		chmod 0750 "${EROOT%/}/var/lib/kapacitor" || die
	fi
	if [[ ! -f "${EROOT%/}"/etc/kapacitor/kapacitor.conf ]]; then
		elog "No kapacitor.conf found, copying the example over"
		cp "${EROOT%/}"/etc/kapacitor/kapacitor.conf{.example,} || die
	else
		elog "kapacitor.conf found, please check example file for possible changes"
	fi
}
