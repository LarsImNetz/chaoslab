# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/michenriksen/${PN}"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
EGO_VENDOR=(
	"github.com/PuerkitoBio/goquery v1.4.1"
	"github.com/andybalholm/cascadia v1.0.0"
	"github.com/asaskevich/EventBus d46933a94f05"
	"github.com/fatih/color v1.7.0"
	"github.com/lair-framework/go-nmap 84c21710ccc8"
	"github.com/mattn/go-colorable v0.0.9"
	"github.com/mattn/go-isatty v0.0.4"
	"github.com/moul/http2curl 9ac6cf4d929b"
	"github.com/mvdan/xurls v2.0.0"
	"github.com/parnurzeal/gorequest v0.2.15"
	"github.com/pkg/errors v0.8.0"
	"github.com/pmezard/go-difflib v1.0.0"
	"github.com/remeh/sizedwaitgroup 5e7302b12cce"
	"golang.org/x/net 9b4f9f5ad519 github.com/golang/net"
	#"golang.org/x/sys 95b1ffbd15a5 github.com/golang/sys"
	#"golang.org/x/text v0.3.0 github.com/golang/text"
)

inherit golang-vcs-snapshot-r1

DESCRIPTION="A tool for visual inspection of websites across a large amount of hosts"
HOMEPAGE="https://github.com/michenriksen/aquatone"
ARCHIVE_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="${ARCHIVE_URI} ${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug pie"

RDEPEND="|| (
		www-client/chromium
		www-client/ungoogled-chromium
		www-client/ungoogled-chromium-bin
	)"

DOCS=( CHANGELOG.md README.md )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie exe)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "$(usex !debug '-s -w' '')"
	)
	go build "${mygoargs[@]}" || die
}

src_install() {
	dobin aquatone
	use debug && dostrip -x /usr/bin/aquatone
	einstalldocs
}
