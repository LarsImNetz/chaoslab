# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/OWASP/${PN^}"
EGO_VENDOR=(
	# Note: Keep EGO_VENDOR in sync with amass/go.mod
	"github.com/PuerkitoBio/fetchbot v1.1.2"
	"github.com/PuerkitoBio/goquery v1.4.1"
	"github.com/andybalholm/cascadia v1.0.0"
	#"github.com/asaskevich/EventBus d46933a94f"
	"github.com/irfansharif/cfilter d07d951ff2" # inderect
	"github.com/fatih/color v1.7.0" # inderect
	"github.com/johnnadratowski/golang-neo4j-bolt-driver c68f22031e"
	"github.com/miekg/dns v1.0.8"
	#"github.com/temoto/robotstxt 9e4646fa70"
	"github.com/temoto/robotstxt-go 9e4646fa70"
	#"golang.org/x/crypto c126467f60 github.com/golang/crypto"
	"golang.org/x/net 3673e40ba2 github.com/golang/net"
	"golang.org/x/sys e072cadbbd github.com/golang/sys"
	#"golang.org/x/text v0.3.0 github.com/golang/text"
	#"golang.org/x/tools 4d8a0ac9f6 github.com/golang/tools"
)

inherit golang-vcs-snapshot-r1

DESCRIPTION="In-Depth DNS Enumeration and Network Mapping"
HOMEPAGE="https://www.owasp.org/index.php/OWASP_Amass_Project"
ARCHIVE_URI="https://${EGO_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="${ARCHIVE_URI} ${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86" # Untested: arm arm64 x86
IUSE="debug pie"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	export GOBIN="${S}/bin"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie exe)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "$(usex !debug '-s -w' '')"
	)
	go install "${mygoargs[@]}" ./cmd/amass{,.db,.netdomains,.viz} || die
}

src_test() {
	go test -v -race ./... || die
}

src_install() {
	dobin bin/amass{,.db,.netdomains,.viz}
	use debug && dostrip -x /usr/bin/amass{,.db,.netdomains,.viz}
	einstalldocs
}
