import 'package:flutter/material.dart';

const Map<String, String> trashCategoryMap = {
  // Model baru
  'Organik': 'Organik',
  'Anorganik': 'Anorganik',
  'B3': 'B3',

  // Model Lama — Anorganik
  'bottle': 'Anorganik',
  'wine glass': 'Anorganik',
  'cup': 'Anorganik',
  'bowl': 'Anorganik',
  'vase': 'Anorganik',
  'fork': 'Anorganik',
  'knife': 'Anorganik',
  'spoon': 'Anorganik',
  'scissors': 'Anorganik',
  'clock': 'Anorganik',
  'umbrella': 'Anorganik',
  'suitcase': 'Anorganik',
  'backpack': 'Anorganik',
  'handbag': 'Anorganik',
  'tie': 'Anorganik',
  'skis': 'Anorganik',
  'snowboard': 'Anorganik',
  'baseball bat': 'Anorganik',
  'baseball glove': 'Anorganik',
  'tennis racket': 'Anorganik',
  'skateboard': 'Anorganik',
  'surfboard': 'Anorganik',
  'kite': 'Anorganik',
  'frisbee': 'Anorganik',
  'sports ball': 'Anorganik',
  'book': 'Anorganik',
  'teddy bear': 'Anorganik',

  // Model Lama — B3
  'cell phone': 'B3',
  'laptop': 'B3',
  'keyboard': 'B3',
  'mouse': 'B3',
  'remote': 'B3',
  'tv': 'B3',
  'hair drier': 'B3',
  'fan': 'B3',
  'battery': 'B3',
  'batteries': 'B3',

  // Model Lama — Organik
  'banana': 'Organik',
  'apple': 'Organik',
  'sandwich': 'Organik',
  'tomato': 'Organik',
  'cucumber': 'Organik',
  'orange': 'Organik',
  'flower': 'Organik',
  'broccoli': 'Organik',
  'carrot': 'Organik',
  'hot dog': 'Organik',
  'pizza': 'Organik',
  'donut': 'Organik',
  'cake': 'Organik',
  'plant': 'Organik',
  'potted plant': 'Organik',

  // Model Baru — label spesifik
  'cardboard': 'Anorganik',
  'glass': 'Anorganik',
  'metal': 'Anorganik',
  'paper': 'Anorganik',
  'plastic': 'Anorganik',
  'tissue': 'Anorganik',
  'napkin': 'Anorganik',
  'can': 'Anorganik',
  'straw': 'Anorganik',
  'styrofoam': 'Anorganik',
  'glass bottle': 'Anorganik',
  'plastic bottle': 'Anorganik',
  'plastic cup': 'Anorganik',
  'junk food wrapper': 'Anorganik',
  'crumpled paper': 'Anorganik',
  'biodegradable': 'Organik',
  'leaves': 'Organik',
  'stick': 'Organik',
  'diaper': 'B3',
  'syringe': 'B3',
};

// Label yang jelas bukan sampah
const Set<String> nonTrashLabels = {
  'person', 'bicycle', 'car', 'motorcycle', 'airplane', 'bus', 'train',
  'truck', 'boat', 'traffic light', 'fire hydrant', 'stop sign',
  'parking meter', 'bench', 'bird', 'cat', 'dog', 'horse', 'sheep',
  'cow', 'elephant', 'bear', 'zebra', 'giraffe',
  'toilet', 'sink', 'refrigerator', 'oven', 'microwave', 'toaster',
  'dining table', 'chair', 'couch', 'bed',
};

bool isTrashLabel(String label) {
  // Model baru selalu lolos filter
  if (label == 'Organik' || label == 'Anorganik' || label == 'B3') {
    return true;
  }
  return !nonTrashLabels.contains(label.toLowerCase());
}

String getCategory(String label) {
  // Model baru langsung return kategori
  if (label == 'Organik' || label == 'Anorganik' || label == 'B3') {
    return label;
  }
  // Model lama pakai mapping
  return trashCategoryMap[label.toLowerCase()] ?? 'Anorganik';
}

Color getCategoryColor(String category) {
  switch (category) {
    case 'Organik':
      return const Color(0xFF3DBE7A);
    case 'Anorganik':
      return const Color(0xFF4AB3E8);
    case 'B3':
      return const Color(0xFFE85A5A);
    default:
      return const Color(0xFF8A9E95);
  }
}

Color getCategoryBgColor(String category) {
  switch (category) {
    case 'Organik':
      return const Color(0xFF1A3D28);
    case 'Anorganik':
      return const Color(0xFF1A2D3D);
    case 'B3':
      return const Color(0xFF3D1A1A);
    default:
      return const Color(0xFF1E2D26);
  }
}

IconData getCategoryIcon(String category) {
  switch (category) {
    case 'Organik':
      return Icons.eco_outlined;
    case 'Anorganik':
      return Icons.recycling_outlined;
    case 'B3':
      return Icons.warning_amber_outlined;
    default:
      return Icons.delete_outline;
  }
}

String getLabelTips(String label) {
  switch (label.toLowerCase()) {
    // Model Baru
    case 'organik':
      return 'Sampah organik mudah terurai. Dapat dijadikan kompos atau pupuk. Buang ke tempat sampah organik berwarna hijau.';
    case 'anorganik':
      return 'Sampah anorganik sulit terurai. Pisahkan, cuci bersih, lalu bawa ke bank sampah atau tempat daur ulang terdekat.';
    case 'b3':
      return 'Bahan Berbahaya dan Beracun. Jangan buang sembarangan. Bawa ke fasilitas pengelolaan B3 atau drop point terdekat.';

    // Model baru — label spesifik
    case 'plastic':
    case 'plastic bottle':
    case 'plastic cup':
      return 'Sampah plastik sulit terurai. Pisahkan, cuci bersih, lalu bawa ke bank sampah atau tempat daur ulang terdekat.';
    case 'cardboard':
    case 'crumpled paper':
      return 'Kardus dan kertas bisa didaur ulang. Pastikan dalam kondisi kering, lalu bawa ke bank sampah atau pengepul kertas.';
    case 'paper':
      return 'Kertas bisa didaur ulang. Pastikan dalam kondisi kering, lalu bawa ke bank sampah atau pengepul kertas.';
    case 'glass':
    case 'glass bottle':
      return 'Kaca dapat didaur ulang berkali-kali. Bungkus dengan kertas agar tidak pecah, lalu bawa ke bank sampah.';
    case 'metal':
    case 'can':
      return 'Logam dan kaleng bernilai daur ulang tinggi. Cuci bersih dan bawa ke bank sampah atau pengepul logam.';
    case 'tissue':
    case 'napkin':
      return 'Tisu dan serbet bekas pakai termasuk sampah anorganik yang sulit terurai. Buang ke tempat sampah anorganik.';
    case 'styrofoam':
      return 'Styrofoam sangat sulit terurai dan berbahaya bagi lingkungan. Kurangi penggunaannya dan buang ke tempat anorganik.';
    case 'straw':
      return 'Sedotan plastik sulit terurai. Ganti dengan sedotan bambu atau stainless steel untuk mengurangi sampah plastik.';
    case 'junk food wrapper':
      return 'Bungkus makanan ringan terbuat dari plastik multilayer yang sulit didaur ulang. Buang ke tempat anorganik.';
    case 'biodegradable':
    case 'leaves':
    case 'stick':
      return 'Sampah organik mudah terurai di alam. Dapat dijadikan kompos atau pupuk untuk tanaman.';
    case 'diaper':
      return 'Popok bekas mengandung bahan kimia dan kuman berbahaya. Bungkus rapat sebelum dibuang ke tempat sampah B3.';
    case 'battery':
      return 'Baterai mengandung logam berat berbahaya seperti merkuri dan kadmium. Bawa ke drop point daur ulang baterai.';
    case 'syringe':
      return 'Jarum suntik termasuk limbah medis berbahaya. Jangan dibuang sembarangan. Bawa ke fasilitas kesehatan terdekat.';

    // Model lama
    case 'bottle':
      return 'Botol plastik atau kaca — bilas terlebih dahulu sebelum dibawa ke bank sampah atau tempat daur ulang.';
    case 'wine glass':
      return 'Gelas kaca — bungkus dengan kertas agar tidak pecah, lalu buang ke tempat sampah anorganik.';
    case 'cup':
      return 'Gelas plastik sekali pakai — kurangi penggunaannya. Jika sudah terpakai, buang ke tempat anorganik.';
    case 'bowl':
      return 'Mangkuk plastik atau kaca — cuci bersih dan bawa ke bank sampah jika masih layak daur ulang.';
    case 'fork':
    case 'knife':
    case 'spoon':
      return 'Peralatan makan plastik sekali pakai — sulit terurai, sebaiknya ganti dengan peralatan yang bisa dipakai ulang.';
    case 'cell phone':
      return 'Ponsel mengandung logam berat berbahaya seperti merkuri dan timbal. Wajib dibawa ke drop point e-waste atau toko elektronik.';
    case 'laptop':
      return 'Laptop mengandung bahan kimia berbahaya. Jangan dibuang sembarangan. Serahkan ke pusat daur ulang elektronik resmi.';
    case 'keyboard':
    case 'mouse':
    case 'remote':
    case 'tv':
      return 'Perangkat elektronik mengandung komponen berbahaya. Bawa ke tempat daur ulang elektronik resmi, jangan dibuang ke TPA.';
    case 'hair drier':
      return 'Pengering rambut mengandung komponen listrik berbahaya. Bawa ke tempat daur ulang elektronik.';
    case 'toothbrush':
      return 'Sikat gigi plastik sulit terurai. Cari program daur ulang sikat gigi atau ganti ke sikat gigi bambu.';
    case 'scissors':
      return 'Gunting dan benda tajam — bungkus ujungnya dengan kain atau kardus sebelum dibuang ke tempat anorganik.';
    case 'book':
      return 'Kertas dan kardus bisa didaur ulang. Kumpulkan dan jual ke pengepul atau bawa ke bank sampah.';
    case 'backpack':
    case 'handbag':
    case 'suitcase':
      return 'Tas yang masih layak sebaiknya didonasikan. Jika sudah rusak, pisahkan komponen logam dan kainnya.';
    case 'umbrella':
      return 'Payung mengandung logam dan plastik. Pisahkan kerangka logam dari kain sebelum dibuang.';
    case 'teddy bear':
      return 'Boneka berbahan kain sintetis termasuk anorganik. Donasikan jika masih layak pakai.';
    case 'banana':
      return 'Kulit pisang mudah terurai dan sangat baik untuk dijadikan kompos atau pupuk tanaman.';
    case 'apple':
    case 'orange':
      return 'Sisa buah — masukkan ke tempat sampah organik atau jadikan kompos untuk pupuk tanaman.';
    case 'sandwich':
    case 'hot dog':
    case 'pizza':
      return 'Sisa makanan — buang ke tempat sampah organik. Jika ada kemasannya, pisahkan ke tempat anorganik.';
    case 'broccoli':
    case 'carrot':
      return 'Sisa sayuran bisa dijadikan kompos yang kaya nutrisi untuk tanaman.';
    case 'donut':
    case 'cake':
      return 'Sisa kue dan makanan manis — masuk kategori organik, buang ke tempat sampah organik.';
    case 'potted plant':
      return 'Tanaman dan media tanamnya bersifat organik. Tanah bekas bisa dipakai ulang sebagai pupuk.';
    default:
      return getTips(getCategory(label));
  }
}

String getTips(String category) {
  switch (category) {
    case 'Organik':
      return 'Sampah organik dapat dijadikan kompos. Buang ke tempat sampah organik berwarna hijau.';
    case 'Anorganik':
      return 'Pisahkan dan cuci bersih. Bawa ke bank sampah atau tempat daur ulang terdekat.';
    case 'B3':
      return 'Bahan Berbahaya dan Beracun. Jangan buang sembarangan. Bawa ke fasilitas pengelolaan B3 terdekat.';
    default:
      return 'Pastikan membuang sampah pada tempatnya dan sesuai kategorinya.';
  }
}