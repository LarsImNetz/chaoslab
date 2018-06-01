# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

SQUASH_DEP=(
	"plugins/brieflz/brieflz jibsen/brieflz 63760a061c5ac8a70aba4ed25a2b2efec650eade"
	"plugins/bsc/libbsc IlyaGrebnov/libbsc 3dea3471251fbac72c895f42f22a1aa75b81da33"
	"plugins/csc/csc fusiyuan2010/CSC c5dbe0944d07acbc97d2c04ec9f99a139c6f3931"
	"plugins/density/density centaurean/density a05d383c58471f57904c17fd39b3f76fb5bc674d"
	"plugins/doboz/doboz nemequ/doboz d03e0f9c1d66ec34d68c439b410ac7f0b1935bd5"
	"plugins/fari/FastARI davidcatt/FastARI e1e87aad2bb5d45d14502e2b54802c61950a6166"
	"plugins/fastlz/fastlz svn2github/fastlz 9ed1867d81a18cbda42805e7238e2dd5997dedfc"
	"plugins/gipfeli/gipfeli google/gipfeli 04fe241e27f6dcfef239afc6c5e3cee0b4d7c333"
	"plugins/heatshrink/heatshrink atomicobject/heatshrink 7d419e1fa4830d0b919b9b6a91fe2fb786cf3280"
	"plugins/libdeflate/libdeflate ebiggers/libdeflate a32bdb097de48e5ddffc959a58297d384b58fcaa"
	"plugins/lzf/liblzf nemequ/liblzf fb25820c3c0aeafd127956ae6c115063b47e459a"
	"plugins/lzfse/lzfse lzfse/lzfse 497c5c176732769abf36ccc71a31c06bad93a84d"
	"plugins/lzg/liblzg mbitsnbites/liblzg 035f0aad8e645d449389fe17c757e38f54b4d995"
	"plugins/lzham/lzham richgel999/lzham_codec_devel 7f1bb9223abfad330797e436254df738c7f52551"
	"plugins/lzjb/lzjb nemequ/lzjb 4544a180ed2ecfed8228d580253fbeaaae1fd2b4"
	"plugins/miniz/miniz richgel999/miniz 28f5066e332590c8a68fa4870e89233e72ce7a44"
	"plugins/ms-compress/ms-compress coderforlife/ms-compress e5d8cc5f4396be26c2c3ccc13fe59ce3a8885fea"
	"plugins/wflz/wflz ShaneYCG/wflz e742c4bad7b3427fb3eeb1fc5af361af9d517a66"
	"plugins/zlib-ng/zlib-ng Dead2/zlib-ng 45a5149c6a8309c83ea81bce95279a41f31c730c"
	"plugins/zling/libzling richox/libzling 40ec9ee83abde8ca0539b6f31bf5961cd38f7c66"
	"plugins/zpaq/zpaq zpaq/zpaq 9ab539f644e364f0d92e2918b90ce2534c75653f"
	"squash/hedley nemequ/hedley 5ea407f445de331cbf7e4636857078fc3cd15994"
	"squash/tinycthread tinycthread/tinycthread 6957fc8383d6c7db25b60b8c849b29caab1caaee"
	"squash/win-iconv win-iconv/win-iconv 9f98392dfecadffd62572e73e9aba878e03496c4"
	"tests/munit nemequ/munit 389aef009e8773a030939bd4fc3cc0af6f865ea1"
	"utils/parg jibsen/parg 97f3a075109ebace4f660fb341c6b99b2a4b092a"
)

YALZ_PV="6810061c57dd"
YALZ_P="tkatchev-yalz77-${YALZ_PV}"
GIT_COMMIT="bcf1acf1661ead91d9201f4b2a6616a884cebbef"

DESCRIPTION="Compression abstraction library and utilities"
HOMEPAGE="https://quixdb.github.io/squash/"
SRC_URI="https://github.com/quixdb/${PN}/archive/${GIT_COMMIT}.tar.gz -> ${P}.tar.gz
	https://bitbucket.org/tkatchev/yalz77/get/${YALZ_PV}.tar.gz -> ${YALZ_P}.tar.gz"
# shellcheck disable=SC2206
for sd in "${SQUASH_DEP[@]}"; do
	sd=(${sd})
	SRC_URI="${SRC_URI} https://github.com/${sd[1]}/archive/${sd[2]}.tar.gz -> ${sd[1]#*/}-${sd[2]}.tar.gz"
done
unset sd
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="app-arch/brotli
	app-arch/lz4
	app-arch/lzop
	app-arch/snappy
	app-arch/xz-utils
	app-arch/zstd
	dev-util/ragel"
RDEPEND="${DEPEND}"

DOCS=( AUTHORS NEWS README )

S="${WORKDIR}/${PN}-${GIT_COMMIT}"

src_prepare() {
	local sd
	# shellcheck disable=SC2206
	for sd in "${SQUASH_DEP[@]}"; do
		sd=(${sd})
		rmdir "${sd[0]}" || die
		mv "${WORKDIR}/${sd[1]#*/}-${sd[2]}" "${sd[0]}" || die
	done

	rmdir plugins/yalz77/yalz77 || die
	mv "${WORKDIR}/${YALZ_P}" plugins/yalz77/yalz77 || die

	cmake-utils_src_prepare
}
