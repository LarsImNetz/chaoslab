# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_PV="${PV/_/}"
GIT_COMMIT="d1a4736" # Change this when you update the ebuild
EGO_PN="github.com/influxdata/${PN}"
# Note: Keep EGO_VENDOR in sync with Godeps
# Deps that are not needed:
# github.com/davecgh/go-spew 346938d
# github.com/google/go-cmp 3af367b
# github.com/paulbellamy/ratecounter 524851a
EGO_VENDOR=(
	"collectd.org 2ce1445 github.com/collectd/go-collectd"
	"github.com/BurntSushi/toml a368813"
	"github.com/RoaringBitmap/roaring d6540aa"
	"github.com/beorn7/perks 4c0e845"
	"github.com/bmizerany/pat 6226ea5"
	"github.com/boltdb/bolt 2f1ce7a"
	"github.com/cespare/xxhash 5c37fe3"
	"github.com/dgrijalva/jwt-go 06ea103"
	"github.com/dgryski/go-bitstream 9f22ccc"
	"github.com/glycerine/go-unsnap-stream 62a9a9e"
	"github.com/gogo/protobuf 1adfc12"
	"github.com/golang/protobuf 9255415"
	"github.com/golang/snappy d9eb7a3"
	"github.com/influxdata/influxql 145e067"
	"github.com/influxdata/usage-client 6d38953"
	"github.com/influxdata/yamux 1f58ded"
	"github.com/influxdata/yarpc 036268c"
	"github.com/jsternberg/zap-logfmt 5ea5386"
	"github.com/jwilder/encoding 2789473"
	"github.com/mattn/go-isatty 6ca4dbf"
	"github.com/matttproud/golang_protobuf_extensions 3247c84"
	"github.com/mschoch/smat 90eadee"
	"github.com/opentracing/opentracing-go 328fceb"
	"github.com/peterh/liner 6106ee4"
	"github.com/philhofer/fwd bb6d471"
	"github.com/prometheus/client_golang 661e31b"
	"github.com/prometheus/client_model 99fa1f4"
	"github.com/prometheus/common e4aa40a"
	"github.com/prometheus/procfs 54d17b5"
	"github.com/retailnext/hllpp 101a6d2"
	"github.com/tinylib/msgp b2b6a67"
	"github.com/willf/bitset d860f34"
	"github.com/xlab/treeprint f3a15cf"
	"go.uber.org/atomic 8474b86 github.com/uber-go/atomic"
	"go.uber.org/multierr 3c49374 github.com/uber-go/multierr"
	"go.uber.org/zap 35aad58 github.com/uber-go/zap"
	"golang.org/x/crypto c3a3ad6 github.com/golang/crypto"
	"golang.org/x/net 92b859f github.com/golang/net"
	"golang.org/x/sync fd80eb9 github.com/golang/sync"
	"golang.org/x/sys d8e400b github.com/golang/sys"
	"golang.org/x/text f21a4df github.com/golang/text"
	"golang.org/x/time 26559e0 github.com/golang/time"
)

inherit golang-vcs-snapshot systemd user

DESCRIPTION="Scalable datastore for metrics, events, and real-time analytics"
HOMEPAGE="https://influxdata.com"
SRC_URI="https://${EGO_PN}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="man pie"

DEPEND="man? ( app-text/asciidoc
	app-text/xmlto )"

QA_PRESTRIPPED="usr/bin/influx
	usr/bin/influxd
	usr/bin/influx_inspect
	usr/bin/influx_stress
	usr/bin/influx_tsm
	usr/bin/influx-tools"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup influxdb
	enewuser influxdb -1 -1 /var/lib/influxdb influxdb
}

src_prepare() {
	# By default InfluxDB sends anonymous statistics to
	# usage.influxdata.com. Let's disable it by default.
	sed -i "s:# reporting.*:reporting-disabled = true:" \
		etc/config.sample.toml || die

	default
}

src_compile() {
	export GOPATH="${G}"
	export GOBIN="${S}"
	# shellcheck disable=SC2207
	local mygoargs=(
		-v -work -x
		$(usex pie '-buildmode=pie' '')
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w
			-X main.version=${MY_PV}
			-X main.branch=non-git
			-X main.commit=${GIT_COMMIT}"
	)
	go install "${mygoargs[@]}" \
		./cmd/influx{,d,_inspect,_stress,_tsm,-tools} || die

	use man && emake -C man
}

src_install() {
	dobin influx{,d,_stress,_inspect,_tsm,-tools}

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"

	systemd_install_serviced "${FILESDIR}/${PN}.service.conf"
	systemd_dounit "scripts/${PN}.service"
	systemd_newtmpfilesd "${FILESDIR}/${PN}.tmpfilesd-r1" "${PN}.conf"

	insinto /etc/influxdb
	newins etc/config.sample.toml influxdb.conf.example

	use man && doman man/*.1

	diropts -o influxdb -g influxdb -m 0750
	keepdir /var/log/influxdb
}

pkg_postinst() {
	if [ ! -e "${EROOT%/}"/etc/influxdb/influxdb.conf ]; then
		elog "No influxdb.conf found, copying the example over"
		cp "${EROOT%/}"/etc/influxdb/influxdb.conf{.example,} || die
	else
		elog "influxdb.conf found, please check example file for possible changes"
	fi
}
