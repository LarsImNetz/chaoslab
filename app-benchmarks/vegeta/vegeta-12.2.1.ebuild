# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Change this when you update the ebuild:
GIT_COMMIT="65db074680f5a0860d495e5fd037074296a4c425"
EGO_PN="github.com/tsenart/${PN}"
# Keep EGO_VENDOR in sync with Gopkg.lock
EGO_VENDOR=(
	"github.com/alecthomas/jsonschema f2c93856175a"
	"github.com/bmizerany/perks d9a9656a3a4b"
	"github.com/c2h5oh/datasize 4eba002a5eae"
	"github.com/dgryski/go-gk 201884a44051"
	"github.com/dgryski/go-lttb 318fcdf10a77"
	"github.com/google/go-cmp v0.2.0"
	"github.com/influxdata/tdigest a7d76c6f093a"
	"github.com/mailru/easyjson 60711f1a8329"
	"github.com/miekg/dns v1.1.2" # tests
	"github.com/shurcooL/httpfs 809beceb2371"
	"github.com/shurcooL/vfsgen 62bca832be04"
	"github.com/streadway/quantile b0c588724d25"
	"github.com/tsenart/go-tsz cdeb9e1e981e"
	"golang.org/x/net c39426892332 github.com/golang/net"
	"golang.org/x/text v0.3.0 github.com/golang/text"
)

inherit golang-vcs-snapshot-r1

DESCRIPTION="HTTP load testing tool and library. It's over 9000!"
HOMEPAGE="https://github.com/tsenart/vegeta"
ARCHIVE_URI="https://${EGO_PN}/archive/cli/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="${ARCHIVE_URI} ${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86" # Untested: arm arm64 x86
IUSE="debug pie"

DOCS=( CHANGELOG README.md )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_pretend() {
	if [[ "${MERGE_TYPE}" != binary ]]; then
		# shellcheck disable=SC2086
		(has test ${FEATURES} && has network-sandbox ${FEATURES}) && \
			die "The test phase requires 'network-sandbox' to be disabled in FEATURES"
	fi
}

src_compile() {
	export GOPATH="${G}"
	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "main.Version=${PV}"
		-X "main.Commit=${GIT_COMMIT}"
		-X "'main.Date=$(date -u '+%Y-%m-%dT%TZ')'"
	)
	local mygoargs=(
		-v -work -x
		-buildmode "$(usex pie pie exe)"
		-asmflags "all=-trimpath=${S}"
		-gcflags "all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)
	go build "${mygoargs[@]}" || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin vegeta
	use debug && dostrip -x /usr/bin/vegeta
	einstalldocs
}
