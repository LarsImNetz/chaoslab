# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/${PN}/client"

inherit golang-vcs-snapshot-r1 systemd

DESCRIPTION="Client for Keybase"
HOMEPAGE="https://keybase.io"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug pie"

RDEPEND="
	app-crypt/kbfs
	app-crypt/gnupg
"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

QA_PRESTRIPPED="usr/bin/.*"

src_compile() {
	export GOPATH="${G}:${S}/go"
	local mygoargs=(
		-v -work -x
		-buildmode "$(usex pie pie exe)"
		-asmflags "all=-trimpath=${S}"
		-gcflags "all=-trimpath=${S}"
		-ldflags "$(usex !debug '-s -w' '')"
		-tags production
	)
	go build "${mygoargs[@]}" ./go/keybase || die
}

src_install() {
	dobin keybase
	use debug && dostrip -x /usr/bin/keybase
	dobin packaging/linux/run_keybase
	systemd_douserunit packaging/linux/systemd/keybase.service
}

pkg_postinst() {
	einfo
	elog "Run the service: keybase service"
	elog "Run the client:  keybase login"
	elog "Restart keybase: run_keybase"
	einfo
}
