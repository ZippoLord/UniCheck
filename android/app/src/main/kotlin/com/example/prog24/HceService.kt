import android.nfc.cardemulation.HostApduService
import android.os.Bundle
import android.content.Context
import android.content.SharedPreferences

class MyHostApduService : HostApduService() {
    private val PREF = "hce_prefs"
    private val KEY_JSON = "emulated_json"

    private fun getEmulatedJson(): ByteArray {
        val prefs = getSharedPreferences(PREF, Context.MODE_PRIVATE)
        val json = prefs.getString(KEY_JSON, "") ?: ""
        return json.toByteArray(Charsets.UTF_8)
    }

    override fun processCommandApdu(commandApdu: ByteArray?, extras: Bundle?): ByteArray {
        if (commandApdu == null) return UNKNOWN

        // Minimal APDU parsing
        val cla = commandApdu[0].toInt() and 0xFF
        val ins = commandApdu[1].toInt() and 0xFF
        val p1 = commandApdu[2].toInt() and 0xFF
        val p2 = commandApdu[3].toInt() and 0xFF

        // SELECT (00 A4 04 00 ...) - egyszerű SELECT detektálás: INS == 0xA4
        if (ins == 0xA4) {
            // visszaadunk csak success status
            return SW_OK
        }

        // GET_CHUNK - saját INS = 0x10
        if (ins == 0x10) {
            // adat mező: offset_hi offset_lo length
            // feltételezzük Lc=3 és ezek a bájtok a commandApdu végén
            val lcIndex = 4
            val lc = commandApdu.size - 5 // nem mindig pontos; egyszerűbb: ha legalább 3 adat van
            if (commandApdu.size >= 8) {
                val offsetHi = commandApdu[5].toInt() and 0xFF
                val offsetLo = commandApdu[6].toInt() and 0xFF
                val length = commandApdu[7].toInt() and 0xFF
                val offset = (offsetHi shl 8) or offsetLo

                val jsonBytes = getEmulatedJson()
                if (offset >= jsonBytes.size) {
                    return SW_FILE_NOT_FOUND // vagy 6A 86
                }
                val end = minOf(jsonBytes.size, offset + length)
                val chunk = jsonBytes.copyOfRange(offset, end)
                return chunk + SW_OK
            } else {
                return SW_WRONG_LENGTH
            }
        }

        // default
        return SW_FILE_NOT_FOUND
    }

    override fun onDeactivated(reason: Int) {
        // nincs teendő
    }

    companion object {
        val SW_OK = byteArrayOf(0x90.toByte(), 0x00.toByte())
        val SW_FILE_NOT_FOUND = byteArrayOf(0x6A.toByte(), 0x82.toByte())
        val SW_WRONG_LENGTH = byteArrayOf(0x67.toByte(), 0x00.toByte())
        val UNKNOWN = byteArrayOf(0x6F.toByte(), 0x00.toByte())
    }
}
