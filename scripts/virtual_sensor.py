# scripts/virtual_sensor.py

import time
import random
import datetime
import firebase_admin
from firebase_admin import credentials, firestore, messaging

# --- Setup Awal ---
cred = credentials.Certificate("scripts/service-account-key.json")
firebase_admin.initialize_app(cred)
db = firestore.client()
print("✅ Sensor Virtual Python Siap...")

# Variabel untuk mencegah spam notifikasi
# Menyimpan status apakah notifikasi bahaya sudah dikirim
alert_sent = False

# --- Loop Utama ---
while True:
    try:
        ntu_value = 0.0
        # Hasilkan nilai acak, dengan kemungkinan lebih tinggi untuk nilai berbahaya
        chance = random.randint(0, 15)
        if chance < 8:
            ntu_value = 5 + random.random() * 25  # Ideal
        elif chance < 12:
            ntu_value = 30 + random.random() * 30 # Waspada
        else:
            ntu_value = 100 + random.random() * 60 # Bahaya & Sangat Bahaya

        timestamp = datetime.datetime.now(datetime.timezone.utc)
        print(f"Mengirim data... NTU: {ntu_value:.1f}")

        # --- Kirim Data ke Firestore ---
        device_ref = db.collection('device_status').document('kolam_01')
        history_ref = db.collection('turbidity_history')

        history_ref.add({'ntu': ntu_value, 'timestamp': timestamp})
        device_ref.update({
            'ntu': ntu_value,
            'lastSeen': timestamp,
            'status': 'Online'
        })
        
        # --- Logika Pengecekan Notifikasi ---
        # Ambil status 'notificationsEnabled' dan 'fcmToken' dari database
        doc = device_ref.get()
        if doc.exists:
            data = doc.to_dict()
            notifications_enabled = data.get('notificationsEnabled', False)
            fcm_token = data.get('fcmToken')

            # Kondisi untuk mengirim notifikasi
            if ntu_value > 100 and notifications_enabled and fcm_token and not alert_sent:
                print(f"⚠️  Kondisi Sangat Bahaya ({ntu_value:.1f} NTU). Mengirim notifikasi...")
                
                message = messaging.Message(
                    notification=messaging.Notification(
                        title='🚨 Peringatan Kekeruhan!',
                        body=f'Tingkat kekeruhan air mencapai {ntu_value:.1f} NTU. Segera periksa kondisi kolam.'
                    ),
                    token=fcm_token,
                )
                
                # Kirim pesan
                messaging.send(message)
                print("✅  Notifikasi berhasil dikirim.")
                alert_sent = True # Tandai bahwa notif sudah dikirim

            # Reset status pengiriman notif jika kondisi kembali aman
            elif ntu_value < 100 and alert_sent:
                print("✅  Kondisi kembali aman. Notifikasi direset.")
                alert_sent = False

        time.sleep(5)

    except KeyboardInterrupt:
        print("\nSensor virtual dihentikan.")
        break
    except Exception as e:
        print(f"\nTerjadi error: {e}")
        break