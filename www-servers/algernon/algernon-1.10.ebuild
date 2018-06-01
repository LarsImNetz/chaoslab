# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/xyproto/${PN}"
# Note: Keep EGO_VENDOR in sync with ./vendor/*
EGO_VENDOR=(
	"github.com/alecthomas/chroma 222a1f0"
	"github.com/bifurcation/mint 1983579"
	"github.com/bmizerany/assert b7ed37b"
	"github.com/boltdb/bolt fd01fc7"
	"github.com/chzyer/readline f6d7a1f"
	"github.com/danwakefield/fnmatch cbb64ac"
	"github.com/didip/tollbooth b10a036"
	"github.com/dlclark/regexp2 7632a26"
	"github.com/dop251/goja 9183045"
	"github.com/eknkc/amber cdade1c"
	"github.com/fatih/color 507f605"
	"github.com/flosch/pongo2 e7cf9ea"
	"github.com/fsnotify/fsnotify c282820"
	"github.com/garyburd/redigo 569eae5"
	"github.com/getwe/figlet4go bc87934"
	"github.com/go-sourcemap/sourcemap b019cc3"
	"github.com/go-sql-driver/mysql 3287d94"
	"github.com/hashicorp/golang-lru 0fb14ef"
	"github.com/juju/errors c7d06af"
	"github.com/juju/ratelimit 59fac50"
	"github.com/jvatic/goja-babel 00569a2"
	"github.com/kr/pretty cfb55aa"
	"github.com/kr/text 7cafcd8"
	"github.com/lib/pq d34b9ff"
	"github.com/lucas-clemente/aes12 cd47fb3"
	"github.com/lucas-clemente/fnv128a 393af48"
	"github.com/lucas-clemente/quic-go 2127e2f"
	"github.com/lucas-clemente/quic-go-certificates d2f8652"
	"github.com/mattetti/filebuffer 3a1e8e5"
	"github.com/mattn/go-runewidth ce7b0b5"
	"github.com/mitchellh/go-homedir b8bc1bf"
	"github.com/mitchellh/mapstructure 00c29f5"
	"github.com/natefinch/pie 9a0d720"
	"github.com/nsf/termbox-go 7cbfaac"
	"github.com/russross/blackfriday 11635eb"
	"github.com/shurcooL/sanitized_anchor_name 86672fc"
	"github.com/sirupsen/logrus 778f2e7"
	"github.com/tylerb/graceful d72b015"
	"github.com/wellington/sass cab90b3"
	"github.com/xyproto/cookie 8ce3def"
	"github.com/xyproto/datablock f8aac43"
	"github.com/xyproto/jpath c3c5db5"
	"github.com/xyproto/mime 71c4d38"
	"github.com/xyproto/onthefly 267ff29"
	"github.com/xyproto/permissionbolt 3025da1"
	"github.com/xyproto/permissions2 50a1d96"
	"github.com/xyproto/permissionsql 59c2446"
	"github.com/xyproto/pinterface 05fa0e3"
	"github.com/xyproto/pstore 65a49d4"
	"github.com/xyproto/recwatch aaa94ab"
	"github.com/xyproto/simplebolt c36bc96"
	"github.com/xyproto/simplehstore e029054"
	"github.com/xyproto/simplemaria 014c7f7"
	"github.com/xyproto/simpleredis 82a64a0"
	"github.com/xyproto/splash 349c2b9"
	"github.com/xyproto/term 77ad530"
	"github.com/xyproto/unzip 8239505"
	"github.com/yosssi/gcss 3967759"
	"github.com/yuin/gluamapper d836955"
	"github.com/yuin/gopher-lua b0fa786"
	"golang.org/x/crypto ae8bce0 github.com/golang/crypto"
	"golang.org/x/net 5f9ae10 github.com/golang/net"
	"golang.org/x/sys 78d5f26 github.com/golang/sys"
	"golang.org/x/text 7922cc4 github.com/golang/text"
	"gopkg.in/gcfg.v1 f02745a github.com/go-gcfg/gcfg"
	"gopkg.in/warnings.v0 ec4a0fe github.com/go-warnings/warnings"
)

inherit golang-vcs-snapshot systemd user

DESCRIPTION="Pure Go web server with Lua, Markdown, QUIC and Pongo2 support"
HOMEPAGE="http://algernon.roboticoverlords.org"
SRC_URI="https://${EGO_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="examples mysql postgres redis"

RDEPEND="mysql? ( virtual/mysql )
	postgres? ( dev-db/postgresql:* )
	redis? ( dev-db/redis )"

DOCS=( ChangeLog.md )
QA_PRESTRIPPED="usr/bin/algernon"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup algernon
	enewuser algernon -1 -1 -1 algernon
}

src_compile() {
	export GOPATH="${G}"
	# shellcheck disable=SC2207
	local mygoargs=(
		-v -work -x
		$(usex pie '-buildmode=pie' '')
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w"
	)
	go build "${mygoargs[@]}" || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin algernon desktop/mdview
	einstalldocs

	newinitd "${FILESDIR}/${PN}.initd-r1" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd-r1" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"

	insinto /etc/algernon
	doins system/serverconf.lua

	if use examples; then
		docinto examples
		dodoc -r samples/*
		docompress -x "/usr/share/doc/${PF}/examples"
	fi

	insinto /etc/logrotate.d
	newins "${FILESDIR}/${PN}.logrotate" "${PN}"

	keepdir /var/www/algernon
	diropts -o algernon -g algernon -m 0700
	keepdir /var/log/algernon
}
