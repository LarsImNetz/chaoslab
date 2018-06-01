# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/gilbertchen/${PN}"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
# Deps that are not needed:
# github.com/gilbertchen/go-ole 0e87ea77
# google.golang.org/appengine 150dc57
EGO_VENDOR=(
	"cloud.google.com/go 2d3a665 github.com/GoogleCloudPlatform/gcloud-golang"
	"github.com/Azure/azure-sdk-for-go b7fadeb"
	"github.com/Azure/go-autorest 0ae36a9"
	"github.com/aryann/difflib e206f87"
	"github.com/aws/aws-sdk-go a32b1dc"
	"github.com/bkaradzic/go-lz4 74ddf82"
	"github.com/dgrijalva/jwt-go dbeaa93"
	"github.com/gilbertchen/azure-sdk-for-go bbf89bd"
	"github.com/gilbertchen/cli 1de0a18"
	"github.com/gilbertchen/go-dropbox 90711b6"
	"github.com/gilbertchen/go.dbus 9e442e6"
	"github.com/gilbertchen/goamz eada9f"
	"github.com/gilbertchen/gopass bf9dde6"
	"github.com/gilbertchen/keyring 8855f56"
	"github.com/gilbertchen/xattr 68e7a68"
	"github.com/go-ini/ini 32e4c1e"
	"github.com/golang/protobuf 1e59b77"
	"github.com/googleapis/gax-go 317e000"
	"github.com/jmespath/go-jmespath 0b12d6b"
	"github.com/kr/fs 2788f0d"
	"github.com/marstr/guid 8bd9a64"
	"github.com/minio/blake2b-simd 3f5f724"
	"github.com/ncw/swift ae9f0ea"
	"github.com/pkg/errors 645ef00"
	"github.com/pkg/sftp 98203f5"
	"github.com/satori/go.uuid f58768c"
	"github.com/vaughan0/go-ini a98ad7e"
	"golang.org/x/crypto 9f005a0 github.com/golang/crypto"
	"golang.org/x/net 9dfe398 github.com/golang/net"
	"golang.org/x/oauth2 f95fa95 github.com/golang/oauth2"
	"golang.org/x/sys 82aafbf github.com/golang/sys"
	"golang.org/x/text 88f656f github.com/golang/text"
	"google.golang.org/api 17b5f22 github.com/google/google-api-go-client"
	"google.golang.org/genproto 891aceb github.com/google/go-genproto"
	"google.golang.org/grpc 5a9f7b4 github.com/grpc/grpc-go"
)

inherit golang-vcs-snapshot

DESCRIPTION="A new generation cloud backup tool"
HOMEPAGE="https://duplicacy.com"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="duplicacy"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="pie"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/duplicacy"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	# shellcheck disable=SC2207
	local mygoargs=(
		-v -work -x
		$(usex pie '-buildmode=pie' '')
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w"
		-o bin/duplicacy
	)
	go build "${mygoargs[@]}" ./duplicacy || die
}

src_test() {
	local PATH="${S}/bin:$PATH"
	pushd integration_tests || die
	sed -i "s:DUPLICACY=.*:DUPLICACY=duplicacy:" \
		./test_functions.sh || die
	./test.sh || die
	popd || die
}

src_install() {
	dobin bin/duplicacy
	einstalldocs
}
