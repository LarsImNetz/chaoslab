# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

BOOTSTRAP_DIST="https://dev.gentoo.org/~williamh/dist"
BOOTSTRAP_VERSION="bootstrap-1.8"
BOOTSTRAP_URI="
	amd64? ( ${BOOTSTRAP_DIST}/go-linux-amd64-${BOOTSTRAP_VERSION}.tbz )
	x86? ( ${BOOTSTRAP_DIST}/go-linux-386-${BOOTSTRAP_VERSION}.tbz )
"

MY_PV=${PV/_/}
DESCRIPTION="A concurrent garbage collected and typesafe programming language"
HOMEPAGE="https://golang.org"
ARCHIVE_URI="https://storage.googleapis.com/golang/go${MY_PV}.src.tar.gz -> ${P}.tar.gz"
SRC_URI="${ARCHIVE_URI} ${BOOTSTRAP_URI}"

# Stripping is unsupported upstream and may fail
# The upstream tests fail under portage but pass if the build is
# run according to their documentation (https://golang.org/issues/18442).
RESTRICT="mirror strip test"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="-* ~amd64 ~x86"
IUSE="default-buildmode-pie"

# These test data objects have writable/executable stacks
QA_EXECSTACK="
	usr/lib/go/src/debug/elf/testdata/*.obj
	usr/lib/go/src/go/internal/gccgoimporter/testdata/escapeinfo.gox
	usr/lib/go/src/go/internal/gccgoimporter/testdata/unicode.gox
	usr/lib/go/src/go/internal/gccgoimporter/testdata/time.gox
"

# Do not complain about CFLAGS, etc, since Go doesn't use them
QA_FLAGS_IGNORED='.*'

REQUIRES_EXCLUDE="/usr/lib/go/src/debug/elf/testdata/*"

# The tools in /usr/lib/go should not cause the multilib-strict check to fail
QA_MULTILIB_PATHS="usr/lib/go/pkg/tool/.*/.*"

DOCS=( AUTHORS CONTRIBUTORS PATENTS README.md )

S="${WORKDIR}"/go

src_prepare() {
	use default-buildmode-pie && eapply "${FILESDIR}/${PN}-buildmode-pie.patch"
	default
}

src_compile() {
	case "$(tc-arch)" in
		x86) export GOARCH=386 ;;
		x64-*) export GOARCH=amd64 ;;
	esac

	export GOROOT_BOOTSTRAP="${WORKDIR}"/go-linux-${GOARCH}-bootstrap
	export GOROOT_FINAL="${EPREFIX}"/usr/lib/go
	export GOROOT="${S}"
	export GOBIN="${GOROOT}/bin"
	export GOOS=linux

	einfo "GOROOT_BOOTSTRAP is ${GOROOT_BOOTSTRAP}"

	pushd src > /dev/null || die
	./make.bash --no-clean -v || die "build failed"

	PATH="${GOBIN}:${PATH}" go install -v -buildmode=shared std || die
	PATH="${GOBIN}:${PATH}" go install -v -race std || die
	popd > /dev/null || die
}

src_test() {
	export GO_TEST_TIMEOUT_SCALE=2

	pushd src > /dev/null || die
	PATH="${GOBIN}:${PATH}" \
	./run.bash --no-rebuild -v -v -v -k  || die "tests failed"
	popd > /dev/null || die
}

src_install() {
	insinto /usr/lib/go
	doins VERSION

	# There is a known issue which requires the source tree to be installed [1].
	# Once this is fixed, we can consider using the doc use flag to control
	# installing the doc and src directories.
	# [1] https://golang.org/issue/2775
	#
	# deliberately use cp to retain permissions
	cp -R api bin doc lib pkg misc src "${ED}"/usr/lib/go || die

	local f x
	for x in bin/*; do
		f=${x##*/}
		dosym "../lib/go/bin/${f}" "/usr/bin/${f}"
	done

	rm -r \
		"${ED}"/usr/lib/go/pkg/bootstrap \
		"${ED}"/usr/lib/go/pkg/tool/*/api \
		"${ED}"/usr/lib/go/pkg/obj/go-build/* || die

	einstalldocs
}
