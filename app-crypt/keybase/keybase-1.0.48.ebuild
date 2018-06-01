# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/keybase/client"

inherit golang-vcs-snapshot systemd

DESCRIPTION="Client for Keybase"
HOMEPAGE="https://keybase.io"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="pie"

DEPEND="app-crypt/kbfs"
RDEPEND="app-crypt/gnupg"

QA_PRESTRIPPED="usr/bin/keybase"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}:${S}/go/vendor"
	# shellcheck disable=SC2207
	local mygoargs=(
		-v -work -x
		$(usex pie '-buildmode=pie' '')
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w"
		-tags production
	)
	go build "${mygoargs[@]}" \
		./go/keybase || die
}

src_install() {
	dobin keybase
	dobin packaging/linux/run_keybase
	systemd_douserunit packaging/linux/systemd/keybase.service
}

pkg_postinst() {
	elog "Run the service: keybase service"
	elog "Run the client:  keybase login"
	elog "Restart keybase: run_keybase"
}
