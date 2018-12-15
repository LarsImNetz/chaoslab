# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Change this when you update the ebuild:
GIT_COMMIT="ac4fff416318bf0915a0ab80e062a99ef3724334"
EGO_PN="github.com/hashicorp/terraform"
EGO_VENDOR=( "golang.org/x/tools 40a48ad93f github.com/golang/tools" )

inherit golang-vcs-snapshot-r1

DESCRIPTION="A tool for building, changing, and combining infrastructure safely/efficiently"
HOMEPAGE="https://www.terraform.io"
ARCHIVE_URI="https://${EGO_PN}/archive/v${PV/_/-}.tar.gz -> ${P}.tar.gz"
SRC_URI="${ARCHIVE_URI} ${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="debug examples fish-completion pie terraform-bundle"

RDEPEND="fish-completion? ( app-shells/fish )"

DOCS=( CHANGELOG.md README.md )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	export PATH="${G}/bin:$PATH"
	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "main.GitCommit=${GIT_COMMIT}"
		-X "version.Prerelease="
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie exe)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
		-o ./bin/terraform
	)
	local mygoargs2=(
		-v -work -x
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "$(usex !debug '-s -w' '')"
	)

	# Build stringer locally
	go build -o "${G}"/bin/stringer ./vendor/golang.org/x/tools/cmd/stringer || die

	emake generate
	go build "${mygoargs[@]}" || die

	if use terraform-bundle; then
		go build "${mygoargs2[@]}" ./tools/terraform-bundle || die
	fi
}

src_install() {
	dobin bin/terraform
	use debug && dostrip -x /usr/bin/terraform
	einstalldocs

	if use terraform-bundle; then
		dobin terraform-bundle
		use debug && dostrip -x /usr/bin/terraform-bundle
		newdoc tools/terraform-bundle/README.md terraform-bundle.md
	fi

	if use examples; then
		docinto examples
		dodoc -r examples/*
		docompress -x "/usr/share/doc/${PF}/examples"
	fi

	if use fish-completion; then
		insinto /usr/share/fish/functions/
		doins contrib/fish-completion/terraform.fish
	fi
}
