# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Keep this in sync with frontend/
FRONTEND_COMMIT="99740e3eabf437d3d6f4893870f66c3653d48e3b"
FRONTEND_P="frontend-${FRONTEND_COMMIT}"

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
	"github.com/BurntSushi/toml a368813c5e"
	"github.com/GeertJohan/go.rice c02ca9a983"
	"github.com/GeertJohan/go.incremental 1172aab965"
	"github.com/akavel/rsrc f6a15ece2c"
	"github.com/asdine/storm v2.0.2"
	"github.com/chaseadamsio/goorgeous v1.1.0"
	"github.com/coreos/bbolt v1.3.0"
	"github.com/daaku/go.zipexe a5fe2436ff"
	"github.com/dgrijalva/jwt-go v3.1.0"
	"github.com/dsnet/compress cc9eb1d7ad"
	"github.com/fsnotify/fsnotify v1.4.7"
	"github.com/gohugoio/hugo v0.36.1"
	"github.com/golang/snappy 553a641470"
	"github.com/gorilla/websocket v1.2.0"
	"github.com/hacdias/fileutils 76b1c6ab90"
	"github.com/hacdias/varutils 82d3b57f66"
	"github.com/hashicorp/hcl 23c074d0ec"
	"github.com/jessevdk/go-flags v1.4.0"
	"github.com/kardianos/osext ae77be60af"
	"github.com/magiconair/properties v1.7.6"
	"github.com/maruel/natural dbcb3e2e8c"
	"github.com/mholt/archiver 26cf5bb32d"
	"github.com/mholt/caddy v0.10.11"
	"github.com/mitchellh/mapstructure 00c29f56e2"
	"github.com/nwaples/rardecode e06696f847"
	"github.com/pelletier/go-toml v1.1.0"
	"github.com/pierrec/lz4 v1.1"
	"github.com/pierrec/xxHash v0.1.1"
	"github.com/robfig/cron v1"
	"github.com/russross/blackfriday v1.5"
	"github.com/shurcooL/sanitized_anchor_name 86672fcb3f"
	"github.com/spf13/afero v1.0.2"
	"github.com/spf13/cast v1.2.0"
	"github.com/spf13/jwalterweatherman 7c0cea34c8"
	"github.com/spf13/pflag v1.0.0"
	"github.com/spf13/viper v1.0.0"
	"github.com/ulikunitz/xz v0.5.4"
	"golang.org/x/crypto 49796115aa github.com/golang/crypto"
	"golang.org/x/sys 88d2dcc510 github.com/golang/sys"
	"golang.org/x/text v0.3.0 github.com/golang/text"
	"gopkg.in/natefinch/lumberjack.v2 v2.1 github.com/natefinch/lumberjack"
	"gopkg.in/yaml.v2 v2.1.1 github.com/go-yaml/yaml"
)

inherit golang-vcs-snapshot-r1 systemd user

DESCRIPTION="A stylish web file manager"
HOMEPAGE="https://filebrowser.github.io"
SRC_URI="
	https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/${PN}/frontend/archive/${FRONTEND_COMMIT}.tar.gz -> ${FRONTEND_P}.tar.gz
	${EGO_VENDOR_URI}
"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+daemon debug pie"

DEPEND="sys-apps/yarn"

QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_pretend() {
	# shellcheck disable=SC2086
	if has network-sandbox ${FEATURES} && [[ "${MERGE_TYPE}" != binary ]]; then
		ewarn
		ewarn "${CATEGORY}/${PN} requires 'network-sandbox' to be disabled in FEATURES"
		ewarn
		die "[network-sandbox] is enabled in FEATURES"
	fi
}

pkg_setup() {
	if use daemon; then
		enewgroup filebrowser
		enewuser filebrowser -1 -1 -1 filebrowser
	fi
}

src_unpack() {
	golang-vcs-snapshot-r1_src_unpack
	cd "${S}" || die
	unpack "${FRONTEND_P}.tar.gz"
	rmdir frontend || die
	mv "${FRONTEND_P}" frontend || die
}

src_compile() {
	export GOPATH="${G}"
	local PATH="${G}/bin:$PATH"
	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "filebrowser.Version=${PV}"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)

	pushd frontend || die
	yarn install || die
	yarn build || die
	popd || die

	# Build rice locally
	go install ./vendor/github.com/GeertJohan/go.rice/rice || die
	# Embed the assets using rice
	rice embed-go || die

	go build "${mygoargs[@]}" ./cmd/filebrowser || die
}

src_install() {
	dobin filebrowser
	use debug && dostrip -x /usr/bin/filebrowser

	if use daemon; then
		newinitd "${FILESDIR}/${PN}.initd" "${PN}"
		systemd_dounit "${FILESDIR}/${PN}.service"

		insinto /etc/filebrowser
		newins "${FILESDIR}"/filebrowser.conf-r1 filebrowser.yaml.example

		diropts -o filebrowser -g filebrowser -m 0750
		keepdir /var/{lib,log,www}/filebrowser
	fi
}

src_test() {
	go test -v ./... || die
}

pkg_postinst() {
	if use daemon; then
		if [[ ! -e "${EROOT}/etc/filebrowser/filebrowser.yaml" ]]; then
			elog "No filebrowser.yaml found, copying the example over"
			cp "${EROOT}"/etc/filebrowser/filebrowser.yaml{.example,} || die
		else
			elog "filebrowser.yaml found, please check example file for possible changes"
		fi
	fi
}
