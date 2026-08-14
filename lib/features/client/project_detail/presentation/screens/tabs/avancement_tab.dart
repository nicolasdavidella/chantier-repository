import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../gallery_full_screen.dart';

class AvancementTab extends StatelessWidget {
  final String projectId;

  const AvancementTab({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Mock Data for timeline
    final reports = [
      {
        'date': '12 Août 2026',
        'title': 'Coulage de la dalle',
        'description': 'La dalle du rez-de-chaussée a été coulée avec succès. Temps de séchage estimé à 21 jours.',
        'percentage': 35,
        'image': 'https://images.unsplash.com/photo-1541888081622-1db116fb837a?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60'
      },
      {
        'date': '25 Juillet 2026',
        'title': 'Élévation des murs',
        'description': 'Murs extérieurs terminés. Les réservations pour les menuiseries sont faites.',
        'percentage': 25,
        'image': 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60'
      },
      {
        'date': '10 Juin 2026',
        'title': 'Fondations achevées',
        'description': 'Les semelles filantes ont été coulées et le vide sanitaire est monté.',
        'percentage': 15,
        'image': 'https://images.unsplash.com/photo-1503387762-592deb58ef4e?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60'
      },
    ];

    final galleryImages = reports.map((r) => r['image'] as String).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Progression Chart
          Text('Courbe d\'avancement', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          AppSpacing.vLg,
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 25,
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toInt()}%', style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const months = ['Juin', 'Juil', 'Août', 'Sept'];
                        if (value.toInt() >= 0 && value.toInt() < months.length) {
                          return Text(months[value.toInt()], style: const TextStyle(fontSize: 10));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 3,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 15),
                      FlSpot(1, 25),
                      FlSpot(2, 35),
                    ],
                    isCurved: true,
                    color: theme.colorScheme.primary,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 800.ms).scaleXY(begin: 0.9, curve: Curves.easeOutBack),
          ),
          
          AppSpacing.vXxl,
          
          // 2. Photo Gallery
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Galerie du chantier', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('Tout voir')),
            ],
          ),
          AppSpacing.vSm,
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: galleryImages.length,
              separatorBuilder: (_, __) => AppSpacing.hSm,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => GalleryFullScreen(images: galleryImages, initialIndex: index),
                    ));
                  },
                  child: Hero(
                    tag: 'gallery_image_$index',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      child: CachedNetworkImage(
                        imageUrl: galleryImages[index],
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ).animate().scale(delay: (index * 100).ms);
              },
            ),
          ),
          
          AppSpacing.vXxl,

          // 3. Vertical Timeline
          Text('Historique des rapports', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          AppSpacing.vLg,
          
          ...reports.asMap().entries.map((entry) {
            int idx = entry.key;
            Map<String, dynamic> report = entry.value;
            
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline Connector
                Column(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (idx != reports.length - 1)
                      Container(
                        width: 2,
                        height: 180, // Approximate height of the card
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                  ],
                ),
                AppSpacing.hMd,
                // Card Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        side: BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CachedNetworkImage(
                            imageUrl: report['image'] as String,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(report['date'] as String, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.secondaryContainer,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text('${report['percentage']}%', style: TextStyle(color: theme.colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold, fontSize: 12)),
                                    ),
                                  ],
                                ),
                                AppSpacing.vSm,
                                Text(report['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                AppSpacing.vXs,
                                Text(report['description'] as String, style: theme.textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ).animate().slideX(begin: 0.2, curve: Curves.easeOut).fadeIn(delay: (idx * 200).ms);
          }),
        ],
      ),
    );
  }
}
