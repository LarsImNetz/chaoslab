# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_PV="${PV/_/}"
GIT_COMMIT="dac4c6f571" # Change this when you update the ebuild
EGO_PN="github.com/influxdata/${PN}"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
# Deps that are not needed:
# github.com/Masterminds/semver c7af129439
# github.com/alecthomas/kingpin 947dcec5ba
# github.com/alecthomas/template a0175ee3bc
# github.com/alecthomas/units 2efee857e7
# github.com/apex/log 941dea75d3
# github.com/aws/aws-sdk-go dd947f47de
# github.com/blakesmith/ar 8bd4349a67
# github.com/caarlos0/ctrlc 70dc48d5d7
# github.com/campoy/unique 88950e537e
# github.com/davecgh/go-spew 346938d642
# github.com/fatih/color 570b54cabe
# github.com/go-ini/ini 7b29465103
# github.com/google/go-cmp 3af367b6b3
# github.com/google/go-github dd29b543e1
# github.com/google/go-querystring 44c6ddd0a2
# github.com/goreleaser/goreleaser f99940ff53
# github.com/goreleaser/nfpm de75d67990
# github.com/imdario/mergo 9f23e2d6bd
# github.com/jmespath/go-jmespath 0b12d6b521
# github.com/kevinburke/go-bindata 06af60a446
# github.com/kisielk/gotool 80517062f5
# github.com/mattn/go-colorable 167de6bfdf
# github.com/mattn/go-tty 13ff1204f1
# github.com/mattn/go-zglob 2ea3427bfa
# github.com/mitchellh/go-homedir ae18d6b8b3
# github.com/mna/pigeon 9df264905d
# github.com/mschoch/smat 90eadee771
# github.com/paulbellamy/ratecounter 524851a932
# github.com/willf/bitset d860f346b8
# golang.org/x/oauth2 c57b0facac
# golang.org/x/tools 45ff765b48
# google.golang.org/appengine ae0ab99deb
# gopkg.in/yaml.v2 5420a8b674
# honnef.co/go/tools d73ab98e7c
EGO_VENDOR=(
	"collectd.org 2ce144541b github.com/collectd/go-collectd"
	"github.com/BurntSushi/toml a368813c5e"
	"github.com/RoaringBitmap/roaring 3d677d3262"
	"github.com/beorn7/perks 3a771d9929"
	"github.com/bmizerany/pat 6226ea591a"
	"github.com/boltdb/bolt 2f1ce7a837"
	"github.com/c-bata/go-prompt e99fbc797b"
	"github.com/cespare/xxhash 5c37fe3735"
	"github.com/dgrijalva/jwt-go 06ea103174"
	"github.com/dgryski/go-bitstream 3522498ce2"
	"github.com/glycerine/go-unsnap-stream 9f0cb55181"
	"github.com/go-sql-driver/mysql d523deb1b2"
	"github.com/gogo/protobuf 636bf0302b"
	"github.com/golang/protobuf b4deda0973"
	"github.com/golang/snappy d9eb7a3d35"
	"github.com/influxdata/flux 69370f6c35"
	"github.com/influxdata/influxql 1cbfca8e56"
	"github.com/influxdata/line-protocol 32c6aa80de"
	"github.com/influxdata/platform 362d4c6b34"
	"github.com/influxdata/roaring fc520f41fa"
	"github.com/influxdata/tdigest a7d76c6f09"
	"github.com/influxdata/usage-client 6d38953763"
	"github.com/jsternberg/zap-logfmt ac4bd917e1"
	"github.com/jwilder/encoding b4e1701a28"
	"github.com/klauspost/compress b939724e78"
	"github.com/klauspost/cpuid ae7887de9f"
	"github.com/klauspost/crc32 cb6bfca970"
	"github.com/klauspost/pgzip 0bf5dcad4a"
	"github.com/lib/pq 4ded0e9383"
	"github.com/mattn/go-isatty 6ca4dbf54d"
	"github.com/mattn/go-runewidth 9e777a8366"
	"github.com/matttproud/golang_protobuf_extensions c12348ce28"
	"github.com/opentracing/opentracing-go bd9c319339"
	"github.com/peterh/liner 8c1271fcf4"
	"github.com/philhofer/fwd bb6d471dc9"
	"github.com/pkg/errors 645ef00459"
	"github.com/pkg/term bffc007b7f"
	"github.com/prometheus/client_golang 661e31bf84"
	"github.com/prometheus/client_model 5c3871d899"
	"github.com/prometheus/common 7600349dcf"
	"github.com/prometheus/procfs ae68e2d4c0"
	"github.com/retailnext/hllpp 101a6d2f8b"
	"github.com/satori/go.uuid f58768cc1a"
	"github.com/segmentio/kafka-go c6db943547"
	"github.com/tinylib/msgp b2b6a672cf"
	"github.com/xlab/treeprint d6fb6747fe"
	"go.uber.org/atomic 1ea20fb1cb github.com/uber-go/atomic"
	"go.uber.org/multierr 3c4937480c github.com/uber-go/multierr"
	"go.uber.org/zap 4d45f9617f github.com/uber-go/zap"
	"golang.org/x/crypto a214413485 github.com/golang/crypto"
	"golang.org/x/net a680a1efc5 github.com/golang/net"
	"golang.org/x/sync 1d60e4601c github.com/golang/sync"
	"golang.org/x/sys ac767d655b github.com/golang/sys"
	"golang.org/x/text f21a4dfb5e github.com/golang/text"
	"golang.org/x/time fbb02b2291 github.com/golang/time"
	"google.golang.org/genproto fedd286124 github.com/google/go-genproto"
	"google.golang.org/grpc 168a6198bc github.com/grpc/grpc-go"
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
	usr/bin/influx_tools
	usr/bin/influx_tsm
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
		-v
		"-buildmode=$(usex pie pie default)"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)
	go install "${mygoargs[@]}" \
		./cmd/influx{,d,_inspect,_stress,_tools,_tsm} || die

	use man && emake -C man
}

src_test() {
	go test -v -timeout 10s ./cmd/influxd/run || die
}

src_install() {
	dobin influx{,d,_stress,_inspect,_tools,_tsm}

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
	if [[ ! -e "${EROOT%/}/etc/influxdb/influxdb.conf" ]]; then
		elog "No influxdb.conf found, copying the example over"
		cp "${EROOT%/}"/etc/influxdb/influxdb.conf{.example,} || die
	else
		elog "influxdb.conf found, please check example file for possible changes"
	fi
}
