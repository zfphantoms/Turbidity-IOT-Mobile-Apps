// functions/index.js

const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Inisialisasi Firebase Admin SDK
admin.initializeApp();

/**
 * Cloud Function ini akan terpicu (trigger) setiap kali ada
 * pembaruan pada dokumen di dalam koleksi 'device_status'.
 */
exports.logTurbidityHistory = functions.firestore
  .document("device_status/{deviceId}")
  .onUpdate((change, context) => {
    // Ambil data baru setelah di-update
    const newData = change.after.data();
    // Ambil data lama sebelum di-update untuk perbandingan
    const oldData = change.before.data();

    // PENTING: Cek apakah nilai 'ntu' benar-benar berubah.
    // Ini untuk mencegah fungsi berjalan jika hanya field lain yang berubah.
    if (newData.ntu === oldData.ntu) {
      console.log("Nilai NTU tidak berubah, riwayat tidak dicatat.");
      return null; // Hentikan fungsi
    }

    const deviceId = context.params.deviceId;
    console.log(`Terdeteksi perubahan NTU untuk perangkat: ${deviceId}`);

    // Siapkan data yang akan disimpan ke koleksi riwayat
    const historyData = {
      ntu: newData.ntu,
      timestamp: newData.lastSeen, // Gunakan timestamp dari data yang diupdate
    };

    // Tambahkan dokumen baru ke koleksi 'turbidity_history'
    return admin.firestore().collection("turbidity_history").add(historyData)
      .then(() => {
        console.log(`Riwayat berhasil dicatat: NTU = ${newData.ntu}`);
        return null; // Sukses
      })
      .catch((error) => {
        console.error("Gagal mencatat riwayat:", error);
        return null; // Gagal
      });
  });