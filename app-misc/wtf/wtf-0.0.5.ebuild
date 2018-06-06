# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GIT_COMMIT="e1372f6" # Change this when you update the ebuild
EGO_PN="github.com/senorprogrammer/${PN}"
EGO_VENDOR=(
	"github.com/briandowns/openweathermap 722564b"
	"github.com/gdamore/encoding b23993c"
	"github.com/gdamore/tcell 3d5f294"
	"github.com/google/go-github 2ae5df7"
	"github.com/google/go-querystring 53e6ce1"
	"github.com/jessevdk/go-flags 1c38ed7"
	"github.com/lucasb-eyer/go-colorful 345fbb3" #v1.0
	"github.com/mattn/go-runewidth ce7b0b5"
	"github.com/olebedev/config 9a10d05"
	"github.com/radovskyb/watcher 0d9d326"
	"github.com/rivo/tview 71ecf1f"
	"github.com/yfronto/newrelic f7fa0c6"
	"golang.org/x/net 1e49130 github.com/golang/net"
	"golang.org/x/oauth2 ec22f46 github.com/golang/oauth2"
	"golang.org/x/text 5c1cf69 github.com/golang/text"
	"google.golang.org/api f71c6d4 github.com/google/google-api-go-client"
	"gopkg.in/yaml.v2 5420a8b github.com/go-yaml/yaml"
	"cloud.google.com/go 0fd7230 github.com/GoogleCloudPlatform/google-cloud-go" #v0.23.0
)

inherit golang-vcs-snapshot

DESCRIPTION="A personal information dashboard for your terminal"
HOMEPAGE="https://wtfutil.com"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/wtf"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w
			-X main.version=v${PV}-${GIT_COMMIT}
			-X 'main.date=$(date -u '+%FT%T%z')'"
	)
	go build "${mygoargs[@]}" -o bin/wtf || die
}

src_install() {
	dobin bin/wtf
	einstalldocs
}

pkg_postinst() {
	einfo
	elog "See https://wtfutil.com/posts/configuration/ for configuration guide."
	einfo
}
