# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/${PN}/${PN}"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
# Deps that are not needed:
# github.com/aead/chacha20
# github.com/bifurcation/mint
# github.com/codahale/aesnicheck
# github.com/flynn/go-shlex
# github.com/hashicorp/go-syslog
# github.com/hashicorp/golang-lru
# github.com/lucas-clemente/aes12
# github.com/lucas-clemente/fnv128a
# github.com/lucas-clemente/quic-go
# github.com/lucas-clemente/quic-go-certificates
# github.com/miekg/dns
# github.com/xenolf/lego
# golang.org/x/net
# gopkg.in/square/go-jose.v1
EGO_VENDOR=(
	"github.com/BurntSushi/toml a368813"
	"github.com/GeertJohan/go.rice c02ca9a"
	"github.com/asdine/storm 68fc73b"
	"github.com/chaseadamsio/goorgeous dcf1ef8"
	"github.com/coreos/bbolt 583e893"
	"github.com/daaku/go.zipexe a5fe243"
	"github.com/dgrijalva/jwt-go dbeaa93"
	"github.com/dsnet/compress cc9eb1d"
	"github.com/fsnotify/fsnotify c282820"
	"github.com/gohugoio/hugo 25e88cc"
	"github.com/golang/snappy 553a641"
	"github.com/gorilla/websocket ea4d1f6"
	"github.com/hacdias/fileutils 76b1c6a"
	"github.com/hacdias/varutils 82d3b57"
	"github.com/hashicorp/hcl 23c074d"
	"github.com/kardianos/osext ae77be6"
	"github.com/magiconair/properties c3beff4"
	"github.com/mholt/archiver 26cf5b"
	"github.com/mholt/caddy d3f338d"
	"github.com/mitchellh/mapstructure 00c29f5"
	"github.com/nwaples/rardecode e06696f"
	"github.com/pelletier/go-toml acdc450"
	"github.com/pierrec/lz4 2fcda4c"
	"github.com/pierrec/xxHash f051bb7"
	"github.com/robfig/cron b024fc5"
	"github.com/russross/blackfriday 4048872"
	"github.com/shurcooL/sanitized_anchor_name 86672fc"
	"github.com/spf13/afero bb8f192"
	"github.com/spf13/cast 8965335"
	"github.com/spf13/jwalterweatherman 7c0cea3"
	"github.com/spf13/pflag e57e3ee"
	"github.com/spf13/viper 25b30aa"
	"github.com/ulikunitz/xz 0c6b41e"
	"golang.org/x/crypto 4979611 github.com/golang/crypto"
	"golang.org/x/sys 88d2dcc github.com/golang/sys"
	"golang.org/x/text f21a4df github.com/golang/text"
	"gopkg.in/natefinch/lumberjack.v2 a96e638 github.com/natefinch/lumberjack"
	"gopkg.in/yaml.v2 7f97868 github.com/go-yaml/yaml"
)

inherit golang-vcs-snapshot systemd user

DESCRIPTION="A stylish web file manager"
HOMEPAGE="https://filebrowser.github.io/"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+daemon pie"

QA_PRESTRIPPED="usr/bin/filebrowser"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	if use daemon; then
		enewgroup filebrowser
		enewuser filebrowser -1 -1 -1 filebrowser
	fi
}

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		$(usex pie '-buildmode=pie' '')
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w -X filebrowser.Version=${PV}"
	)
	go build "${mygoargs[@]}" ./cmd/${PN} || die
}

src_install() {
	dobin filebrowser

	if use daemon; then
		newinitd "${FILESDIR}"/${PN}.initd ${PN}
		systemd_dounit "${FILESDIR}"/${PN}.service

		insinto /etc/filebrowser
		newins "${FILESDIR}"/filebrowser.conf-r1 \
			filebrowser.yaml.example

		diropts -o filebrowser -g filebrowser -m 0750
		keepdir /var/{lib,log,www}/filebrowser
	fi
}

src_test() {
	go test -v ./... || die
}

pkg_postinst() {
	if use daemon; then
		if [ ! -e "${EROOT%/}"/etc/filebrowser/filebrowser.yaml ]; then
			elog "No filebrowser.yaml found, copying the example over"
			cp "${EROOT%/}"/etc/filebrowser/filebrowser.yaml{.example,} || die
		else
			elog "filebrowser.yaml found, please check example file for possible changes"
		fi
	fi
}
