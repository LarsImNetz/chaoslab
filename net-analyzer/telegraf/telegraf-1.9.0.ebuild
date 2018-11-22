# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GIT_COMMIT="2bf21c0d43" # Change this when you update the ebuild
EGO_PN="github.com/influxdata/${PN}"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
# Deps that are not needed:
# github.com/Microsoft/go-winio v0.4.9
# github.com/StackExchange/wmi 1.0.0
# github.com/docker/distribution edc3ab29cd
# github.com/docker/go-connections v0.3.0
# github.com/docker/go-units v0.3.3
# github.com/go-ini/ini v1.38.1
# github.com/go-ole/go-ole v1.2.1
# github.com/google/uuid 0.2
# github.com/gorilla/context v1.1.1
# github.com/hashicorp/go-cleanhttp d5fe4b57a1
# github.com/hashicorp/go-rootcerts 6bb64b370b
# github.com/hashicorp/serf v0.8.1
# github.com/jmespath/go-jmespath 0b12d6b521
# github.com/kardianos/osext ae77be60af
# github.com/kr/logfmt b84e30acd5
# github.com/mitchellh/go-homedir 3864e76763
# github.com/opencontainers/go-digest v1.0.0-rc1
# github.com/opencontainers/image-spec v1.0.1
# github.com/pmezard/go-difflib v1.0.0
# github.com/shirou/w32 bb4de0191a
# github.com/stretchr/objx v0.1.1
# github.com/vishvananda/netlink b2de5d10e3
# github.com/vishvananda/netns 13995c7128
# google.golang.org/appengine v1.1.0
# gopkg.in/fsnotify.v1 v1.4.7
# gopkg.in/tomb.v1 dd632973f1
EGO_VENDOR=(
	"cloud.google.com/go v0.27.0 github.com/GoogleCloudPlatform/google-cloud-go"
	"code.cloudfoundry.org/clock 02e53af36e github.com/cloudfoundry/clock"
	"collectd.org v0.3.0 github.com/collectd/go-collectd"
	"contrib.go.opencensus.io/exporter/stackdriver v0.6.0 github.com/census-ecosystem/opencensus-go-exporter-stackdriver"
	"github.com/Azure/go-autorest v10.12.0"
	"github.com/Microsoft/ApplicationInsights-Go d2df5d440e"
	"github.com/Shopify/sarama v1.18.0"
	"github.com/aerospike/aerospike-client-go v1.27.0"
	"github.com/alecthomas/template a0175ee3bc"
	"github.com/alecthomas/units 2efee857e7"
	"github.com/amir/raidman 1ccc43bfb9"
	"github.com/apache/thrift f2867c2498"
	"github.com/aws/aws-sdk-go v1.15.54"
	"github.com/beorn7/perks 3a771d9929"
	"github.com/bsm/sarama-cluster v2.1.13"
	"github.com/cenkalti/backoff v2.0.0"
	"github.com/couchbase/go-couchbase 16db1f1fe0"
	"github.com/couchbase/gomemcached 0da75df145"
	"github.com/couchbase/goutils e865a1461c"
	"github.com/davecgh/go-spew v1.1.0"
	"github.com/denisenkom/go-mssqldb 1eb28afdf9"
	"github.com/dgrijalva/jwt-go v3.2.0"
	"github.com/dimchansky/utfbom 6c6132ff69"
	"github.com/docker/docker ed7b6428c1"
	"github.com/docker/libnetwork d7b61745d1"
	"github.com/eapache/go-resiliency v1.1.0"
	"github.com/eapache/go-xerial-snappy 040cc1a32f"
	"github.com/eapache/queue v1.1.0"
	"github.com/eclipse/paho.mqtt.golang v1.1.1"
	"github.com/ericchiang/k8s v1.2.0"
	"github.com/go-logfmt/logfmt v0.3.0"
	"github.com/go-redis/redis v6.12.0"
	"github.com/go-sql-driver/mysql v1.4.0"
	"github.com/gobwas/glob v0.2.3"
	"github.com/gogo/protobuf v1.1.1" # tests
	"github.com/golang/protobuf v1.1.0"
	"github.com/golang/snappy 2e65f85255"
	"github.com/google/go-cmp v0.2.0" # tests
	"github.com/googleapis/gax-go v2.0.0"
	"github.com/gorilla/mux v1.6.2"
	"github.com/hailocab/go-hostpool e80d13ce29"
	"github.com/hashicorp/consul v1.2.1"
	"github.com/influxdata/go-syslog v1.0.1"
	"github.com/influxdata/tail c43482518d"
	"github.com/influxdata/toml 2a2e3012f7"
	"github.com/influxdata/wlog 7c63b0a71e"
	"github.com/jackc/pgx v3.1.0"
	"github.com/kardianos/service 615a14ed75"
	"github.com/kballard/go-shellquote 95032a82bc"
	"github.com/mailru/easyjson efc7eb8984"
	"github.com/matttproud/golang_protobuf_extensions v1.0.1"
	"github.com/miekg/dns v1.0.8"
	"github.com/mitchellh/mapstructure f15292f7a6"
	"github.com/multiplay/go-ts3 v1.0.0"
	"github.com/naoina/go-stringutil v0.1.0"
	"github.com/nats-io/gnatsd v1.2.0"
	"github.com/nats-io/go-nats v1.5.0"
	"github.com/nats-io/nuid v1.0.0"
	"github.com/nsqio/go-nsq v1.0.7"
	"github.com/opentracing-contrib/go-observer a52f234244" # tests
	"github.com/opentracing/opentracing-go v1.0.2" # tests
	"github.com/openzipkin/zipkin-go-opentracing v0.3.4"
	"github.com/pierrec/lz4 v2.0.3"
	"github.com/pkg/errors v0.8.0"
	"github.com/prometheus/client_golang v0.8.0"
	"github.com/prometheus/client_model 5c3871d899"
	"github.com/prometheus/common 7600349dcf"
	"github.com/prometheus/procfs ae68e2d4c0"
	"github.com/rcrowley/go-metrics e2704e1651"
	"github.com/samuel/go-zookeeper c4fab1ac1b"
	"github.com/satori/go.uuid v1.2.0"
	"github.com/shirou/gopsutil v2.18.07"
	"github.com/sirupsen/logrus v1.0.5"
	"github.com/soniah/gosnmp 96b86229e9"
	"github.com/streadway/amqp e5adc2ada8"
	"github.com/stretchr/testify v1.2.2"
	"github.com/tidwall/gjson v1.1.2"
	"github.com/tidwall/match 1731857f09"
	"github.com/vjeantet/grok v1.0.0"
	"github.com/vmware/govmomi v0.18.0"
	"github.com/wvanbergen/kafka e2edea948d"
	"github.com/wvanbergen/kazoo-go f72d861129"
	"github.com/yuin/gopher-lua 46796da1b0"
	"go.opencensus.io v0.17.0 github.com/census-instrumentation/opencensus-go"
	"golang.org/x/crypto a214413485 github.com/golang/crypto"
	"golang.org/x/net a680a1efc5 github.com/golang/net"
	"golang.org/x/oauth2 d2e6202438 github.com/golang/oauth2"
	"golang.org/x/sys ac767d655b github.com/golang/sys"
	"golang.org/x/text v0.3.0 github.com/golang/text"
	"google.golang.org/api 19ff8768a5 github.com/googleapis/google-api-go-client"
	"google.golang.org/genproto fedd286124 github.com/google/go-genproto"
	"google.golang.org/grpc v1.13.0 github.com/grpc/grpc-go"
	"gopkg.in/alecthomas/kingpin.v2 v2.2.6 github.com/alecthomas/kingpin"
	"gopkg.in/asn1-ber.v1 v1.2 github.com/go-asn1-ber/asn1-ber"
	"gopkg.in/fatih/pool.v2 v2.0.0 github.com/fatih/pool"
	"gopkg.in/gorethink/gorethink.v3 v3.0.5 github.com/GoRethink/gorethink"
	"gopkg.in/ldap.v2 v2.5.1 github.com/go-ldap/ldap"
	"gopkg.in/mgo.v2 9856a29383 github.com/go-mgo/mgo"
	"gopkg.in/olivere/elastic.v5 v5.0.70 github.com/olivere/elastic"
	"gopkg.in/yaml.v2 v2.2.1 github.com/go-yaml/yaml"
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

pkg_pretend() {
	if [[ "${MERGE_TYPE}" != binary ]]; then
		# shellcheck disable=SC2086
		(has test ${FEATURES} && has network-sandbox ${FEATURES}) && \
			die "The test phase requires 'network-sandbox' to be disabled in FEATURES"
	fi
}

pkg_setup() {
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
