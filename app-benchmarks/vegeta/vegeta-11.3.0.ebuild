# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# Change this when you update the ebuild:
GIT_COMMIT="c6176ccd5d95c452ad255cccca31c1114a79451d"
EGO_PN="github.com/tsenart/${PN}"
# Keep EGO_VENDOR in sync with Gopkg.lock
EGO_VENDOR=(
	"github.com/alecthomas/jsonschema f2c9385"
	"github.com/bmizerany/perks d9a9656"
	"github.com/c2h5oh/datasize 4eba002"
	"github.com/dgryski/go-gk 201884a"
	"github.com/dgryski/go-lttb 318fcdf"
	"github.com/google/go-cmp 3af367b"
	"github.com/influxdata/tdigest a7d76c6"
	"github.com/mailru/easyjson 60711f1"
	"github.com/shurcooL/httpfs 809bece"
	"github.com/shurcooL/vfsgen 62bca83"
	"github.com/streadway/quantile b0c5887"
	"github.com/tsenart/go-tsz cdeb9e1"
	"golang.org/x/net c394268 github.com/golang/net"
	"golang.org/x/text f21a4df github.com/golang/text"
)

inherit golang-vcs-snapshot

DESCRIPTION="HTTP load testing tool and library. It's over 9000!"
HOMEPAGE="https://github.com/tsenart/vegeta"
SRC_URI="https://${EGO_PN}/archive/cli/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DOCS=( CHANGELOG README.md )
QA_PRESTRIPPED="usr/bin/vegeta"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local myldflags=( -s -w
		-X "main.Version=${PV}"
		-X "main.Commit=${GIT_COMMIT}"
		-X "'main.Date=$(date -u '+%Y-%m-%dT%TZ')'"
	)
	local mygoargs=(
		-v -work -x
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)
	go build "${mygoargs[@]}" || die
}

src_test() {
	go test ./... || die
}

src_install() {
	dobin vegeta
	einstalldocs
}
