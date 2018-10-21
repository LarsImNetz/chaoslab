# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_PV="${PV/_/}"
GIT_COMMIT="c75cdfdfa6" # Change this when you update the ebuild
EGO_PN="github.com/influxdata/${PN}"
# Note: Keep EGO_VENDOR in sync with Godeps
# Deps that are not needed:
# github.com/davecgh/go-spew 346938d642
# github.com/google/go-cmp 3af367b6b3
# github.com/mschoch/smat 90eadee771
# github.com/paulbellamy/ratecounter 524851a932
# github.com/willf/bitset d860f346b8
EGO_VENDOR=(
	"collectd.org 2ce144541b github.com/collectd/go-collectd"
	"github.com/BurntSushi/toml a368813c5e"
	"github.com/RoaringBitmap/roaring d6540aab65"
	"github.com/beorn7/perks 4c0e84591b"
	"github.com/bmizerany/pat 6226ea591a"
	"github.com/boltdb/bolt 2f1ce7a837"
	"github.com/cespare/xxhash 5c37fe3735"
	"github.com/dgrijalva/jwt-go 06ea103174"
	"github.com/dgryski/go-bitstream 9f22ccc247"
	"github.com/glycerine/go-unsnap-stream 62a9a9eb44"
	"github.com/gogo/protobuf 1adfc126b4"
	"github.com/golang/protobuf 925541529c"
	"github.com/golang/snappy d9eb7a3d35"
	"github.com/influxdata/influxql a7267bff53"
	"github.com/influxdata/usage-client 6d38953763"
	"github.com/influxdata/yamux 1f58ded512"
	"github.com/influxdata/yarpc f0da2db138"
	"github.com/jsternberg/zap-logfmt ac4bd917e1"
	"github.com/jwilder/encoding b4e1701a28"
	"github.com/klauspost/compress 6c8db69c4b"
	"github.com/klauspost/cpuid ae7887de9f"
	"github.com/klauspost/crc32 cb6bfca970"
	"github.com/klauspost/pgzip 0bf5dcad4a"
	"github.com/mattn/go-isatty 6ca4dbf54d"
	"github.com/matttproud/golang_protobuf_extensions 3247c84500"
	"github.com/opentracing/opentracing-go 328fceb754"
	"github.com/peterh/liner 6106ee4fe3"
	"github.com/philhofer/fwd bb6d471dc9"
	"github.com/prometheus/client_golang 661e31bf84"
	"github.com/prometheus/client_model 99fa1f4be8"
	"github.com/prometheus/common e4aa40a916"
	"github.com/prometheus/procfs 54d17b57dd"
	"github.com/retailnext/hllpp 101a6d2f8b"
	"github.com/tinylib/msgp b2b6a672cf"
	"github.com/xlab/treeprint f3a15cfd24"
	"go.uber.org/atomic 8474b86a5a github.com/uber-go/atomic"
	"go.uber.org/multierr 3c4937480c github.com/uber-go/multierr"
	"go.uber.org/zap 35aad58495 github.com/uber-go/zap"
	"golang.org/x/crypto c3a3ad6d03 github.com/golang/crypto"
	"golang.org/x/net 92b859f39a github.com/golang/net"
	"golang.org/x/sync 1d60e4601c github.com/golang/sync"
	"golang.org/x/sys d8e400bc7d github.com/golang/sys"
	"golang.org/x/text f21a4dfb5e github.com/golang/text"
	"golang.org/x/time 26559e0f76 github.com/golang/time"
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

DEPEND="
	man? ( app-text/asciidoc app-text/xmlto )
"

QA_PRESTRIPPED="
	usr/bin/influx
	usr/bin/influxd
	usr/bin/influx_inspect
	usr/bin/influx_stress
	usr/bin/influx_tsm
	usr/bin/influx-tools
"

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
	local myldflags=( -s -w
		-X "main.version=${MY_PV}"
		-X "main.branch=non-git"
		-X "main.commit=${GIT_COMMIT}"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "${myldflags[*]}"
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

	insinto /etc/influxdb
	newins etc/config.sample.toml influxdb.conf.example

	use man && doman man/*.1

	diropts -o influxdb -g influxdb -m 0750
	keepdir /var/log/influxdb
}

pkg_postinst() {
	if [[ $(stat -c %a "${EROOT%/}/var/lib/influxdb") != "750" ]]; then
		einfo "Fixing ${EROOT%/}/var/lib/influxdb permissions"
		chown influxdb:influxdb "${EROOT%/}/var/lib/influxdb" || die
		chmod 0750 "${EROOT%/}/var/lib/influxdb" || die
	fi

	if [[ ! -e "${EROOT%/}/etc/influxdb/influxdb.conf" ]]; then
		elog "No influxdb.conf found, copying the example over"
		cp "${EROOT%/}"/etc/influxdb/influxdb.conf{.example,} || die
	else
		elog "influxdb.conf found, please check example file for possible changes"
	fi
}
