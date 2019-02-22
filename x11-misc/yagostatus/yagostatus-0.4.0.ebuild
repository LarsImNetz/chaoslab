# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/burik666/${PN}"
# Note: Keep EGO_VENDOR in sync with go.mod
EGO_VENDOR=(
	"github.com/BurntSushi/xgbutil f7c97cef3b4e" #inderect
	"github.com/BurntSushi/xgb 27f122750802"
	"github.com/pkg/errors v0.8.1"
	"go.i3wm.org/i3 e2468ef5e1cd github.com/i3/go-i3"
	"golang.org/x/net c10e9556a7bc github.com/golang/net"
	"gopkg.in/yaml.v2 v2.2.1 github.com/go-yaml/yaml"
)

inherit golang-vcs-snapshot-r1

DESCRIPTION="Yet Another i3status replacement written in Go"
HOMEPAGE="https://github.com/burik666/yagostatus"
ARCHIVE_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="${ARCHIVE_URI} ${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86" # Untested: arm arm64 x86
IUSE="debug pie static"

QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"
	(use static && use pie) && CGO_LDFLAGS+=" -static"

	local mygoargs=(
		-v -work -x
		-buildmode "$(usex pie pie exe)"
		-asmflags "all=-trimpath=${S}"
		-gcflags "all=-trimpath=${S}"
		-ldflags "$(usex !debug '-s -w' '')"
		-tags "$(usex static 'netgo' '')"
		-installsuffix "$(usex static 'netgo' '')"
	)

	go build "${mygoargs[@]}" || die
}

src_install() {
	dobin yagostatus
	use debug && dostrip -x /usr/bin/yagostatus

	dodoc README.md yagostatus.yml
	docompress -x "/usr/share/doc/${PF}"
}
