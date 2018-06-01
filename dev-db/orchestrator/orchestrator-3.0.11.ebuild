# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/github/${PN}"
GIT_COMMIT="3a57610" # Change this when you update the ebuild

inherit golang-vcs-snapshot user

DESCRIPTION="A MySQL high availability and replication management tool"
HOMEPAGE="https://github.com/github/orchestrator"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="pie"

QA_PRESTRIPPED="usr/bin/orchestrator"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup orchestrator
	enewuser orchestrator -1 -1 -1 orchestrator
}

src_compile() {
	export GOPATH="${G}"
	# shellcheck disable=SC2207
	local mygoargs=(
		-v -work -x
		$(usex pie '-buildmode=pie' '')
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w
			-X main.AppVersion=${PV}
			-X main.GitCommit=${GIT_COMMIT}"
		./go/cmd/orchestrator
	)
	go build "${mygoargs[@]}" || die
}

src_install() {
	exeinto /usr/libexec/orchestrator
	doexe orchestrator

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"

	insinto /etc/orchestrator
	doins conf/orchestrator-*.conf.json

	insinto /usr/share/orchestrator
	doins -r resources

	dosym ../../share/orchestrator/resources \
		/usr/libexec/orchestrator/resources

	diropts -m 0750 -o orchestrator -g orchestrator
	keepdir /var/log/orchestrator
}
