# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GIT_COMMIT="dfa67e536a" # Change this when you update the ebuild
EGO_PN="github.com/influxdata/${PN}"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
# Deps that are not needed:
# github.com/Microsoft/go-winio a6d595ae73
# github.com/StackExchange/wmi 5d049714c4
# github.com/docker/distribution edc3ab29cd
# github.com/docker/go-connections 3ede32e203
# github.com/docker/go-units 47565b4f72
# github.com/go-ini/ini 358ee76639
# github.com/go-ole/go-ole a41e3c4b70
# github.com/google/uuid 064e2069ce
# github.com/gorilla/context 08b5f424b9
# github.com/hashicorp/go-cleanhttp d5fe4b57a1
# github.com/hashicorp/go-rootcerts 6bb64b370b
# github.com/hashicorp/serf d6574a5bb1
# github.com/jmespath/go-jmespath 0b12d6b521
# github.com/kardianos/osext ae77be60af
# github.com/kr/logfmt b84e30acd5
# github.com/mitchellh/go-homedir 3864e76763
# github.com/opencontainers/go-digest 279bed9867
# github.com/opencontainers/image-spec d60099175f
# github.com/pmezard/go-difflib 792786c740
# github.com/shirou/w32 bb4de0191a
# github.com/stretchr/objx 477a77ecc6
# github.com/vishvananda/netlink b2de5d10e3
# github.com/vishvananda/netns 13995c7128
# google.golang.org/appengine b1f26356af
# gopkg.in/fsnotify.v1 c2828203cd
# gopkg.in/tomb.v1 dd632973f1
EGO_VENDOR=(
	"cloud.google.com/go c728a003b2 github.com/GoogleCloudPlatform/google-cloud-go"
	"code.cloudfoundry.org/clock 02e53af36e github.com/cloudfoundry/clock"
	"collectd.org 2ce144541b github.com/collectd/go-collectd"
	"contrib.go.opencensus.io/exporter/stackdriver 2b93072101 github.com/census-ecosystem/opencensus-go-exporter-stackdriver"
	"github.com/Azure/go-autorest 1f7cd6cfe0"
	"github.com/Microsoft/ApplicationInsights-Go d2df5d440e"
	"github.com/Shopify/sarama a6144ae922"
	"github.com/aerospike/aerospike-client-go 1dc8cf203d"
	"github.com/alecthomas/template a0175ee3bc"
	"github.com/alecthomas/units 2efee857e7"
	"github.com/amir/raidman 1ccc43bfb9"
	"github.com/apache/thrift f2867c2498"
	"github.com/aws/aws-sdk-go bf8067ceb6"
	"github.com/beorn7/perks 3a771d9929"
	"github.com/bsm/sarama-cluster cf455bc755"
	"github.com/cenkalti/backoff 2ea60e5f09"
	"github.com/couchbase/go-couchbase 16db1f1fe0"
	"github.com/couchbase/gomemcached 0da75df145"
	"github.com/couchbase/goutils e865a1461c"
	"github.com/davecgh/go-spew 346938d642"
	"github.com/denisenkom/go-mssqldb 1eb28afdf9"
	"github.com/dgrijalva/jwt-go 06ea103174"
	"github.com/dimchansky/utfbom 6c6132ff69"
	"github.com/docker/docker ed7b6428c1"
	"github.com/docker/libnetwork d7b61745d1"
	"github.com/eapache/go-resiliency ea41b0fad3"
	"github.com/eapache/go-xerial-snappy 040cc1a32f"
	"github.com/eapache/queue 44cc805cf1"
	"github.com/eclipse/paho.mqtt.golang 36d01c2b4c"
	"github.com/ericchiang/k8s d1bbc0cffa"
	"github.com/go-logfmt/logfmt 390ab7935e"
	"github.com/go-redis/redis 83fb42932f"
	"github.com/go-sql-driver/mysql d523deb1b2"
	"github.com/gobwas/glob 5ccd90ef52"
	"github.com/gogo/protobuf 636bf0302b" #tests
	"github.com/golang/protobuf b4deda0973"
	"github.com/golang/snappy 2e65f85255"
	"github.com/google/go-cmp 3af367b6b3" #tests
	"github.com/googleapis/gax-go 317e000625"
	"github.com/gorilla/mux e3702bed27"
	"github.com/hailocab/go-hostpool e80d13ce29"
	"github.com/hashicorp/consul 39f93f011e"
	"github.com/influxdata/go-syslog eecd51df3a"
	"github.com/influxdata/tail c43482518d"
	"github.com/influxdata/toml 2a2e3012f7"
	"github.com/influxdata/wlog 7c63b0a71e"
	"github.com/jackc/pgx da3231b0b6"
	"github.com/kardianos/service 615a14ed75"
	"github.com/kballard/go-shellquote 95032a82bc"
	"github.com/mailru/easyjson efc7eb8984"
	"github.com/matttproud/golang_protobuf_extensions c12348ce28"
	"github.com/miekg/dns 5a2b9fab83"
	"github.com/mitchellh/mapstructure f15292f7a6"
	"github.com/multiplay/go-ts3 d0d4455549"
	"github.com/naoina/go-stringutil 6b638e95a3"
	"github.com/nats-io/gnatsd 6608e9ac3b"
	"github.com/nats-io/go-nats 062418ea1c"
	"github.com/nats-io/nuid 289cccf02c"
	"github.com/nsqio/go-nsq eee57a3ac4"
	"github.com/opentracing-contrib/go-observer a52f234244" #tests
	"github.com/opentracing/opentracing-go 1949ddbfd1" #tests
	"github.com/openzipkin/zipkin-go-opentracing 26cf970748"
	"github.com/pierrec/lz4 1958fd8fff"
	"github.com/pkg/errors 645ef00459"
	"github.com/prometheus/client_golang c5b7fccd20"
	"github.com/prometheus/client_model 5c3871d899"
	"github.com/prometheus/common 7600349dcf"
	"github.com/prometheus/procfs ae68e2d4c0"
	"github.com/rcrowley/go-metrics e2704e1651"
	"github.com/samuel/go-zookeeper c4fab1ac1b"
	"github.com/satori/go.uuid f58768cc1a"
	"github.com/shirou/gopsutil 8048a2e9c5"
	"github.com/sirupsen/logrus c155da1940"
	"github.com/soniah/gosnmp 96b86229e9"
	"github.com/streadway/amqp e5adc2ada8"
	"github.com/stretchr/testify f35b8ab0b5"
	"github.com/tidwall/gjson f123b34087"
	"github.com/tidwall/match 1731857f09"
	"github.com/vjeantet/grok ce01e59abc"
	"github.com/vmware/govmomi e3a01f9611"
	"github.com/wvanbergen/kafka e2edea948d"
	"github.com/wvanbergen/kazoo-go f72d861129"
	"github.com/yuin/gopher-lua 46796da1b0"
	"go.opencensus.io 79993219be github.com/census-instrumentation/opencensus-go"
	"golang.org/x/crypto a214413485 github.com/golang/crypto"
	"golang.org/x/net a680a1efc5 github.com/golang/net"
	"golang.org/x/oauth2 d2e6202438 github.com/golang/oauth2"
	"golang.org/x/sys ac767d655b github.com/golang/sys"
	"golang.org/x/text f21a4dfb5e github.com/golang/text"
	"google.golang.org/api 19ff8768a5 github.com/googleapis/google-api-go-client"
	"google.golang.org/genproto fedd286124 github.com/google/go-genproto"
	"google.golang.org/grpc 168a6198bc github.com/grpc/grpc-go"
	"gopkg.in/alecthomas/kingpin.v2 947dcec5ba github.com/alecthomas/kingpin"
	"gopkg.in/asn1-ber.v1 379148ca02 github.com/go-asn1-ber/asn1-ber"
	"gopkg.in/fatih/pool.v2 010e0b745d github.com/fatih/pool"
	"gopkg.in/gorethink/gorethink.v3 7f5bdfd858 github.com/GoRethink/gorethink"
	"gopkg.in/ldap.v2 bb7a9ca6e4 github.com/go-ldap/ldap"
	"gopkg.in/mgo.v2 9856a29383 github.com/go-mgo/mgo"
	"gopkg.in/olivere/elastic.v5 52741dc2ce github.com/olivere/elastic"
	"gopkg.in/yaml.v2 5420a8b674 github.com/go-yaml/yaml"
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
IUSE="pie"

QA_PRESTRIPPED="usr/bin/telegraf"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	if [[ "${MERGE_TYPE}" != binary ]]; then
		# shellcheck disable=SC2086
		if has test && has network-sandbox $FEATURES; then
			ewarn
			ewarn "The test phase requires 'network-sandbox' to be disabled in FEATURES"
			ewarn
			die "[network-sandbox] is enabled in FEATURES"
		fi
	fi

	enewgroup telegraf
	enewuser telegraf -1 -1 -1 telegraf
}

src_compile() {
	export GOPATH="${G}"
	local myldflags=( -s -w
		-X "main.version=${MY_PV}"
		-X "main.branch=${MY_PV}"
		-X "main.commit=${GIT_COMMIT}"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)
	go build "${mygoargs[@]}" ./cmd/telegraf || die
}

src_test() {
	# Remove tests that doesn't work inside portage's sandbox
	rm plugins/inputs/socket_listener/socket_listener_test.go || die
	rm plugins/outputs/socket_writer/socket_writer_test.go || die

	go test -short ./... || die
}

src_install() {
	dobin telegraf

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	systemd_dounit "scripts/${PN}.service"

	dodir /etc/telegraf/telegraf.d
	insinto /etc/telegraf
	newins etc/telegraf.conf telegraf.conf.example

	insinto /etc/logrotate.d
	doins etc/logrotate.d/telegraf

	diropts -o telegraf -g telegraf -m 0750
	keepdir /var/log/telegraf
}

pkg_postinst() {
	if [[ ! -e "${EROOT%/}/etc/telegraf/telegraf.conf" ]]; then
		elog "No telegraf.conf found, copying the example over"
		cp "${EROOT%/}"/etc/telegraf/telegraf.conf{.example,} || die
	else
		elog "telegraf.conf found, please check example file for possible changes"
	fi
}
