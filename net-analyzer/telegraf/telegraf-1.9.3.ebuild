# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Change this when you update the ebuild
GIT_COMMIT="6ad8c8b00b244809cdf5b7f4747eb27b002986d0"
EGO_PN="github.com/influxdata/${PN}"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
EGO_VENDOR=(
	"cloud.google.com/go v0.27.0 github.com/GoogleCloudPlatform/google-cloud-go"
	"code.cloudfoundry.org/clock 02e53af36e6c github.com/cloudfoundry/clock"
	"collectd.org v0.3.0 github.com/collectd/go-collectd"
	"contrib.go.opencensus.io/exporter/stackdriver v0.6.0 github.com/census-ecosystem/opencensus-go-exporter-stackdriver"
	"github.com/Azure/go-autorest v10.12.0"
	"github.com/Microsoft/ApplicationInsights-Go d2df5d440eda"
	#"github.com/Microsoft/go-winio v0.4.9"
	"github.com/Shopify/sarama v1.18.0"
	#"github.com/StackExchange/wmi 1.0.0"
	"github.com/aerospike/aerospike-client-go v1.27.0"
	"github.com/alecthomas/template a0175ee3bccc"
	"github.com/alecthomas/units 2efee857e7cf"
	"github.com/amir/raidman 1ccc43bfb9c9"
	"github.com/apache/thrift f2867c24984a"
	"github.com/aws/aws-sdk-go v1.15.54"
	"github.com/beorn7/perks 3a771d992973"
	"github.com/bsm/sarama-cluster v2.1.13"
	"github.com/cenkalti/backoff v2.0.0"
	"github.com/couchbase/go-couchbase 16db1f1fe037"
	"github.com/couchbase/gomemcached 0da75df14530"
	"github.com/couchbase/goutils e865a1461c8a"
	"github.com/davecgh/go-spew v1.1.0"
	"github.com/denisenkom/go-mssqldb 1eb28afdf9b6"
	"github.com/dgrijalva/jwt-go v3.2.0"
	"github.com/dimchansky/utfbom 6c6132ff69f0"
	#"github.com/docker/distribution edc3ab29cdff"
	"github.com/docker/docker ed7b6428c133"
	#"github.com/docker/go-connections v0.3.0"
	#"github.com/docker/go-units v0.3.3"
	"github.com/docker/libnetwork d7b61745d166"
	"github.com/eapache/go-resiliency v1.1.0"
	"github.com/eapache/go-xerial-snappy 040cc1a32f57"
	"github.com/eapache/queue v1.1.0"
	"github.com/eclipse/paho.mqtt.golang v1.1.1"
	"github.com/ericchiang/k8s v1.2.0"
	#"github.com/go-ini/ini v1.38.1"
	"github.com/go-logfmt/logfmt v0.3.0"
	#"github.com/go-ole/go-ole v1.2.1"
	"github.com/go-redis/redis v6.12.0"
	"github.com/go-sql-driver/mysql v1.4.0"
	"github.com/gobwas/glob v0.2.3"
	"github.com/gogo/protobuf v1.1.1" # tests
	"github.com/golang/protobuf v1.1.0"
	"github.com/golang/snappy 2e65f85255db"
	"github.com/google/go-cmp v0.2.0" # tests
	#"github.com/google/uuid 0.2"
	"github.com/googleapis/gax-go v2.0.0"
	#"github.com/gorilla/context v1.1.1"
	"github.com/gorilla/mux v1.6.2"
	"github.com/hailocab/go-hostpool e80d13ce29ed"
	"github.com/hashicorp/consul v1.2.1"
	#"github.com/hashicorp/go-cleanhttp d5fe4b57a186"
	#"github.com/hashicorp/go-rootcerts"
	#"github.com/hashicorp/serf v0.8.1"
	"github.com/influxdata/go-syslog v2.0.0"
	"github.com/influxdata/tail c43482518d41"
	"github.com/influxdata/toml 2a2e3012f7cf"
	"github.com/influxdata/wlog 7c63b0a71ef8"
	"github.com/jackc/pgx v3.2.0"
	#"github.com/jmespath/go-jmespath 0b12d6b521d8"
	#"github.com/kardianos/osext ae77be60afb1"
	"github.com/kardianos/service 615a14ed7509"
	"github.com/kballard/go-shellquote 95032a82bc51"
	#"github.com/kr/logfmt b84e30acd515"
	"github.com/leodido/ragel-machinery 299bdde78165"
	"github.com/mailru/easyjson efc7eb8984d6"
	"github.com/matttproud/golang_protobuf_extensions v1.0.1"
	"github.com/miekg/dns v1.0.8"
	#"github.com/mitchellh/go-homedir 3864e76763d9"
	"github.com/mitchellh/mapstructure f15292f7a699"
	"github.com/multiplay/go-ts3 v1.0.0"
	"github.com/naoina/go-stringutil v0.1.0"
	"github.com/nats-io/gnatsd v1.2.0"
	"github.com/nats-io/go-nats v1.5.0"
	"github.com/nats-io/nuid v1.0.0"
	"github.com/nsqio/go-nsq v1.0.7"
	#"github.com/opencontainers/go-digest v1.0.0-rc1"
	#"github.com/opencontainers/image-spec v1.0.1"
	"github.com/opentracing-contrib/go-observer a52f23424492" # tests
	"github.com/opentracing/opentracing-go v1.0.2" # tests
	"github.com/openzipkin/zipkin-go-opentracing v0.3.4"
	"github.com/pierrec/lz4 v2.0.3"
	"github.com/pkg/errors v0.8.0"
	#"github.com/pmezard/go-difflib v1.0.0"
	"github.com/prometheus/client_golang v0.8.0"
	"github.com/prometheus/client_model 5c3871d89910"
	"github.com/prometheus/common 7600349dcfe1"
	"github.com/prometheus/procfs ae68e2d4c00f"
	"github.com/rcrowley/go-metrics e2704e165165"
	"github.com/samuel/go-zookeeper c4fab1ac1bec"
	"github.com/satori/go.uuid v1.2.0"
	"github.com/shirou/gopsutil v2.18.07"
	#"github.com/shirou/w32 bb4de0191aa4"
	"github.com/sirupsen/logrus v1.0.5"
	"github.com/soniah/gosnmp 96b86229e9b3"
	"github.com/streadway/amqp e5adc2ada8b8"
	"github.com/stretchr/testify v1.2.2"
	#"github.com/stretchr/objx v0.1.1"
	"github.com/tidwall/gjson v1.1.2"
	"github.com/tidwall/match 1731857f09b1"
	#"github.com/vishvananda/netlink b2de5d10e38e"
	#"github.com/vishvananda/netns 13995c7128cc"
	"github.com/vjeantet/grok v1.0.0"
	"github.com/vmware/govmomi v0.18.0"
	"github.com/wvanbergen/kafka e2edea948ddf"
	"github.com/wvanbergen/kazoo-go f72d8611297a"
	"github.com/yuin/gopher-lua 46796da1b0b4"
	"go.opencensus.io v0.17.0 github.com/census-instrumentation/opencensus-go"
	"golang.org/x/crypto a2144134853f github.com/golang/crypto"
	"golang.org/x/net a680a1efc54d github.com/golang/net"
	"golang.org/x/oauth2 d2e6202438be github.com/golang/oauth2"
	"golang.org/x/sys ac767d655b30 github.com/golang/sys"
	"golang.org/x/text v0.3.0 github.com/golang/text"
	"google.golang.org/api 19ff8768a5c0 github.com/googleapis/google-api-go-client"
	#"google.golang.org/appengine v1.1.0 github.com/golang/appengine"
	"google.golang.org/genproto fedd2861243f github.com/google/go-genproto"
	"google.golang.org/grpc v1.13.0 github.com/grpc/grpc-go"
	"gopkg.in/alecthomas/kingpin.v2 v2.2.6 github.com/alecthomas/kingpin"
	"gopkg.in/asn1-ber.v1 v1.2 github.com/go-asn1-ber/asn1-ber"
	"gopkg.in/fatih/pool.v2 v2.0.0 github.com/fatih/pool"
	#"gopkg.in/fsnotify.v1 v1.4.7 github.com/fsnotify/fsnotify"
	"gopkg.in/gorethink/gorethink.v3 v3.0.5 github.com/GoRethink/gorethink"
	"gopkg.in/ldap.v2 v2.5.1 github.com/go-ldap/ldap"
	"gopkg.in/mgo.v2 9856a29383ce github.com/go-mgo/mgo"
	"gopkg.in/olivere/elastic.v5 v5.0.70 github.com/olivere/elastic"
	#"gopkg.in/tomb.v1 dd632973f1e7 github.com/go-tomb/tomb"
	"gopkg.in/yaml.v2 v2.2.1 github.com/go-yaml/yaml"
)

inherit golang-vcs-snapshot-r1 systemd user

MY_PV="${PV/_/-}"
DESCRIPTION="An agent for collecting, processing, aggregating, and writing metrics"
HOMEPAGE="https://influxdata.com"
ARCHIVE_URI="https://${EGO_PN}/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="${ARCHIVE_URI} ${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug pie"

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

pkg_setup() {
	enewgroup telegraf
	enewuser telegraf -1 -1 -1 telegraf
}

src_compile() {
	export GOPATH="${G}"
	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "main.version=${MY_PV}"
		-X "main.branch=${MY_PV}"
		-X "main.commit=${GIT_COMMIT:0:7}"
	)
	local mygoargs=(
		-v -work -x
		-buildmode "$(usex pie pie exe)"
		-asmflags "all=-trimpath=${S}"
		-gcflags "all=-trimpath=${S}"
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
	use debug && dostrip -x /usr/bin/telegraf

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
	if [[ ! -e "${EROOT}/etc/telegraf/telegraf.conf" ]]; then
		elog "No telegraf.conf found, copying the example over"
		cp "${EROOT}"/etc/telegraf/telegraf.conf{.example,} || die
	else
		elog "telegraf.conf found, please check example file for possible changes"
	fi
}
