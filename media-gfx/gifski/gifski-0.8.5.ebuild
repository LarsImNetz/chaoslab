# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CRATES="
aho-corasick-0.6.8
ansi_term-0.11.0
arrayvec-0.4.7
atty-0.2.11
backtrace-0.3.9
backtrace-sys-0.1.24
bindgen-0.32.3
bitflags-0.9.1
bitflags-1.0.4
cc-1.0.23
cexpr-0.2.3
cfg-if-0.1.5
clang-sys-0.21.2
clap-2.32.0
color_quant-1.0.1
crossbeam-deque-0.2.0
crossbeam-epoch-0.3.1
crossbeam-utils-0.2.2
either-1.5.0
env_logger-0.4.3
error-chain-0.12.0
gif-0.10.0
gif-dispose-2.1.1
glob-0.2.11
imagequant-2.11.9
imagequant-sys-2.12.0
imgref-1.3.5
kernel32-sys-0.2.2
lazy_static-1.1.0
libc-0.2.43
libloading-0.4.3
lodepng-2.4.1
log-0.3.9
log-0.4.4
lzw-0.10.0
memchr-1.0.2
memchr-2.0.2
memoffset-0.2.1
natord-1.0.9
nodrop-0.1.12
nom-3.2.1
num_cpus-1.8.0
openmp-sys-0.1.6
pbr-1.0.1
peeking_take_while-0.1.2
pkg-config-0.3.14
proc-macro2-0.2.3
quote-0.4.2
rand-0.4.2
rayon-1.0.2
rayon-core-1.4.1
redox_syscall-0.1.40
redox_termios-0.1.1
regex-0.2.11
regex-syntax-0.5.6
resize-0.3.0
rgb-0.8.11
rustc-demangle-0.1.9
scopeguard-0.3.3
strsim-0.7.0
termion-1.5.1
textwrap-0.10.0
thread_local-0.3.6
time-0.1.40
ucd-util-0.1.1
unicode-width-0.1.5
unicode-xid-0.1.0
utf8-ranges-1.0.1
vec_map-0.8.1
version_check-0.1.4
which-1.0.5
wild-2.0.0
winapi-0.2.8
winapi-0.3.5
winapi-build-0.1.1
winapi-i686-pc-windows-gnu-0.4.0
winapi-x86_64-pc-windows-gnu-0.4.0
"

inherit cargo

DESCRIPTION="GIF encoder based on libimagequant"
HOMEPAGE="https://gif.ski"
# shellcheck disable=SC2086
SRC_URI="https://github.com/ImageOptim/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
	$(cargo_crate_uris ${CRATES})"
RESTRICT="mirror"

LICENSE="AGPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="openmp video"

RDEPEND="
	media-gfx/libimagequant[openmp?]
	video? ( <media-video/ffmpeg-4 )
"
DEPEND="${RDEPEND}
	video? (
		|| (
			sys-devel/clang:6
			sys-devel/clang:5
		)
	)
"

pkg_setup() {
	# shellcheck disable=SC2086
	if has network-sandbox $FEATURES; then
		ewarn ""
		ewarn "${CATEGORY}/${PN} requires 'network-sandbox' to be disabled in FEATURES"
		ewarn ""
		die "[network-sandbox] is enabled in FEATURES"
	fi
}

src_compile() {
	# shellcheck disable=SC2153
	export CARGO_HOME="${ECARGO_HOME}"

	# shellcheck disable=SC2207
	# build up optional flags
	local options=(
		$(usex video 'video' '')
		$(usex openmp 'openmp' '')
	)

	local LIBCLANG_PATH
	if use video; then
		if has_version '>sys-devel/clang-5'; then
			LIBCLANG_PATH="/usr/lib/llvm/6/$(get_libdir)"
		else
			LIBCLANG_PATH="/usr/lib/llvm/5/$(get_libdir)"
		fi
	fi

	LIBCLANG_PATH="${LIBCLANG_PATH}" \
	cargo build -v "$(usex debug '' --release)" \
		--features "${options[*]}" || die
}

src_install() {
	dobin target/release/gifski
}
