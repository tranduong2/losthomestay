import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giới thiệu')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              'https://picsum.photos/seed/homestaymain/800/400',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                color: Colors.grey[300],
                child: const Icon(Icons.house, size: 48),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Cozy Homestay',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
            'Cozy Homestay là điểm dừng chân lý tưởng cho những ai yêu thích không gian ấm cúng, '
            'gần gũi thiên nhiên nhưng vẫn đầy đủ tiện nghi hiện đại. Với đa dạng loại phòng từ '
            'phòng đơn tiết kiệm đến villa riêng tư sang trọng, chúng tôi cam kết mang đến trải '
            'nghiệm nghỉ dưỡng thoải mái như ở nhà.',
            style: TextStyle(height: 1.6, color: AppTheme.ink),
          ),
          const SizedBox(height: 24),
          const Text('Vì sao chọn chúng tôi?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _featureTile(Icons.eco_outlined, 'Không gian xanh',
              'Gần gũi thiên nhiên, không khí trong lành'),
          _featureTile(Icons.support_agent, 'Hỗ trợ 24/7',
              'Đội ngũ luôn sẵn sàng hỗ trợ mọi lúc'),
          _featureTile(Icons.price_check, 'Giá tốt nhất',
              'Nhiều ưu đãi và mã giảm giá hấp dẫn'),
          _featureTile(Icons.cleaning_services_outlined, 'Vệ sinh sạch sẽ',
              'Phòng được dọn dẹp kỹ lưỡng trước mỗi lượt khách'),
          const SizedBox(height: 24),
          const Text('Liên hệ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.location_on_outlined, color: AppTheme.primary),
            title: Text('123 Đường Hoa Sen, Quận 1, TP. Hồ Chí Minh'),
          ),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.phone_outlined, color: AppTheme.primary),
            title: Text('0909 123 456'),
          ),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.email_outlined, color: AppTheme.primary),
            title: Text('contact@cozyhomestay.vn'),
          ),
        ],
      ),
    );
  }

  Widget _featureTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


