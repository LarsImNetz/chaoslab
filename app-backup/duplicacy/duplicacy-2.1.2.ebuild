# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/gilbertchen/${PN}"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
EGO_VENDOR=(
	"cloud.google.com/go 2d3a6656c1 github.com/GoogleCloudPlatform/gcloud-golang"
	"github.com/Azure/azure-sdk-for-go b7fadebe0e"
	"github.com/Azure/go-autorest 0ae36a9e54"
	"github.com/aryann/difflib e206f873d1"
	"github.com/aws/aws-sdk-go a32b1dcd09"
	"github.com/bkaradzic/go-lz4 74ddf82598"
	"github.com/dgrijalva/jwt-go dbeaa9332f"
	"github.com/gilbertchen/azure-sdk-for-go bbf89bd4d7"
	"github.com/gilbertchen/cli 1de0a1836c"
	"github.com/gilbertchen/go-dropbox 90711b6033"
	#"github.com/gilbertchen/go-ole 0e87ea779d"
	"github.com/gilbertchen/go.dbus 9e442e6378"
	"github.com/gilbertchen/goamz eada9f4e8c"
	"github.com/gilbertchen/gopass bf9dde6d0d"
	"github.com/gilbertchen/keyring 8855f56320"
	"github.com/gilbertchen/xattr 68e7a6806b"
	"github.com/go-ini/ini 32e4c1e6bc"
	"github.com/golang/protobuf 1e59b77b52"
	"github.com/googleapis/gax-go 317e000625"
	"github.com/jmespath/go-jmespath 0b12d6b521"
	"github.com/kr/fs 2788f0dbd1"
	"github.com/marstr/guid 8bd9a64bf3"
	"github.com/minio/blake2b-simd 3f5f724cb5"
	"github.com/ncw/swift ae9f0ea160"
	"github.com/pkg/errors 645ef00459"
	"github.com/pkg/sftp 98203f5a83"
	"github.com/satori/go.uuid f58768cc1a"
	"github.com/vaughan0/go-ini a98ad7ee00"
	"golang.org/x/crypto 9f005a07e0 github.com/golang/crypto"
	"golang.org/x/net 9dfe398356 github.com/golang/net"
	"golang.org/x/oauth2 f95fa95eaa github.com/golang/oauth2"
	"golang.org/x/sys 82aafbf43b github.com/golang/sys"
	"golang.org/x/text 88f656faf3 github.com/golang/text"
	"google.golang.org/api 17b5f22a24 github.com/google/google-api-go-client"
	#"google.golang.org/appengine 150dc57a1b github.com/golang/appengine"
	"google.golang.org/genproto 891aceb7c2 github.com/google/go-genproto"
	"google.golang.org/grpc 5a9f7b402f github.com/grpc/grpc-go"
)

inherit golang-vcs-snapshot-r1

DESCRIPTION="A new generation cloud backup tool"
HOMEPAGE="https://duplicacy.com"
ARCHIVE_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="${ARCHIVE_URI} ${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="duplicacy"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86" # Untested: arm arm64 x86
IUSE="debug pie static"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

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
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie exe)"
		-asmflags "all=-trimpath=${S}"
		-gcflags "all=-trimpath=${S}"
		-ldflags "$(usex !debug '-s -w' '')"
		-o bin/duplicacy
	)
	go build "${mygoargs[@]}" ./duplicacy || die
}

src_test() {
	pushd integration_tests > /dev/null || die
	sed -i "s|duplicacy_main|bin/duplicacy|" test_functions.sh || die
	./test.sh || die
	popd > /dev/null || die
}

src_install() {
	dobin bin/duplicacy
	use debug && dostrip -x /usr/bin/duplicacy
	einstalldocs
}
