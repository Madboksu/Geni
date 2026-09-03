extends Node

var player_name: String = "Banyu"
var active_save_slot: int = 0  # 0 = belum pilih slot

# Story text data
const WORLD_PREMISE: String = """Dahulu, wilayah Desa Wana Asri merupakan daerah hijau yang dikelilingi hutan hujan lebat. Masyarakat hidup tentram dari hasil pertanian dan ladang. Sungai mengalir jernih, dan hutan menjadi pelindung alami desa.

Namun, dalam beberapa tahun terakhir, pemerintah daerah mulai menjalankan proyek ekspansi industri skala besar. Hutan dibabat untuk tambang dan perkebunan. Untuk mempercepat pembersihan lahan tanpa biaya mahal, sebagian besar wilayah hutan sengaja dibakar secara rahasia.

Kepada publik, pemerintah mengklaim bahwa kebakaran tersebut adalah 'bencana alam tak terkendali'. Namun kenyataannya, kebakaran itu adalah kejahatan terencana demi kepentingan bisnis pembakar lahan."""

const PROLOGUE_DIALOGUES: Array = [
	{
		"speaker": "Narator",
		"text": "Malam itu, warna langit berubah menjadi merah membara. Angin kencang bertiup membawa hawa panas yang menyengat..."
	},
	{
		"speaker": "Narator",
		"text": "Api dengan cepat merambat dari perbatasan hutan industri ke pemukiman warga. Suara jeritan dan gemuruh kayu terbakar memecah keheningan malam."
	},
	{
		"speaker": "{PLAYER_NAME}",
		"text": "Ayah... Ibu... Kalian di mana?! Rumah kita terbakar!"
	},
	{
		"speaker": "Narator",
		"text": "Dalam kepungan asap tebal, {PLAYER_NAME} berlari menerobos kobaran api kembali ke rumahnya. Namun yang tersisa hanyalah puing-puing abu yang hangus."
	},
	{
		"speaker": "{PLAYER_NAME}",
		"text": "Tidak ada seorang pun yang tersisa... Hanya abu dan liontin pelindung rimba ini..."
	},
	{
		"speaker": "{PLAYER_NAME}",
		"text": "Aku tidak tahu harus berbuat apa dan ke mana aku harus pergi... Tapi api ini tidak muncul secara alami. Seseorang sengaja membakar rumahku!"
	},
	{
		"speaker": "{PLAYER_NAME}",
		"text": "Aku bersumpah akan menggunakan kekuatan rahasia Reaksi Berantai elemen ini untuk padamkan api mereka dan membongkar kebenaran!"
	}
]

const ACT_1_INTRO: String = """ACT 1: Lost On The Fire (Hilang Dalam Lalapan Api)

{PLAYER_NAME} melangkah menyusuri sisa rimba Wana Asri yang terbakar. Asap tebal menutupi pandangan, dan monster-monster elemen api yang marah berkeliaran di sepanjang jalan.

Gunakan kartu Primer [Douse] dan [Cooling Mud] untuk menanamkan status [Wet] atau [Muddy] pada musuh, lalu picu ledakan Reaksi Berantai menggunakan kartu Igniter seperti [Gale Wind] dan [Thunder Strike]!"""

const ACT_1_OUTRO: String = """Kemenangan Act 1!

Dengan tumbangnya Ember Beast (Wira Api), asap di perbatasan hutan mulai reda. Di antara sisa-sisa reruntuhan markas pengawal, {PLAYER_NAME} menemukan dokumen rahasia bertanda tangan 'Eksekutif Utama PT Ignis Resources'.

Dokumen itu membuktikan bahwa pembakaran hutan diproduksi secara massal dari fasilitas industri pusat. Tujuan selanjutnya sudah jelas: Menuju Fasilitas Pusat Pembakaran!"""

const ACT_2_INTRO: String = """ACT 2: Hunt the Flame (Mengejar Sang Pembakar)

{PLAYER_NAME} menerobos benteng pertahanan korporasi. Medan perang semakin ganas dengan pengawal elit dan pasukan penyemprot api mekanis.

Manfaatkan seluruh kombinasi kartu Reaksi Berantai dan kartu Ultimate [Drought's End] untuk menghentikan kejahatan mereka!"""

const ACT_2_OUTRO: String = """Tamat — Hujan Penyejuk Rimba

Chief Executive Ignis berlutut saat Reaksi Berantai elemen terbesar memadamkan tungku pembakaran utama!

Dokumen kejahatan korporasi berhasil disebarkan ke seluruh pelosok negeri. Api di Wana Asri akhirnya padam total. Dari balik tanah hitam abu, tunas-tunas hijau baru mulai bermunculan kembali. {PLAYER_NAME} berdiri menatap terbitnya matahari baru di rimba yang mulai pulih."""
