# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_PV="${PV/_/-}"
GIT_COMMIT="4f10efc" # Change this when you update the ebuild
EGO_PN="github.com/influxdata/kapacitor"

inherit bash-completion-r1 golang-vcs-snapshot systemd user

DESCRIPTION="A framework for processing, monitoring, and alerting on time series data"
HOMEPAGE="https://influxdata.com"
SRC_URI="https://${EGO_PN}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

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
	local mygoargs=(
		-v -work -x
		$(usex pie '-buildmode=pie' '')
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w
			-X main.version=${MY_PV}
			-X main.branch=${MY_PV}
			-X main.commit=${GIT_COMMIT}"
	)
	go install "${mygoargs[@]}" \
		./cmd/kapacitor{,d} || die
}

src_test() {
	go test -short ./... || die
}

src_install() {
	dobin kapacitor{,d}

	newinitd "${FILESDIR}"/${PN}.initd-r2 ${PN}
	newconfd "${FILESDIR}"/${PN}.confd ${PN}
	systemd_dounit scripts/${PN}.service
	systemd_newtmpfilesd "${FILESDIR}"/${PN}.tmpfilesd ${PN}.conf

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
		docompress -x /usr/share/doc/${PF}/examples
	fi

	diropts -o kapacitor -g kapacitor -m 0750
	keepdir /var/{lib,log}/kapacitor
}

pkg_postinst() {
	if [ ! -e "${EROOT%/}"/etc/${PN}/kapacitor.conf ]; then
		elog "No kapacitor.conf found, copying the example over"
		cp "${EROOT%/}"/etc/${PN}/kapacitor.conf{.example,} || die
	else
		elog "kapacitor.conf found, please check example file for possible changes"
	fi
}
