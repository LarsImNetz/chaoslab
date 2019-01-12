# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Keep this in sync with frontend/
FRONTEND_COMMIT="2642333928b21dd76c5bfb2457a19502d73d6475"
FRONTEND_P="frontend-${FRONTEND_COMMIT}"

EGO_PN="github.com/${PN}/${PN}"
# Note: Keep EGO_VENDOR in sync with go.mod
EGO_VENDOR=(
	"github.com/BurntSushi/toml v0.3.1" #indirect
	"github.com/GeertJohan/go.incremental 1172aab96510" #indirect
	"github.com/GeertJohan/go.rice c02ca9a983da"
	"github.com/PuerkitoBio/purell 975f53781597" #indirect
	"github.com/PuerkitoBio/urlesc de5bf2ad4578" #indirect
	"github.com/Sereal/Sereal 509a78ddbda3"
	"github.com/alecthomas/chroma v0.6.2" #indirect
	"github.com/akavel/rsrc f6a15ece2cfd" #indirect
	"github.com/asdine/storm v2.1.2"
	"github.com/boltdb/bolt v1.3.1"
	"github.com/chaseadamsio/goorgeous v1.1.0" #indirect
	"github.com/daaku/go.zipexe a5fe2436ffcb"
	"github.com/danwakefield/fnmatch cbb64ac3d964" #indirect
	"github.com/dgrijalva/jwt-go v3.2.0"
	"github.com/dlclark/regexp2 7632a260cbaf" #indirect
	"github.com/dsnet/compress cc9eb1d7ad76"
	"github.com/flynn/go-shlex 3f9db97f8568"
	"github.com/fsnotify/fsnotify v1.4.7" #indirect
	"github.com/gohugoio/hugo v0.49.2"
	"github.com/golang/protobuf v1.2.0"
	"github.com/golang/snappy 2e65f85255db"
	"github.com/google/uuid v1.1.0"
	"github.com/gorilla/websocket v1.4.0"
	"github.com/hacdias/fileutils 227b317161a1"
	"github.com/hacdias/varutils 82d3b57f667a"
	"github.com/hashicorp/go-immutable-radix v1.0.0" #indirect
	"github.com/hashicorp/golang-lru v0.5.0" #indirect
	"github.com/hashicorp/hcl v1.0.0" #indirect
	"github.com/jdkato/prose a179b97cfa6f" #indirect
	"github.com/jessevdk/go-flags v1.4.0" #indirect
	"github.com/kardianos/osext ae77be60afb1"
	"github.com/kyokomi/emoji v2.0.0" #indirect
	"github.com/magiconair/properties v1.8.0" #indirect
	"github.com/maruel/natural dbcb3e2e8cf1"
	"github.com/mattn/go-runewidth v0.0.4" #indirect
	"github.com/mholt/archiver v2.1.0"
	"github.com/mholt/caddy v0.11.1"
	"github.com/miekg/mmark v1.3.6" #indirect
	"github.com/mitchellh/go-homedir v1.0.0"
	"github.com/mitchellh/mapstructure v1.1.2"
	"github.com/nwaples/rardecode v1.0.0"
	"github.com/olekukonko/tablewriter v0.0.1" #indirect
	"github.com/pelletier/go-toml v1.2.0" #indirect
	"github.com/pierrec/lz4 v2.0.5"
	"github.com/robfig/cron b41be1df6967"
	"github.com/russross/blackfriday v1.5.2" #indirect
	"github.com/shurcooL/sanitized_anchor_name v1.0.0" #indirect
	"github.com/spf13/afero v1.2.0" #indirect
	"github.com/spf13/cast v1.3.0" #indirect
	"github.com/spf13/cobra v0.0.3"
	"github.com/spf13/jwalterweatherman v1.0.0" #indirect
	"github.com/spf13/pflag v1.0.3" #indirect
	"github.com/spf13/viper v1.3.1"
	"github.com/ulikunitz/xz v0.5.5"
	"github.com/vmihailenco/msgpack v4.0.1"
	"github.com/xi2/xz 48954b6210f8"
	"go.etcd.io/bbolt v1.3.0 github.com/etcd-io/bbolt"
	"golang.org/x/crypto 505ab145d0a9 github.com/golang/crypto"
	"golang.org/x/net 45ffb0cd1ba0 github.com/golang/net" #indirect
	"golang.org/x/sys 7fbe1cd0fcc2 github.com/golang/sys" #indirect
	"golang.org/x/text v0.3.0 github.com/golang/text" #indirect
	"gopkg.in/natefinch/lumberjack.v2 v2.0.0 github.com/natefinch/lumberjack"
	"gopkg.in/yaml.v2 v2.2.2 github.com/go-yaml/yaml" #indirect
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
IUSE="+daemon debug pie static"

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

src_prepare() {
	if use static; then
		use pie || export CGO_ENABLED=0
		use pie && append-ldflags -static
	fi
	default
}

src_compile() {
	export GOPATH="${G}"
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"
	local PATH="${G}/bin:$PATH"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie exe)"
		-asmflags "all=-trimpath=${S}"
		-gcflags "all=-trimpath=${S}"
		-ldflags "$(usex !debug '-s -w' '')"
		-o filebrowser
	)

	pushd frontend || die
	yarn install || die
	yarn build || die
	popd || die

	# Build rice locally
	go install ./vendor/github.com/GeertJohan/go.rice/rice || die
	# Embed the assets using rice
	pushd lib > /dev/null || die
	rice embed-go || die
	popd > /dev/null || die

	go build "${mygoargs[@]}" ./cli || die
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
