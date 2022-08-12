package com.Ls.skipBle.protocol;

public class HexUtil {

    private static final char[] DIGITS_LOWER = {'0', '1', '2', '3', '4', '5',
            '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};

    private static final char[] DIGITS_UPPER = {'0', '1', '2', '3', '4', '5',
            '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};

    public static char[] encodeHex(byte[] data) {
        return encodeHex(data, true);
    }

    public static char[] encodeHex(byte[] data, boolean toLowerCase) {
        return encodeHex(data, toLowerCase ? DIGITS_LOWER : DIGITS_UPPER);
    }

    protected static char[] encodeHex(byte[] data, char[] toDigits) {
        if (data == null)
            return null;
        int l = data.length;
        char[] out = new char[l << 1];
        for (int i = 0, j = 0; i < l; i++) {
            out[j++] = toDigits[(0xF0 & data[i]) >>> 4];
            out[j++] = toDigits[0x0F & data[i]];
        }
        return out;
    }


    public static String encodeHexStr(byte[] data) {
        return encodeHexStr(data, true);
    }

    public static String encodeHexStr(byte[] data, boolean toLowerCase) {
        return encodeHexStr(data, toLowerCase ? DIGITS_LOWER : DIGITS_UPPER);
    }


    protected static String encodeHexStr(byte[] data, char[] toDigits) {
        return new String(encodeHex(data, toDigits));
    }

    public static String formatHexString(byte[] data) {
        return formatHexString(data, false);
    }

    public static String formatHexString(byte[] data, boolean addSpace) {
        if (data == null || data.length < 1)
            return null;
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < data.length; i++) {
            String hex = Integer.toHexString(data[i] & 0xFF);
            if (hex.length() == 1) {
                hex = '0' + hex;
            }
            sb.append(hex);
            if (addSpace)
                sb.append(" ");
        }
        return sb.toString().trim();
    }

    public static byte[] decodeHex(char[] data) {

        int len = data.length;

        if ((len & 0x01) != 0) {
            throw new RuntimeException("Odd number of characters.");
        }

        byte[] out = new byte[len >> 1];

        // two characters form the hex value.
        for (int i = 0, j = 0; j < len; i++) {
            int f = toDigit(data[j], j) << 4;
            j++;
            f = f | toDigit(data[j], j);
            j++;
            out[i] = (byte) (f & 0xFF);
        }

        return out;
    }


    protected static int toDigit(char ch, int index) {
        int digit = Character.digit(ch, 16);
        if (digit == -1) {
            throw new RuntimeException("Illegal hexadecimal character " + ch
                    + " at index " + index);
        }
        return digit;
    }


    public static byte[] hexStringToBytes(String hexString) {
        if (hexString == null || hexString.equals("")) {
            return null;
        }
        hexString = hexString.trim();
        hexString = hexString.toUpperCase();
        int length = hexString.length() / 2;
        char[] hexChars = hexString.toCharArray();
        byte[] d = new byte[length];
        for (int i = 0; i < length; i++) {
            int pos = i * 2;
            d[i] = (byte) (charToByte(hexChars[pos]) << 4 | charToByte(hexChars[pos + 1]));
        }
        return d;
    }

    public static byte charToByte(char c) {
        return (byte) "0123456789ABCDEF".indexOf(c);
    }

    public static String extractData(byte[] data, int position) {
        return HexUtil.formatHexString(new byte[]{data[position]});
    }

    public static String byteToAsciiString(byte[] data) {
        return new String(data);
    }

    public static int unicodeToUTF8(int unicode) {
        if (unicode >= 0x00000000 && unicode <= 0x0000007F) {
            return unicode;
        }
        else if (unicode >= 0x00000080 && unicode <= 0x000007FF) {
            int r1 = (((unicode & 0x7C0) >> 6) | 0xC0) << 8;
            int r2 = (unicode & 0x03F) | 0x80;
            return r1 | r2;
        }
        else if (unicode >= 0x00000800 && unicode <= 0x0000FFFF) {
            int r1 = (((unicode & 0xF000) >> 12) | 0xE0) << 16;
            int r2 = (((unicode & 0x0FC0) >> 6) | 0x80) << 8;
            int r3 = ((unicode & 0x003F) | 0x80);
            return r1 | r2 | r3;
        }
        else if (unicode >= 0x00010000 && unicode <= 0x0010FFFF) {
            int r1 = (((unicode & 0x1C0000) >> 18) | 0xE0) << 24;
            int r2 = (((unicode & 0x03F000) >> 12) | 0x80) << 16;
            int r3 = (((unicode & 0x000FC0) >> 6) | 0x80) << 8;
            int r4 = ((unicode & 0x00003F) | 0x80);
            return r1 | r2 | r3 | r4;
        }
        else {
            return 0;
        }
    }



    public static String Utf8ToUnicode(byte[] strUtf8) {
        int Unic;
        int b1, b2, b3, b4, b5, b6;
        String str = new String();

        for (int i = 0; i < strUtf8.length; i++) {
            int size = GetUtf8Size(strUtf8[i]);
            if (size == 1) {
                Unic = strUtf8[i];
                str += (char) Unic;
            }
            if (size == 2) {
                b1 = ( strUtf8[i] & 0xff );
                b2 = ( strUtf8[i + 1] & 0xff );
                if ((b2 & 0xC0) != 0x80)
                    return "";
                int s1 = (b1 << 6) + (b2 & 0x3F);
                int s2 = (b1 >> 2) & 0x07;
                Unic = ((s2 & 0xFF) << 8) + (s1 & 0xFF);
                i += size - 1;
                str += (char) Unic;
            }
            if (size == 3) {
                b1 = ( strUtf8[i] & 0xff );
                b2 = ( strUtf8[i + 1] & 0xff );
                b3 = ( strUtf8[i + 2] & 0xff );
                if (((b2 & 0xC0) != 0x80) || ((b3 & 0xC0) != 0x80))
                    return "";
                int s1 = (b2 << 6) + (b3 & 0x3F);
                int s2 = (b1 << 4) + ((b2 >> 2) & 0x0F);
                Unic = ((s2 & 0xFF) << 8) + (s1 & 0xFF);
                i += size - 1;
                str += (char) Unic;
            }
            if (size == 4) {
                b1 = ( strUtf8[i] & 0xff );
                b2 = ( strUtf8[i + 1] & 0xff );
                b3 = ( strUtf8[i + 2] & 0xff );
                b4 = ( strUtf8[i + 3] & 0xff );
                if (((b2 & 0xC0) != 0x80) || ((b3 & 0xC0) != 0x80)
                        || ((b4 & 0xC0) != 0x80)) {
                    return "";
                }

                int s1 = (b3 << 6) + (b4 & 0x3F);
                int s2 = (b2 << 4) + ((b3 >> 2) & 0x0F);
                int s3 = ((b1 << 2) & 0x1C) + ((b2 >> 4) & 0x03);
                Unic = ((s3 & 0xFF) << 16) + ((s2 & 0xFF) << 8) + (s1 & 0xFF);
                i += size - 1;
                str += (char) Unic;
            }
            if (size == 5) {
                b1 = ( strUtf8[i] & 0xff );
                b2 = ( strUtf8[i + 1] & 0xff );
                b3 = ( strUtf8[i + 2] & 0xff );
                b4 = ( strUtf8[i + 3] & 0xff );
                b5 = ( strUtf8[i + 4] & 0xff );
                if (((b2 & 0xC0) != 0x80) || ((b3 & 0xC0) != 0x80)
                        || ((b4 & 0xC0) != 0x80) || ((b5 & 0xC0) != 0x80))
                    return "";
                int s1 = (b4 << 6) + (b5 & 0x3F);
                int s2 = (b3 << 4) + ((b4 >> 2) & 0x0F);
                int s3 = (b2 << 2) + ((b3 >> 4) & 0x03);
                int s4 = (b1 << 6);
                Unic = ((s4 & 0xFF) << 24) + ((s3 & 0xFF) << 16) + ((s2 & 0xFF) << 8) + (s1 & 0xFF);
                i += size - 1;
                str += (char) Unic;
            }
            if (size == 6) {
                b1 = ( strUtf8[i] & 0xff );
                b2 = ( strUtf8[i + 1] & 0xff );
                b3 = ( strUtf8[i + 2] & 0xff );
                b4 = ( strUtf8[i + 3] & 0xff );
                b5 = ( strUtf8[i + 4] & 0xff );
                b6 = ( strUtf8[i + 5] & 0xff );
                if (((b2 & 0xC0) != 0x80) || ((b3 & 0xC0) != 0x80)
                        || ((b4 & 0xC0) != 0x80) || ((b5 & 0xC0) != 0x80)
                        || ((b6 & 0xC0) != 0x80))
                    return "";
                int s1 = (b5 << 6) + (b6 & 0x3F);
                int s2 = (b5 << 4) + ((b6 >> 2) & 0x0F);
                int s3 = (b3 << 2) + ((b4 >> 4) & 0x03);
                int s4 = ((b1 << 6) & 0x40) + (b2 & 0x3F);
                Unic = ((s4 & 0xFF) << 24) + ((s3 & 0xFF) << 16) + ((s2 & 0xFF) << 8) + (s1 & 0xFF);
                i += size - 1;
                str += (char) Unic;
            }
        }
        return str;
    }

    private static int GetUtf8Size(byte utf8Data) {
        if (( utf8Data & 0xff ) < 0x80) return 1;
        if (( utf8Data & 0xff ) >= 0x80 && ( utf8Data & 0xff ) < 0xC0) return 0;
        if (( utf8Data & 0xff ) >= 0xC0 && ( utf8Data & 0xff ) < 0xE0) return 2;
        if (( utf8Data & 0xff ) >= 0xE0 && ( utf8Data & 0xff ) < 0xF0) return 3;
        if (( utf8Data & 0xff ) >= 0xF0 && ( utf8Data & 0xff ) < 0xF8) return 4;
        if (( utf8Data & 0xff ) >= 0xF8 && ( utf8Data & 0xff ) < 0xFC) return 5;
        if (( utf8Data & 0xff ) >= 0xFC) return 6;

        return 0;
    }
}
