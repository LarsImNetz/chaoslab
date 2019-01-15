# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PV="0316580e924fc6a907071b9d408f62c829df6eda"
EGO_PN="github.com/evilsocket/${PN/d}"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
EGO_VENDOR=(
	"github.com/evilsocket/ftrace v1.2.0"
	"github.com/fsnotify/fsnotify v1.4.7"
	"github.com/golang/protobuf v1.0.0"
	"github.com/google/gopacket v1.1.14"
	"golang.org/x/net 8d16fa6dc9a8 github.com/golang/net"
	"golang.org/x/sys b126b21c05a9 github.com/golang/sys"
	"golang.org/x/text v0.3.0 github.com/golang/text"
	"google.golang.org/genproto 7fd901a49ba6 github.com/google/go-genproto"
	"google.golang.org/grpc v1.11.3 github.com/grpc/grpc-go"
)

inherit golang-vcs-snapshot-r1 linux-info systemd

DESCRIPTION="OpenSnitch daemon"
HOMEPAGE="https://www.opensnitch.io/"
ARCHIVE_URI="https://${EGO_PN}/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="${ARCHIVE_URI} ${EGO_VENDOR_URI}"
RESTRICT="mirror test"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86" # Untested: arm arm64 x86
IUSE="debug pie static"

LIB_DEPEND="
	net-libs/libnfnetlink[static-libs(+)]
	net-libs/libnetfilter_queue[static-libs(+)]
"
DEPEND="
	!static? ( ${LIB_DEPEND//\[static-libs\(+\)]} )
	static? ( ${LIB_DEPEND} )
"
RDEPEND="${DEPEND}
	net-firewall/iptables
	net-libs/libpcap
"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/.*"

CONFIG_CHECK="
	~KPROBES
	~FTRACE
	~FUNCTION_TRACER
	~KPROBE_EVENTS
	~DYNAMIC_FTRACE
	~NETFILTER_XT_TARGET_NFQUEUE
"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"
	use static && CGO_LDFLAGS+=" -static"

	local mygoargs=(
		-v -work -x
		-buildmode "$(usex pie pie exe)"
		-asmflags "all=-trimpath=${S}"
		-gcflags "all=-trimpath=${S}"
		-ldflags "$(usex !debug '-s -w' '')"
		-tags "$(usex static 'netgo' '')"
		-installsuffix "$(usex static 'netgo' '')"
		-o ./opensnitchd
	)
	go build "${mygoargs[@]}" ./daemon || die
}

src_install() {
	dobin opensnitchd
	use debug && dostrip -x /usr/bin/opensnitchd
	einstalldocs

	keepdir /etc/opensnitchd/rules

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	systemd_newunit "${FILESDIR}/${PN}.service" "${PN}.service"
}
