# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/burik666/${PN}"
# Snapshot taken on 2018.12.14
EGO_VENDOR=(
	"golang.org/x/net 88d92db4c5 github.com/golang/net"
	"gopkg.in/yaml.v2 5420a8b674 github.com/go-yaml/yaml"
)

inherit golang-vcs-snapshot

DESCRIPTION="Yet Another i3status replacement written in Go"
HOMEPAGE="https://github.com/burik666/yagostatus"
SRC_URI="https://${EGO_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="pie"

QA_PRESTRIPPED="usr/bin/yagostatus"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "-s -w"
	)
	go build "${mygoargs[@]}" || die
}

src_install() {
	dobin yagostatus

	dodoc README.md yagostatus.yml
	docompress -x "/usr/share/doc/${PF}"
}
