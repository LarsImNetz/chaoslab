# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/dshearer/${PN}"

inherit golang-vcs-snapshot systemd

DESCRIPTION="A replacement for cron, with sophisticated status-reporting and error-handling"
HOMEPAGE="https://dshearer.github.io/jobber/"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="pie"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/jobber
	usr/libexec/jobbermaster
	usr/libexec/jobberrunner"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	export GOBIN="${S}/bin"
	# shellcheck disable=SC2207
	local mygoargs=(
		-v -work -x
		$(usex pie '-buildmode=pie' '')
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w -X ${EGO_PN}/common.jobberVersion=${PV}"
	)

	# Prepare time spec
	emake jobfile/parse_time_spec.go

	go install "${mygoargs[@]}" ./jobber{,master,runner} || die
}

src_install() {
	dobin bin/jobber
	einstalldocs

	exeinto /usr/libexec
	doexe bin/jobber{master,runner}

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"
}
