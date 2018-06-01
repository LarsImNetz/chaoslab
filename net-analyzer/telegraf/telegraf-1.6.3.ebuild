# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GIT_COMMIT="890f1d3" # Change this when you update the ebuild
EGO_PN="github.com/influxdata/${PN}"
# Note: Keep EGO_VENDOR in sync with Godeps
# Deps that are not needed:
# github.com/go-ini/ini 9144852
# github.com/go-ole/go-ole be49f7c
# github.com/fsnotify/fsnotify c282820
# github.com/jmespath/go-jmespath bd40a43
# github.com/Microsoft/go-winio ce2922f
# github.com/pmezard/go-difflib 792786c
# github.com/shirou/w32 3c9377f
# github.com/StackExchange/wmi f3e2bae
# github.com/stretchr/objx facf9a8
# gopkg.in/tomb.v1 dd63297
EGO_VENDOR=(
	"collectd.org 2ce1445 github.com/collectd/go-collectd"
	"github.com/aerospike/aerospike-client-go 9701404"
	"github.com/amir/raidman c74861f"
	"github.com/apache/thrift 4aaa92e"
	"github.com/aws/aws-sdk-go c861d27"
	"github.com/beorn7/perks 4c0e845"
	"github.com/bsm/sarama-cluster abf0394"
	"github.com/cenkalti/backoff b02f2bb"
	"github.com/couchbase/go-couchbase bfe555a"
	"github.com/couchbase/gomemcached 4a25d2f"
	"github.com/couchbase/goutils 5823a0c"
	"github.com/davecgh/go-spew 346938d"
	"github.com/dgrijalva/jwt-go dbeaa93"
	"github.com/docker/docker f5ec1e2"
	"github.com/docker/go-connections 990a1a1"
	"github.com/eapache/go-resiliency b86b1ec"
	"github.com/eapache/go-xerial-snappy bb955e0"
	"github.com/eapache/queue 44cc805"
	"github.com/eclipse/paho.mqtt.golang aff1577"
	"github.com/go-logfmt/logfmt 390ab79"
	"github.com/go-sql-driver/mysql 2e00b5c"
	"github.com/gobwas/glob bea32b9"
	"github.com/gogo/protobuf 7b6c639"
	"github.com/golang/protobuf 8ee7999"
	"github.com/golang/snappy 7db9049"
	"github.com/google/go-cmp f94e52c"
	"github.com/gorilla/mux 392c28f"
	"github.com/go-redis/redis 73b7059"
	"github.com/go-sql-driver/mysql 2e00b5c"
	"github.com/hailocab/go-hostpool e80d13c"
	"github.com/hashicorp/consul 63d2fc6"
	"github.com/influxdata/tail c434825"
	"github.com/influxdata/toml 5d1d907"
	"github.com/influxdata/wlog 7c63b0a"
	"github.com/jackc/pgx 63f58fd"
	"github.com/kardianos/osext c2c54e5"
	"github.com/kardianos/service 6d3a0ee"
	"github.com/kballard/go-shellquote d8ec1a6"
	"github.com/matttproud/golang_protobuf_extensions c12348c"
	"github.com/miekg/dns 99f84ae"
	"github.com/mitchellh/mapstructure d0303fe"
	"github.com/multiplay/go-ts3 07477f4"
	"github.com/naoina/go-stringutil 6b638e9"
	"github.com/nats-io/gnatsd 393bbb7"
	"github.com/nats-io/go-nats ea95856"
	"github.com/nats-io/nats ea95856"
	"github.com/nats-io/nuid 289cccf"
	"github.com/nsqio/go-nsq eee57a3"
	"github.com/opencontainers/runc 89ab7f2"
	"github.com/opentracing-contrib/go-observer a52f234"
	"github.com/opentracing/opentracing-go 06f47b4"
	"github.com/openzipkin/zipkin-go-opentracing 1cafbdf"
	"github.com/pierrec/lz4 5c9560b"
	"github.com/pierrec/xxHash 5a00444"
	"github.com/pkg/errors 645ef00"
	"github.com/prometheus/client_golang c317fb7"
	"github.com/prometheus/client_model fa8ad6f"
	"github.com/prometheus/common dd2f054"
	"github.com/prometheus/procfs 1878d9f"
	"github.com/rcrowley/go-metrics 1f30fe9"
	"github.com/samuel/go-zookeeper 1d7be4e"
	"github.com/satori/go.uuid 5bf94b6"
	"github.com/shirou/gopsutil c95755e"
	"github.com/Shopify/sarama 3b1b388"
	"github.com/Sirupsen/logrus 61e43dc"
	"github.com/soniah/gosnmp f15472a"
	"github.com/streadway/amqp 63795da"
	"github.com/stretchr/testify 12b6f73"
	"github.com/tidwall/gjson 0623bd8"
	"github.com/tidwall/match 173748d"
	"github.com/vjeantet/grok d73e972"
	"github.com/wvanbergen/kafka bc265fe"
	"github.com/wvanbergen/kazoo-go 9689573"
	"github.com/yuin/gopher-lua 66c871e"
	"github.com/zensqlmonitor/go-mssqldb ffe5510"
	"golang.org/x/crypto dc137be github.com/golang/crypto"
	"golang.org/x/net f249948 github.com/golang/net"
	"golang.org/x/sys 739734 github.com/golang/sys"
	"golang.org/x/text 506f9d5 github.com/golang/text"
	"gopkg.in/asn1-ber.v1 4e86f43 github.com/go-asn1-ber/asn1-ber"
	"gopkg.in/fatih/pool.v2 6e328e6 github.com/fatih/pool"
	"gopkg.in/gorethink/gorethink.v3 7ab832f github.com/GoRethink/gorethink"
	"gopkg.in/ldap.v2 8168ee0 github.com/go-ldap/ldap"
	"gopkg.in/mgo.v2 3f83fa5 github.com/go-mgo/mgo"
	"gopkg.in/olivere/elastic.v5 3113f9b github.com/olivere/elastic"
	"gopkg.in/yaml.v2 4c78c97 github.com/go-yaml/yaml"
)

inherit golang-vcs-snapshot systemd user

MY_PV="${PV/_/-}"
DESCRIPTION="An agent for collecting, processing, aggregating, and writing metrics"
HOMEPAGE="https://influxdata.com"
SRC_URI="https://${EGO_PN}/archive/${MY_PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="pie test"

QA_PRESTRIPPED="usr/bin/telegraf"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	if use test; then
		has network-sandbox $FEATURES && \
			die "The test phase requires 'network-sandbox' to be disabled in FEATURES"
	fi

	enewgroup telegraf
	enewuser telegraf -1 -1 -1 telegraf
}

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		$(usex pie '-buildmode=pie' '')
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w
			-X main.version=${MY_PV}
			-X main.branch=${MY_PV}
			-X main.commit=${GIT_COMMIT}"
	)
	go build "${mygoargs[@]}" ./cmd/telegraf || die
}

src_test() {
	go test -short ./... || die
}

src_install() {
	dobin telegraf

	newinitd "${FILESDIR}"/${PN}.initd-r2 ${PN}
	newconfd "${FILESDIR}"/${PN}.confd-r1 ${PN}
	systemd_dounit scripts/${PN}.service
	systemd_newtmpfilesd "${FILESDIR}"/${PN}.tmpfilesd-r1 ${PN}.conf

	dodir /etc/telegraf/telegraf.d
	insinto /etc/telegraf
	newins etc/telegraf.conf telegraf.conf.example

	insinto /etc/logrotate.d
	doins etc/logrotate.d/telegraf

	diropts -o telegraf -g telegraf -m 0750
	keepdir /var/log/telegraf
}

pkg_postinst() {
	if [ ! -e "${EROOT%/}"/etc/${PN}/telegraf.conf ]; then
		elog "No telegraf.conf found, copying the example over"
		cp "${EROOT%/}"/etc/${PN}/telegraf.conf{.example,} || die
	else
		elog "telegraf.conf found, please check example file for possible changes"
	fi
}
